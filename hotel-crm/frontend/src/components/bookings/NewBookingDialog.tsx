import { useEffect, useMemo, useState } from 'react';
import { useMutation, useQuery } from '@tanstack/react-query';
import { CalendarRange, Plus, Trash2, UserRoundPlus, Users } from 'lucide-react';
import { toast } from 'sonner';
import { Button } from '@/components/ui/button';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Checkbox, Field, Input, Select, Textarea } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { Separator, Spinner } from '@/components/ui/misc';
import { useHotelScope } from '@/context/HotelContext';
import { bookingApi, guestApi, roomApi } from '@/lib/endpoints';
import { fieldErrors, getErrorMessage } from '@/lib/api';
import { currency, formatDate, labelize, nightsBetween } from '@/lib/format';
import { addDaysISO, cn, todayISO } from '@/lib/utils';
import type { Guest } from '@/lib/types';

const SOURCES = ['DIRECT', 'WALK_IN', 'PHONE', 'WEBSITE', 'OTA', 'AGENT', 'CORPORATE'];
const ID_TYPES = ['AADHAAR', 'PASSPORT', 'DRIVING_LICENSE', 'VOTER_ID', 'PAN', 'OTHER'];
const METHODS = ['CASH', 'UPI', 'CARD', 'BANK_TRANSFER', 'CHEQUE', 'ONLINE'];

type RoomLine = { categoryId: string; roomId: string; extraBeds: string };

