import { useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Banknote, CreditCard, IndianRupee, Plus, ReceiptText, RotateCcw, Search } from 'lucide-react';
import { toast } from 'sonner';
import { PageHeader } from '@/components/common/PageHeader';
import { StatCard } from '@/components/common/StatCard';
import { EmptyState, ErrorState, TableSkeleton } from '@/components/common/States';
import { ClearFilters, FilterSelect, SearchInput, TableToolbar } from '@/components/common/TableToolbar';
import { Pagination } from '@/components/common/Pagination';
import { DateRangeFilter } from '@/components/common/DateRangeFilter';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Badge, StatusBadge } from '@/components/ui/badge';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Field, Input, Select } from '@/components/ui/input';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { useHotelScope } from '@/context/HotelContext';
import { useAuth } from '@/context/AuthContext';
import { bookingApi, paymentApi } from '@/lib/endpoints';
import { fieldErrors, getErrorMessage } from '@/lib/api';
import { currency, formatDate, formatDateTime, labelize } from '@/lib/format';
import { addDaysISO, todayISO } from '@/lib/utils';

const METHODS = ['CASH', 'UPI', 'CARD', 'BANK_TRANSFER', 'CHEQUE', 'ONLINE'];
const TYPES = ['ADVANCE', 'PARTIAL', 'SETTLEMENT'];

