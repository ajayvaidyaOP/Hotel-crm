import { useMemo, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import {
  Area, AreaChart, Bar, CartesianGrid, Cell, ComposedChart, Legend, Line, Pie, PieChart,
  ResponsiveContainer, Tooltip, XAxis, YAxis,
} from 'recharts';
import {
  ArrowRight, BedDouble, CalendarCheck2, CalendarPlus, CircleDollarSign, ClipboardCheck, DoorOpen,
  IndianRupee, Percent, RefreshCw, Sparkles, TrendingUp, Users, Wallet, Wrench,
} from 'lucide-react';
import { PageHeader } from '@/components/common/PageHeader';
import { StatCard } from '@/components/common/StatCard';
import { ChartCard } from '@/components/common/ChartCard';
import { ChartSkeleton, EmptyState, ErrorState, TableSkeleton } from '@/components/common/States';
import { DateRangeFilter } from '@/components/common/DateRangeFilter';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { StatusBadge, Badge } from '@/components/ui/badge';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { ProgressBar } from '@/components/ui/misc';
import { useHotelScope } from '@/context/HotelContext';
import { useAuth } from '@/context/AuthContext';
import { dashboardApi } from '@/lib/endpoints';
import { getErrorMessage } from '@/lib/api';
import { currency, formatDateShort, labelize, relativeTime } from '@/lib/format';
import { addDaysISO, cn } from '@/lib/utils';

const STATUS_COLORS: Record<string, string> = {
  AVAILABLE: '#10b981',
  OCCUPIED: '#1a5cf5',
  CLEANING: '#f59e0b',
  MAINTENANCE: '#ef4444',
  OUT_OF_SERVICE: '#64748b',
  RESERVED: '#8b5cf6',
};

const PIE_COLORS = ['#1a5cf5', '#0ea5e9', '#8b5cf6', '#f59e0b', '#10b981', '#ef4444', '#64748b'];

const DashboardPage = () => {
  const { hotelId, isGroupView, hotels } = useHotelScope();
  const { user, has } = useAuth();
  const navigate = useNavigate();
  const [range, setRange] = useState({ from: addDaysISO(-29), to: addDaysISO(0) });

  const params = { hotelId: isGroupView ? undefined : hotelId ?? undefined, from: range.from, to: range.to };
  const { data, isLoading, isError, error, refetch, isFetching } = useQuery({
    queryKey: ['dashboard', params],
    queryFn: () => dashboardApi.get(params as Record<string, unknown>),
  });

  const trend = useMemo(
    () =>
      (data?.revenueTrend ?? []).map((point) => ({
        ...point,
        revenue: Number(point.revenue ?? 0),
        occupancyPercent: Number(point.occupancyPercent ?? 0),
      })),
    [data?.revenueTrend],
  );

  const roomStatus = (data?.roomStatusBreakdown ?? []).filter((item) => item.value > 0);
  const paymentMix = (data?.paymentMethodBreakdown ?? []).filter((item) => item.value > 0);

  if (isError) {
    return (
      <div className="space-y-4">
        <PageHeader title="Dashboard" description="Centralised view of group performance" />
        <Card>
          <ErrorState message={getErrorMessage(error)} onRetry={() => refetch()} />
        </Card>
      </div>
    );
  }

  const totalRooms = Number(data?.totalRooms ?? 0);
  const occupancy = Number(data?.occupancyPercent ?? 0);
  const availableRooms = Number(data?.availableRooms ?? 0);

  return (
    <div className="space-y-5">
      <PageHeader
        title={`Good ${greeting()}, ${user?.fullName.split(' ')[0] ?? 'there'}`}
        description={
          isGroupView
            ? `Group overview across ${data?.hotelCount ?? hotels.length} hotels · ${range.from} → ${range.to}`
            : `${data?.hotels?.[0]?.hotelName ?? 'Hotel'} · ${range.from} → ${range.to}`
        }
        actions={
          <>
            <DateRangeFilter from={range.from} to={range.to} onChange={setRange} compact />
            <Button variant="outline" size="sm" onClick={() => refetch()} loading={isFetching}>
              <RefreshCw className="h-4 w-4" /> Refresh
            </Button>
            {has('booking:write') && (
              <Button size="sm" onClick={() => navigate('/bookings?new=1')}>
                <CalendarPlus className="h-4 w-4" /> New booking
              </Button>
            )}
          </>
        }
      />

      <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
        {isLoading ? (
          Array.from({ length: 4 }).map((_, index) => <div key={index} className="surface h-[112px] animate-pulse" />)
        ) : (
          <>
            <StatCard
              label="Revenue this month"
              value={currency(data?.monthlyRevenue, true)}
              hint={`Today ${currency(data?.todayRevenue, true)} · Year ${currency(data?.yearlyRevenue, true)}`}
              icon={IndianRupee}
              tone="success"
            />
            <StatCard
              label="Occupancy"
              value={`${occupancy.toFixed(1)}%`}
              hint={`${Number(data?.occupiedRooms ?? 0)} of ${totalRooms} rooms occupied`}
              icon={Percent}
              tone="brand"
            />
            <StatCard
              label="ADR / RevPAR"
              value={`${currency(data?.adr, true)} / ${currency(data?.revpar, true)}`}
              hint={`Net of refunds · ${currency(data?.serviceRevenueMonth, true)} services`}
              icon={TrendingUp}
              tone="violet"
            />
            <StatCard
              label="Pending payments"
              value={currency(data?.pendingPayments, true)}
              hint={`${Number(data?.outstandingInvoices ?? 0)} invoices awaiting settlement`}
              icon={Wallet}
              tone="warning"
              onClick={() => navigate('/payments?tab=pending')}
            />
          </>
        )}
      </div>

      <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6">
        <MiniStat icon={CalendarCheck2} label="Arrivals today" value={data?.todayCheckIns ?? 0} tone="brand" onClick={() => navigate('/bookings?tab=today')} />
        <MiniStat icon={DoorOpen} label="Departures today" value={data?.todayCheckOuts ?? 0} tone="navy" onClick={() => navigate('/bookings?tab=today')} />
        <MiniStat icon={Users} label="In-house guests" value={data?.inHouseGuests ?? 0} tone="success" />
        <MiniStat icon={BedDouble} label="Rooms available" value={`${availableRooms}/${totalRooms}`} tone="success" onClick={() => navigate('/rooms')} />
        <MiniStat icon={Sparkles} label="Pending housekeeping" value={data?.pendingHousekeeping ?? 0} tone="warning" onClick={() => navigate('/housekeeping')} />
        <MiniStat icon={Wrench} label="Open maintenance" value={data?.openMaintenance ?? 0} tone="danger" onClick={() => navigate('/housekeeping?tab=maintenance')} />
      </div>

      <div className="grid gap-4 xl:grid-cols-3">
        <ChartCard
          title="Revenue & bookings trend"
          description={isGroupView ? 'All accessible hotels' : 'Selected hotel'}
          className="xl:col-span-2"
          contentClassName="pt-2"
        >
          {isLoading ? (
            <ChartSkeleton />
          ) : trend.length === 0 ? (
            <EmptyState title="No revenue recorded in this period" description="Try a wider date range." />
          ) : (
            <ResponsiveContainer width="100%" height={286}>
              <AreaChart data={trend} margin={{ left: 4, right: 8, top: 8 }}>
                <defs>
                  <linearGradient id="revenueGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#1a5cf5" stopOpacity={0.35} />
                    <stop offset="95%" stopColor="#1a5cf5" stopOpacity={0.02} />
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" vertical={false} />
                <XAxis dataKey="label" tick={{ fontSize: 11, fill: '#64748b' }} axisLine={false} tickLine={false} />
                <YAxis
                  tick={{ fontSize: 11, fill: '#64748b' }}
                  axisLine={false}
                  tickLine={false}
                  tickFormatter={(value) => `₹${Math.round(Number(value) / 1000)}k`}
                  width={48}
                />
                <Tooltip
                  contentStyle={{ borderRadius: 10, border: '1px solid #e2e8f0', fontSize: 12 }}
                  formatter={(value: number, name) =>
                    name === 'revenue' ? [currency(value), 'Revenue'] : [value, labelize(String(name))]
                  }
                />
                <Area type="monotone" dataKey="revenue" stroke="#1a5cf5" strokeWidth={2} fill="url(#revenueGradient)" />
              </AreaChart>
            </ResponsiveContainer>
          )}
        </ChartCard>

        <ChartCard title="Room status" description={`${totalRooms} rooms across the scope`}>
          {isLoading ? (
            <ChartSkeleton />
          ) : roomStatus.length === 0 ? (
            <EmptyState title="No rooms to display" />
          ) : (
            <div className="flex flex-col items-center">
              <ResponsiveContainer width="100%" height={210}>
                <PieChart>
                  <Pie
                    data={roomStatus}
                    dataKey="value"
                    nameKey="name"
                    innerRadius={58}
                    outerRadius={84}
                    paddingAngle={2}
                    strokeWidth={0}
                  >
                    {roomStatus.map((entry) => (
                      <Cell key={entry.name} fill={STATUS_COLORS[entry.name] ?? '#94a3b8'} />
                    ))}
                  </Pie>
                  <Tooltip
                    contentStyle={{ borderRadius: 10, border: '1px solid #e2e8f0', fontSize: 12 }}
                    formatter={(value: number, name) => [value, labelize(String(name))]}
                  />
                </PieChart>
              </ResponsiveContainer>
              <div className="grid w-full grid-cols-2 gap-1.5">
                {roomStatus.map((entry) => (
                  <div key={entry.name} className="flex items-center justify-between rounded-md bg-muted/60 px-2 py-1">
                    <span className="flex items-center gap-1.5 text-[11px] text-navy-700">
                      <span className="h-2 w-2 rounded-full" style={{ background: STATUS_COLORS[entry.name] ?? '#94a3b8' }} />
                      {labelize(entry.name)}
                    </span>
                    <span className="text-[11px] font-semibold text-navy-900">{entry.value}</span>
                  </div>
                ))}
              </div>
              <div className="mt-3 w-full">
                <div className="mb-1 flex items-center justify-between text-[11px] text-muted-foreground">
                  <span>Occupancy</span>
                  <span className="font-semibold text-navy-800">{occupancy.toFixed(1)}%</span>
                </div>
                <ProgressBar value={occupancy} tone={occupancy > 80 ? 'success' : occupancy > 45 ? 'brand' : 'warning'} />
              </div>
            </div>
          )}
        </ChartCard>
      </div>

      <div className="grid gap-4 xl:grid-cols-3">
        <ChartCard
          title="Hotel comparison"
          description="Revenue this month vs occupancy"
          className="xl:col-span-2"
          action={
            <Button variant="ghost" size="sm" asChild>
              <Link to="/reports">
                Reports <ArrowRight className="h-3.5 w-3.5" />
              </Link>
            </Button>
          }
        >
          {isLoading ? (
            <ChartSkeleton />
          ) : (data?.hotels?.length ?? 0) === 0 ? (
            <EmptyState title="No hotels in scope" />
          ) : (
            <ResponsiveContainer width="100%" height={252}>
              <ComposedChart data={data?.hotels ?? []} margin={{ left: 4, right: 8, top: 8 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" vertical={false} />
                <XAxis dataKey="hotelName" tick={{ fontSize: 10, fill: '#64748b' }} axisLine={false} tickLine={false} interval={0} />
                <YAxis
                  yAxisId="left"
                  tick={{ fontSize: 11, fill: '#64748b' }}
                  axisLine={false}
                  tickLine={false}
                  tickFormatter={(value) => `₹${Math.round(Number(value) / 1000)}k`}
                  width={46}
                />
                <YAxis
                  yAxisId="right"
                  orientation="right"
                  tick={{ fontSize: 11, fill: '#64748b' }}
                  axisLine={false}
                  tickLine={false}
                  unit="%"
                  width={38}
                />
                <Tooltip
                  contentStyle={{ borderRadius: 10, border: '1px solid #e2e8f0', fontSize: 12 }}
                  formatter={(value: number, name) =>
                    name === 'revenueThisMonth' ? [currency(value), 'Revenue'] : [`${value}%`, 'Occupancy']
                  }
                />
                <Legend wrapperStyle={{ fontSize: 11 }} />
                <Bar yAxisId="left" dataKey="revenueThisMonth" name="Revenue" fill="#1a5cf5" radius={[6, 6, 0, 0]} maxBarSize={42} />
                <Line yAxisId="right" type="monotone" dataKey="occupancyPercent" name="Occupancy" stroke="#f59e0b" strokeWidth={2} dot={{ r: 3 }} />
              </ComposedChart>
            </ResponsiveContainer>
          )}
        </ChartCard>

        <ChartCard title="Payment mix" description="Collections by method (period)">
          {isLoading ? (
            <ChartSkeleton />
          ) : paymentMix.length === 0 ? (
            <EmptyState title="No payments in this period" />
          ) : (
            <div className="space-y-2.5">
              {paymentMix.map((entry, index) => {
                const total = paymentMix.reduce((sum, item) => sum + Number(item.value), 0) || 1;
                const share = (Number(entry.value) / total) * 100;
                return (
                  <div key={entry.name}>
                    <div className="mb-1 flex items-center justify-between text-xs">
                      <span className="font-medium text-navy-800">{labelize(entry.name)}</span>
                      <span className="text-muted-foreground">
                        {currency(entry.value, true)} · {share.toFixed(0)}%
                      </span>
                    </div>
                    <div className="h-2 w-full overflow-hidden rounded-full bg-muted">
                      <div
                        className="h-full rounded-full"
                        style={{ width: `${share}%`, background: PIE_COLORS[index % PIE_COLORS.length] }}
                      />
                    </div>
                  </div>
                );
              })}
              <div className="mt-4 rounded-lg bg-muted/60 p-3">
                <p className="text-[11px] uppercase tracking-wide text-muted-foreground">Booking sources</p>
                <div className="mt-2 space-y-1">
                  {(data?.bookingSourceBreakdown ?? []).slice(0, 4).map((source) => (
                    <div key={source.name} className="flex items-center justify-between text-xs">
                      <span className="text-navy-700">{labelize(source.name)}</span>
                      <span className="font-medium text-navy-900">{source.count} bookings</span>
                    </div>
                  ))}
                  {(data?.bookingSourceBreakdown ?? []).length === 0 && (
                    <p className="text-xs text-muted-foreground">No bookings recorded yet.</p>
                  )}
                </div>
              </div>
            </div>
          )}
        </ChartCard>
      </div>

      <div className="grid gap-4 xl:grid-cols-3">
        <Card className="xl:col-span-2">
          <CardHeader className="flex-row items-center justify-between">
            <CardTitle>Upcoming arrivals</CardTitle>
            <Button variant="ghost" size="sm" asChild>
              <Link to="/bookings">
                All bookings <ArrowRight className="h-3.5 w-3.5" />
              </Link>
            </Button>
          </CardHeader>
          {isLoading ? (
            <TableSkeleton rows={4} columns={4} />
          ) : (data?.upcomingCheckIns?.length ?? 0) === 0 ? (
            <EmptyState title="No upcoming arrivals" description="New reservations will appear here." icon={CalendarCheck2} />
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Guest</TableHead>
                  <TableHead>Stay</TableHead>
                  <TableHead>Rooms</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead className="text-right">Payment</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {data?.upcomingCheckIns.map((booking) => (
                  <TableRow key={booking.id} className="cursor-pointer" onClick={() => navigate(`/bookings/${booking.id}`)}>
                    <TableCell>
                      <p className="font-medium text-navy-900">{booking.guestName}</p>
                      <p className="text-xs text-muted-foreground">{booking.bookingCode} · {booking.guestMobile}</p>
                    </TableCell>
                    <TableCell className="text-xs text-navy-700">
                      {formatDateShort(booking.checkInDate)} → {formatDateShort(booking.checkOutDate)}
                    </TableCell>
                    <TableCell className="text-xs">{booking.rooms}</TableCell>
                    <TableCell><StatusBadge value={booking.status} /></TableCell>
                    <TableCell className="text-right"><StatusBadge value={booking.paymentStatus} /></TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Recent activity</CardTitle>
          </CardHeader>
          {isLoading ? (
            <TableSkeleton rows={5} columns={2} />
          ) : (data?.recentActivities?.length ?? 0) === 0 ? (
            <EmptyState title="No activity yet" icon={ClipboardCheck} />
          ) : (
            <CardContent className="space-y-3 pt-0">
              {data?.recentActivities.slice(0, 7).map((activity, index) => (
                <div key={`${activity.at}-${index}`} className="flex gap-3">
                  <div className="mt-1 flex flex-col items-center">
                    <span className="h-2 w-2 rounded-full bg-brand-500" />
                    {index < 6 && <span className="mt-1 h-full w-px flex-1 bg-border" />}
                  </div>
                  <div className="min-w-0 pb-1">
                    <p className="truncate text-xs font-medium text-navy-900">{labelize(activity.action)}</p>
                    <p className="line-clamp-2 text-[11px] text-muted-foreground">{activity.description ?? activity.hotelName}</p>
                    <p className="mt-0.5 text-[10px] text-muted-foreground">
                      {activity.actor ?? 'system'} · {relativeTime(activity.at)}
                    </p>
                  </div>
                </div>
              ))}
            </CardContent>
          )}
        </Card>
      </div>

      {isGroupView && (data?.hotels?.length ?? 0) > 0 && (
        <Card>
          <CardHeader className="flex-row items-center justify-between">
            <CardTitle>Hotel performance snapshot</CardTitle>
            <Badge tone="info">{data?.hotels.length} properties</Badge>
          </CardHeader>
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Hotel</TableHead>
                <TableHead>Rooms</TableHead>
                <TableHead>Available</TableHead>
                <TableHead>Occupancy</TableHead>
                <TableHead>ADR</TableHead>
                <TableHead className="text-right">Revenue (month)</TableHead>
                <TableHead className="text-right">Pending</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {data?.hotels.map((hotel) => (
                <TableRow key={hotel.hotelId} className="cursor-pointer" onClick={() => navigate(`/hotels/${hotel.hotelId}`)}>
                  <TableCell className="font-medium text-navy-900">{hotel.hotelName}</TableCell>
                  <TableCell>{hotel.totalRooms}</TableCell>
                  <TableCell>{hotel.availableRooms}</TableCell>
                  <TableCell>
                    <div className="flex items-center gap-2">
                      <span className="w-10 text-xs font-medium">{Number(hotel.occupancyPercent).toFixed(0)}%</span>
                      <ProgressBar
                        value={Number(hotel.occupancyPercent)}
                        className="w-16"
                        tone={Number(hotel.occupancyPercent) > 75 ? 'success' : 'brand'}
                      />
                    </div>
                  </TableCell>
                  <TableCell>{currency(hotel.adr, true)}</TableCell>
                  <TableCell className="text-right font-medium">{currency(hotel.revenueThisMonth)}</TableCell>
                  <TableCell className={cn('text-right', Number(hotel.pendingPayments) > 0 && 'text-amber-600')}>
                    {currency(hotel.pendingPayments)}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </Card>
      )}
    </div>
  );
};

const MiniStat = ({
  icon: Icon,
  label,
  value,
  tone,
  onClick,
}: {
  icon: typeof BedDouble;
  label: string;
  value: string | number;
  tone: 'brand' | 'navy' | 'success' | 'warning' | 'danger';
  onClick?: () => void;
}) => {
  const tones = {
    brand: 'bg-brand-50 text-brand-700',
    navy: 'bg-navy-50 text-navy-700',
    success: 'bg-emerald-50 text-emerald-700',
    warning: 'bg-amber-50 text-amber-700',
    danger: 'bg-red-50 text-red-700',
  };
  return (
    <div
      className={cn('surface flex items-center gap-3 p-3', onClick && 'cursor-pointer transition-shadow hover:shadow-popover')}
      onClick={onClick}
    >
      <span className={cn('grid h-9 w-9 place-items-center rounded-lg', tones[tone])}>
        <Icon className="h-4 w-4" />
      </span>
      <div className="min-w-0">
        <p className="truncate text-[11px] uppercase tracking-wide text-muted-foreground">{label}</p>
        <p className="text-base font-semibold text-navy-900">{value}</p>
      </div>
    </div>
  );
};

function greeting() {
  const hour = new Date().getHours();
  if (hour < 12) return 'morning';
  if (hour < 17) return 'afternoon';
  return 'evening';
}

export default DashboardPage;
