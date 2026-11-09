import { Link, useNavigate, useParams } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import { ArrowLeft, BadgeCheck, Mail, MapPin, Phone, Star, Wallet } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge, StatusBadge } from '@/components/ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Avatar, Skeleton } from '@/components/ui/misc';
import { EmptyState, ErrorState } from '@/components/common/States';
import { guestApi } from '@/lib/endpoints';
import { getErrorMessage } from '@/lib/api';
import { currency, formatDate, formatDateTime, labelize } from '@/lib/format';

const GuestDetailPage = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const query = useQuery({
    queryKey: ['guest', id],
    queryFn: () => guestApi.get(Number(id)),
    enabled: Boolean(id),
  });

  if (query.isError) {
    return <Card><ErrorState message={getErrorMessage(query.error)} onRetry={() => query.refetch()} /></Card>;
  }
  if (query.isLoading || !query.data) {
    return (
      <div className="space-y-4">
        <Skeleton className="h-9 w-32" />
        <Skeleton className="h-32 w-full" />
        <Skeleton className="h-72 w-full" />
      </div>
    );
  }

  const { guest, bookings, payments, feedback, services } = query.data;

  return (
    <div className="space-y-5">
      <Button variant="ghost" size="sm" onClick={() => navigate('/guests')}>
        <ArrowLeft className="h-4 w-4" /> All guests
      </Button>

      <Card>
        <CardContent className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
          <div className="flex items-start gap-3">
            <Avatar name={guest.fullName} className="h-14 w-14 text-base" />
            <div>
              <div className="flex flex-wrap items-center gap-2">
                <h1 className="text-xl font-semibold text-navy-900">{guest.fullName}</h1>
                {guest.vip && <Badge tone="purple">VIP</Badge>}
                <Badge tone={guest.blacklisted ? 'danger' : 'neutral'}>{labelize(guest.category)}</Badge>
              </div>
              <p className="mt-0.5 flex flex-wrap items-center gap-3 text-xs text-muted-foreground">
                <span className="flex items-center gap-1"><Phone className="h-3 w-3" /> {guest.mobile}</span>
                {guest.email && <span className="flex items-center gap-1"><Mail className="h-3 w-3" /> {guest.email}</span>}
                <span className="flex items-center gap-1"><MapPin className="h-3 w-3" /> {[guest.city, guest.state].filter(Boolean).join(', ') || '—'}</span>
              </p>
              <p className="mt-1 flex items-center gap-1 text-xs text-muted-foreground">
                <BadgeCheck className="h-3 w-3" /> {guest.idProofType ? labelize(guest.idProofType) : 'No ID'} · {guest.idProofMasked ?? 'not captured'}
              </p>
            </div>
          </div>
          <div className="grid grid-cols-3 gap-3 text-center sm:text-right">
            <div>
              <p className="text-[11px] uppercase tracking-wide text-muted-foreground">Stays</p>
              <p className="text-lg font-semibold text-navy-900">{guest.completedStays}</p>
            </div>
            <div>
              <p className="text-[11px] uppercase tracking-wide text-muted-foreground">Spent</p>
              <p className="text-lg font-semibold text-navy-900">{currency(guest.totalSpending, true)}</p>
            </div>
            <div>
              <p className="text-[11px] uppercase tracking-wide text-muted-foreground">Outstanding</p>
              <p className="text-lg font-semibold text-amber-700">{currency(guest.outstanding, true)}</p>
            </div>
          </div>
        </CardContent>
      </Card>

      <Tabs defaultValue="bookings">
        <TabsList>
          <TabsTrigger value="bookings">Bookings ({bookings.length})</TabsTrigger>
          <TabsTrigger value="payments">Payments ({payments.length})</TabsTrigger>
          <TabsTrigger value="feedback">Feedback ({feedback.length})</TabsTrigger>
          <TabsTrigger value="services">Services ({services.length})</TabsTrigger>
        </TabsList>

        <TabsContent value="bookings">
          <Card>
            {bookings.length === 0 ? (
              <EmptyState title="No bookings yet" description="Reservations for this guest will appear here." />
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Code</TableHead>
                    <TableHead>Hotel</TableHead>
                    <TableHead>Stay</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Payment</TableHead>
                    <TableHead className="text-right">Total</TableHead>
                    <TableHead className="text-right">Pending</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {bookings.map((booking) => (
                    <TableRow key={booking.id} className="cursor-pointer" onClick={() => navigate(`/bookings/${booking.id}`)}>
                      <TableCell className="text-xs font-medium text-brand-700">{booking.bookingCode}</TableCell>
                      <TableCell className="text-xs">{booking.hotelName}</TableCell>
                      <TableCell className="text-xs">{formatDate(booking.checkInDate)} → {formatDate(booking.checkOutDate)}</TableCell>
                      <TableCell><StatusBadge value={booking.status} /></TableCell>
                      <TableCell><StatusBadge value={booking.paymentStatus} /></TableCell>
                      <TableCell className="text-right text-xs">{currency(booking.totalAmount)}</TableCell>
                      <TableCell className="text-right text-xs text-amber-700">{currency(booking.pendingAmount)}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </Card>
        </TabsContent>

        <TabsContent value="payments">
          <Card>
            {payments.length === 0 ? (
              <EmptyState icon={Wallet} title="No payments recorded" />
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Code</TableHead>
                    <TableHead>Booking</TableHead>
                    <TableHead>Method</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Date</TableHead>
                    <TableHead className="text-right">Amount</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {payments.map((payment) => (
                    <TableRow key={payment.id}>
                      <TableCell className="text-xs font-medium">{payment.paymentCode}</TableCell>
                      <TableCell className="text-xs">{payment.bookingCode ?? '—'}</TableCell>
                      <TableCell className="text-xs">{labelize(payment.method)}</TableCell>
                      <TableCell><StatusBadge value={payment.status} /></TableCell>
                      <TableCell className="text-xs">{formatDateTime(payment.paidAt)}</TableCell>
                      <TableCell className="text-right text-xs font-medium">{currency(payment.amount)}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </Card>
        </TabsContent>

        <TabsContent value="feedback">
          <Card>
            {feedback.length === 0 ? (
              <EmptyState icon={Star} title="No feedback or complaints" />
            ) : (
              <div className="divide-y divide-border">
                {feedback.map((item) => (
                  <div key={item.id} className="p-4">
                    <div className="flex flex-wrap items-center gap-2">
                      <StatusBadge value={item.type} />
                      {item.rating && (
                        <span className="flex items-center gap-0.5 text-amber-500">
                          {Array.from({ length: 5 }).map((_, index) => (
                            <Star key={index} className={index < item.rating! ? 'h-3 w-3 fill-current' : 'h-3 w-3 text-navy-200'} />
                          ))}
                        </span>
                      )}
                      <StatusBadge value={item.status} />
                      <span className="text-[11px] text-muted-foreground">{formatDateTime(item.createdAt)}</span>
                    </div>
                    <p className="mt-1 text-sm text-navy-800">{item.comments}</p>
                    {item.resolution && <p className="mt-1 rounded bg-muted px-2 py-1 text-xs text-navy-700">Resolution: {item.resolution}</p>}
                  </div>
                ))}
              </div>
            )}
          </Card>
        </TabsContent>

        <TabsContent value="services">
          <Card>
            {services.length === 0 ? (
              <EmptyState title="No service orders" />
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Type</TableHead>
                    <TableHead>Description</TableHead>
                    <TableHead>Booking</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead className="text-right">Amount</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {services.map((service) => (
                    <TableRow key={service.id}>
                      <TableCell className="text-xs">{labelize(service.orderType)}</TableCell>
                      <TableCell className="text-xs">{service.description}</TableCell>
                      <TableCell className="text-xs">
                        {service.bookingId ? (
                          <Link to={`/bookings/${service.bookingId}`} className="text-brand-700 hover:underline">{service.bookingCode}</Link>
                        ) : '—'}
                      </TableCell>
                      <TableCell><StatusBadge value={service.status} /></TableCell>
                      <TableCell className="text-right text-xs font-medium">{currency(service.lineTotal)}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </Card>
        </TabsContent>
      </Tabs>

      {(guest.notes || guest.specialRequests) && (
        <Card>
          <CardHeader><CardTitle>Notes</CardTitle></CardHeader>
          <CardContent className="space-y-2 pt-0 text-sm text-navy-800">
            {guest.notes && <p>{guest.notes}</p>}
            {guest.specialRequests && <p className="text-xs text-muted-foreground">Preferences: {guest.specialRequests}</p>}
          </CardContent>
        </Card>
      )}
    </div>
  );
};

export default GuestDetailPage;
