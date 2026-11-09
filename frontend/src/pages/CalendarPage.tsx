import { useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { CalendarDays, ChevronLeft, ChevronRight, GripVertical, Info, RefreshCw } from 'lucide-react';
import { toast } from 'sonner';
import { PageHeader } from '@/components/common/PageHeader';
import { EmptyState, ErrorState, TableSkeleton } from '@/components/common/States';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Badge, StatusBadge } from '@/components/ui/badge';
import { Select } from '@/components/ui/input';
import { useHotelScope } from '@/context/HotelContext';
import { useAuth } from '@/context/AuthContext';
import { bookingApi } from '@/lib/endpoints';
import { getErrorMessage } from '@/lib/api';
import { currency, formatDate, formatDateShort, labelize } from '@/lib/format';
import { addDaysISO, cn } from '@/lib/utils';
import type { CalendarEntry } from '@/lib/types';

type DragPayload = {
  bookingId: number;
  segmentId: number;
  roomId: number | null;
  checkInDate: string;
  checkOutDate: string;
  guestName: string;
};

const DAY_MS = 86_400_000;
const dayDiff = (from: string, to: string) =>
  Math.round((new Date(`${to}T00:00:00`).getTime() - new Date(`${from}T00:00:00`).getTime()) / DAY_MS);

const STATUS_BAR: Record<string, string> = {
  CONFIRMED: 'bg-brand-100 text-brand-900 border-brand-300',
  PENDING: 'bg-amber-100 text-amber-900 border-amber-300',
  CHECKED_IN: 'bg-emerald-100 text-emerald-900 border-emerald-300',
  CHECKED_OUT: 'bg-slate-100 text-slate-700 border-slate-300',
  NO_SHOW: 'bg-red-100 text-red-800 border-red-300',
  CANCELLED: 'bg-red-50 text-red-500 border-red-200 line-through',
};

