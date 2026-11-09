import { useEffect, useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { FileText, IndianRupee, Plus, Printer, Receipt, Search, XCircle } from 'lucide-react';
import { toast } from 'sonner';
import { PageHeader } from '@/components/common/PageHeader';
import { EmptyState, ErrorState, TableSkeleton } from '@/components/common/States';
import { ClearFilters, FilterSelect, SearchInput, TableToolbar } from '@/components/common/TableToolbar';
import { Pagination } from '@/components/common/Pagination';
import { ConfirmDialog } from '@/components/common/ConfirmDialog';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { Badge, StatusBadge } from '@/components/ui/badge';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Field, Input, Select } from '@/components/ui/input';
import { Separator } from '@/components/ui/misc';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { useHotelScope } from '@/context/HotelContext';
import { useAuth } from '@/context/AuthContext';
import { bookingApi, invoiceApi } from '@/lib/endpoints';
import { getErrorMessage, openPdf } from '@/lib/api';
import { currency, formatDate, labelize } from '@/lib/format';
import { addDaysISO, todayISO } from '@/lib/utils';
import type { Invoice } from '@/lib/types';

const STATUSES = ['DRAFT', 'ISSUED', 'PARTIALLY_PAID', 'PAID', 'CANCELLED'];
const METHODS = ['CASH', 'UPI', 'CARD', 'BANK_TRANSFER', 'CHEQUE', 'ONLINE'];

