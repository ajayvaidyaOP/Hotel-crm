import { useEffect, useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { BedDouble, LogIn, LogOut, XCircle } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Checkbox, Field, Input, Select, Textarea } from '@/components/ui/input';
import { Spinner } from '@/components/ui/misc';
import { bookingApi, roomApi } from '@/lib/endpoints';
import { currency, formatDate, labelize } from '@/lib/format';
import type { BookingSummary } from '@/lib/types';

const METHODS = ['CASH', 'UPI', 'CARD', 'BANK_TRANSFER', 'CHEQUE', 'ONLINE'];

export const CheckInDialog = ({
  booking,
  onClose,
  onSubmit,
  loading,
}: {
  booking: BookingSummary | null;
  onClose: () => void;
  onSubmit: (payload: Record<string, unknown>) => void;
  loading: boolean;
}) => {
  const [assignments, setAssignments] = useState<Record<number, string>>({});
  const [earlyCharge, setEarlyCharge] = useState('0');
  const [idVerified, setIdVerified] = useState(true);
  const [notes, setNotes] = useState('');

  const detailQuery = useQuery({
    queryKey: ['booking', booking?.id],
    queryFn: () => bookingApi.get(booking!.id),
    enabled: Boolean(booking),
  });
  const roomsQuery = useQuery({
    queryKey: ['rooms', 'available', booking?.hotelId],
    queryFn: () => roomApi.list({ hotelId: booking?.hotelId, status: 'AVAILABLE' }),
    enabled: Boolean(booking),
  });

  useEffect(() => {
    if (detailQuery.data) {
      const initial: Record<number, string> = {};
      detailQuery.data.rooms.forEach((segment) => {
        initial[segment.id] = segment.roomId ? String(segment.roomId) : '';
      });
      setAssignments(initial);
    }
  }, [detailQuery.data]);

  const segments = detailQuery.data?.rooms ?? [];
  const availableRooms = (roomsQuery.data ?? []).filter((room) => room.status === 'AVAILABLE');

  return (
    <Dialog open={Boolean(booking)} onOpenChange={(open) => !open && onClose()}>
      <DialogContent size="md">
        <DialogHeader>
          <DialogTitle>Check in {booking?.guestName}</DialogTitle>
          <DialogDescription>
            {booking?.bookingCode} · {formatDate(booking?.checkInDate)} → {formatDate(booking?.checkOutDate)} ·{' '}
            {currency(booking?.pendingAmount)} balance
          </DialogDescription>
        </DialogHeader>

        {detailQuery.isLoading ? (
          <div className="flex items-center gap-2 py-8 text-sm text-muted-foreground">
            <Spinner /> Loading room allocation…
          </div>
        ) : (
          <div className="space-y-3">
            {segments.map((segment) => (
              <div key={segment.id} className="grid gap-2 rounded-lg border border-border p-3 sm:grid-cols-2">
                <div>
                  <p className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Segment</p>
                  <p className="text-sm text-navy-900">
                    {segment.categoryName} · {formatDate(segment.checkInDate)} → {formatDate(segment.checkOutDate)}
                  </p>
                  <p className="text-[11px] text-muted-foreground">
                    {segment.nights} nights · {currency(segment.ratePerNight)}/night
                  </p>
                </div>
                <Field label="Assign room" hint={segment.roomNumber ? `Currently ${segment.roomNumber}` : 'Room not yet assigned'}>
                  <Select
                    value={assignments[segment.id] ?? ''}
                    onChange={(event) => setAssignments({ ...assignments, [segment.id]: event.target.value })}
                  >
                    <option value="">Auto-assign available</option>
                    {availableRooms
                      .filter((room) => room.categoryId === segment.categoryId)
                      .map((room) => (
                        <option key={room.id} value={room.id}>
                          {room.roomNumber} · floor {room.floor}
                        </option>
                      ))}
                  </Select>
                </Field>
              </div>
            ))}

            <div className="grid gap-2 sm:grid-cols-2">
              <Field label="Early check-in charge">
                <Input type="number" min={0} value={earlyCharge} onChange={(event) => setEarlyCharge(event.target.value)} />
              </Field>
              <Field label="Notes">
                <Input value={notes} onChange={(event) => setNotes(event.target.value)} placeholder="Key handover, ID verified…" />
              </Field>
            </div>

            <Checkbox
              checked={idVerified}
              onChange={setIdVerified}
              label="Government ID verified"
              description="ID proof numbers are stored encrypted; only the last 4 digits are visible."
            />

            {Number(booking?.pendingAmount ?? 0) > 0 && (
              <p className="rounded-lg bg-amber-50 px-3 py-2 text-xs text-amber-800">
                This booking still has {currency(booking?.pendingAmount)} outstanding. Collect it from the booking page
                after check-in.
              </p>
            )}
          </div>
        )}

        <DialogFooter>
          <Button variant="outline" onClick={onClose}>Cancel</Button>
          <Button
            loading={loading}
            onClick={() =>
              onSubmit({
                assignments: Object.entries(assignments)
                  .filter(([, roomId]) => roomId)
                  .map(([segmentId, roomId]) => ({ segmentId: Number(segmentId), roomId: Number(roomId) })),
                earlyCheckInCharge: Number(earlyCharge || 0),
                idVerified,
                notes: notes || undefined,
              })
            }
          >
            <LogIn className="h-4 w-4" /> Confirm check-in
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
};

export const CheckOutDialog = ({
  booking,
  onClose,
  onSubmit,
  loading,
}: {
  booking: BookingSummary | null;
  onClose: () => void;
  onSubmit: (payload: Record<string, unknown>) => void;
  loading: boolean;
}) => {
  const [extraCharges, setExtraCharges] = useState('0');
  const [lateCharge, setLateCharge] = useState('0');
  const [discount, setDiscount] = useState('0');
  const [collectPayment, setCollectPayment] = useState(true);
  const [method, setMethod] = useState('CASH');
  const [reference, setReference] = useState('');
  const [notes, setNotes] = useState('');

  useEffect(() => {
    if (booking) {
      setExtraCharges('0');
      setLateCharge('0');
      setDiscount('0');
      setCollectPayment(Number(booking.pendingAmount) > 0);
      setReference('');
      setNotes('');
    }
  }, [booking]);

  const pending = Number(booking?.pendingAmount ?? 0);
  const payable = Math.max(0, pending + Number(extraCharges || 0) + Number(lateCharge || 0) - Number(discount || 0));

  return (
    <Dialog open={Boolean(booking)} onOpenChange={(open) => !open && onClose()}>
      <DialogContent size="md">
        <DialogHeader>
          <DialogTitle>Check out {booking?.guestName}</DialogTitle>
          <DialogDescription>
            Room {booking?.roomNumbers.join(', ')} · invoice is generated automatically with GST.
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-3">
          <div className="grid gap-2 sm:grid-cols-2">
            <Field label="Extra charges" hint="Minibar, laundry, room service">
              <Input type="number" min={0} value={extraCharges} onChange={(event) => setExtraCharges(event.target.value)} />
            </Field>
            <Field label="Late check-out charge">
              <Input type="number" min={0} value={lateCharge} onChange={(event) => setLateCharge(event.target.value)} />
            </Field>
            <Field label="Discount">
              <Input type="number" min={0} value={discount} onChange={(event) => setDiscount(event.target.value)} />
            </Field>
            <Field label="Settlement">
              <Select value={method} onChange={(event) => setMethod(event.target.value)} disabled={!collectPayment}>
                {METHODS.map((item) => (
                  <option key={item} value={item}>{labelize(item)}</option>
                ))}
              </Select>
            </Field>
          </div>

          {collectPayment && (
            <Field label="Payment reference">
              <Input value={reference} onChange={(event) => setReference(event.target.value)} placeholder="UPI / card / cheque reference" />
            </Field>
          )}

          <label className="flex items-start gap-2 rounded-lg bg-muted/60 p-3">
            <input
              type="checkbox"
              checked={collectPayment}
              onChange={(event) => setCollectPayment(event.target.checked)}
              className="mt-0.5 h-4 w-4 rounded border-input"
            />
            <span className="text-xs">
              <span className="block font-medium text-navy-900">Settle the balance now</span>
              <span className="block text-muted-foreground">
                {collectPayment
                  ? `Records a payment of ${currency(payable)} at checkout.`
                  : 'Leaves the invoice open — you can settle it later from Invoices.'}
              </span>
            </span>
          </label>

          <Field label="Notes">
            <Textarea rows={2} value={notes} onChange={(event) => setNotes(event.target.value)} />
          </Field>

          <div className="rounded-lg border border-border p-3 text-sm">
            <div className="flex justify-between py-0.5"><span className="text-muted-foreground">Outstanding</span><span>{currency(pending)}</span></div>
            <div className="flex justify-between py-0.5"><span className="text-muted-foreground">Extras</span><span>{currency(Number(extraCharges || 0) + Number(lateCharge || 0))}</span></div>
            <div className="flex justify-between py-0.5"><span className="text-muted-foreground">Discount</span><span>-{currency(discount)}</span></div>
            <div className="mt-1 flex justify-between border-t border-border pt-1.5 font-semibold text-navy-900">
              <span>Payable now</span><span>{currency(payable)}</span>
            </div>
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={onClose}>Cancel</Button>
          <Button
            loading={loading}
            onClick={() =>
              onSubmit({
                extraCharges: Number(extraCharges || 0),
                lateCheckOutCharge: Number(lateCharge || 0),
                discount: Number(discount || 0),
                collectPayment,
                paymentMethod: collectPayment ? method : undefined,
                paymentReference: reference || undefined,
                notes: notes || undefined,
              })
            }
          >
            <LogOut className="h-4 w-4" /> Confirm checkout
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
};

export const CancelBookingDialog = ({
  booking,
  onClose,
  onSubmit,
  loading,
}: {
  booking: BookingSummary | null;
  onClose: () => void;
  onSubmit: (payload: { reason: string; refundAmount?: number; refundMethod?: string }) => void;
  loading: boolean;
}) => {
  const [reason, setReason] = useState('');
  const [refundAmount, setRefundAmount] = useState('');
  const [refundMethod, setRefundMethod] = useState('UPI');

  useEffect(() => {
    if (booking) {
      setReason('');
      setRefundAmount(String(booking.paidAmount ?? 0));
      setRefundMethod('UPI');
    }
  }, [booking]);

  return (
    <Dialog open={Boolean(booking)} onOpenChange={(open) => !open && onClose()}>
      <DialogContent size="sm">
        <DialogHeader>
          <DialogTitle>Cancel {booking?.bookingCode}</DialogTitle>
          <DialogDescription>
            Paid so far: {currency(booking?.paidAmount)}. Cancelling frees the room; refunds are recorded in the ledger.
          </DialogDescription>
        </DialogHeader>
        <div className="space-y-3">
          <Field label="Cancellation reason" required>
            <Textarea rows={2} value={reason} onChange={(event) => setReason(event.target.value)} placeholder="Guest travel plans changed" />
          </Field>
          <div className="grid grid-cols-2 gap-2">
            <Field label="Refund amount">
              <Input type="number" min={0} max={Number(booking?.paidAmount ?? 0)} value={refundAmount} onChange={(event) => setRefundAmount(event.target.value)} />
            </Field>
            <Field label="Refund method">
              <Select value={refundMethod} onChange={(event) => setRefundMethod(event.target.value)}>
                {METHODS.map((method) => <option key={method} value={method}>{labelize(method)}</option>)}
              </Select>
            </Field>
          </div>
          <p className="flex items-start gap-2 rounded-lg bg-red-50 px-3 py-2 text-[11px] text-red-800">
            <XCircle className="mt-0.5 h-3.5 w-3.5 shrink-0" />
            Cancelling is permanent and is written to the audit log.
          </p>
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={onClose}>Keep booking</Button>
          <Button
            variant="destructive"
            loading={loading}
            disabled={reason.trim().length < 3}
            onClick={() =>
              onSubmit({
                reason: reason.trim(),
                refundAmount: refundAmount ? Number(refundAmount) : undefined,
                refundMethod: refundAmount ? refundMethod : undefined,
              })
            }
          >
            Cancel booking
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
};

export const TransferRoomDialog = ({
  bookingId,
  segments,
  hotelId,
  onClose,
  onSubmit,
  loading,
}: {
  bookingId: number | null;
  segments: { id: number; roomNumber?: string | null; categoryName: string; categoryId: number }[];
  hotelId: number;
  onClose: () => void;
  onSubmit: (payload: { segmentId: number; newRoomId: number; reason?: string }) => void;
  loading: boolean;
}) => {
  const [segmentId, setSegmentId] = useState('');
  const [newRoomId, setNewRoomId] = useState('');
  const [reason, setReason] = useState('');

  const roomsQuery = useQuery({
    queryKey: ['rooms', 'transfer', hotelId],
    queryFn: () => roomApi.list({ hotelId, status: 'AVAILABLE' }),
    enabled: Boolean(bookingId),
  });

  const rooms = roomsQuery.data ?? [];
  const selectedSegment = segments.find((segment) => segment.id === Number(segmentId));

  return (
    <Dialog open={Boolean(bookingId)} onOpenChange={(open) => !open && onClose()}>
      <DialogContent size="sm">
        <DialogHeader>
          <DialogTitle>Transfer room</DialogTitle>
          <DialogDescription>Overlap is validated server-side before the transfer commits.</DialogDescription>
        </DialogHeader>
        <div className="space-y-3">
          <Field label="Segment" required>
            <Select value={segmentId} onChange={(event) => setSegmentId(event.target.value)}>
              <option value="">Select segment</option>
              {segments.map((segment) => (
                <option key={segment.id} value={segment.id}>
                  {segment.categoryName} · room {segment.roomNumber ?? 'TBA'}
                </option>
              ))}
            </Select>
          </Field>
          <Field label="New room" required>
            <Select value={newRoomId} onChange={(event) => setNewRoomId(event.target.value)}>
              <option value="">Select available room</option>
              {rooms
                .filter((room) => !selectedSegment || room.categoryId === selectedSegment.categoryId)
                .map((room) => (
                  <option key={room.id} value={room.id}>
                    {room.roomNumber} · {room.categoryName} · {currency(room.basePrice)}
                  </option>
                ))}
            </Select>
          </Field>
          <Field label="Reason">
            <Input value={reason} onChange={(event) => setReason(event.target.value)} placeholder="Guest requested higher floor" />
          </Field>
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={onClose}>Cancel</Button>
          <Button
            loading={loading}
            disabled={!segmentId || !newRoomId}
            onClick={() => onSubmit({ segmentId: Number(segmentId), newRoomId: Number(newRoomId), reason: reason || undefined })}
          >
            <BedDouble className="h-4 w-4" /> Transfer
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
};