const CalendarPage = () => {
  const { hotels, hotelId, setHotelId } = useHotelScope();
  const { has } = useAuth();
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  const [startDate, setStartDate] = useState(addDaysISO(-1));
  const [span, setSpan] = useState(14);
  const [dragPayload, setDragPayload] = useState<DragPayload | null>(null);
  const [hoverCell, setHoverCell] = useState<string | null>(null);

  const endDate = addDaysISO(span - 1, new Date(`${startDate}T00:00:00`));

  const calendarQuery = useQuery({
    queryKey: ['calendar', hotelId, startDate, endDate],
    queryFn: () => bookingApi.calendar(hotelId as number, startDate, endDate),
    enabled: Boolean(hotelId),
  });

  const days = useMemo(
    () => Array.from({ length: span }, (_, index) => addDaysISO(index, new Date(`${startDate}T00:00:00`))),
    [span, startDate],
  );

  const entriesByRoom = useMemo(() => {
    const map = new Map<number, CalendarEntry[]>();
    (calendarQuery.data?.entries ?? []).forEach((entry) => {
      if (!entry.roomId) return;
      const list = map.get(entry.roomId) ?? [];
      list.push(entry);
      map.set(entry.roomId, list);
    });
    return map;
  }, [calendarQuery.data?.entries]);

  const unassigned = (calendarQuery.data?.entries ?? []).filter((entry) => !entry.roomId);

  const refresh = () => {
    queryClient.invalidateQueries({ queryKey: ['calendar'] });
    queryClient.invalidateQueries({ queryKey: ['bookings'] });
    queryClient.invalidateQueries({ queryKey: ['dashboard'] });
  };

  const rescheduleMutation = useMutation({
    mutationFn: ({ bookingId, checkInDate, checkOutDate, segmentId }: { bookingId: number; checkInDate: string; checkOutDate: string; segmentId: number }) =>
      bookingApi.reschedule(bookingId, { checkInDate, checkOutDate, segmentId }),
  });

  const transferMutation = useMutation({
    mutationFn: ({ bookingId, segmentId, roomId }: { bookingId: number; segmentId: number; roomId: number }) =>
      bookingApi.transferRoom(bookingId, { segmentId, newRoomId: roomId, reason: 'Dragged on calendar' }),
  });

  const handleDrop = async (roomId: number, date: string) => {
    setHoverCell(null);
    if (!dragPayload || !has('booking:write')) {
      setDragPayload(null);
      return;
    }
    const delta = dayDiff(dragPayload.checkInDate, date);
    const roomChanged = dragPayload.roomId !== roomId;
    if (delta === 0 && !roomChanged) {
      setDragPayload(null);
      return;
    }
    try {
      if (delta !== 0) {
        const nights = dayDiff(dragPayload.checkInDate, dragPayload.checkOutDate);
        const newCheckIn = date;
        const newCheckOut = addDaysISO(nights, new Date(`${date}T00:00:00`));
        await rescheduleMutation.mutateAsync({
          bookingId: dragPayload.bookingId,
          checkInDate: newCheckIn,
          checkOutDate: newCheckOut,
          segmentId: dragPayload.segmentId,
        });
        toast.success(`Shifted ${dragPayload.guestName} by ${delta} day${Math.abs(delta) === 1 ? '' : 's'}`);
      }
      if (roomChanged) {
        await transferMutation.mutateAsync({ bookingId: dragPayload.bookingId, segmentId: dragPayload.segmentId, roomId });
        toast.success('Room transferred');
      }
      refresh();
    } catch (err) {
      toast.error(getErrorMessage(err));
    } finally {
      setDragPayload(null);
    }
  };

  const rooms = calendarQuery.data?.rooms ?? [];

  return (
    <div className="space-y-5">
      <PageHeader
        title="Booking calendar"
        description="Drag a reservation onto another room or date — availability is re-validated by the API before it saves."
        actions={
          <>
            <Select
              value={hotelId ?? ''}
              onChange={(event) => setHotelId(Number(event.target.value))}
              className="h-9 w-full sm:w-52"
              aria-label="Hotel"
            >
              {hotels.map((hotel) => (
                <option key={hotel.id} value={hotel.id}>{hotel.name}</option>
              ))}
            </Select>
            <Button variant="outline" size="sm" onClick={refresh}>
              <RefreshCw className="h-4 w-4" /> Refresh
            </Button>
          </>
        }
      />

      <Card className="overflow-hidden">
        <div className="flex flex-wrap items-center gap-2 border-b border-border/70 px-4 py-3">
          <Button variant="outline" size="icon-sm" onClick={() => setStartDate(addDaysISO(-span, new Date(`${startDate}T00:00:00`)))} aria-label="Previous window">
            <ChevronLeft className="h-4 w-4" />
          </Button>
          <Button variant="outline" size="icon-sm" onClick={() => setStartDate(addDaysISO(span, new Date(`${startDate}T00:00:00`)))} aria-label="Next window">
            <ChevronRight className="h-4 w-4" />
          </Button>
          <Button variant="outline" size="sm" onClick={() => setStartDate(addDaysISO(-1))}>
            <CalendarDays className="h-4 w-4" /> Today
          </Button>
          <div className="flex items-center gap-1 rounded-lg bg-muted p-1">
            {[1, 7, 14, 30].map((option) => (
              <button
                key={option}
                onClick={() => setSpan(option)}
                className={cn(
                  'rounded px-2 py-1 text-xs font-medium transition-colors',
                  span === option ? 'bg-card text-navy-900 shadow-sm' : 'text-muted-foreground hover:text-navy-800',
                )}
              >
                {option === 1 ? 'Day' : option === 7 ? 'Week' : option === 14 ? '2 weeks' : 'Month'}
              </button>
            ))}
          </div>
          <p className="text-xs text-muted-foreground">
            {formatDate(startDate)} → {formatDate(endDate)} · {rooms.length} rooms
          </p>
          <div className="ml-auto flex flex-wrap items-center gap-2">
            {['CONFIRMED', 'PENDING', 'CHECKED_IN'].map((status) => (
              <span key={status} className="flex items-center gap-1 text-[11px] text-muted-foreground">
                <span className={cn('h-2.5 w-2.5 rounded-sm border', STATUS_BAR[status])} />
                {labelize(status)}
              </span>
            ))}
          </div>
        </div>

        {calendarQuery.isError ? (
          <ErrorState message={getErrorMessage(calendarQuery.error)} onRetry={() => calendarQuery.refetch()} />
        ) : calendarQuery.isLoading ? (
          <TableSkeleton rows={8} columns={6} />
        ) : rooms.length === 0 ? (
          <EmptyState icon={CalendarDays} title="No rooms to display" description="Add rooms to this hotel to use the calendar." />
        ) : (
          <div className="overflow-x-auto">
            <div className="min-w-[900px]">
              <div
                className="sticky top-0 z-10 grid border-b border-border bg-muted/70 backdrop-blur"
                style={{ gridTemplateColumns: `160px repeat(${span}, minmax(64px, 1fr))` }}
              >
                <div className="px-3 py-2 text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">Room</div>
                {days.map((day) => {
                  const date = new Date(`${day}T00:00:00`);
                  const isToday = day === new Date().toISOString().slice(0, 10);
                  const isWeekend = [0, 6].includes(date.getDay());
                  return (
                    <div
                      key={day}
                      className={cn(
                        'border-l border-border/60 px-1 py-2 text-center',
                        isWeekend && 'bg-navy-50/60',
                        isToday && 'bg-brand-100/70',
                      )}
                    >
                      <p className="text-[10px] uppercase text-muted-foreground">{date.toLocaleDateString('en-IN', { weekday: 'short' })}</p>
                      <p className={cn('text-xs font-semibold', isToday ? 'text-brand-700' : 'text-navy-800')}>{date.getDate()}</p>
                    </div>
                  );
                })}
              </div>

              {rooms.map((room) => {
                const roomEntries = entriesByRoom.get(room.roomId) ?? [];
                return (
                  <div
                    key={room.roomId}
                    className="grid border-b border-border/60 last:border-0"
                    style={{ gridTemplateColumns: `160px repeat(${span}, minmax(64px, 1fr))` }}
                  >
                    <div className="flex items-center justify-between gap-2 px-3 py-2">
                      <div className="min-w-0">
                        <p className="truncate text-xs font-semibold text-navy-900">{room.roomNumber}</p>
                        <p className="truncate text-[10px] text-muted-foreground">{room.categoryName}</p>
                      </div>
                      <StatusBadge value={room.status} />
                    </div>
                    {days.map((day) => {
                      const cellEntries = roomEntries.filter(
                        (entry) => entry.checkInDate <= day && entry.checkOutDate > day,
                      );
                      const cellKey = `${room.roomId}-${day}`;
                      const isDropTarget = Boolean(dragPayload) && has('booking:write');
                      return (
                        <div
                          key={cellKey}
                          onDragOver={(event) => {
                            if (!isDropTarget) return;
                            event.preventDefault();
                            setHoverCell(cellKey);
                          }}
                          onDragLeave={() => setHoverCell((value) => (value === cellKey ? null : value))}
                          onDrop={(event) => {
                            event.preventDefault();
                            void handleDrop(room.roomId, day);
                          }}
                          className={cn(
                            'relative min-h-[52px] border-l border-border/60 p-0.5 transition-colors',
                            isDropTarget && 'cursor-copy',
                            hoverCell === cellKey && 'bg-brand-100/70 ring-1 ring-inset ring-brand-400',
                          )}
                        >
                          {cellEntries.map((entry) => {
                            const isStart = entry.checkInDate === day;
                            return (
                              <div
                                key={`${entry.segmentId}-${day}`}
                                draggable={has('booking:write') && entry.status !== 'CANCELLED'}
                                onDragStart={() => {
                                  setDragPayload({
                                    bookingId: entry.bookingId,
                                    segmentId: entry.segmentId,
                                    roomId: entry.roomId ?? null,
                                    checkInDate: entry.checkInDate,
                                    checkOutDate: entry.checkOutDate,
                                    guestName: entry.guestName,
                                  });
                                }}
                                onDragEnd={() => setDragPayload(null)}
                                onClick={() => navigate(`/bookings/${entry.bookingId}`)}
                                title={`${entry.guestName} · ${entry.bookingCode} · ${formatDate(entry.checkInDate)} → ${formatDate(entry.checkOutDate)} · ${currency(entry.totalAmount)}`}
                                className={cn(
                                  'group flex h-full cursor-pointer items-center gap-0.5 overflow-hidden rounded border px-1 py-0.5 text-[10px] font-medium',
                                  STATUS_BAR[entry.status] ?? 'bg-muted text-navy-800 border-border',
                                  isStart ? 'rounded-l-md' : 'rounded-l-none border-l-0',
                                )}
                              >
                                {isStart && <GripVertical className="h-2.5 w-2.5 shrink-0 opacity-60" />}
                                <span className="truncate">{isStart ? entry.guestName : ''}</span>
                              </div>
                            );
                          })}
                        </div>
                      );
                    })}
                  </div>
                );
              })}
            </div>
          </div>
        )}
      </Card>

      {unassigned.length > 0 && (
        <Card>
          <div className="flex items-center gap-2 border-b border-border/70 px-4 py-3">
            <Info className="h-4 w-4 text-amber-600" />
            <p className="text-sm font-semibold text-navy-900">Unassigned reservations</p>
            <Badge tone="warning">{unassigned.length}</Badge>
          </div>
          <div className="grid gap-2 p-3 sm:grid-cols-2 lg:grid-cols-3">
            {unassigned.map((entry) => (
              <button
                key={entry.segmentId}
                onClick={() => navigate(`/bookings/${entry.bookingId}`)}
                className="rounded-lg border border-amber-200 bg-amber-50/60 p-2 text-left transition-shadow hover:shadow-card"
              >
                <p className="text-xs font-semibold text-navy-900">{entry.guestName}</p>
                <p className="text-[10px] text-muted-foreground">
                  {entry.bookingCode} · {formatDateShort(entry.checkInDate)} → {formatDateShort(entry.checkOutDate)}
                </p>
                <p className="text-[10px] text-amber-800">{labelize(entry.status)} · assign a room at check-in</p>
              </button>
            ))}
          </div>
        </Card>
      )}
    </div>
  );
};

export default CalendarPage;