const InvoicesPage = () => {
  const { hotelId, isGroupView } = useHotelScope();
  const { has } = useAuth();
  const [params] = useSearchParams();
  const queryClient = useQueryClient();

  const [search, setSearch] = useState('');
  const [status, setStatus] = useState('');
  const [range, setRange] = useState({ from: addDaysISO(-59), to: todayISO() });
  const [page, setPage] = useState(0);
  const [size, setSize] = useState(20);

  const [detail, setDetail] = useState<Invoice | null>(null);
  const [settleTarget, setSettleTarget] = useState<Invoice | null>(null);
  const [settleForm, setSettleForm] = useState({ amount: '', method: 'CASH', reference: '', notes: '' });
  const [cancelTarget, setCancelTarget] = useState<Invoice | null>(null);
  const [generateOpen, setGenerateOpen] = useState(false);
  const [bookingSearch, setBookingSearch] = useState('');
  const [generateForm, setGenerateForm] = useState({ bookingId: '', taxRate: '12', includeServices: true, notes: '' });

  const scope = { hotelId: isGroupView ? undefined : hotelId ?? undefined };

  const listQuery = useQuery({
    queryKey: ['invoices', { scope, search, status, range, page, size }],
    queryFn: () =>
      invoiceApi.list({
        ...scope,
        search: search.trim() || undefined,
        status: status || undefined,
        from: range.from || undefined,
        to: range.to || undefined,
        page,
        size,
      }),
  });

  const bookingLookup = useQuery({
    queryKey: ['bookings', 'invoice-lookup', bookingSearch],
    queryFn: () => bookingApi.list({ search: bookingSearch.trim(), size: 6, hotelId: scope.hotelId }),
    enabled: generateOpen && bookingSearch.trim().length >= 2,
  });

  const detailQuery = useQuery({
    queryKey: ['invoice', detail?.id],
    queryFn: () => invoiceApi.get(detail!.id),
    enabled: Boolean(detail?.id),
  });

  useEffect(() => {
    if (detailQuery.data) setDetail(detailQuery.data);
  }, [detailQuery.data]);

  const settleMutation = useMutation({
    mutationFn: () =>
      invoiceApi.settle(settleTarget!.id, {
        amount: Number(settleForm.amount),
        method: settleForm.method,
        referenceNo: settleForm.reference || undefined,
        notes: settleForm.notes || undefined,
      }),
    onSuccess: (invoice) => {
      toast.success('Invoice settled');
      setSettleTarget(null);
      setDetail(invoice);
      queryClient.invalidateQueries({ queryKey: ['invoices'] });
      queryClient.invalidateQueries({ queryKey: ['payments'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard'] });
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  const cancelMutation = useMutation({
    mutationFn: () => invoiceApi.cancel(cancelTarget!.id),
    onSuccess: () => {
      toast.success('Invoice cancelled');
      setCancelTarget(null);
      setDetail(null);
      queryClient.invalidateQueries({ queryKey: ['invoices'] });
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  const generateMutation = useMutation({
    mutationFn: () =>
      invoiceApi.generate({
        bookingId: Number(generateForm.bookingId),
        taxRate: Number(generateForm.taxRate),
        includeServices: generateForm.includeServices,
        notes: generateForm.notes || undefined,
      }),
    onSuccess: (invoice) => {
      toast.success(`Invoice ${invoice.invoiceNumber} generated`);
      setGenerateOpen(false);
      setGenerateForm({ bookingId: '', taxRate: '12', includeServices: true, notes: '' });
      queryClient.invalidateQueries({ queryKey: ['invoices'] });
      queryClient.invalidateQueries({ queryKey: ['bookings'] });
      setDetail(invoice);
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  useEffect(() => {
    const invoiceId = params.get('invoiceId');
    if (invoiceId) {
      invoiceApi.get(Number(invoiceId)).then(setDetail).catch(() => undefined);
    }
  }, [params]);

  const rows = listQuery.data?.content ?? [];

  return (
    <div className="space-y-5">
      <PageHeader
        title="GST invoices"
        description="Sequential, tax-compliant invoices with offline PDF generation."
        actions={has('invoice:write') ? (
          <Button size="sm" onClick={() => setGenerateOpen(true)}>
            <Plus className="h-4 w-4" /> Generate invoice
          </Button>
        ) : undefined}
      />

      <Card>
        <TableToolbar>
          <div className="flex flex-1 flex-wrap items-center gap-2">
            <SearchInput value={search} onChange={setSearch} placeholder="Search invoice, booking or guest…" />
            <FilterSelect value={status} onChange={setStatus} placeholder="All statuses" options={STATUSES.map((item) => ({ value: item, label: labelize(item) }))} />
            <div className="flex items-center gap-1.5 rounded-lg border border-input px-2 py-1">
              <input
                type="date"
                value={range.from}
                onChange={(event) => setRange({ ...range, from: event.target.value })}
                className="bg-transparent text-xs text-navy-800 focus:outline-none"
                aria-label="Issued from"
              />
              <span className="text-xs text-muted-foreground">→</span>
              <input
                type="date"
                value={range.to}
                onChange={(event) => setRange({ ...range, to: event.target.value })}
                className="bg-transparent text-xs text-navy-800 focus:outline-none"
                aria-label="Issued to"
              />
            </div>
            <ClearFilters visible={Boolean(search || status)} onClick={() => { setSearch(''); setStatus(''); setPage(0); }} />
          </div>
        </TableToolbar>

        {listQuery.isError ? (
          <ErrorState message={getErrorMessage(listQuery.error)} onRetry={() => listQuery.refetch()} />
        ) : listQuery.isLoading ? (
          <TableSkeleton rows={8} columns={6} />
        ) : rows.length === 0 ? (
          <EmptyState icon={FileText} title="No invoices found" description="Invoices are generated automatically when a guest checks out." />
        ) : (
          <>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Invoice</TableHead>
                  <TableHead>Guest</TableHead>
                  {isGroupView && <TableHead>Hotel</TableHead>}
                  <TableHead>Issued</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead className="text-right">Total</TableHead>
                  <TableHead className="text-right">Paid</TableHead>
                  <TableHead className="text-right">Balance</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {rows.map((invoice) => (
                  <TableRow key={invoice.id} className="cursor-pointer" onClick={() => setDetail(invoice)}>
                    <TableCell>
                      <p className="text-xs font-medium text-brand-700">{invoice.invoiceNumber}</p>
                      <p className="text-[11px] text-muted-foreground">{invoice.bookingCode ?? '—'}</p>
                    </TableCell>
                    <TableCell className="text-xs">{invoice.guestName ?? '—'}</TableCell>
                    {isGroupView && <TableCell className="text-xs">{invoice.hotelName}</TableCell>}
                    <TableCell className="text-xs">{formatDate(invoice.issueDate)}</TableCell>
                    <TableCell><StatusBadge value={invoice.status} /></TableCell>
                    <TableCell className="text-right text-xs font-medium">{currency(invoice.total)}</TableCell>
                    <TableCell className="text-right text-xs text-emerald-700">{currency(invoice.amountPaid)}</TableCell>
                    <TableCell className="text-right text-xs font-semibold text-amber-700">{currency(invoice.balance)}</TableCell>
                    <TableCell className="text-right" onClick={(event) => event.stopPropagation()}>
                      <div className="flex justify-end gap-1">
                        <Button variant="ghost" size="icon-sm" onClick={() => setDetail(invoice)} aria-label="View invoice">
                          <Receipt className="h-3.5 w-3.5" />
                        </Button>
                        <Button
                          variant="ghost"
                          size="icon-sm"
                          onClick={() => void openPdf(`/invoices/${invoice.id}/pdf`).catch((err) => toast.error(getErrorMessage(err)))}
                          aria-label="Download PDF"
                        >
                          <Printer className="h-3.5 w-3.5" />
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
            <Pagination
              page={listQuery.data?.page ?? 0}
              size={size}
              totalElements={listQuery.data?.totalElements ?? 0}
              totalPages={listQuery.data?.totalPages ?? 0}
              onPageChange={setPage}
              onSizeChange={(value) => { setSize(value); setPage(0); }}
            />
          </>
        )}
      </Card>

      <Dialog open={Boolean(detail)} onOpenChange={(open) => !open && setDetail(null)}>
        <DialogContent size="lg">
          {detail && (
            <>
              <DialogHeader>
                <DialogTitle className="flex items-center gap-2">
                  Invoice {detail.invoiceNumber}
                  <StatusBadge value={detail.status} />
                </DialogTitle>
                <DialogDescription>
                  {detail.hotelName} · {detail.hotelAddress ?? ''} {detail.hotelGstin ? `· GSTIN ${detail.hotelGstin}` : ''}
                </DialogDescription>
              </DialogHeader>

              <div className="grid gap-3 sm:grid-cols-2">
                <div className="rounded-lg bg-muted/60 p-3">
                  <p className="text-[11px] uppercase tracking-wide text-muted-foreground">Billed to</p>
                  <p className="text-sm font-medium text-navy-900">{detail.guestName ?? '—'}</p>
                  <p className="text-xs text-muted-foreground">{detail.billToAddress ?? '—'}</p>
                </div>
                <div className="rounded-lg bg-muted/60 p-3">
                  <p className="text-[11px] uppercase tracking-wide text-muted-foreground">Invoice</p>
                  <p className="text-sm text-navy-900">Issued {formatDate(detail.issueDate)}</p>
                  <p className="text-xs text-muted-foreground">Booking {detail.bookingCode ?? '—'}{detail.dueDate ? ` · due ${formatDate(detail.dueDate)}` : ''}</p>
                </div>
              </div>

              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Type</TableHead>
                    <TableHead>Description</TableHead>
                    <TableHead className="text-right">Qty</TableHead>
                    <TableHead className="text-right">Rate</TableHead>
                    <TableHead className="text-right">Amount</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {detail.lines.map((line) => (
                    <TableRow key={line.id}>
                      <TableCell className="text-xs">{labelize(line.lineType)}</TableCell>
                      <TableCell className="text-xs">{line.description}</TableCell>
                      <TableCell className="text-right text-xs">{Number(line.quantity)}</TableCell>
                      <TableCell className="text-right text-xs">{currency(line.unitPrice)}</TableCell>
                      <TableCell className="text-right text-xs font-medium">{currency(line.amount)}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>

              <div className="ml-auto w-full max-w-xs space-y-1 text-sm">
                <div className="flex justify-between"><span className="text-muted-foreground">Subtotal</span><span>{currency(detail.subtotal)}</span></div>
                <div className="flex justify-between"><span className="text-muted-foreground">Discount</span><span>-{currency(detail.discount)}</span></div>
                <div className="flex justify-between"><span className="text-muted-foreground">GST @ {detail.taxRate}%</span><span>{currency(detail.taxAmount)}</span></div>
                <Separator />
                <div className="flex justify-between font-semibold text-navy-900"><span>Total</span><span>{currency(detail.total)}</span></div>
                <div className="flex justify-between text-emerald-700"><span>Paid</span><span>{currency(detail.amountPaid)}</span></div>
                <div className="flex justify-between font-medium text-amber-700"><span>Balance</span><span>{currency(detail.balance)}</span></div>
              </div>

              <DialogFooter>
                {has('invoice:write') && Number(detail.balance) > 0 && detail.status !== 'CANCELLED' && (
                  <Button
                    variant="outline"
                    onClick={() => {
                      setSettleTarget(detail);
                      setSettleForm({ amount: String(detail.balance), method: 'CASH', reference: '', notes: '' });
                    }}
                  >
                    <IndianRupee className="h-4 w-4" /> Settle
                  </Button>
                )}
                {has('invoice:write') && detail.status !== 'CANCELLED' && (
                  <Button variant="outline" className="text-destructive" onClick={() => setCancelTarget(detail)}>
                    <XCircle className="h-4 w-4" /> Cancel invoice
                  </Button>
                )}
                <Button onClick={() => void openPdf(`/invoices/${detail.id}/pdf`).catch((err) => toast.error(getErrorMessage(err)))}>
                  <Printer className="h-4 w-4" /> PDF
                </Button>
              </DialogFooter>
            </>
          )}
        </DialogContent>
      </Dialog>

      <Dialog open={Boolean(settleTarget)} onOpenChange={(open) => !open && setSettleTarget(null)}>
        <DialogContent size="sm">
          <DialogHeader>
            <DialogTitle>Settle invoice</DialogTitle>
            <DialogDescription>Balance {currency(settleTarget?.balance ?? 0)} · payments are auditable.</DialogDescription>
          </DialogHeader>
          <div className="grid gap-3 sm:grid-cols-2">
            <Field label="Amount" required className="sm:col-span-2">
              <Input type="number" min={1} value={settleForm.amount} onChange={(event) => setSettleForm({ ...settleForm, amount: event.target.value })} />
            </Field>
            <Field label="Method">
              <Select value={settleForm.method} onChange={(event) => setSettleForm({ ...settleForm, method: event.target.value })}>
                {METHODS.map((item) => <option key={item} value={item}>{labelize(item)}</option>)}
              </Select>
            </Field>
            <Field label="Reference">
              <Input value={settleForm.reference} onChange={(event) => setSettleForm({ ...settleForm, reference: event.target.value })} />
            </Field>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setSettleTarget(null)}>Cancel</Button>
            <Button loading={settleMutation.isPending} disabled={!settleForm.amount} onClick={() => settleMutation.mutate()}>
              Settle {settleForm.amount ? currency(settleForm.amount) : ''}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={generateOpen} onOpenChange={setGenerateOpen}>
        <DialogContent size="md">
          <DialogHeader>
            <DialogTitle>Generate invoice</DialogTitle>
            <DialogDescription>Pick a checked-out booking to raise a GST invoice including service charges.</DialogDescription>
          </DialogHeader>
          <div className="space-y-3">
            <Field label="Find booking" required>
              <div className="relative">
                <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <Input value={bookingSearch} onChange={(event) => setBookingSearch(event.target.value)} placeholder="Booking code or guest…" className="pl-9" />
              </div>
            </Field>
            {bookingLookup.data?.content.length ? (
              <div className="max-h-40 overflow-y-auto rounded-lg border border-border">
                {bookingLookup.data.content.map((booking) => (
                  <button
                    key={booking.id}
                    type="button"
                    onClick={() => setGenerateForm({ ...generateForm, bookingId: String(booking.id), taxRate: '12' })}
                    className={`flex w-full items-center justify-between border-b border-border/60 px-3 py-2 text-left last:border-0 hover:bg-muted ${
                      generateForm.bookingId === String(booking.id) ? 'bg-brand-50' : ''
                    }`}
                  >
                    <span>
                      <span className="block text-xs font-medium text-navy-900">{booking.bookingCode} · {booking.guestName}</span>
                      <span className="block text-[11px] text-muted-foreground">{formatDate(booking.checkInDate)} → {formatDate(booking.checkOutDate)}</span>
                    </span>
                    <Badge tone="neutral">{booking.status}</Badge>
                  </button>
                ))}
              </div>
            ) : bookingSearch.trim().length >= 2 ? (
              <p className="text-[11px] text-muted-foreground">No matching bookings.</p>
            ) : null}
            <div className="grid gap-3 sm:grid-cols-2">
              <Field label="GST rate (%)">
                <Input type="number" min={0} max={28} value={generateForm.taxRate} onChange={(event) => setGenerateForm({ ...generateForm, taxRate: event.target.value })} />
              </Field>
              <Field label="Notes">
                <Input value={generateForm.notes} onChange={(event) => setGenerateForm({ ...generateForm, notes: event.target.value })} />
              </Field>
            </div>
            <label className="flex items-center gap-2 text-xs text-navy-800">
              <input
                type="checkbox"
                checked={generateForm.includeServices}
                onChange={(event) => setGenerateForm({ ...generateForm, includeServices: event.target.checked })}
                className="h-4 w-4 rounded border-input"
              />
              Include unbilled services and extra charges
            </label>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setGenerateOpen(false)}>Cancel</Button>
            <Button loading={generateMutation.isPending} disabled={!generateForm.bookingId} onClick={() => generateMutation.mutate()}>
              Generate invoice
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <ConfirmDialog
        open={Boolean(cancelTarget)}
        onOpenChange={(open) => !open && setCancelTarget(null)}
        title="Cancel this invoice?"
        description="Cancelled invoices stay visible for audit but can no longer be settled."
        confirmLabel="Cancel invoice"
        loading={cancelMutation.isPending}
        onConfirm={() => cancelMutation.mutate()}
      />
    </div>
  );
};

export default InvoicesPage;
