import { useMemo, useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import {
  Area, AreaChart, Bar, CartesianGrid, Cell, ComposedChart, Legend, Line, Pie, PieChart, ResponsiveContainer, Tooltip, XAxis, YAxis,
} from 'recharts';
import {
  BadgePercent, BedDouble, Download, FileSpreadsheet, FileText, IndianRupee, Percent, TrendingUp, Users, Wallet,
} from 'lucide-react';
import { toast } from 'sonner';
import { PageHeader } from '@/components/common/PageHeader';
import { StatCard } from '@/components/common/StatCard';
import { ChartCard } from '@/components/common/ChartCard';
import { ChartSkeleton, EmptyState, ErrorState, TableSkeleton } from '@/components/common/States';
import { DateRangeFilter } from '@/components/common/DateRangeFilter';
import { Button } from '@/components/ui/button';
import { Card, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { StatusBadge } from '@/components/ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { ProgressBar } from '@/components/ui/misc';
import { useHotelScope } from '@/context/HotelContext';
import { reportApi } from '@/lib/endpoints';
import { downloadFile, getErrorMessage } from '@/lib/api';
import { currency, formatDate, formatDateTime, labelize, number } from '@/lib/format';
import { addDaysISO } from '@/lib/utils';

const COLORS = ['#1a5cf5', '#0ea5e9', '#8b5cf6', '#f59e0b', '#10b981', '#ef4444', '#64748b', '#14b8a6'];

const ReportsPage = () => {
  const { hotelId, isGroupView } = useHotelScope();
  const [range, setRange] = useState({ from: addDaysISO(-29), to: addDaysISO(0) });
  const [tab, setTab] = useState('revenue');
  const [exporting, setExporting] = useState<string | null>(null);

  const scope = { hotelId: isGroupView ? undefined : hotelId ?? undefined, from: range.from, to: range.to };

  const kpiQuery = useQuery({ queryKey: ['reports', 'kpi', scope], queryFn: () => reportApi.kpi(scope) });
  const revenueQuery = useQuery({ queryKey: ['reports', 'revenue', scope], queryFn: () => reportApi.revenue(scope) });
  const occupancyQuery = useQuery({ queryKey: ['reports', 'occupancy', scope], queryFn: () => reportApi.occupancy(scope) });
  const categoriesQuery = useQuery({ queryKey: ['reports', 'categories', scope], queryFn: () => reportApi.categories(scope) });
  const expensesQuery = useQuery({ queryKey: ['reports', 'expenses', scope], queryFn: () => reportApi.expenses(scope) });
  const profitQuery = useQuery({ queryKey: ['reports', 'profit', scope], queryFn: () => reportApi.profit(scope) });
  const cancellationsQuery = useQuery({ queryKey: ['reports', 'cancellations', scope], queryFn: () => reportApi.cancellations(scope) });
  const pendingQuery = useQuery({ queryKey: ['reports', 'pending', scope], queryFn: () => reportApi.pendingPayments(scope) });

  const kpi = kpiQuery.data;
  const revenue = revenueQuery.data ?? [];
  const occupancy = occupancyQuery.data ?? [];
  const categories = categoriesQuery.data ?? [];
  const expenses = expensesQuery.data ?? [];
  const profit = profitQuery.data ?? [];
  const cancellations = cancellationsQuery.data ?? [];
  const pending = pendingQuery.data ?? [];

  const trend = useMemo(
    () => revenue.map((row) => ({ ...row, total: Number(row.total), roomRevenue: Number(row.roomRevenue), serviceRevenue: Number(row.serviceRevenue) })),
    [revenue],
  );

  const exportReport = async (report: string, format: string) => {
    setExporting(`${report}-${format}`);
    try {
      await downloadFile('/reports/export', { report, format, ...scope }, `${report}-${range.from}-${range.to}.${format}`);
      toast.success(`${labelize(report)} exported as ${format.toUpperCase()}`);
    } catch (err) {
      toast.error(getErrorMessage(err));
    } finally {
      setExporting(null);
    }
  };

  return (
    <div className="space-y-5">
      <PageHeader
        title="Reports & analytics"
        description="Revenue, occupancy, ADR, RevPAR, cancellations and profit — computed from live data."
        actions={
          <>
            <DateRangeFilter from={range.from} to={range.to} onChange={setRange} compact />
            <Button variant="outline" size="sm" loading={exporting === 'revenue-csv'} onClick={() => exportReport('revenue', 'csv')}>
              <Download className="h-4 w-4" /> CSV
            </Button>
            <Button variant="outline" size="sm" loading={exporting === 'revenue-xlsx'} onClick={() => exportReport('revenue', 'xlsx')}>
              <FileSpreadsheet className="h-4 w-4" /> Excel
            </Button>
            <Button variant="outline" size="sm" loading={exporting === 'revenue-pdf'} onClick={() => exportReport('revenue', 'pdf')}>
              <FileText className="h-4 w-4" /> PDF
            </Button>
          </>
        }
      />

      {kpiQuery.isError ? (
        <Card><ErrorState message={getErrorMessage(kpiQuery.error)} onRetry={() => kpiQuery.refetch()} /></Card>
      ) : (
        <>
          <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
            <StatCard label="Net revenue" value={currency(kpi?.netRevenue, true)} hint={`Gross ${currency(kpi?.revenue, true)} · refunds ${currency(kpi?.refunds, true)}`} icon={IndianRupee} tone="success" />
            <StatCard label="Occupancy" value={`${Number(kpi?.occupancyPercent ?? 0).toFixed(1)}%`} hint={`${number(kpi?.roomNightsSold)} of ${number(kpi?.roomNightsAvailable)} room nights`} icon={Percent} tone="brand" />
            <StatCard label="ADR / RevPAR" value={`${currency(kpi?.adr, true)} / ${currency(kpi?.revpar, true)}`} hint={`ALOS ${Number(kpi?.averageLengthOfStay ?? 0).toFixed(1)} nights`} icon={TrendingUp} tone="violet" />
            <StatCard label="Profit" value={currency(kpi?.profit, true)} hint={`Expenses ${currency(kpi?.expenses, true)}`} icon={Wallet} tone="warning" />
          </div>

          <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
            <StatCard label="Bookings" value={number(kpi?.bookings)} hint={`${number(kpi?.completedStays)} completed stays`} icon={BedDouble} tone="navy" />
            <StatCard label="Cancellations" value={number(kpi?.cancelledBookings)} hint={`${Number(kpi?.cancellationPercent ?? 0).toFixed(1)}% of bookings`} icon={BadgePercent} tone="danger" />
            <StatCard label="Room revenue" value={currency(kpi?.roomRevenue, true)} hint={`Service ${currency(kpi?.serviceRevenue, true)}`} icon={Users} tone="brand" />
            <StatCard label="Pending payments" value={currency(kpi?.pendingPayments, true)} hint={`${pending.length} bookings outstanding`} icon={Wallet} tone="warning" />
          </div>
        </>
      )}

      <Tabs value={tab} onValueChange={setTab}>
        <TabsList>
          <TabsTrigger value="revenue">Revenue</TabsTrigger>
          <TabsTrigger value="occupancy">Occupancy</TabsTrigger>
          <TabsTrigger value="profit">Profit</TabsTrigger>
          <TabsTrigger value="categories">Categories</TabsTrigger>
          <TabsTrigger value="cancellations">Cancellations</TabsTrigger>
          <TabsTrigger value="pending">Pending dues</TabsTrigger>
        </TabsList>

        <TabsContent value="revenue">
          <div className="grid gap-4 xl:grid-cols-3">
            <ChartCard title="Revenue trend" description="Room + service revenue per period" className="xl:col-span-2">
              {revenueQuery.isLoading ? (
                <ChartSkeleton />
              ) : trend.length === 0 ? (
                <EmptyState title="No revenue in this period" />
              ) : (
                <ResponsiveContainer width="100%" height={300}>
                  <AreaChart data={trend} margin={{ left: 4, right: 8, top: 8 }}>
                    <defs>
                      <linearGradient id="roomGradient" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#1a5cf5" stopOpacity={0.35} />
                        <stop offset="95%" stopColor="#1a5cf5" stopOpacity={0.02} />
                      </linearGradient>
                      <linearGradient id="serviceGradient" x1="0" y1="0" x2="0" y2="1">
                        <stop offset="5%" stopColor="#8b5cf6" stopOpacity={0.35} />
                        <stop offset="95%" stopColor="#8b5cf6" stopOpacity={0.02} />
                      </linearGradient>
                    </defs>
                    <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" vertical={false} />
                    <XAxis dataKey="period" tick={{ fontSize: 11, fill: '#64748b' }} axisLine={false} tickLine={false} />
                    <YAxis tick={{ fontSize: 11, fill: '#64748b' }} axisLine={false} tickLine={false} tickFormatter={(value) => `₹${Math.round(Number(value) / 1000)}k`} width={48} />
                    <Tooltip contentStyle={{ borderRadius: 10, border: '1px solid #e2e8f0', fontSize: 12 }} formatter={(value: number) => currency(value)} />
                    <Legend wrapperStyle={{ fontSize: 11 }} />
                    <Area type="monotone" dataKey="roomRevenue" name="Room" stroke="#1a5cf5" fill="url(#roomGradient)" strokeWidth={2} />
                    <Area type="monotone" dataKey="serviceRevenue" name="Services" stroke="#8b5cf6" fill="url(#serviceGradient)" strokeWidth={2} />
                  </AreaChart>
                </ResponsiveContainer>
              )}
            </ChartCard>

            <ChartCard title="Expense split" description="Period expenses by category">
              {expensesQuery.isLoading ? (
                <ChartSkeleton />
              ) : expenses.length === 0 ? (
                <EmptyState title="No expenses" />
              ) : (
                <>
                  <ResponsiveContainer width="100%" height={210}>
                    <PieChart>
                      <Pie data={expenses} dataKey="amount" nameKey="category" innerRadius={52} outerRadius={82} paddingAngle={2} strokeWidth={0}>
                        {expenses.map((entry, index) => (
                          <Cell key={entry.category} fill={COLORS[index % COLORS.length]} />
                        ))}
                      </Pie>
                      <Tooltip formatter={(value: number) => currency(value)} />
                    </PieChart>
                  </ResponsiveContainer>
                  <div className="space-y-1">
                    {expenses.map((entry, index) => (
                      <div key={entry.category} className="flex items-center justify-between text-xs">
                        <span className="flex items-center gap-1.5 text-navy-700">
                          <span className="h-2 w-2 rounded-full" style={{ background: COLORS[index % COLORS.length] }} />
                          {labelize(entry.category)}
                        </span>
                        <span className="font-medium">{currency(entry.amount, true)}</span>
                      </div>
                    ))}
                  </div>
                </>
              )}
            </ChartCard>
          </div>

          <Card className="mt-4">
            <CardHeader className="flex-row items-center justify-between">
              <CardTitle>Revenue detail</CardTitle>
              <Button variant="ghost" size="sm" onClick={() => exportReport('revenue', 'csv')}>Export CSV</Button>
            </CardHeader>
            {revenueQuery.isLoading ? (
              <TableSkeleton rows={6} columns={5} />
            ) : trend.length === 0 ? (
              <EmptyState title="No rows" />
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Period</TableHead>
                    <TableHead className="text-right">Room revenue</TableHead>
                    <TableHead className="text-right">Service revenue</TableHead>
                    <TableHead className="text-right">Tax</TableHead>
                    <TableHead className="text-right">Refunds</TableHead>
                    <TableHead className="text-right">Bookings</TableHead>
                    <TableHead className="text-right">Total</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {revenue.map((row) => (
                    <TableRow key={row.period}>
                      <TableCell className="text-xs font-medium text-navy-900">{row.period}</TableCell>
                      <TableCell className="text-right text-xs">{currency(row.roomRevenue)}</TableCell>
                      <TableCell className="text-right text-xs">{currency(row.serviceRevenue)}</TableCell>
                      <TableCell className="text-right text-xs">{currency(row.tax)}</TableCell>
                      <TableCell className="text-right text-xs text-red-600">{currency(row.refunds)}</TableCell>
                      <TableCell className="text-right text-xs">{number(row.bookings)}</TableCell>
                      <TableCell className="text-right text-xs font-semibold">{currency(row.total)}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </Card>
        </TabsContent>

        <TabsContent value="occupancy">
          <Card>
            <CardHeader className="flex-row items-center justify-between">
              <div>
                <CardTitle>Occupancy by hotel</CardTitle>
                <CardDescription>Room nights sold against available capacity</CardDescription>
              </div>
              <Button variant="ghost" size="sm" onClick={() => exportReport('occupancy', 'xlsx')}>
                <FileSpreadsheet className="h-4 w-4" /> Excel
              </Button>
            </CardHeader>
            {occupancyQuery.isLoading ? (
              <TableSkeleton rows={5} columns={6} />
            ) : occupancy.length === 0 ? (
              <EmptyState title="No occupancy data" />
            ) : (
              <>
                <div className="px-4 pb-2">
                  <ResponsiveContainer width="100%" height={220}>
                    <ComposedChart data={occupancy} margin={{ left: 4, right: 8, top: 8 }}>
                      <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" vertical={false} />
                      <XAxis dataKey="hotelName" tick={{ fontSize: 10, fill: '#64748b' }} axisLine={false} tickLine={false} interval={0} />
                      <YAxis tick={{ fontSize: 11, fill: '#64748b' }} axisLine={false} tickLine={false} unit="%" width={40} />
                      <Tooltip formatter={(value: number) => `${value}%`} />
                      <Bar dataKey="occupancyPercent" name="Occupancy" fill="#1a5cf5" radius={[6, 6, 0, 0]} maxBarSize={40} />
                      <Line type="monotone" dataKey="occupancyPercent" stroke="#f59e0b" strokeWidth={0} dot={false} legendType="none" />
                    </ComposedChart>
                  </ResponsiveContainer>
                </div>
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Hotel</TableHead>
                      <TableHead className="text-right">Rooms</TableHead>
                      <TableHead className="text-right">Room nights</TableHead>
                      <TableHead className="text-right">Occupied</TableHead>
                      <TableHead>Occupancy</TableHead>
                      <TableHead className="text-right">ADR</TableHead>
                      <TableHead className="text-right">RevPAR</TableHead>
                      <TableHead className="text-right">Revenue</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {occupancy.map((row) => (
                      <TableRow key={row.hotelId}>
                        <TableCell className="text-xs font-medium text-navy-900">{row.hotelName}</TableCell>
                        <TableCell className="text-right text-xs">{row.totalRooms}</TableCell>
                        <TableCell className="text-right text-xs">{number(row.roomNights)}</TableCell>
                        <TableCell className="text-right text-xs">{number(row.occupiedNights)}</TableCell>
                        <TableCell>
                          <div className="flex items-center gap-2">
                            <span className="w-10 text-xs font-medium">{Number(row.occupancyPercent).toFixed(1)}%</span>
                            <ProgressBar value={Number(row.occupancyPercent)} className="w-20" />
                          </div>
                        </TableCell>
                        <TableCell className="text-right text-xs">{currency(row.adr)}</TableCell>
                        <TableCell className="text-right text-xs">{currency(row.revpar)}</TableCell>
                        <TableCell className="text-right text-xs font-semibold">{currency(row.revenue)}</TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </>
            )}
          </Card>
        </TabsContent>

        <TabsContent value="profit">
          <Card>
            <CardHeader className="flex-row items-center justify-between">
              <div>
                <CardTitle>Profit by hotel</CardTitle>
                <CardDescription>Revenue net of refunds, minus recorded expenses</CardDescription>
              </div>
              <Button variant="ghost" size="sm" onClick={() => exportReport('profit', 'pdf')}>
                <FileText className="h-4 w-4" /> PDF
              </Button>
            </CardHeader>
            {profitQuery.isLoading ? (
              <TableSkeleton rows={5} columns={6} />
            ) : profit.length === 0 ? (
              <EmptyState title="No profit data" />
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Hotel</TableHead>
                    <TableHead className="text-right">Revenue</TableHead>
                    <TableHead className="text-right">Refunds</TableHead>
                    <TableHead className="text-right">Expenses</TableHead>
                    <TableHead className="text-right">Profit</TableHead>
                    <TableHead>Margin</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {profit.map((row) => (
                    <TableRow key={row.hotelId}>
                      <TableCell className="text-xs font-medium text-navy-900">{row.hotelName}</TableCell>
                      <TableCell className="text-right text-xs">{currency(row.revenue)}</TableCell>
                      <TableCell className="text-right text-xs text-red-600">{currency(row.refunds)}</TableCell>
                      <TableCell className="text-right text-xs">{currency(row.expenses)}</TableCell>
                      <TableCell className={`text-right text-xs font-semibold ${Number(row.profit) >= 0 ? 'text-emerald-700' : 'text-red-600'}`}>
                        {currency(row.profit)}
                      </TableCell>
                      <TableCell>
                        <div className="flex items-center gap-2">
                          <span className="w-10 text-xs">{Number(row.marginPercent).toFixed(1)}%</span>
                          <ProgressBar value={Math.max(0, Number(row.marginPercent))} className="w-20" tone={Number(row.marginPercent) > 30 ? 'success' : 'warning'} />
                        </div>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </Card>
        </TabsContent>

        <TabsContent value="categories">
          <div className="grid gap-4 lg:grid-cols-2">
            <Card>
              <CardHeader><CardTitle>Revenue by category</CardTitle></CardHeader>
              {categoriesQuery.isLoading ? (
                <TableSkeleton rows={4} columns={3} />
              ) : categories.length === 0 ? (
                <EmptyState title="No category data" />
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Category</TableHead>
                      <TableHead className="text-right">Bookings</TableHead>
                      <TableHead className="text-right">Revenue</TableHead>
                      <TableHead className="text-right">Share</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {categories.map((row, index) => (
                      <TableRow key={row.category}>
                        <TableCell className="flex items-center gap-2 text-xs font-medium text-navy-900">
                          <span className="h-2 w-2 rounded-full" style={{ background: COLORS[index % COLORS.length] }} />
                          {row.category}
                        </TableCell>
                        <TableCell className="text-right text-xs">{row.bookings}</TableCell>
                        <TableCell className="text-right text-xs">{currency(row.revenue)}</TableCell>
                        <TableCell className="text-right text-xs">{Number(row.sharePercent).toFixed(1)}%</TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              )}
            </Card>

            <ChartCard title="Category mix" description="Share of room revenue">
              {categories.length === 0 ? (
                <EmptyState title="No data" />
              ) : (
                <ResponsiveContainer width="100%" height={280}>
                  <PieChart>
                    <Pie data={categories} dataKey="revenue" nameKey="category" outerRadius={100} label={({ name }) => String(name)} labelLine={false}>
                      {categories.map((entry, index) => (
                        <Cell key={entry.category} fill={COLORS[index % COLORS.length]} />
                      ))}
                    </Pie>
                    <Tooltip formatter={(value: number) => currency(value)} />
                  </PieChart>
                </ResponsiveContainer>
              )}
            </ChartCard>
          </div>
        </TabsContent>

        <TabsContent value="cancellations">
          <Card>
            <CardHeader className="flex-row items-center justify-between">
              <CardTitle>Cancellations</CardTitle>
              <Button variant="ghost" size="sm" onClick={() => exportReport('cancellations', 'csv')}>Export CSV</Button>
            </CardHeader>
            {cancellationsQuery.isLoading ? (
              <TableSkeleton rows={5} columns={5} />
            ) : cancellations.length === 0 ? (
              <EmptyState title="No cancellations in this period" description="Great news — nothing was cancelled." />
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Booking</TableHead>
                    <TableHead>Guest</TableHead>
                    <TableHead>Hotel</TableHead>
                    <TableHead>Cancelled</TableHead>
                    <TableHead>Reason</TableHead>
                    <TableHead className="text-right">Amount</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {cancellations.map((row) => (
                    <TableRow key={row.bookingId}>
                      <TableCell className="text-xs font-medium text-brand-700">{row.bookingCode}</TableCell>
                      <TableCell className="text-xs">{row.guestName}</TableCell>
                      <TableCell className="text-xs">{row.hotelName}</TableCell>
                      <TableCell className="text-xs">{formatDateTime(row.cancelledAt)}</TableCell>
                      <TableCell className="max-w-[220px] truncate text-xs text-muted-foreground">{row.reason ?? '—'}</TableCell>
                      <TableCell className="text-right text-xs font-medium">{currency(row.amount)}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </Card>
        </TabsContent>

        <TabsContent value="pending">
          <Card>
            <CardHeader className="flex-row items-center justify-between">
              <CardTitle>Pending payments</CardTitle>
              <Button variant="ghost" size="sm" onClick={() => exportReport('pending-payments', 'xlsx')}>Export Excel</Button>
            </CardHeader>
            {pendingQuery.isLoading ? (
              <TableSkeleton rows={5} columns={6} />
            ) : pending.length === 0 ? (
              <EmptyState title="Everything is settled" />
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Booking</TableHead>
                    <TableHead>Guest</TableHead>
                    <TableHead>Hotel</TableHead>
                    <TableHead>Stay</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead className="text-right">Total</TableHead>
                    <TableHead className="text-right">Paid</TableHead>
                    <TableHead className="text-right">Pending</TableHead>
                    <TableHead className="text-right">Age</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {pending.map((row) => (
                    <TableRow key={row.bookingId}>
                      <TableCell className="text-xs font-medium text-brand-700">{row.bookingCode}</TableCell>
                      <TableCell className="text-xs">{row.guestName}</TableCell>
                      <TableCell className="text-xs">{row.hotelName}</TableCell>
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
      </Tabs>
    </div>
  );
};

export default ReportsPage;