export const NewBookingDialog = ({
  open,
  onClose,
  defaultHotelId,
  onCreated,
}: {
  open: boolean;
  onClose: () => void;
  defaultHotelId: number | null;
  onCreated: (bookingId: number) => void;
}) => {
  const { hotels } = useHotelScope();
  const [hotelId, setHotelId] = useState<number | null>(defaultHotelId);
  const [mode, setMode] = useState<'new' | 'existing'>('new');
  const [guestSearch, setGuestSearch] = useState('');
  const [selectedGuest, setSelectedGuest] = useState<Guest | null>(null);
  const [newGuest, setNewGuest] = useState({
    fullName: '',
    mobile: '',
    email: '',
    city: '',
    state: '',
    idProofType: 'AADHAAR',
    idProofNumber: '',
    vip: false,
  });
  const [stay, setStay] = useState({
    checkInDate: todayISO(),
    checkOutDate: addDaysISO(1),
    adults: '2',
    children: '0',
    bookingSource: 'DIRECT',
    specialRequests: '',
    discountAmount: '',
    advanceAmount: '',
    advanceMethod: 'CASH',
    couponCode: '',
  });
  const [lines, setLines] = useState<RoomLine[]>([{ categoryId: '', roomId: '', extraBeds: '0' }]);
  const [errors, setErrors] = useState<Record<string, string>>({});

  useEffect(() => {
    if (open && defaultHotelId) setHotelId(defaultHotelId);
  }, [open, defaultHotelId]);

  useEffect(() => {
    if (!open) {
      setErrors({});
      setGuestSearch('');
      setSelectedGuest(null);
    }
  }, [open]);

  const categoriesQuery = useQuery({
    queryKey: ['room-categories', hotelId],
    queryFn: () => roomApi.categories(hotelId as number),
    enabled: Boolean(hotelId) && open,
  });
  const roomsQuery = useQuery({
    queryKey: ['rooms', 'picker', hotelId],
    queryFn: () => roomApi.list({ hotelId: hotelId ?? undefined }),
    enabled: Boolean(hotelId) && open,
  });
  const guestsQuery = useQuery({
    queryKey: ['guests', 'picker', guestSearch],
    queryFn: () => guestApi.list({ search: guestSearch.trim(), size: 8 }),
    enabled: open && mode === 'existing' && guestSearch.trim().length >= 2,
  });

  const categories = categoriesQuery.data ?? [];
  const rooms = (roomsQuery.data ?? []).filter((room) => room.status === 'AVAILABLE' && room.active);

  const primaryCategory = lines[0]?.categoryId;
  const quoteQuery = useQuery({
    queryKey: ['quote', hotelId, primaryCategory, stay.checkInDate, stay.checkOutDate, stay.adults, stay.children],
    queryFn: () =>
      bookingApi.quote(hotelId as number, {
        categoryId: Number(primaryCategory),
        checkIn: stay.checkInDate,
        checkOut: stay.checkOutDate,
        adults: Number(stay.adults),
        children: Number(stay.children),
      }),
    enabled: Boolean(hotelId) && Boolean(primaryCategory) && stay.checkOutDate > stay.checkInDate && open,
  });

  const quote = quoteQuery.data;
  const nights = Math.max(0, nightsBetween(stay.checkInDate, stay.checkOutDate));

  const extraRoomTotal = useMemo(
    () =>
      lines.slice(1).reduce((sum, line) => {
        const category = categories.find((item) => item.id === Number(line.categoryId));
        return sum + Number(category?.basePrice ?? 0) * nights;
      }, 0),
    [lines, categories, nights],
  );

  const roomTotal = Number(quote?.total ?? 0) + extraRoomTotal;
  const discount = Number(stay.discountAmount || 0);
  const grandTotal = Math.max(0, roomTotal - discount);

  const mutation = useMutation({
    mutationFn: () =>
      bookingApi.create({
        hotelId,
        guestId: mode === 'existing' ? selectedGuest?.id : undefined,
        newGuest:
          mode === 'new'
            ? {
                fullName: newGuest.fullName.trim(),
                mobile: newGuest.mobile.trim(),
                email: newGuest.email || undefined,
                city: newGuest.city || undefined,
                state: newGuest.state || undefined,
                idProofType: newGuest.idProofType,
                idProofNumber: newGuest.idProofNumber || undefined,
                vip: newGuest.vip,
              }
            : undefined,
        checkInDate: stay.checkInDate,
        checkOutDate: stay.checkOutDate,
        adults: Number(stay.adults),
        children: Number(stay.children),
        bookingSource: stay.bookingSource,
        status: 'CONFIRMED',
        rooms: lines
          .filter((line) => line.categoryId)
          .map((line) => ({
            categoryId: Number(line.categoryId),
            roomId: line.roomId ? Number(line.roomId) : undefined,
            extraBeds: Number(line.extraBeds || 0),
          })),
        couponCode: stay.couponCode.trim() || undefined,
        discountAmount: stay.discountAmount ? Number(stay.discountAmount) : undefined,
        advanceAmount: stay.advanceAmount ? Number(stay.advanceAmount) : undefined,
        advanceMethod: stay.advanceAmount ? stay.advanceMethod : undefined,
        specialRequests: stay.specialRequests || undefined,
      }),
    onSuccess: (booking) => {
      toast.success(`Booking ${booking.summary.bookingCode} created`);
      setLines([{ categoryId: '', roomId: '', extraBeds: '0' }]);
      setNewGuest({ fullName: '', mobile: '', email: '', city: '', state: '', idProofType: 'AADHAAR', idProofNumber: '', vip: false });
      setStay({
        checkInDate: todayISO(),
        checkOutDate: addDaysISO(1),
        adults: '2',
        children: '0',
        bookingSource: 'DIRECT',
        specialRequests: '',
        discountAmount: '',
        advanceAmount: '',
        advanceMethod: 'CASH',
        couponCode: '',
      });
      setSelectedGuest(null);
      onCreated(booking.summary.id);
    },
    onError: (err) => {
      setErrors(fieldErrors(err));
      toast.error(getErrorMessage(err));
    },
  });

  const canSubmit =
    Boolean(hotelId) &&
    lines.some((line) => line.categoryId) &&
    stay.checkOutDate > stay.checkInDate &&
    (mode === 'existing' ? Boolean(selectedGuest) : newGuest.fullName.trim().length > 1 && newGuest.mobile.trim().length >= 8);

  return (
    <Dialog open={open} onOpenChange={(value) => !value && onClose()}>
      <DialogContent size="xl">
        <DialogHeader>
          <DialogTitle>New reservation</DialogTitle>
          <DialogDescription>
            Rooms may be left unassigned — availability is validated on save and again at check-in.
          </DialogDescription>
        </DialogHeader>

        <div className="grid gap-5 lg:grid-cols-[1.35fr_1fr]">
          <div className="space-y-4">
            <section className="space-y-3 rounded-lg border border-border p-3">
              <div className="flex items-center justify-between">
                <p className="text-sm font-semibold text-navy-900">Guest</p>
                <div className="flex rounded-lg bg-muted p-0.5 text-xs">
                  <button
                    type="button"
                    onClick={() => setMode('new')}
                    className={cn('rounded px-2 py-1 font-medium', mode === 'new' ? 'bg-card shadow-sm' : 'text-muted-foreground')}
                  >
                    <UserRoundPlus className="mr-1 inline h-3 w-3" /> New guest
                  </button>
                  <button
                    type="button"
                    onClick={() => setMode('existing')}
                    className={cn('rounded px-2 py-1 font-medium', mode === 'existing' ? 'bg-card shadow-sm' : 'text-muted-foreground')}
                  >
                    <Users className="mr-1 inline h-3 w-3" /> Returning
                  </button>
                </div>
              </div>

              {mode === 'new' ? (
                <div className="grid gap-2.5 sm:grid-cols-2">
                  <Field label="Full name" required error={errors['newGuest.fullName']}>
                    <Input
                      value={newGuest.fullName}
                      onChange={(event) => setNewGuest({ ...newGuest, fullName: event.target.value })}
                      placeholder="Aarav Kapoor"
                    />
                  </Field>
                  <Field label="Mobile" required error={errors['newGuest.mobile']}>
                    <Input
                      value={newGuest.mobile}
                      onChange={(event) => setNewGuest({ ...newGuest, mobile: event.target.value })}
                      placeholder="+91 98765 43210"
                    />
                  </Field>
                  <Field label="Email">
                    <Input
                      type="email"
                      value={newGuest.email}
                      onChange={(event) => setNewGuest({ ...newGuest, email: event.target.value })}
                      placeholder="aarav@example.com"
                    />
                  </Field>
                  <Field label="City">
                    <Input value={newGuest.city} onChange={(event) => setNewGuest({ ...newGuest, city: event.target.value })} />
                  </Field>
                  <Field label="ID proof type">
                    <Select
                      value={newGuest.idProofType}
                      onChange={(event) => setNewGuest({ ...newGuest, idProofType: event.target.value })}
                    >
                      {ID_TYPES.map((type) => (
                        <option key={type} value={type}>{labelize(type)}</option>
                      ))}
                    </Select>
                  </Field>
                  <Field label="ID proof number" hint="Encrypted at rest (AES-GCM)">
                    <Input
                      value={newGuest.idProofNumber}
                      onChange={(event) => setNewGuest({ ...newGuest, idProofNumber: event.target.value })}
                      placeholder="XXXX XXXX 1234"
                    />
                  </Field>
                  <div className="sm:col-span-2">
                    <Checkbox
                      checked={newGuest.vip}
                      onChange={(value) => setNewGuest({ ...newGuest, vip: value })}
                      label="VIP guest"
                      description="Flagged for priority service across all hotels"
                    />
                  </div>
                </div>
              ) : (
                <div className="space-y-2">
                  <Input
                    value={guestSearch}
                    onChange={(event) => setGuestSearch(event.target.value)}
                    placeholder="Search guest by name or mobile…"
                  />
                  {selectedGuest ? (
                    <div className="flex items-center justify-between rounded-lg bg-brand-50 px-3 py-2">
                      <div>
                        <p className="text-sm font-medium text-navy-900">{selectedGuest.fullName}</p>
                        <p className="text-[11px] text-muted-foreground">
                          {selectedGuest.mobile} · {selectedGuest.totalBookings} stays
                          {selectedGuest.vip ? ' · VIP' : ''}
                        </p>
                      </div>
                      <Button variant="ghost" size="sm" onClick={() => setSelectedGuest(null)}>Change</Button>
                    </div>
                  ) : guestsQuery.data?.content.length ? (
                    <div className="max-h-40 overflow-y-auto rounded-lg border border-border">
                      {guestsQuery.data.content.map((guest) => (
                        <button
                          key={guest.id}
                          type="button"
                          onClick={() => setSelectedGuest(guest)}
                          className="flex w-full items-center justify-between border-b border-border/60 px-3 py-2 text-left last:border-0 hover:bg-muted"
                        >
                          <span>
                            <span className="block text-sm text-navy-900">{guest.fullName}</span>
                            <span className="block text-[11px] text-muted-foreground">{guest.mobile}</span>
                          </span>
                          {guest.vip && <Badge tone="purple">VIP</Badge>}
                        </button>
                      ))}
                    </div>
                  ) : (
                    <p className="text-[11px] text-muted-foreground">
                      {guestSearch.trim().length < 2 ? 'Type at least 2 characters to search.' : 'No matching guests.'}
                    </p>
                  )}
                </div>
              )}
            </section>

            <section className="space-y-3 rounded-lg border border-border p-3">
              <div className="flex items-center justify-between">
                <p className="text-sm font-semibold text-navy-900">Stay</p>
                <Badge tone="info">
                  <CalendarRange className="h-3 w-3" /> {nights} night{nights === 1 ? '' : 's'}
                </Badge>
              </div>
              <div className="grid gap-2.5 sm:grid-cols-2">
                <Field label="Hotel" required>
                  <Select value={hotelId ?? ''} onChange={(event) => setHotelId(Number(event.target.value))}>
                    {hotels.map((item) => (
                      <option key={item.id} value={item.id}>{item.name}</option>
                    ))}
                  </Select>
                </Field>
                <Field label="Booking source">
                  <Select
                    value={stay.bookingSource}
                    onChange={(event) => setStay({ ...stay, bookingSource: event.target.value })}
                  >
                    {SOURCES.map((source) => (
                      <option key={source} value={source}>{labelize(source)}</option>
                    ))}
                  </Select>
                </Field>
                <Field label="Check-in" required error={errors.checkInDate}>
                  <Input
                    type="date"
                    value={stay.checkInDate}
                    min={todayISO()}
                    onChange={(event) => {
                      const checkInDate = event.target.value;
                      setStay({
                        ...stay,
                        checkInDate,
                        checkOutDate: stay.checkOutDate <= checkInDate ? addDaysISO(1, new Date(`${checkInDate}T00:00:00`)) : stay.checkOutDate,
                      });
                    }}
                  />
                </Field>
                <Field label="Check-out" required error={errors.checkOutDate}>
                  <Input
                    type="date"
                    value={stay.checkOutDate}
                    min={addDaysISO(1, new Date(`${stay.checkInDate}T00:00:00`))}
                    onChange={(event) => setStay({ ...stay, checkOutDate: event.target.value })}
                  />
                </Field>
                <Field label="Adults">
                  <Input type="number" min={1} max={12} value={stay.adults} onChange={(event) => setStay({ ...stay, adults: event.target.value })} />
                </Field>
                <Field label="Children">
                  <Input type="number" min={0} max={8} value={stay.children} onChange={(event) => setStay({ ...stay, children: event.target.value })} />
                </Field>
              </div>
            </section>

            <section className="space-y-2.5 rounded-lg border border-border p-3">
              <div className="flex items-center justify-between">
                <p className="text-sm font-semibold text-navy-900">Rooms</p>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => setLines([...lines, { categoryId: '', roomId: '', extraBeds: '0' }])}
                  disabled={lines.length >= 4}
                >
                  <Plus className="h-3.5 w-3.5" /> Add room
                </Button>
              </div>
              {lines.map((line, index) => (
                <div key={index} className="grid gap-2 sm:grid-cols-[1.2fr_1fr_0.7fr_auto]">
                  <Select
                    value={line.categoryId}
                    onChange={(event) => {
                      const next = [...lines];
                      next[index] = { ...line, categoryId: event.target.value, roomId: '' };
                      setLines(next);
                    }}
                    aria-label={`Category for room ${index + 1}`}
                  >
                    <option value="">Select category</option>
                    {categories.map((category) => (
                      <option key={category.id} value={category.id}>
                        {category.name} · {currency(category.basePrice)}
                      </option>
                    ))}
                  </Select>
                  <Select
                    value={line.roomId}
                    onChange={(event) => {
                      const next = [...lines];
                      next[index] = { ...line, roomId: event.target.value };
                      setLines(next);
                    }}
                    aria-label={`Room for line ${index + 1}`}
                  >
                    <option value="">Auto-assign</option>
                    {rooms
                      .filter((room) => !line.categoryId || room.categoryId === Number(line.categoryId))
                      .map((room) => (
                        <option key={room.id} value={room.id}>{room.roomNumber}</option>
                      ))}
                  </Select>
                  <Select
                    value={line.extraBeds}
                    onChange={(event) => {
                      const next = [...lines];
                      next[index] = { ...line, extraBeds: event.target.value };
                      setLines(next);
                    }}
                    aria-label={`Extra beds for line ${index + 1}`}
                  >
                    {[0, 1, 2].map((count) => (
                      <option key={count} value={count}>{count} extra bed{count === 1 ? '' : 's'}</option>
                    ))}
                  </Select>
                  <Button
                    variant="ghost"
                    size="icon-sm"
                    className="text-destructive"
                    disabled={lines.length === 1}
                    onClick={() => setLines(lines.filter((_, lineIndex) => lineIndex !== index))}
                    aria-label="Remove room"
                  >
                    <Trash2 className="h-3.5 w-3.5" />
                  </Button>
                </div>
              ))}
              {errors.rooms && <p className="text-xs font-medium text-destructive">{errors.rooms}</p>}
            </section>
          </div>

          <div className="space-y-3">
            <div className="rounded-lg border border-border bg-muted/40 p-3">
              <p className="text-sm font-semibold text-navy-900">Rate summary</p>
              {quoteQuery.isFetching ? (
                <div className="flex items-center gap-2 py-6 text-xs text-muted-foreground">
                  <Spinner className="h-4 w-4" /> Calculating nightly rates…
                </div>
              ) : quote ? (
                <div className="mt-2 space-y-1.5 text-xs">
                  <div className="flex justify-between"><span className="text-muted-foreground">Category</span><span className="font-medium">{quote.categoryName}</span></div>
                  <div className="flex justify-between"><span className="text-muted-foreground">Nights</span><span className="font-medium">{quote.nights}</span></div>
                  <div className="flex justify-between"><span className="text-muted-foreground">Average / night</span><span className="font-medium">{currency(quote.averageRate)}</span></div>
                  <div className="flex justify-between"><span className="text-muted-foreground">Room total</span><span className="font-medium">{currency(quote.roomTotal)}</span></div>
                  {Number(quote.extraPersonCharge) > 0 && (
                    <div className="flex justify-between"><span className="text-muted-foreground">Extra person</span><span className="font-medium">{currency(quote.extraPersonCharge)}</span></div>
                  )}
                  {extraRoomTotal > 0 && (
                    <div className="flex justify-between"><span className="text-muted-foreground">Additional rooms</span><span className="font-medium">{currency(extraRoomTotal)}</span></div>
                  )}
                  <div className="mt-1 max-h-28 overflow-y-auto rounded border border-border/70 bg-card p-1.5">
                    {quote.breakdown.map((night) => (
                      <div key={night.date} className="flex items-center justify-between text-[11px]">
                        <span className="text-muted-foreground">
                          {formatDate(night.date)}
                          {night.appliedPlan ? ` · ${night.appliedPlan}` : ''}
                        </span>
                        <span className="font-medium text-navy-800">{currency(night.rate)}</span>
                      </div>
                    ))}
                  </div>
                  <Separator className="my-1.5" />
                  <div className="flex justify-between text-sm">
                    <span className="font-medium text-navy-900">Expected total</span>
                    <span className="font-semibold text-navy-900">{currency(grandTotal)}</span>
                  </div>
                </div>
              ) : (
                <p className="mt-2 text-xs text-muted-foreground">Select a category to see the nightly breakdown.</p>
              )}
            </div>

            <div className="space-y-2.5 rounded-lg border border-border p-3">
              <p className="text-sm font-semibold text-navy-900">Payments & discounts</p>
              <Field label="Coupon code">
                <Input
                  value={stay.couponCode}
                  onChange={(event) => setStay({ ...stay, couponCode: event.target.value.toUpperCase() })}
                  placeholder="WELCOME10"
                />
              </Field>
              <Field label="Discount amount" error={errors.discountAmount}>
                <Input
                  type="number"
                  min={0}
                  value={stay.discountAmount}
                  onChange={(event) => setStay({ ...stay, discountAmount: event.target.value })}
                />
              </Field>
              <div className="grid grid-cols-2 gap-2">
                <Field label="Advance">
                  <Input
                    type="number"
                    min={0}
                    value={stay.advanceAmount}
                    onChange={(event) => setStay({ ...stay, advanceAmount: event.target.value })}
                  />
                </Field>
                <Field label="Method">
                  <Select
                    value={stay.advanceMethod}
                    onChange={(event) => setStay({ ...stay, advanceMethod: event.target.value })}
                    disabled={!stay.advanceAmount}
                  >
                    {METHODS.map((method) => (
                      <option key={method} value={method}>{labelize(method)}</option>
                    ))}
                  </Select>
                </Field>
              </div>
              <Field label="Special requests">
                <Textarea
                  rows={2}
                  value={stay.specialRequests}
                  onChange={(event) => setStay({ ...stay, specialRequests: event.target.value })}
                  placeholder="High floor, airport pickup…"
                />
              </Field>
            </div>
          </div>
        </div>

        <DialogFooter>
          <Button variant="outline" onClick={onClose}>Cancel</Button>
          <Button loading={mutation.isPending} disabled={!canSubmit} onClick={() => mutation.mutate()}>
            Create booking · {currency(grandTotal)}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
};
