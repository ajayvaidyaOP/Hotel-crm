import { Link, useNavigate, useParams } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import {
  ArrowLeft, BedDouble, Building2, CalendarDays, Clock, Mail, MapPin, Phone, Sparkles, Users, Wallet, Wrench,
} from 'lucide-react';
import { PageHeader } from '@/components/common/PageHeader';
import { StatCard } from '@/components/common/StatCard';
import { EmptyState, ErrorState, TableSkeleton } from '@/components/common/States';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { StatusBadge } from '@/components/ui/badge';
import { ProgressBar, Skeleton } from '@/components/ui/misc';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { dashboardApi, hotelApi, roomApi } from '@/lib/endpoints';
import { getErrorMessage } from '@/lib/api';
import { currency, formatDate, labelize } from '@/lib/format';

const HotelDetailPage = () => {
  const { id } = useParams();
  const hotelId = Number(id);
  const navigate = useNavigate();

  const hotelQuery = useQuery({
    queryKey: ['hotel', hotelId],
    queryFn: () => hotelApi.get(hotelId),
    enabled: Number.isFinite(hotelId),
  });
  const dashboardQuery = useQuery({
    queryKey: ['dashboard', 'hotel', hotelId],
    queryFn: () => dashboardApi.get({ hotelId }),
    enabled: Number.isFinite(hotelId),
  });
  const roomsQuery = useQuery({
    queryKey: ['rooms', 'hotel', hotelId],
    queryFn: () => roomApi.list({ hotelId }),
    enabled: Number.isFinite(hotelId),
  });

  const hotel = hotelQuery.data;
  const dashboard = dashboardQuery.data;
  const rooms = roomsQuery.data ?? [];

  if (hotelQuery.isError) {
    return <Card><ErrorState message={getErrorMessage(hotelQuery.error)} onRetry={() => hotelQuery.refetch()} /></Card>;
  }

  return (
    <div className="space-y-5">
      <div className="flex items-center gap-2">
        <Button variant="ghost" size="sm" onClick={() => navigate('/hotels')}>
          <ArrowLeft className="h-4 w-4" /> All hotels
        </Button>
      </div>

      <Card className="overflow-hidden">
        <div className="relative h-36 bg-gradient-to-br from-navy-900 via-navy-800 to-brand-700">
          {hotel?.imageUrls?.[0] && (
            <img src={hotel.imageUrls[0]} alt={hotel.name} className="h-full w-full object-cover opacity-60" />
          )}
          <div className="absolute inset-0 bg-gradient-to-t from-navy-950/85 to-navy-900/20" />
          <div className="absolute inset-x-0 bottom-0 flex flex-wrap items-end justify-between gap-3 p-5">
            <div>
              {hotelQuery.isLoading ? (
                <Skeleton className="h-7 w-56 bg-white/20" />
              ) : (
                <>
                  <h1 className="text-xl font-semibold text-white">{hotel?.name}</h1>
                  <p className="mt-0.5 flex flex-wrap items-center gap-3 text-[11px] text-navy-200">
                    <span className="flex items-center gap-1"><MapPin className="h-3 w-3" /> {hotel?.city}, {hotel?.state}</span>
                    <span className="flex items-center gap-1"><Building2 className="h-3 w-3" /> {hotel?.code}</span>
                    <span className="flex items-center gap-1"><Clock className="h-3 w-3" /> {hotel?.checkInTime?.slice(0, 5)} check-in · {hotel?.checkOutTime?.slice(0, 5)} check-out</span>
                  </p>
                </>
              )}
            </div>
            <div className="flex items-center gap-2">
              <StatusBadge value={hotel?.status} className="bg-white/90" />
              <Button size="sm" variant="secondary" onClick={() => navigate(`/bookings?new=1&hotelId=${hotelId}`)}>
                <CalendarDays className="h-4 w-4" /> New booking
              </Button>
            </div>
          </div>
        </div>
        <CardContent className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          <InfoRow icon={Phone} label="Contact" value={hotel?.contactNumber ?? '—'} />
          <InfoRow icon={Mail} label="Email" value={hotel?.email ?? '—'} />
          <InfoRow icon={Wallet} label="GSTIN" value={hotel?.gstNumber ?? '—'} />
          <InfoRow icon={Sparkles} label="Tax rate" value={`${hotel?.taxRate ?? 0}% GST`} />
        </CardContent>
      </Card>

      <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard label="Rooms" value={hotel?.roomCount ?? rooms.length} hint={`${dashboard?.availableRooms ?? 0} available now`} icon={BedDouble} tone="brand" />
        <StatCard label="Occupancy" value={`${Number(dashboard?.occupancyPercent ?? 0).toFixed(1)}%`} hint={`${dashboard?.occupiedRooms ?? 0} rooms occupied`} icon={Users} tone="success" />
        <StatCard label="Revenue this month" value={currency(hotel?.revenueThisMonth, true)} hint={`ADR ${currency(dashboard?.adr, true)}`} icon={Wallet} tone="violet" />
        <StatCard label="Active bookings" value={hotel?.activeBookings ?? 0} hint={`${dashboard?.pendingPayments ? currency(dashboard.pendingPayments, true) : '—'} pending payments`} icon={CalendarDays} tone="warning" />
      </div>

      <div className="grid gap-4 xl:grid-cols-3">
        <Card className="xl:col-span-2">
          <CardHeader className="flex-row items-center justify-between">
            <CardTitle>Room inventory</CardTitle>
            <div className="flex gap-2">
              <Button variant="ghost" size="sm" asChild>
                <Link to={`/rooms?hotelId=${hotelId}`}>Manage rooms</Link>
              </Button>
              <Button variant="ghost" size="sm" asChild>
                <Link to={`/housekeeping?hotelId=${hotelId}`}>Housekeeping</Link>
              </Button>
            </div>
          </CardHeader>
          {roomsQuery.isLoading ? (
            <TableSkeleton rows={5} columns={4} />
          ) : rooms.length === 0 ? (
            <EmptyState icon={BedDouble} title="No rooms configured" description="Add room categories and rooms to start taking bookings." action={<Button size="sm" onClick={() => navigate('/rooms')}>Configure rooms</Button>} />
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Room</TableHead>
                  <TableHead>Category</TableHead>
                  <TableHead>Floor</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Housekeeping</TableHead>
                  <TableHead className="text-right">Rate</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {rooms.slice(0, 12).map((room) => (
                  <TableRow key={room.id}>
                    <TableCell className="font-medium text-navy-900">{room.roomNumber}</TableCell>
                    <TableCell className="text-xs">{room.categoryName}</TableCell>
                    <TableCell className="text-xs">{room.floor}</TableCell>
                    <TableCell><StatusBadge value={room.status} /></TableCell>
                    <TableCell><StatusBadge value={room.housekeepingStatus} /></TableCell>
                    <TableCell className="text-right text-xs font-medium">{currency(room.basePrice)}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </Card>

        <div className="space-y-4">
          <Card>
            <CardHeader><CardTitle>Today</CardTitle></CardHeader>
            <CardContent className="space-y-3 pt-0">
              <Metric label="Expected arrivals" value={dashboard?.todayCheckIns ?? 0} />
              <Metric label="Expected departures" value={dashboard?.todayCheckOuts ?? 0} />
              <Metric label="In-house guests" value={dashboard?.inHouseGuests ?? 0} />
              <Metric label="Pending housekeeping" value={dashboard?.pendingHousekeeping ?? 0} />
              <Metric label="Open maintenance" value={dashboard?.openMaintenance ?? 0} />
              <div>
                <div className="mb-1 flex items-center justify-between text-xs">
                  <span className="text-muted-foreground">Occupancy</span>
                  <span className="font-semibold text-navy-900">{Number(dashboard?.occupancyPercent ?? 0).toFixed(1)}%</span>
                </div>
                <ProgressBar value={Number(dashboard?.occupancyPercent ?? 0)} />
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader><CardTitle>Facilities</CardTitle></CardHeader>
            <CardContent className="flex flex-wrap gap-1.5 pt-0">
              {(hotel?.facilities ?? []).length === 0 ? (
                <p className="text-xs text-muted-foreground">No facilities recorded.</p>
              ) : (
                hotel?.facilities.map((facility) => (
                  <span key={facility} className="rounded-full bg-brand-50 px-2.5 py-1 text-[11px] font-medium text-brand-700">
                    {facility}
                  </span>
                ))
              )}
            </CardContent>
          </Card>

          <Card>
            <CardHeader><CardTitle>Quick actions</CardTitle></CardHeader>
            <CardContent className="grid grid-cols-2 gap-2 pt-0">
              <Button variant="outline" size="sm" asChild><Link to={`/bookings?hotelId=${hotelId}`}>Bookings</Link></Button>
              <Button variant="outline" size="sm" asChild><Link to={`/guests`}>Guests</Link></Button>
              <Button variant="outline" size="sm" asChild><Link to={`/invoices?hotelId=${hotelId}`}>Invoices</Link></Button>
              <Button variant="outline" size="sm" asChild><Link to={`/reports?hotelId=${hotelId}`}>Reports</Link></Button>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
};

const InfoRow = ({ icon: Icon, label, value }: { icon: typeof Phone; label: string; value: string }) => (
  <div className="flex items-start gap-2">
    <Icon className="mt-0.5 h-4 w-4 text-muted-foreground" />
    <div className="min-w-0">
      <p className="text-[11px] uppercase tracking-wide text-muted-foreground">{label}</p>
      <p className="truncate text-sm font-medium text-navy-900">{value}</p>
    </div>
  </div>
);

const Metric = ({ label, value }: { label: string; value: number | string }) => (
  <div className="flex items-center justify-between text-sm">
    <span className="text-muted-foreground">{label}</span>
    <span className="font-semibold text-navy-900">{value}</span>
  </div>
);

export default HotelDetailPage;
