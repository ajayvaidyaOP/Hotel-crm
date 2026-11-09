import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Building2, MapPin, Pencil, Plus, Star, Users, Wallet } from 'lucide-react';
import { toast } from 'sonner';
import { PageHeader } from '@/components/common/PageHeader';
import { EmptyState, ErrorState } from '@/components/common/States';
import { SearchInput } from '@/components/common/TableToolbar';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { StatusBadge } from '@/components/ui/badge';
import { Dialog, DialogContent, DialogFooter, DialogHeader, DialogTitle, DialogDescription } from '@/components/ui/dialog';
import { Field, Input, Select, Textarea } from '@/components/ui/input';
import { Skeleton } from '@/components/ui/misc';
import {
  DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuLabel, DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { MoreHorizontal } from 'lucide-react';
import { hotelApi } from '@/lib/endpoints';
import { getErrorMessage, fieldErrors } from '@/lib/api';
import { currency } from '@/lib/format';
import { useAuth } from '@/context/AuthContext';
import type { Hotel } from '@/lib/types';

const EMPTY_FORM = {
  name: '',
  code: '',
  address: '',
  city: '',
  state: '',
  country: 'India',
  postalCode: '',
  contactNumber: '',
  email: '',
  description: '',
  checkInTime: '14:00',
  checkOutTime: '11:00',
  starRating: '4',
  gstNumber: '',
  taxRate: '12',
  facilities: 'Wi-Fi, Breakfast, Parking, Pool',
  imageUrls: '',
};

const HotelsPage = () => {
  const { has } = useAuth();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [search, setSearch] = useState('');
  const [dialogOpen, setDialogOpen] = useState(false);
  const [editing, setEditing] = useState<Hotel | null>(null);
  const [form, setForm] = useState(EMPTY_FORM);
  const [errors, setErrors] = useState<Record<string, string>>({});

  const { data, isLoading, isError, error, refetch } = useQuery({
    queryKey: ['hotels'],
    queryFn: () => hotelApi.list(),
  });

  const saveMutation = useMutation({
    mutationFn: async () => {
      const payload = {
        name: form.name.trim(),
        code: form.code.trim().toUpperCase(),
        address: form.address || null,
        city: form.city || null,
        state: form.state || null,
        country: form.country || null,
        postalCode: form.postalCode || null,
        contactNumber: form.contactNumber || null,
        email: form.email || null,
        description: form.description || null,
        checkInTime: form.checkInTime,
        checkOutTime: form.checkOutTime,
        starRating: form.starRating ? Number(form.starRating) : null,
        gstNumber: form.gstNumber || null,
        taxRate: form.taxRate ? Number(form.taxRate) : 0,
        facilities: form.facilities.split(',').map((item) => item.trim()).filter(Boolean),
        imageUrls: form.imageUrls.split(',').map((item) => item.trim()).filter(Boolean),
        status: 'ACTIVE',
      };
      return editing ? hotelApi.update(editing.id, payload) : hotelApi.create(payload);
    },
    onSuccess: () => {
      toast.success(editing ? 'Hotel updated' : 'Hotel created');
      setDialogOpen(false);
      setEditing(null);
      setForm(EMPTY_FORM);
      setErrors({});
      queryClient.invalidateQueries({ queryKey: ['hotels'] });
    },
    onError: (err) => {
      setErrors(fieldErrors(err));
      toast.error(getErrorMessage(err));
    },
  });

  const statusMutation = useMutation({
    mutationFn: ({ id, status }: { id: number; status: string }) => hotelApi.updateStatus(id, status),
    onSuccess: () => {
      toast.success('Hotel status updated');
      queryClient.invalidateQueries({ queryKey: ['hotels'] });
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  const openCreate = () => {
    setEditing(null);
    setForm(EMPTY_FORM);
    setErrors({});
    setDialogOpen(true);
  };

  const openEdit = (hotel: Hotel) => {
    setEditing(hotel);
    setForm({
      name: hotel.name,
      code: hotel.code,
      address: hotel.address ?? '',
      city: hotel.city ?? '',
      state: hotel.state ?? '',
      country: hotel.country ?? 'India',
      postalCode: hotel.postalCode ?? '',
      contactNumber: hotel.contactNumber ?? '',
      email: hotel.email ?? '',
      description: hotel.description ?? '',
      checkInTime: hotel.checkInTime?.slice(0, 5) ?? '14:00',
      checkOutTime: hotel.checkOutTime?.slice(0, 5) ?? '11:00',
      starRating: hotel.starRating ? String(hotel.starRating) : '4',
      gstNumber: hotel.gstNumber ?? '',
      taxRate: String(hotel.taxRate ?? 12),
      facilities: (hotel.facilities ?? []).join(', '),
      imageUrls: (hotel.imageUrls ?? []).join(', '),
    });
    setErrors({});
    setDialogOpen(true);
  };

  const hotels = (data ?? []).filter((hotel) => {
    if (!search.trim()) return true;
    const term = search.toLowerCase();
    return (
      hotel.name.toLowerCase().includes(term) ||
      hotel.code.toLowerCase().includes(term) ||
      (hotel.city ?? '').toLowerCase().includes(term)
    );
  });

  const totalRevenue = (data ?? []).reduce((sum, hotel) => sum + Number(hotel.revenueThisMonth ?? 0), 0);
  const totalRooms = (data ?? []).reduce((sum, hotel) => sum + Number(hotel.roomCount ?? 0), 0);

  return (
    <div className="space-y-5">
      <PageHeader
        title="Hotels"
        description={`${data?.length ?? 0} properties · ${totalRooms} rooms · ${currency(totalRevenue)} revenue this month`}
        actions={
          <>
            <SearchInput value={search} onChange={setSearch} placeholder="Search hotels…" className="sm:w-56" />
            {has('hotel:write') && (
              <Button size="sm" onClick={openCreate}>
                <Plus className="h-4 w-4" /> Add hotel
              </Button>
            )}
          </>
        }
      />

      {isError ? (
        <Card><ErrorState message={getErrorMessage(error)} onRetry={() => refetch()} /></Card>
      ) : isLoading ? (
        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
          {Array.from({ length: 3 }).map((_, index) => (
            <Card key={index} className="overflow-hidden">
              <Skeleton className="h-28 w-full rounded-none" />
              <div className="space-y-3 p-4">
                <Skeleton className="h-5 w-2/3" />
                <Skeleton className="h-4 w-1/2" />
                <Skeleton className="h-12 w-full" />
              </div>
            </Card>
          ))}
        </div>
      ) : hotels.length === 0 ? (
        <Card>
          <EmptyState
            icon={Building2}
            title="No hotels found"
            description={search ? 'Try a different search term.' : 'Create your first property to start managing rooms and bookings.'}
            action={has('hotel:write') ? <Button onClick={openCreate}><Plus className="h-4 w-4" /> Add hotel</Button> : undefined}
          />
        </Card>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3">
          {hotels.map((hotel) => (
            <Card key={hotel.id} className="group overflow-hidden transition-shadow hover:shadow-popover">
              <div className="relative h-28 bg-gradient-to-br from-navy-900 via-navy-800 to-brand-700">
                {hotel.imageUrls?.[0] && (
                  <img src={hotel.imageUrls[0]} alt={hotel.name} className="h-full w-full object-cover opacity-70" loading="lazy" />
                )}
                <div className="absolute inset-0 bg-gradient-to-t from-navy-950/80 to-transparent" />
                <div className="absolute inset-x-0 bottom-0 flex items-end justify-between p-3">
                  <div className="min-w-0">
                    <p className="truncate text-sm font-semibold text-white">{hotel.name}</p>
                    <p className="flex items-center gap-1 truncate text-[11px] text-navy-200">
                      <MapPin className="h-3 w-3" /> {hotel.city ?? '—'}, {hotel.state ?? ''} · {hotel.code}
                    </p>
                  </div>
                  <div className="flex items-center gap-2">
                    <StatusBadge value={hotel.status} className="bg-white/90" />
                    <DropdownMenu>
                      <DropdownMenuTrigger asChild>
                        <Button variant="ghost" size="icon-sm" className="text-white hover:bg-white/20">
                          <MoreHorizontal className="h-4 w-4" />
                        </Button>
                      </DropdownMenuTrigger>
                      <DropdownMenuContent align="end">
                        <DropdownMenuLabel>{hotel.code}</DropdownMenuLabel>
                        <DropdownMenuItem onSelect={() => navigate(`/hotels/${hotel.id}`)}>Open dashboard</DropdownMenuItem>
                        {has('hotel:write') && <DropdownMenuItem onSelect={() => openEdit(hotel)}>Edit property</DropdownMenuItem>}
                        {has('hotel:write') && (
                          <DropdownMenuItem
                            onSelect={() =>
                              statusMutation.mutate({ id: hotel.id, status: hotel.status === 'ACTIVE' ? 'INACTIVE' : 'ACTIVE' })
                            }
                          >
                            {hotel.status === 'ACTIVE' ? 'Deactivate' : 'Activate'}
                          </DropdownMenuItem>
                        )}
                      </DropdownMenuContent>
                    </DropdownMenu>
                  </div>
                </div>
              </div>

              <div className="space-y-3 p-4">
                <div className="flex items-center gap-3 text-xs text-muted-foreground">
                  <span className="flex items-center gap-1">
                    <Star className="h-3.5 w-3.5 text-amber-500" /> {hotel.starRating ?? '—'}-star
                  </span>
                  <span className="flex items-center gap-1">
                    <Users className="h-3.5 w-3.5" /> {hotel.staffCount} staff
                  </span>
                  <span>GST {hotel.taxRate}%</span>
                </div>

                <div className="grid grid-cols-3 gap-2 rounded-lg bg-muted/60 p-2.5 text-center">
                  <div>
                    <p className="text-[10px] uppercase tracking-wide text-muted-foreground">Rooms</p>
                    <p className="text-sm font-semibold text-navy-900">{hotel.roomCount}</p>
                  </div>
                  <div>
                    <p className="text-[10px] uppercase tracking-wide text-muted-foreground">Active</p>
                    <p className="text-sm font-semibold text-navy-900">{hotel.activeBookings}</p>
                  </div>
                  <div>
                    <p className="text-[10px] uppercase tracking-wide text-muted-foreground">Revenue</p>
                    <p className="text-sm font-semibold text-navy-900">{currency(hotel.revenueThisMonth, true)}</p>
                  </div>
                </div>

                <div className="flex flex-wrap gap-1">
                  {(hotel.facilities ?? []).slice(0, 4).map((facility) => (
                    <span key={facility} className="rounded-full bg-brand-50 px-2 py-0.5 text-[10px] font-medium text-brand-700">
                      {facility}
                    </span>
                  ))}
                </div>

                <div className="flex gap-2">
                  <Button asChild size="sm" className="flex-1">
                    <Link to={`/hotels/${hotel.id}`}>Open</Link>
                  </Button>
                  {has('hotel:write') && (
                    <Button variant="outline" size="sm" onClick={() => openEdit(hotel)}>
                      <Pencil className="h-3.5 w-3.5" /> Edit
                    </Button>
                  )}
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}

      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogContent size="lg">
          <DialogHeader>
            <DialogTitle>{editing ? `Edit ${editing.name}` : 'Add a hotel'}</DialogTitle>
            <DialogDescription>
              Property details drive bookings, invoices, tax and reporting for this location.
            </DialogDescription>
          </DialogHeader>

          <div className="grid gap-3 sm:grid-cols-2">
            <Field label="Hotel name" required error={errors.name}>
              <Input value={form.name} onChange={(event) => setForm({ ...form, name: event.target.value })} placeholder="Hotel Marine Bay" />
            </Field>
            <Field label="Short code" required hint="Used in booking codes, e.g. GV" error={errors.code}>
              <Input
                value={form.code}
                maxLength={12}
                onChange={(event) => setForm({ ...form, code: event.target.value.toUpperCase() })}
                placeholder="GV"
              />
            </Field>
            <Field label="City">
              <Input value={form.city} onChange={(event) => setForm({ ...form, city: event.target.value })} placeholder="Mumbai" />
            </Field>
            <Field label="State">
              <Input value={form.state} onChange={(event) => setForm({ ...form, state: event.target.value })} placeholder="Maharashtra" />
            </Field>
            <Field label="Address" className="sm:col-span-2">
              <Input value={form.address} onChange={(event) => setForm({ ...form, address: event.target.value })} placeholder="12 Marine Drive" />
            </Field>
            <Field label="Contact number">
              <Input value={form.contactNumber} onChange={(event) => setForm({ ...form, contactNumber: event.target.value })} placeholder="+91 22 4567 8900" />
            </Field>
            <Field label="Email">
              <Input type="email" value={form.email} onChange={(event) => setForm({ ...form, email: event.target.value })} placeholder="stay@marinebay.com" />
            </Field>
            <Field label="Check-in time">
              <Input type="time" value={form.checkInTime} onChange={(event) => setForm({ ...form, checkInTime: event.target.value })} />
            </Field>
            <Field label="Check-out time">
              <Input type="time" value={form.checkOutTime} onChange={(event) => setForm({ ...form, checkOutTime: event.target.value })} />
            </Field>
            <Field label="Star rating">
              <Select value={form.starRating} onChange={(event) => setForm({ ...form, starRating: event.target.value })}>
                {[3, 4, 5].map((rating) => (
                  <option key={rating} value={rating}>{rating} star</option>
                ))}
              </Select>
            </Field>
            <Field label="GST rate (%)">
              <Input type="number" min={0} max={28} value={form.taxRate} onChange={(event) => setForm({ ...form, taxRate: event.target.value })} />
            </Field>
            <Field label="GSTIN">
              <Input value={form.gstNumber} onChange={(event) => setForm({ ...form, gstNumber: event.target.value })} placeholder="27AABCH1234M1Z5" />
            </Field>
            <Field label="Postal code">
              <Input value={form.postalCode} onChange={(event) => setForm({ ...form, postalCode: event.target.value })} />
            </Field>
            <Field label="Facilities" hint="Comma separated" className="sm:col-span-2">
              <Input value={form.facilities} onChange={(event) => setForm({ ...form, facilities: event.target.value })} />
            </Field>
            <Field label="Image URLs" hint="Comma separated (optional)" className="sm:col-span-2">
              <Input value={form.imageUrls} onChange={(event) => setForm({ ...form, imageUrls: event.target.value })} />
            </Field>
            <Field label="Description" className="sm:col-span-2">
              <Textarea value={form.description} onChange={(event) => setForm({ ...form, description: event.target.value })} rows={3} />
            </Field>
          </div>

          <DialogFooter>
            <Button variant="outline" onClick={() => setDialogOpen(false)}>Cancel</Button>
            <Button loading={saveMutation.isPending} onClick={() => saveMutation.mutate()} disabled={!form.name || !form.code}>
              <Wallet className="h-4 w-4" /> {editing ? 'Save changes' : 'Create hotel'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
};

export default HotelsPage;
