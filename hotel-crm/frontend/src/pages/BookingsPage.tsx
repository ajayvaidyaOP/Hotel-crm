import { useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import {
  CalendarPlus, CheckCircle2, Eye, FileText, LogIn, LogOut, MoreHorizontal, Plus, Search, XCircle,
} from 'lucide-react';
import { toast } from 'sonner';
import { PageHeader } from '@/components/common/PageHeader';
import { EmptyState, ErrorState, TableSkeleton } from '@/components/common/States';
import { ClearFilters, FilterSelect, SearchInput, TableToolbar } from '@/components/common/TableToolbar';
import { Pagination } from '@/components/common/Pagination';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { Badge, StatusBadge } from '@/components/ui/badge';
import { Select } from '@/components/ui/input';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import {
  DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuLabel, DropdownMenuSeparator, DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { NewBookingDialog } from '@/components/bookings/NewBookingDialog';
import { CancelBookingDialog, CheckInDialog, CheckOutDialog } from '@/components/bookings/BookingActionDialogs';
import { useHotelScope } from '@/context/HotelContext';
import { useAuth } from '@/context/AuthContext';
import { bookingApi } from '@/lib/endpoints';
import { getErrorMessage, openPdf } from '@/lib/api';
import { currency, formatDate, labelize } from '@/lib/format';
import type { BookingSummary } from '@/lib/types';

const BOOKING_STATUSES = ['PENDING', 'CONFIRMED', 'CHECKED_IN', 'CHECKED_OUT', 'CANCELLED', 'NO_SHOW'];
const PAYMENT_STATUSES = ['UNPAID', 'PARTIALLY_PAID', 'PAID', 'REFUNDED'];
const SOURCES = ['DIRECT', 'WALK_IN', 'PHONE', 'WEBSITE', 'OTA', 'AGENT', 'CORPORATE'];

const BookingsPage = () => {
  const { hotelId, hotel, hotels, setHotelId, isGroupView } = useHotelScope();
  const { has } = useAuth();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [params, setParams] = useSearchParams();

  const [tab, setTab] = useState(params.get('tab') ?? 'list');
  const [search, setSearch] = useState('');
  const [statusFilter, setStatusFilter] = useState('');
  const [paymentFilter, setPaymentFilter] = useState('');
  const [sourceFilter, setSourceFilter] = useState('');
  const [range, setRange] = useState({ from: '', to: '' });
  const [page, setPage] = useState(0);
  const [size, setSize] = useState(20);

  const [newDialog, setNewDialog] = useState(params.get('new') === '1');
  const [checkInTarget, setCheckInTarget] = useState<BookingSummary | null>(null);
  const [checkOutTarget, setCheckOutTarget] = useState<BookingSummary | null>(null);
  const [cancelTarget, setCancelTarget] = useState<BookingSummary | null>(null);

  useEffect(() => {
    if (params.get('new') === '1') setNewDialog(true);
  }, [params]);

  const listQuery = useQuery({
    queryKey: ['bookings', { hotelId, statusFilter, paymentFilter, sourceFilter, range, search, page, size }],
    queryFn: () =>
      bookingApi.list({
        hotelId: isGroupView ? undefined : hotelId ?? undefined,
        status: statusFilter || undefined,
        paymentStatus: paymentFilter || undefined,
        source: sourceFilter || undefined,
        from: range.from || undefined,
        to: range.to || undefined,
        search: search.trim() || undefined,
        page,
        size,
      }),
  });

  const opsQuery = useQuery({
    queryKey: ['bookings', 'day-operations', hotelId],
    queryFn: () => bookingApi.dayOperations({ hotelId: isGroupView ? undefined : hotelId ?? undefined }),
    enabled: tab === 'today',
  });

  const invalidate = () => {
    queryClient.invalidateQueries({ queryKey: ['bookings'] });
    queryClient.invalidateQueries({ queryKey: ['dashboard'] });
    queryClient.invalidateQueries({ queryKey: ['payments'] });
    queryClient.invalidateQueries({ queryKey: ['invoices'] });
  };

  const cancelMutation = useMutation({
    mutationFn: ({ id, reason, refundAmount, refundMethod }: { id: number; reason: string; refundAmount?: number; refundMethod?: string }) =>
      bookingApi.cancel(id, { reason, refundAmount, refundMethod }),
    onSuccess: () => {
      toast.success('Booking cancelled');
      setCancelTarget(null);
      invalidate();
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  const checkInMutation = useMutation({
    mutationFn: ({ id, payload }: { id: number; payload: Record<string, unknown> }) => bookingApi.checkIn(id, payload),
    onSuccess: () => {
      toast.success('Guest checked in');
      setCheckInTarget(null);
      invalidate();
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  const checkOutMutation = useMutation({
    mutationFn: ({ id, payload }: { id: number; payload: Record<string, unknown> }) => bookingApi.checkOut(id, payload),
    onSuccess: () => {
      toast.success('Guest checked out · invoice generated');
      setCheckOutTarget(null);
      invalidate();
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  const rows = listQuery.data?.content ?? [];

  const closeNewDialog = () => {
    setNewDialog(false);
    if (params.get('new')) {
      params.delete('new');
      setParams(params, { replace: true });
    }
  };

  return (
    <div className="space-y-5">
      <PageHeader
        title="Bookings"
        description={
          isGroupView
            ? 'Reservations across every property you can access'
            : `${hotel?.name ?? 'Hotel'} · reservations and front-desk operations`
        }
        actions={
          <>
            <Select
              value={hotelId ?? ''}
              onChange={(event) => setHotelId(Number(event.target.value))}
              className="h-9 w-full sm:w-52"
              aria-label="Hotel"
            >
              {hotels.map((item) => (
                <option key={item.id} value={item.id}>{item.name}</option>
              ))}
            </Select>
            <Button variant="outline" size="sm" onClick={() => navigate('/calendar')}>
              <CalendarPlus className="h-4 w-4" /> Calendar
            </Button>
            {has('booking:write') && (
              <Button size="sm" onClick={() => setNewDialog(true)}>
                <Plus className="h-4 w-4" /> New booking
              </Button>
            )}
          </>
        }
      />

      <Tabs value={tab} onValueChange={setTab}>
        <TabsList>
          <TabsTrigger value="list">All bookings</TabsTrigger>
          <TabsTrigger value="today">Today&apos;s operations</TabsTrigger>
        </TabsList>

        <TabsContent value="list">
          <Card>
            <TableToolbar>
              <div className="flex flex-1 flex-wrap items-center gap-2">
                <SearchInput value={search} onChange={setSearch} placeholder="Search code, guest, mobile…" />
                <FilterSelect
                  value={statusFilter}
                  onChange={setStatusFilter}
                  placeholder="All statuses"
                  options={BOOKING_STATUSES.map((status) => ({ value: status, label: labelize(status) }))}
                />
                <FilterSelect
                  value={paymentFilter}
                  onChange={setPaymentFilter}
                  placeholder="All payments"
                  options={PAYMENT_STATUSES.map((status) => ({ value: status, label: labelize(status) }))}
                />
                <FilterSelect
                  value={sourceFilter}
                  onChange={setSourceFilter}
                  placeholder="All sources"
                  options={SOURCES.map((source) => ({ value: source, label: labelize(source) }))}
                />
                <div className="flex items-center gap-1.5 rounded-lg border border-input px-2 py-1">
                  <input
                    type="date"
                    value={range.from}
                    onChange={(event) => setRange({ ...range, from: event.target.value })}
                    className="bg-transparent text-xs text-navy-800 focus:outline-none"
                    aria-label="Stay from"
                  />
                  <span className="text-xs text-muted-foreground">→</span>
                  <input
                    type="date"
                    value={range.to}
                    onChange={(event) => setRange({ ...range, to: event.target.value })}
                    className="bg-transparent text-xs text-navy-800 focus:outline-none"
                    aria-label="Stay to"
                  />
                </div>
                <ClearFilters
                  visible={Boolean(statusFilter || paymentFilter || sourceFilter || search || range.from || range.to)}
                  onClick={() => {
                    setStatusFilter('');
                    setPaymentFilter('');
                    setSourceFilter('');
                    setSearch('');
                    setRange({ from: '', to: '' });
                    setPage(0);
                  }}
                />
              </div>
              <p className="text-xs text-muted-foreground">{listQuery.data?.totalElements ?? 0} bookings</p>
            </TableToolbar>

            {listQuery.isError ? (
              <ErrorState message={getErrorMessage(listQuery.error)} onRetry={() => listQuery.refetch()} />
            ) : listQuery.isLoading ? (
              <TableSkeleton rows={8} columns={6} />
            ) : rows.length === 0 ? (
              <EmptyState
                title="No bookings found"
                description="Adjust the filters or create a new reservation."
                icon={Search}
                action={has('booking:write') ? <Button size="sm" onClick={() => setNewDialog(true)}><Plus className="h-4 w-4" /> New booking</Button> : undefined}
              />
            ) : (
              <>
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Booking</TableHead>
                      <TableHead>Guest</TableHead>
                      {isGroupView && <TableHead>Hotel</TableHead>}
                      <TableHead>Stay</TableHead>
                      <TableHead>Rooms</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead>Payment</TableHead>
                      <TableHead className="text-right">Total</TableHead>
                      <TableHead className="text-right">Pending</TableHead>
                      <TableHead className="text-right">Actions</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {rows.map((booking) => (
                      <TableRow key={booking.id}>
                        <TableCell>
                          <button onClick={() => navigate(`/bookings/${booking.id}`)} className="text-left">
                            <p className="font-medium text-brand-700 hover:underline">{booking.bookingCode}</p>
                            <p className="text-[11px] text-muted-foreground">{labelize(booking.bookingSource)}</p>
                          </button>
                        </TableCell>
                        <TableCell>
                          <p className="font-medium text-navy-900">{booking.guestName}</p>
                          <p className="text-[11px] text-muted-foreground">{booking.guestMobile}</p>
                        </TableCell>
                        {isGroupView && <TableCell className="text-xs">{booking.hotelName}</TableCell>}
                        <TableCell className="text-xs text-navy-700">
                          {formatDate(booking.checkInDate)}
                          <span className="block text-[11px] text-muted-foreground">
                            {booking.nights} nights · {booking.adults}A{booking.children > 0 ? ` ${booking.children}C` : ''}
                          </span>
                        </TableCell>
                        <TableCell className="text-xs">{booking.roomNumbers.join(', ') || 'TBA'}</TableCell>
                        <TableCell><StatusBadge value={booking.status} /></TableCell>
                        <TableCell><StatusBadge value={booking.paymentStatus} /></TableCell>
                        <TableCell className="text-right text-xs font-medium">{currency(booking.totalAmount)}</TableCell>
                        <TableCell className="text-right text-xs font-medium text-amber-700">{currency(booking.pendingAmount)}</TableCell>
                        <TableCell className="text-right">
                          <DropdownMenu>
                            <DropdownMenuTrigger asChild>
                              <Button variant="ghost" size="icon-sm" aria-label="Booking actions">
                                <MoreHorizontal className="h-4 w-4" />
                              </Button>
                            </DropdownMenuTrigger>
                            <DropdownMenuContent align="end" className="w-52">
                              <DropdownMenuLabel>{booking.bookingCode}</DropdownMenuLabel>
                              <DropdownMenuItem onSelect={() => navigate(`/bookings/${booking.id}`)}>
                                <Eye className="h-4 w-4" /> Open booking
                              </DropdownMenuItem>
                              {has('checkin:write') && ['CONFIRMED', 'PENDING'].includes(booking.status) && (
                                <DropdownMenuItem onSelect={() => setCheckInTarget(booking)}>
                                  <LogIn className="h-4 w-4" /> Check in
                                </DropdownMenuItem>
                              )}
                              {has('checkout:write') && booking.status === 'CHECKED_IN' && (
                                <DropdownMenuItem onSelect={() => setCheckOutTarget(booking)}>
                                  <LogOut className="h-4 w-4" /> Check out
                                </DropdownMenuItem>
                              )}
                              <DropdownMenuItem
                                onSelect={() =>
                                  void openPdf(`/bookings/${booking.id}/receipt.pdf`).catch((err) => toast.error(getErrorMessage(err)))
                                }
                              >
                                <FileText className="h-4 w-4" /> Receipt PDF
                              </DropdownMenuItem>
                              {has('booking:cancel') && !['CANCELLED', 'CHECKED_OUT'].includes(booking.status) && (
                                <>
                                  <DropdownMenuSeparator />
                                  <DropdownMenuItem destructive onSelect={() => setCancelTarget(booking)}>
                                    <XCircle className="h-4 w-4" /> Cancel booking
                                  </DropdownMenuItem>
                                </>
                              )}
                            </DropdownMenuContent>
                          </DropdownMenu>
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
                  onSizeChange={(value) => {
                    setSize(value);
                    setPage(0);
                  }}
                />
              </>
            )}
          </Card>
        </TabsContent>

        <TabsContent value="today">
          {opsQuery.isError ? (
            <Card><ErrorState message={getErrorMessage(opsQuery.error)} onRetry={() => opsQuery.refetch()} /></Card>
          ) : (
            <div className="grid gap-4 xl:grid-cols-3">
              <OpsColumn
                title="Arrivals"
                description="Guests due to check in"
                bookings={opsQuery.data?.arrivals ?? []}
                loading={opsQuery.isLoading}
                actionLabel="Check in"
                onAction={has('checkin:write') ? (booking) => setCheckInTarget(booking) : undefined}
                onOpen={(booking) => navigate(`/bookings/${booking.id}`)}
              />
              <OpsColumn
                title="Departures"
                description="Guests due to check out"
                bookings={opsQuery.data?.departures ?? []}
                loading={opsQuery.isLoading}
                actionLabel="Check out"
                onAction={has('checkout:write') ? (booking) => setCheckOutTarget(booking) : undefined}
                onOpen={(booking) => navigate(`/bookings/${booking.id}`)}
              />
              <OpsColumn
                title="In-house"
                description="Currently staying"
                bookings={opsQuery.data?.inHouse ?? []}
                loading={opsQuery.isLoading}
                onOpen={(booking) => navigate(`/bookings/${booking.id}`)}
              />
            </div>
          )}
        </TabsContent>
      </Tabs>

      <NewBookingDialog
        open={newDialog}
        onClose={closeNewDialog}
        defaultHotelId={hotelId}
        onCreated={(bookingId) => {
          invalidate();
          closeNewDialog();
          navigate(`/bookings/${bookingId}`);
        }}
      />

      <CheckInDialog
        booking={checkInTarget}
        onClose={() => setCheckInTarget(null)}
        onSubmit={(payload) => checkInTarget && checkInMutation.mutate({ id: checkInTarget.id, payload })}
        loading={checkInMutation.isPending}
      />

      <CheckOutDialog
        booking={checkOutTarget}
        onClose={() => setCheckOutTarget(null)}
        onSubmit={(payload) => checkOutTarget && checkOutMutation.mutate({ id: checkOutTarget.id, payload })}
        loading={checkOutMutation.isPending}
      />

      <CancelBookingDialog
        booking={cancelTarget}
        onClose={() => setCancelTarget(null)}
        onSubmit={(payload) => cancelTarget && cancelMutation.mutate({ id: cancelTarget.id, ...payload })}
        loading={cancelMutation.isPending}
      />
    </div>
  );
};

const OpsColumn = ({
  title,
  description,
  bookings,
  loading,
  actionLabel,
  onAction,
  onOpen,
}: {
  title: string;
  description: string;
  bookings: BookingSummary[];
  loading: boolean;
  actionLabel?: string;
  onAction?: (booking: BookingSummary) => void;
  onOpen: (booking: BookingSummary) => void;
}) => (
  <Card>
    <div className="flex items-center justify-between border-b border-border/70 px-4 py-3">
      <div>
        <p className="text-sm font-semibold text-navy-900">{title}</p>
        <p className="text-[11px] text-muted-foreground">{description}</p>
      </div>
      <Badge tone="info">{bookings.length}</Badge>
    </div>
    {loading ? (
      <TableSkeleton rows={4} columns={2} />
    ) : bookings.length === 0 ? (
      <EmptyState title={`No ${title.toLowerCase()} today`} icon={CheckCircle2} />
    ) : (
      <CardContent className="space-y-2 pt-3">
        {bookings.map((booking) => (
          <div key={booking.id} className="rounded-lg border border-border p-3 transition-shadow hover:shadow-card">
            <div className="flex items-start justify-between gap-2">
              <button onClick={() => onOpen(booking)} className="min-w-0 text-left">
                <p className="truncate text-sm font-medium text-navy-900">{booking.guestName}</p>
                <p className="truncate text-[11px] text-muted-foreground">
                  {booking.bookingCode} · {booking.roomNumbers.join(', ') || 'Room TBA'}
                </p>
              </button>
              <StatusBadge value={booking.status} />
            </div>
            <div className="mt-2 flex items-center justify-between">
              <p className="text-[11px] text-muted-foreground">
                {formatDate(booking.checkInDate)} → {formatDate(booking.checkOutDate)}
              </p>
              <div className="flex items-center gap-1">
                <span className="text-[11px] font-medium text-amber-700">{currency(booking.pendingAmount)} due</span>
                {onAction && actionLabel && (
                  <Button size="sm" variant="outline" onClick={() => onAction(booking)}>
                    {actionLabel}
                  </Button>
                )}
              </div>
            </div>
          </div>
        ))}
      </CardContent>
    )}
  </Card>
);

export default BookingsPage;
