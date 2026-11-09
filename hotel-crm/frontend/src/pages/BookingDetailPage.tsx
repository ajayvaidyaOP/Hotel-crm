import { useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import {
  ArrowLeft, BadgeCheck, BedDouble, CalendarClock, CreditCard, FileText, IndianRupee, LogIn, LogOut, Mail,
  Phone, Plus, Sparkles, User, XCircle,
} from 'lucide-react';
import { toast } from 'sonner';
import { PageHeader } from '@/components/common/PageHeader';
import { EmptyState, ErrorState, TableSkeleton } from '@/components/common/States';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge, StatusBadge } from '@/components/ui/badge';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Field, Input, Select, Textarea } from '@/components/ui/input';
import { Separator, Skeleton } from '@/components/ui/misc';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { CancelBookingDialog, CheckInDialog, CheckOutDialog, TransferRoomDialog } from '@/components/bookings/BookingActionDialogs';
import { useAuth } from '@/context/AuthContext';
import { bookingApi, paymentApi, serviceApi } from '@/lib/endpoints';
import { getErrorMessage, openPdf } from '@/lib/api';
import { currency, formatDate, formatDateTime, labelize } from '@/lib/format';
import { todayISO } from '@/lib/utils';

const METHODS = ['CASH', 'UPI', 'CARD', 'BANK_TRANSFER', 'CHEQUE', 'ONLINE'];
const PAYMENT_TYPES = ['ADVANCE', 'PARTIAL', 'SETTLEMENT', 'REFUND'];
const SERVICE_TYPES = ['RESTAURANT', 'ROOM_SERVICE', 'LAUNDRY', 'MINIBAR', 'OTHER'];