const PaymentsPage = () => {
  const { hotelId, isGroupView } = useHotelScope();
  const { has } = useAuth();
  const [params] = useSearchParams();
  const queryClient = useQueryClient();

  const [tab, setTab] = useState(params.get('tab') ?? 'payments');
  const [search, setSearch] = useState('');
  const [method, setMethod] = useState('');
  const [range, setRange] = useState({ from: addDaysISO(-29), to: todayISO() });
  const [page, setPage] = useState(0);
  const [size, setSize] = useState(20);

  const [dialogOpen, setDialogOpen] = useState(false);
  const [bookingSearch, setBookingSearch] = useState('');
  const [selectedBooking, setSelectedBooking] = useState<{ id: number; code: string; guest: string; pending: number; hotelId: number } | null>(null);
  const [form, setForm] = useState({ amount: '', method: 'CASH', paymentType: 'PARTIAL', reference: '', notes: '' });
  const [errors, setErrors] = useState<Record<string, string>>({});

  const scope = { hotelId: isGroupView ? undefined : hotelId ?? undefined };

  const paymentsQuery = useQuery({
    queryKey: ['payments', { scope, search, method, range, page, size }],
    queryFn: () =>
      paymentApi.list({
        ...scope,
        search: search.trim() || undefined,
        method: method || undefined,
        from: range.from || undefined,
        to: range.to || undefined,
        page,
        size,
      }),
  });

  const summaryQuery = useQuery({
    queryKey: ['payments', 'summary', { scope, range }],
    queryFn: () => paymentApi.summary({ ...scope, from: range.from, to: range.to }),
  });

  const pendingQuery = useQuery({
    queryKey: ['payments', 'pending', scope],
    queryFn: () => paymentApi.pending(scope),
    enabled: tab === 'pending',
  });

  const refundsQuery = useQuery({
    queryKey: ['payments', 'refunds', scope],
    queryFn: () => paymentApi.refunds(scope),
    enabled: tab === 'refunds',
  });

  const bookingLookup = useQuery({
    queryKey: ['bookings', 'lookup', bookingSearch],
    queryFn: () => bookingApi.list({ search: bookingSearch.trim(), size: 6, hotelId: scope.hotelId }),
    enabled: dialogOpen && bookingSearch.trim().length >= 2,
  });

  const paymentMutation = useMutation({
    mutationFn: () =>
      paymentApi.create({
        hotelId: selectedBooking?.hotelId ?? scope.hotelId,
        bookingId: selectedBooking?.id,
        amount: Number(form.amount),
        method: form.method,
        paymentType: form.paymentType,
        referenceNo: form.reference || undefined,
        notes: form.notes || undefined,
        paidAt: new Date().toISOString(),
      }),
    onSuccess: () => {
      toast.success('Payment recorded');
      setDialogOpen(false);
      setSelectedBooking(null);
      setForm({ amount: '', method: 'CASH', paymentType: 'PARTIAL', reference: '', notes: '' });
      setErrors({});
      queryClient.invalidateQueries({ queryKey: ['payments'] });
      queryClient.invalidateQueries({ queryKey: ['bookings'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard'] });
      queryClient.invalidateQueries({ queryKey: ['invoices'] });
    },
    onError: (err) => {
      setErrors(fieldErrors(err));
      toast.error(getErrorMessage(err));
    },
  });

  const summary = summaryQuery.data;
  const rows = paymentsQuery.data?.content ?? [];
  const pendingRows = pendingQuery.data ?? [];
  const refunds = refundsQuery.data ?? [];
  const totalPending = pendingRows.reduce((sum, row) => sum + Number(row.pendingAmount), 0);

  return (
    <div className="space-y-5">
      <PageHeader
        title="Payments"
        description="Cash, UPI, card and bank transfers with advance, partial and refund handling — no card data is stored."
        actions={has('payment:write') ? (
          <Button size="sm" onClick={() => setDialogOpen(true)}>
            <Plus className="h-4 w-4" /> Record payment
          </Button>
        ) : undefined}
      />

      <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard label="Collected" value={currency(summary?.collected, true)} hint="Successful payments in period" icon={IndianRupee} tone="success" />
        <StatCard label="Refunded" value={currency(summary?.refunded, true)} hint="Completed refunds in period" icon={RotateCcw} tone="violet" />
        <StatCard label="Net collected" value={currency(summary?.netCollected, true)} hint={`Tax collected ${currency(summary?.taxCollected, true)}`} icon={Banknote} tone="brand" />
        <StatCard label="Outstanding" value={currency(summary?.outstanding ?? totalPending, true)} hint={`${pendingRows.length} bookings pending`} icon={CreditCard} tone="warning" />
      </div>

      <Tabs value={tab} onValueChange={setTab}>
        <TabsList>
          <TabsTrigger value="payments">Payments</TabsTrigger>
          <TabsTrigger value="pending">Pending dues</TabsTrigger>
          <TabsTrigger value="refunds">Refunds</TabsTrigger>
        </TabsList>

        <TabsContent value="payments">
          <Card>
            <TableToolbar>
              <div className="flex flex-1 flex-wrap items-center gap-2">
                <SearchInput value={search} onChange={setSearch} placeholder="Search payment, booking or guest…" />
                <FilterSelect value={method} onChange={setMethod} placeholder="All methods" options={METHODS.map((item) => ({ value: item, label: labelize(item) }))} />
                <DateRangeFilter from={range.from} to={range.to} onChange={setRange} compact />
                <ClearFilters visible={Boolean(search || method)} onClick={() => { setSearch(''); setMethod(''); }} />
              </div>
            </TableToolbar>

            {paymentsQuery.isError ? (
              <ErrorState message={getErrorMessage(paymentsQuery.error)} onRetry={() => paymentsQuery.refetch()} />
            ) : paymentsQuery.isLoading ? (
              <TableSkeleton rows={8} columns={6} />
            ) : rows.length === 0 ? (
              <EmptyState icon={CreditCard} title="No payments in this period" description="Adjust the filters or record a new payment." />
            ) : (
              <>
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Payment</TableHead>
                      <TableHead>Booking</TableHead>
                      <TableHead>Guest</TableHead>
                      {isGroupView && <TableHead>Hotel</TableHead>}
                      <TableHead>Method</TableHead>
                      <TableHead>Type</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead>Received by</TableHead>
                      <TableHead className="text-right">Amount</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {rows.map((payment) => (
                      <TableRow key={payment.id}>
                        <TableCell>
                          <p className="text-xs font-medium text-navy-900">{payment.paymentCode}</p>
                          <p className="text-[11px] text-muted-foreground">{formatDateTime(payment.paidAt)}</p>
                        </TableCell>
                        <TableCell className="text-xs">{payment.bookingCode ?? payment.invoiceNumber ?? '—'}</TableCell>
                        <TableCell className="text-xs">{payment.guestName ?? '—'}</TableCell>
                        {isGroupView && <TableCell className="text-xs">{payment.hotelName}</TableCell>}
                        <TableCell className="text-xs">{labelize(payment.method)}</TableCell>
                        <TableCell className="text-xs">{labelize(payment.paymentType)}</TableCell>
                        <TableCell><StatusBadge value={payment.status} /></TableCell>
                        <TableCell className="text-xs">{payment.receivedByName ?? '—'}</TableCell>
                        <TableCell className="text-right text-xs font-medium">{currency(payment.amount)}</TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
                <Pagination
                  page={paymentsQuery.data?.page ?? 0}
                  size={size}
                  totalElements={paymentsQuery.data?.totalElements ?? 0}
                  totalPages={paymentsQuery.data?.totalPages ?? 0}
                  onPageChange={setPage}
                  onSizeChange={(value) => { setSize(value); setPage(0); }}
                />
              </>
            )}
          </Card>
        </TabsContent>

        <TabsContent value="pending">
          <Card>
            <div className="flex items-center justify-between border-b border-border/70 px-4 py-3">
              <div>
                <p className="text-sm font-semibold text-navy-900">Outstanding balances</p>
                <p className="text-xs text-muted-foreground">Bookings with a balance greater than zero</p>
              </div>
              <Badge tone="warning">{currency(totalPending)}</Badge>
            </div>
            {pendingQuery.isError ? (
              <ErrorState message={getErrorMessage(pendingQuery.error)} onRetry={() => pendingQuery.refetch()} />
            ) : pendingQuery.isLoading ? (
              <TableSkeleton rows={6} columns={5} />
            ) : pendingRows.length === 0 ? (
              <EmptyState icon={ReceiptText} title="No pending dues" description="Every booking in scope is settled." />
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Booking</TableHead>
                    <TableHead>Guest</TableHead>
                    <TableHead>Stay</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead className="text-right">Total</TableHead>
                    <TableHead className="text-right">Paid</TableHead>
                    <TableHead className="text-right">Pending</TableHead>
                    <TableHead className="text-right">Age</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {pendingRows.map((row) => (
                    <TableRow key={row.bookingId}>
                      <TableCell className="text-xs font-medium text-brand-700">{row.bookingCode}</TableCell>
                      <TableCell>
                        <p className="text-xs text-navy-900">{row.guestName}</p>
                        <p className="text-[11px] text-muted-foreground">{row.guestMobile}</p>
                      </TableCell>
                      <TableCell className="text-xs">{formatDate(row.checkInDate)} → {formatDate(row.checkOutDate)}</TableCell>
                      <TableCell><StatusBadge value={row.status} /></TableCell>
                      <TableCell className="text-right text-xs">{currency(row.totalAmount)}</TableCell>
                      <TableCell className="text-right text-xs text-emerald-700">{currency(row.paidAmount)}</TableCell>
                      <TableCell className="text-right text-xs font-semibold text-amber-700">{currency(row.pendingAmount)}</TableCell>
                      <TableCell className="text-right text-xs">{row.daysOverdue > 0 ? `${row.daysOverdue}d` : '—'}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </Card>
        </TabsContent>

        <TabsContent value="refunds">
          <Card>
            {refundsQuery.isError ? (
              <ErrorState message={getErrorMessage(refundsQuery.error)} onRetry={() => refundsQuery.refetch()} />
            ) : refundsQuery.isLoading ? (
              <TableSkeleton rows={5} columns={5} />
            ) : refunds.length === 0 ? (
              <EmptyState icon={RotateCcw} title="No refunds recorded" description="Refunds raised from a cancellation appear here." />
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Booking</TableHead>
                    <TableHead>Reason</TableHead>
                    <TableHead>Method</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Processed</TableHead>
                    <TableHead className="text-right">Amount</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {refunds.map((refund) => (
                    <TableRow key={refund.id}>
                      <TableCell className="text-xs font-medium">{refund.bookingCode ?? '—'}</TableCell>
                      <TableCell className="max-w-[240px] truncate text-xs">{refund.reason ?? '—'}</TableCell>
                      <TableCell className="text-xs">{refund.method ? labelize(refund.method) : '—'}</TableCell>
                      <TableCell><StatusBadge value={refund.status} /></TableCell>
                      <TableCell className="text-xs">{formatDateTime(refund.processedAt)}</TableCell>
                      <TableCell className="text-right text-xs font-medium">{currency(refund.amount)}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </Card>
        </TabsContent>
      </Tabs>

      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogContent size="md">
          <DialogHeader>
            <DialogTitle>Record payment</DialogTitle>
            <DialogDescription>Search a booking, confirm the amount, and the ledger updates instantly.</DialogDescription>
          </DialogHeader>

          <div className="space-y-3">
            {selectedBooking ? (
              <div className="flex items-center justify-between rounded-lg bg-brand-50 px-3 py-2">
                <div>
                  <p className="text-sm font-medium text-navy-900">{selectedBooking.code} · {selectedBooking.guest}</p>
                  <p className="text-[11px] text-muted-foreground">Outstanding {currency(selectedBooking.pending)}</p>
                </div>
                <Button variant="ghost" size="sm" onClick={() => setSelectedBooking(null)}>Change</Button>
              </div>
            ) : (
              <div className="space-y-2">
                <Field label="Find booking" required>
                  <div className="relative">
                    <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                    <Input
                      value={bookingSearch}
                      onChange={(event) => setBookingSearch(event.target.value)}
                      placeholder="Booking code or guest name…"
                      className="pl-9"
                    />
                  </div>
                </Field>
                {bookingLookup.data?.content.length ? (
                  <div className="max-h-44 overflow-y-auto rounded-lg border border-border">
                    {bookingLookup.data.content.map((booking) => (
                      <button
                        key={booking.id}
                        type="button"
                        onClick={() => {
                          setSelectedBooking({
                            id: booking.id,
                            code: booking.bookingCode,
                            guest: booking.guestName,
                            pending: Number(booking.pendingAmount),
                            hotelId: booking.hotelId,
                          });
                          setForm({ ...form, amount: String(Number(booking.pendingAmount) || '') });
                        }}
                        className="flex w-full items-center justify-between border-b border-border/60 px-3 py-2 text-left last:border-0 hover:bg-muted"
                      >
                        <span>
                          <span className="block text-xs font-medium text-navy-900">{booking.bookingCode} · {booking.guestName}</span>
                          <span className="block text-[11px] text-muted-foreground">{booking.hotelName} · {booking.status}</span>
                        </span>
                        <span className="text-[11px] font-medium text-amber-700">{currency(booking.pendingAmount)}</span>
                      </button>
                    ))}
                  </div>
                ) : (
                  <p className="text-[11px] text-muted-foreground">
                    {bookingSearch.trim().length < 2 ? 'Type at least 2 characters.' : 'No matching bookings.'}
                  </p>
                )}
              </div>
            )}

            <div className="grid gap-3 sm:grid-cols-2">
              <Field label="Amount" required error={errors.amount}>
                <Input type="number" min={1} value={form.amount} onChange={(event) => setForm({ ...form, amount: event.target.value })} />
              </Field>
              <Field label="Method" error={errors.method}>
                <Select value={form.method} onChange={(event) => setForm({ ...form, method: event.target.value })}>
                  {METHODS.map((item) => <option key={item} value={item}>{labelize(item)}</option>)}
                </Select>
              </Field>
              <Field label="Payment type">
                <Select value={form.paymentType} onChange={(event) => setForm({ ...form, paymentType: event.target.value })}>
                  {TYPES.map((item) => <option key={item} value={item}>{labelize(item)}</option>)}
                </Select>
              </Field>
              <Field label="Reference">
                <Input value={form.reference} onChange={(event) => setForm({ ...form, reference: event.target.value })} placeholder="UTR / txn id" />
              </Field>
              <Field label="Notes" className="sm:col-span-2">
                <Input value={form.notes} onChange={(event) => setForm({ ...form, notes: event.target.value })} />
              </Field>
            </div>
          </div>

          <DialogFooter>
            <Button variant="outline" onClick={() => setDialogOpen(false)}>Cancel</Button>
            <Button
              loading={paymentMutation.isPending}
              disabled={!selectedBooking || !form.amount || Number(form.amount) <= 0}
              onClick={() => paymentMutation.mutate()}
            >
              Record {form.amount ? currency(form.amount) : 'payment'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
};

export default PaymentsPage;