const BookingDetailPage = () => {
  const { id } = useParams();
  const bookingId = Number(id);
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const { has } = useAuth();

  const [checkInOpen, setCheckInOpen] = useState(false);
  const [checkOutOpen, setCheckOutOpen] = useState(false);
  const [cancelOpen, setCancelOpen] = useState(false);
  const [transferOpen, setTransferOpen] = useState(false);
  const [paymentOpen, setPaymentOpen] = useState(false);
  const [serviceOpen, setServiceOpen] = useState(false);
  const [rescheduleOpen, setRescheduleOpen] = useState(false);

  const [paymentForm, setPaymentForm] = useState({ amount: '', method: 'CASH', paymentType: 'PARTIAL', reference: '', notes: '' });
  const [serviceForm, setServiceForm] = useState({ orderType: 'ROOM_SERVICE', description: '', amount: '', quantity: '1' });
  const [rescheduleForm, setRescheduleForm] = useState({ checkInDate: '', checkOutDate: '' });

  const bookingQuery = useQuery({
    queryKey: ['booking', bookingId],
    queryFn: () => bookingApi.get(bookingId),
    enabled: Number.isFinite(bookingId),
  });

  const booking = bookingQuery.data;
  const summary = booking?.summary;

  const invalidate = () => {
    queryClient.invalidateQueries({ queryKey: ['booking', bookingId] });
    queryClient.invalidateQueries({ queryKey: ['bookings'] });
    queryClient.invalidateQueries({ queryKey: ['dashboard'] });
    queryClient.invalidateQueries({ queryKey: ['payments'] });
    queryClient.invalidateQueries({ queryKey: ['invoices'] });
  };

  const paymentMutation = useMutation({
    mutationFn: () =>
      paymentApi.create({
        hotelId: summary?.hotelId,
        bookingId,
        amount: Number(paymentForm.amount),
        method: paymentForm.method,
        paymentType: paymentForm.paymentType,
        referenceNo: paymentForm.reference || undefined,
        notes: paymentForm.notes || undefined,
        paidAt: new Date().toISOString(),
      }),
    onSuccess: () => {
      toast.success('Payment recorded');
      setPaymentOpen(false);
      setPaymentForm({ amount: '', method: 'CASH', paymentType: 'PARTIAL', reference: '', notes: '' });
      invalidate();
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  const serviceMutation = useMutation({
    mutationFn: () =>
      serviceApi.create({
        hotelId: summary?.hotelId,
        bookingId,
        orderType: serviceForm.orderType,
        description: serviceForm.description,
        amount: Number(serviceForm.amount),
        quantity: Number(serviceForm.quantity || 1),
        billedToRoom: true,
      }),
    onSuccess: () => {
      toast.success('Service added to folio');
      setServiceOpen(false);
      setServiceForm({ orderType: 'ROOM_SERVICE', description: '', amount: '', quantity: '1' });
      invalidate();
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  const checkInMutation = useMutation({
    mutationFn: (payload: Record<string, unknown>) => bookingApi.checkIn(bookingId, payload),
    onSuccess: () => {
      toast.success('Guest checked in');
      setCheckInOpen(false);
      invalidate();
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  const checkOutMutation = useMutation({
    mutationFn: (payload: Record<string, unknown>) => bookingApi.checkOut(bookingId, payload),
    onSuccess: () => {
      toast.success('Checked out · invoice generated');
      setCheckOutOpen(false);
      invalidate();
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  const cancelMutation = useMutation({
    mutationFn: (payload: { reason: string; refundAmount?: number; refundMethod?: string }) => bookingApi.cancel(bookingId, payload),
    onSuccess: () => {
      toast.success('Booking cancelled');
      setCancelOpen(false);
      invalidate();
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  const transferMutation = useMutation({
    mutationFn: (payload: { segmentId: number; newRoomId: number; reason?: string }) => bookingApi.transferRoom(bookingId, payload),
    onSuccess: () => {
      toast.success('Room transferred');
      setTransferOpen(false);
      invalidate();
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  const rescheduleMutation = useMutation({
    mutationFn: () =>
      bookingApi.reschedule(bookingId, {
        checkInDate: rescheduleForm.checkInDate,
        checkOutDate: rescheduleForm.checkOutDate,
        segmentId: booking?.rooms[0]?.id,
      }),
    onSuccess: () => {
      toast.success('Booking rescheduled');
      setRescheduleOpen(false);
      invalidate();
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  const serviceStatusMutation = useMutation({
    mutationFn: ({ id: serviceId, status }: { id: number; status: string }) => serviceApi.updateStatus(serviceId, status),
    onSuccess: () => {
      toast.success('Service status updated');
      invalidate();
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  if (bookingQuery.isError) {
    return (
      <div className="space-y-4">
        <Button variant="ghost" size="sm" onClick={() => navigate('/bookings')}><ArrowLeft className="h-4 w-4" /> Back to bookings</Button>
        <Card><ErrorState message={getErrorMessage(bookingQuery.error)} onRetry={() => bookingQuery.refetch()} /></Card>
      </div>
    );
  }

  if (bookingQuery.isLoading || !booking || !summary) {
    return (
      <div className="space-y-4">
        <Skeleton className="h-9 w-40" />
        <Skeleton className="h-28 w-full" />
        <div className="grid gap-4 lg:grid-cols-3">
          <Skeleton className="h-64 lg:col-span-2" />
          <Skeleton className="h-64" />
        </div>
      </div>
    );
  }

  const payable = Math.max(0, Number(summary.pendingAmount));
  const canCheckIn = has('checkin:write') && ['PENDING', 'CONFIRMED'].includes(summary.status);
  const canCheckOut = has('checkout:write') && summary.status === 'CHECKED_IN';
  const canCancel = has('booking:cancel') && !['CANCELLED', 'CHECKED_OUT', 'CHECKED_IN'].includes(summary.status);

  return (
    <div className="space-y-5">
      <div className="flex items-center justify-between">
        <Button variant="ghost" size="sm" onClick={() => navigate('/bookings')}>
          <ArrowLeft className="h-4 w-4" /> All bookings
        </Button>
        <div className="flex flex-wrap items-center gap-2">
          <Button variant="outline" size="sm" onClick={() => void openPdf(`/bookings/${bookingId}/receipt.pdf`).catch((err) => toast.error(getErrorMessage(err)))}>
            <FileText className="h-4 w-4" /> Receipt PDF
          </Button>
          {canCheckIn && <Button size="sm" onClick={() => setCheckInOpen(true)}><LogIn className="h-4 w-4" /> Check in</Button>}
          {canCheckOut && <Button size="sm" onClick={() => setCheckOutOpen(true)}><LogOut className="h-4 w-4" /> Check out</Button>}
          {canCancel && (
            <Button variant="outline" size="sm" className="text-destructive" onClick={() => setCancelOpen(true)}>
              <XCircle className="h-4 w-4" /> Cancel
            </Button>
          )}
        </div>
      </div>

      <PageHeader
        title={`${summary.bookingCode} · ${summary.guestName}`}
        description={`${summary.hotelName} · ${formatDate(summary.checkInDate)} → ${formatDate(summary.checkOutDate)} · ${summary.nights} nights`}
        actions={
          <>
            <StatusBadge value={summary.status} />
            <StatusBadge value={summary.paymentStatus} />
            <Badge tone="outline">{labelize(summary.bookingSource)}</Badge>
          </>
        }
      />

      <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
        <Card className="p-4">
          <p className="text-xs uppercase tracking-wide text-muted-foreground">Booking total</p>
          <p className="mt-1 text-xl font-semibold text-navy-900">{currency(summary.totalAmount)}</p>
          <p className="text-[11px] text-muted-foreground">Rooms {currency(booking.roomChargeTotal)} · tax {currency(booking.taxAmount)}</p>
        </Card>
        <Card className="p-4">
          <p className="text-xs uppercase tracking-wide text-muted-foreground">Paid</p>
          <p className="mt-1 text-xl font-semibold text-emerald-700">{currency(summary.paidAmount)}</p>
          <p className="text-[11px] text-muted-foreground">{booking.payments.length} payment(s) recorded</p>
        </Card>
        <Card className="p-4">
          <p className="text-xs uppercase tracking-wide text-muted-foreground">Balance due</p>
          <p className="mt-1 text-xl font-semibold text-amber-700">{currency(payable)}</p>
          <p className="text-[11px] text-muted-foreground">{booking.invoiceNumber ? `Invoice ${booking.invoiceNumber}` : 'No invoice yet'}</p>
        </Card>
        <Card className="p-4">
          <p className="text-xs uppercase tracking-wide text-muted-foreground">Extras & discount</p>
          <p className="mt-1 text-xl font-semibold text-navy-900">{currency(booking.extraCharges)}</p>
          <p className="text-[11px] text-muted-foreground">Discount {currency(booking.discountAmount)}{booking.couponCode ? ` · ${booking.couponCode}` : ''}</p>
        </Card>
      </div>

      <div className="grid gap-4 lg:grid-cols-3">
        <div className="space-y-4 lg:col-span-2">
          <Card>
            <CardHeader className="flex-row items-center justify-between">
              <CardTitle>Rooms & stay</CardTitle>
              <div className="flex gap-2">
                {has('booking:write') && summary.status !== 'CANCELLED' && (
                  <Button variant="outline" size="sm" onClick={() => { setRescheduleForm({ checkInDate: summary.checkInDate, checkOutDate: summary.checkOutDate }); setRescheduleOpen(true); }}>
                    <CalendarClock className="h-3.5 w-3.5" /> Reschedule
                  </Button>
                )}
                {has('booking:write') && booking.rooms.some((room) => room.roomId) && summary.status !== 'CANCELLED' && (
                  <Button variant="outline" size="sm" onClick={() => setTransferOpen(true)}>
                    <BedDouble className="h-3.5 w-3.5" /> Transfer room
                  </Button>
                )}
              </div>
            </CardHeader>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Room</TableHead>
                  <TableHead>Category</TableHead>
                  <TableHead>Dates</TableHead>
                  <TableHead>Nights</TableHead>
                  <TableHead className="text-right">Rate</TableHead>
                  <TableHead className="text-right">Amount</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {booking.rooms.map((segment) => (
                  <TableRow key={segment.id}>
                    <TableCell className="font-medium text-navy-900">{segment.roomNumber ?? 'Unassigned'}</TableCell>
                    <TableCell className="text-xs">{segment.categoryName}</TableCell>
                    <TableCell className="text-xs">{formatDate(segment.checkInDate)} → {formatDate(segment.checkOutDate)}</TableCell>
                    <TableCell className="text-xs">{segment.nights}</TableCell>
                    <TableCell className="text-right text-xs">{currency(segment.ratePerNight)}</TableCell>
                    <TableCell className="text-right text-xs font-medium">{currency(segment.totalAmount)}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
            <CardContent className="grid gap-3 border-t border-border/70 sm:grid-cols-3">
              <div>
                <p className="text-[11px] uppercase tracking-wide text-muted-foreground">Occupancy</p>
                <p className="text-sm text-navy-900">{summary.adults} adults{summary.children ? `, ${summary.children} children` : ''}</p>
              </div>
              <div>
                <p className="text-[11px] uppercase tracking-wide text-muted-foreground">Checked in</p>
                <p className="text-sm text-navy-900">{summary.actualCheckInAt ? formatDateTime(summary.actualCheckInAt) : '—'}</p>
                <p className="text-[11px] text-muted-foreground">{booking.checkedInByName ?? ''}</p>
              </div>
              <div>
                <p className="text-[11px] uppercase tracking-wide text-muted-foreground">Checked out</p>
                <p className="text-sm text-navy-900">{summary.actualCheckOutAt ? formatDateTime(summary.actualCheckOutAt) : '—'}</p>
                <p className="text-[11px] text-muted-foreground">{booking.checkedOutByName ?? ''}</p>
              </div>
              {booking.specialRequests && (
                <div className="sm:col-span-3">
                  <p className="text-[11px] uppercase tracking-wide text-muted-foreground">Special requests</p>
                  <p className="text-sm text-navy-800">{booking.specialRequests}</p>
                </div>
              )}
              {booking.cancellationReason && (
                <div className="sm:col-span-3 rounded-lg bg-red-50 p-2">
                  <p className="text-[11px] uppercase tracking-wide text-red-700">Cancellation</p>
                  <p className="text-sm text-red-800">{booking.cancellationReason} · {formatDateTime(booking.cancelledAt)}</p>
                </div>
              )}
            </CardContent>
          </Card>

          <Card>
            <CardHeader className="flex-row items-center justify-between">
              <CardTitle>Payments</CardTitle>
              {has('payment:write') && summary.status !== 'CANCELLED' && (
                <Button size="sm" onClick={() => { setPaymentForm({ ...paymentForm, amount: String(payable || '') }); setPaymentOpen(true); }}>
                  <Plus className="h-3.5 w-3.5" /> Record payment
                </Button>
              )}
            </CardHeader>
            {booking.payments.length === 0 ? (
              <EmptyState icon={CreditCard} title="No payments yet" description="Record an advance or settlement to update the balance." />
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Code</TableHead>
                    <TableHead>Method</TableHead>
                    <TableHead>Type</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Received by</TableHead>
                    <TableHead className="text-right">Amount</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {booking.payments.map((payment) => (
                    <TableRow key={payment.id}>
                      <TableCell>
                        <p className="text-xs font-medium text-navy-900">{payment.paymentCode}</p>
                        <p className="text-[11px] text-muted-foreground">{formatDateTime(payment.paidAt)}</p>
                      </TableCell>
                      <TableCell className="text-xs">{labelize(payment.method)}</TableCell>
                      <TableCell className="text-xs">{labelize(payment.paymentType)}</TableCell>
                      <TableCell><StatusBadge value={payment.status} /></TableCell>
                      <TableCell className="text-xs">{payment.receivedByName ?? '—'}</TableCell>
                      <TableCell className="text-right text-xs font-medium">{currency(payment.amount)}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </Card>

          <Card>
            <CardHeader className="flex-row items-center justify-between">
              <CardTitle>Services & folio</CardTitle>
              {has('service:write') && summary.status === 'CHECKED_IN' && (
                <Button size="sm" variant="outline" onClick={() => setServiceOpen(true)}>
                  <Sparkles className="h-3.5 w-3.5" /> Add service
                </Button>
              )}
            </CardHeader>
            {booking.services.length === 0 ? (
              <EmptyState icon={Sparkles} title="No services billed" description="Room service, restaurant, laundry and minibar charges appear here." />
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Service</TableHead>
                    <TableHead>Description</TableHead>
                    <TableHead>Qty</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead className="text-right">Amount</TableHead>
                    <TableHead className="text-right">Update</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {booking.services.map((service) => (
                    <TableRow key={service.id}>
                      <TableCell className="text-xs">{labelize(service.orderType)}</TableCell>
                      <TableCell className="text-xs text-navy-800">{service.description}</TableCell>
                      <TableCell className="text-xs">{service.quantity}</TableCell>
                      <TableCell><StatusBadge value={service.status} /></TableCell>
                      <TableCell className="text-right text-xs font-medium">{currency(service.lineTotal)}</TableCell>
                      <TableCell className="text-right">
                        {has('service:write') && service.status !== 'BILLED' && service.status !== 'CANCELLED' && (
                          <Select
                            className="h-7 w-[132px] text-xs"
                            value={service.status}
                            onChange={(event) => serviceStatusMutation.mutate({ id: service.id, status: event.target.value })}
                          >
                            {['PENDING', 'PREPARING', 'SERVED', 'DELIVERED', 'BILLED', 'CANCELLED'].map((status) => (
                              <option key={status} value={status}>{labelize(status)}</option>
                            ))}
                          </Select>
                        )}
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </Card>
        </div>

        <div className="space-y-4">
          <Card>
            <CardHeader><CardTitle>Guest</CardTitle></CardHeader>
            <CardContent className="space-y-2.5 pt-0 text-sm">
              <Link to={`/guests/${summary.guestId}`} className="flex items-center gap-2 font-medium text-brand-700 hover:underline">
                <User className="h-4 w-4" /> {summary.guestName}
              </Link>
              <p className="flex items-center gap-2 text-xs text-navy-700"><Phone className="h-3.5 w-3.5" /> {summary.guestMobile}</p>
              {booking.guestEmail && <p className="flex items-center gap-2 text-xs text-navy-700"><Mail className="h-3.5 w-3.5" /> {booking.guestEmail}</p>}
              {booking.guestIdProofMasked && (
                <p className="flex items-center gap-2 text-xs text-navy-700">
                  <BadgeCheck className="h-3.5 w-3.5" /> ID {booking.guestIdProofMasked}
                </p>
              )}
              <Separator />
              <div className="flex items-center justify-between text-xs">
                <span className="text-muted-foreground">Rooms</span>
                <span className="font-medium">{summary.roomNumbers.join(', ') || 'TBA'}</span>
              </div>
              <div className="flex items-center justify-between text-xs">
                <span className="text-muted-foreground">Advance</span>
                <span className="font-medium">{currency(booking.advanceAmount)}</span>
              </div>
              <div className="flex items-center justify-between text-xs">
                <span className="text-muted-foreground">Booked</span>
                <span className="font-medium">{formatDateTime(summary.createdAt)}</span>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader><CardTitle>Billing</CardTitle></CardHeader>
            <CardContent className="space-y-2 pt-0">
              {booking.invoiceId ? (
                <Button variant="outline" className="w-full justify-start" asChild>
                  <Link to={`/invoices?invoiceId=${booking.invoiceId}`}>
                    <FileText className="h-4 w-4" /> Invoice {booking.invoiceNumber}
                  </Link>
                </Button>
              ) : (
                <p className="text-xs text-muted-foreground">An invoice is generated automatically at checkout.</p>
              )}
              <Button variant="outline" className="w-full justify-start" asChild>
                <Link to={`/payments?bookingId=${bookingId}`}>
                  <IndianRupee className="h-4 w-4" /> Payment ledger
                </Link>
              </Button>
              <Button
                variant="outline"
                className="w-full justify-start"
                onClick={() => void openPdf(`/bookings/${bookingId}/receipt.pdf`).catch((err) => toast.error(getErrorMessage(err)))}
              >
                <FileText className="h-4 w-4" /> Download receipt
              </Button>
            </CardContent>
          </Card>

          {booking.internalNotes && (
            <Card>
              <CardHeader><CardTitle>Internal notes</CardTitle></CardHeader>
              <CardContent className="pt-0 text-xs text-navy-700">{booking.internalNotes}</CardContent>
            </Card>
          )}
        </div>
      </div>

      <CheckInDialog booking={summary} onClose={() => setCheckInOpen(false)} onSubmit={(payload) => checkInMutation.mutate(payload)} loading={checkInMutation.isPending} />
      <CheckOutDialog booking={summary} onClose={() => setCheckOutOpen(false)} onSubmit={(payload) => checkOutMutation.mutate(payload)} loading={checkOutMutation.isPending} />
      <CancelBookingDialog booking={summary} onClose={() => setCancelOpen(false)} onSubmit={(payload) => cancelMutation.mutate(payload)} loading={cancelMutation.isPending} />
      <TransferRoomDialog
        bookingId={transferOpen ? bookingId : null}
        hotelId={summary.hotelId}
        segments={booking.rooms.map((segment) => ({
          id: segment.id,
          roomNumber: segment.roomNumber,
          categoryName: segment.categoryName,
          categoryId: segment.categoryId,
        }))}
        onClose={() => setTransferOpen(false)}
        onSubmit={(payload) => transferMutation.mutate(payload)}
        loading={transferMutation.isPending}
      />

      <Dialog open={paymentOpen} onOpenChange={setPaymentOpen}>
        <DialogContent size="sm">
          <DialogHeader>
            <DialogTitle>Record payment</DialogTitle>
            <DialogDescription>Outstanding balance {currency(payable)}. No card data is stored.</DialogDescription>
          </DialogHeader>
          <div className="grid gap-3 sm:grid-cols-2">
            <Field label="Amount" required className="sm:col-span-2">
              <Input type="number" min={1} value={paymentForm.amount} onChange={(event) => setPaymentForm({ ...paymentForm, amount: event.target.value })} />
            </Field>
            <Field label="Method">
              <Select value={paymentForm.method} onChange={(event) => setPaymentForm({ ...paymentForm, method: event.target.value })}>
                {METHODS.map((method) => <option key={method} value={method}>{labelize(method)}</option>)}
              </Select>
            </Field>
            <Field label="Type">
              <Select value={paymentForm.paymentType} onChange={(event) => setPaymentForm({ ...paymentForm, paymentType: event.target.value })}>
                {PAYMENT_TYPES.map((type) => <option key={type} value={type}>{labelize(type)}</option>)}
              </Select>
            </Field>
            <Field label="Reference" className="sm:col-span-2">
              <Input value={paymentForm.reference} onChange={(event) => setPaymentForm({ ...paymentForm, reference: event.target.value })} placeholder="UTR / receipt number" />
            </Field>
            <Field label="Notes" className="sm:col-span-2">
              <Input value={paymentForm.notes} onChange={(event) => setPaymentForm({ ...paymentForm, notes: event.target.value })} />
            </Field>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setPaymentOpen(false)}>Cancel</Button>
            <Button loading={paymentMutation.isPending} disabled={!paymentForm.amount || Number(paymentForm.amount) <= 0} onClick={() => paymentMutation.mutate()}>
              Record {paymentForm.amount ? currency(paymentForm.amount) : 'payment'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={serviceOpen} onOpenChange={setServiceOpen}>
        <DialogContent size="sm">
          <DialogHeader>
            <DialogTitle>Add service</DialogTitle>
            <DialogDescription>Charges are billed to the room and included in the checkout invoice.</DialogDescription>
          </DialogHeader>
          <div className="grid gap-3 sm:grid-cols-2">
            <Field label="Type">
              <Select value={serviceForm.orderType} onChange={(event) => setServiceForm({ ...serviceForm, orderType: event.target.value })}>
                {SERVICE_TYPES.map((type) => <option key={type} value={type}>{labelize(type)}</option>)}
              </Select>
            </Field>
            <Field label="Quantity">
              <Input type="number" min={1} value={serviceForm.quantity} onChange={(event) => setServiceForm({ ...serviceForm, quantity: event.target.value })} />
            </Field>
            <Field label="Description" required className="sm:col-span-2">
              <Textarea rows={2} value={serviceForm.description} onChange={(event) => setServiceForm({ ...serviceForm, description: event.target.value })} placeholder="Club sandwich & coffee" />
            </Field>
            <Field label="Amount" required className="sm:col-span-2">
              <Input type="number" min={1} value={serviceForm.amount} onChange={(event) => setServiceForm({ ...serviceForm, amount: event.target.value })} />
            </Field>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setServiceOpen(false)}>Cancel</Button>
            <Button
              loading={serviceMutation.isPending}
              disabled={!serviceForm.description || !serviceForm.amount}
              onClick={() => serviceMutation.mutate()}
            >
              Add to folio
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={rescheduleOpen} onOpenChange={setRescheduleOpen}>
        <DialogContent size="sm">
          <DialogHeader>
            <DialogTitle>Reschedule booking</DialogTitle>
            <DialogDescription>Availability is re-validated for every night of the new range.</DialogDescription>
          </DialogHeader>
          <div className="grid gap-3 sm:grid-cols-2">
            <Field label="New check-in">
              <Input type="date" value={rescheduleForm.checkInDate} min={todayISO()} onChange={(event) => setRescheduleForm({ ...rescheduleForm, checkInDate: event.target.value })} />
            </Field>
            <Field label="New check-out">
              <Input type="date" value={rescheduleForm.checkOutDate} min={rescheduleForm.checkInDate} onChange={(event) => setRescheduleForm({ ...rescheduleForm, checkOutDate: event.target.value })} />
            </Field>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setRescheduleOpen(false)}>Cancel</Button>
            <Button
              loading={rescheduleMutation.isPending}
              disabled={!rescheduleForm.checkInDate || rescheduleForm.checkOutDate <= rescheduleForm.checkInDate}
              onClick={() => rescheduleMutation.mutate()}
            >
              Update dates
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
};

export default BookingDetailPage;
