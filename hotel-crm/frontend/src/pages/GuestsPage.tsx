import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Eye, Pencil, Plus, UserPlus, Users } from 'lucide-react';
import { toast } from 'sonner';
import { PageHeader } from '@/components/common/PageHeader';
import { EmptyState, ErrorState, TableSkeleton } from '@/components/common/States';
import { ClearFilters, FilterSelect, SearchInput, TableToolbar } from '@/components/common/TableToolbar';
import { Pagination } from '@/components/common/Pagination';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Checkbox, Field, Input, Select, Textarea } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { useHotelScope } from '@/context/HotelContext';
import { guestApi } from '@/lib/endpoints';
import { fieldErrors, getErrorMessage } from '@/lib/api';
import { currency, formatDate } from '@/lib/format';
import { useAuth } from '@/context/AuthContext';
import type { Guest } from '@/lib/types';

const CATEGORIES = ['REGULAR', 'CORPORATE', 'VIP', 'LOYALTY', 'BLACKLISTED'];
const ID_TYPES = ['AADHAAR', 'PASSPORT', 'DRIVING_LICENSE', 'VOTER_ID', 'PAN', 'OTHER'];

const emptyForm = {
  fullName: '',
  mobile: '',
  email: '',
  address: '',
  city: '',
  state: '',
  country: 'India',
  idProofType: 'AADHAAR',
  idProofNumber: '',
  category: 'REGULAR',
  vip: false,
  blacklisted: false,
  notes: '',
  specialRequests: '',
};

const GuestsPage = () => {
  const { has } = useAuth();
  const { hotelId } = useHotelScope();
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  const [search, setSearch] = useState('');
  const [category, setCategory] = useState('');
  const [vipOnly, setVipOnly] = useState(false);
  const [page, setPage] = useState(0);
  const [size, setSize] = useState(20);

  const [dialogOpen, setDialogOpen] = useState(false);
  const [editing, setEditing] = useState<Guest | null>(null);
  const [form, setForm] = useState(emptyForm);
  const [errors, setErrors] = useState<Record<string, string>>({});

  const query = useQuery({
    queryKey: ['guests', { search, category, vipOnly, page, size }],
    queryFn: () =>
      guestApi.list({
        search: search.trim() || undefined,
        category: category || undefined,
        vip: vipOnly || undefined,
        page,
        size,
      }),
  });

  const saveMutation = useMutation({
    mutationFn: () =>
      editing
        ? guestApi.update(editing.id, {
            fullName: form.fullName.trim(),
            mobile: form.mobile.trim(),
            email: form.email || undefined,
            address: form.address || undefined,
            city: form.city || undefined,
            state: form.state || undefined,
            country: form.country || undefined,
            idProofType: form.idProofType,
            idProofNumber: form.idProofNumber || undefined,
            category: form.category,
            vip: form.vip,
            blacklisted: form.blacklisted,
            notes: form.notes || undefined,
            specialRequests: form.specialRequests || undefined,
            hotelId: hotelId ?? undefined,
          })
        : guestApi.create({
            fullName: form.fullName.trim(),
            mobile: form.mobile.trim(),
            email: form.email || undefined,
            address: form.address || undefined,
            city: form.city || undefined,
            state: form.state || undefined,
            country: form.country || undefined,
            idProofType: form.idProofType,
            idProofNumber: form.idProofNumber || undefined,
            category: form.category,
            vip: form.vip,
            blacklisted: form.blacklisted,
            notes: form.notes || undefined,
            specialRequests: form.specialRequests || undefined,
            hotelId: hotelId ?? undefined,
          }),
    onSuccess: () => {
      toast.success(editing ? 'Guest updated' : 'Guest created');
      setDialogOpen(false);
      setEditing(null);
      setForm(emptyForm);
      setErrors({});
      queryClient.invalidateQueries({ queryKey: ['guests'] });
    },
    onError: (err) => {
      setErrors(fieldErrors(err));
      toast.error(getErrorMessage(err));
    },
  });

  const openCreate = () => {
    setEditing(null);
    setForm(emptyForm);
    setErrors({});
    setDialogOpen(true);
  };

  const openEdit = (guest: Guest) => {
    setEditing(guest);
    setForm({
      fullName: guest.fullName,
      mobile: guest.mobile,
      email: guest.email ?? '',
      address: guest.address ?? '',
      city: guest.city ?? '',
      state: guest.state ?? '',
      country: guest.country ?? 'India',
      idProofType: guest.idProofType ?? 'AADHAAR',
      idProofNumber: '',
      category: guest.category,
      vip: guest.vip,
      blacklisted: guest.blacklisted,
      notes: guest.notes ?? '',
      specialRequests: guest.specialRequests ?? '',
    });
    setErrors({});
    setDialogOpen(true);
  };

  const rows = query.data?.content ?? [];

  return (
    <div className="space-y-5">
      <PageHeader
        title="Guest CRM"
        description={`${query.data?.totalElements ?? 0} guest profiles · encrypted ID proofs, stay history and complaints`}
        actions={has('guest:write') ? (
          <Button size="sm" onClick={openCreate}>
            <UserPlus className="h-4 w-4" /> Add guest
          </Button>
        ) : undefined}
      />

      <Card>
        <TableToolbar>
          <div className="flex flex-1 flex-wrap items-center gap-2">
            <SearchInput value={search} onChange={setSearch} placeholder="Search name, mobile or email…" />
            <FilterSelect
              value={category}
              onChange={setCategory}
              placeholder="All categories"
              options={CATEGORIES.map((item) => ({ value: item, label: item.charAt(0) + item.slice(1).toLowerCase() }))}
            />
            <label className="flex items-center gap-1.5 text-xs text-navy-700">
              <input type="checkbox" checked={vipOnly} onChange={(event) => setVipOnly(event.target.checked)} className="h-3.5 w-3.5 rounded border-input" />
              VIP only
            </label>
            <ClearFilters visible={Boolean(search || category || vipOnly)} onClick={() => { setSearch(''); setCategory(''); setVipOnly(false); setPage(0); }} />
          </div>
        </TableToolbar>

        {query.isError ? (
          <ErrorState message={getErrorMessage(query.error)} onRetry={() => query.refetch()} />
        ) : query.isLoading ? (
          <TableSkeleton rows={8} columns={6} />
        ) : rows.length === 0 ? (
          <EmptyState
            icon={Users}
            title="No guests found"
            description="Guests are created automatically with their first booking, or add them here."
            action={has('guest:write') ? <Button size="sm" onClick={openCreate}><Plus className="h-4 w-4" /> Add guest</Button> : undefined}
          />
        ) : (
          <>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Guest</TableHead>
                  <TableHead>Contact</TableHead>
                  <TableHead>Category</TableHead>
                  <TableHead>ID proof</TableHead>
                  <TableHead className="text-right">Stays</TableHead>
                  <TableHead className="text-right">Lifetime value</TableHead>
                  <TableHead>Last stay</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {rows.map((guest) => (
                  <TableRow key={guest.id} className="cursor-pointer" onClick={() => navigate(`/guests/${guest.id}`)}>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        <span className="grid h-8 w-8 place-items-center rounded-full bg-navy-100 text-[11px] font-semibold text-navy-700">
                          {guest.fullName.split(' ').slice(0, 2).map((part) => part[0]).join('')}
                        </span>
                        <div>
                          <p className="font-medium text-navy-900">{guest.fullName}</p>
                          <p className="text-[11px] text-muted-foreground">{guest.city ?? '—'}{guest.hotelName ? ` · ${guest.hotelName}` : ''}</p>
                        </div>
                      </div>
                    </TableCell>
                    <TableCell className="text-xs">
                      {guest.mobile}
                      {guest.email && <span className="block text-[11px] text-muted-foreground">{guest.email}</span>}
                    </TableCell>
                    <TableCell>
                      <div className="flex flex-wrap gap-1">
                        <Badge tone={guest.category === 'VIP' ? 'purple' : guest.category === 'BLACKLISTED' ? 'danger' : 'neutral'}>
                          {guest.category}
                        </Badge>
                        {guest.vip && guest.category !== 'VIP' && <Badge tone="purple">VIP</Badge>}
                      </div>
                    </TableCell>
                    <TableCell className="text-xs">{guest.idProofMasked ?? '—'}</TableCell>
                    <TableCell className="text-right text-xs">{guest.totalBookings}</TableCell>
                    <TableCell className="text-right text-xs font-medium">{currency(guest.totalSpending)}</TableCell>
                    <TableCell className="text-xs">{guest.lastStayDate ? formatDate(guest.lastStayDate) : '—'}</TableCell>
                    <TableCell className="text-right" onClick={(event) => event.stopPropagation()}>
                      <div className="flex justify-end gap-1">
                        <Button variant="ghost" size="icon-sm" onClick={() => navigate(`/guests/${guest.id}`)} aria-label="View guest">
                          <Eye className="h-3.5 w-3.5" />
                        </Button>
                        {has('guest:write') && (
                          <Button variant="ghost" size="icon-sm" onClick={() => openEdit(guest)} aria-label="Edit guest">
                            <Pencil className="h-3.5 w-3.5" />
                          </Button>
                        )}
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
            <Pagination
              page={query.data?.page ?? 0}
              size={size}
              totalElements={query.data?.totalElements ?? 0}
              totalPages={query.data?.totalPages ?? 0}
              onPageChange={setPage}
              onSizeChange={(value) => { setSize(value); setPage(0); }}
            />
          </>
        )}
      </Card>

      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogContent size="lg">
          <DialogHeader>
            <DialogTitle>{editing ? `Edit ${editing.fullName}` : 'Add guest'}</DialogTitle>
            <DialogDescription>ID proof numbers are encrypted with AES-GCM; only the last 4 digits are displayed.</DialogDescription>
          </DialogHeader>
          <div className="grid gap-3 sm:grid-cols-2">
            <Field label="Full name" required error={errors.fullName}>
              <Input value={form.fullName} onChange={(event) => setForm({ ...form, fullName: event.target.value })} />
            </Field>
            <Field label="Mobile" required error={errors.mobile}>
              <Input value={form.mobile} onChange={(event) => setForm({ ...form, mobile: event.target.value })} placeholder="+91 98765 43210" />
            </Field>
            <Field label="Email">
              <Input type="email" value={form.email} onChange={(event) => setForm({ ...form, email: event.target.value })} />
            </Field>
            <Field label="City">
              <Input value={form.city} onChange={(event) => setForm({ ...form, city: event.target.value })} />
            </Field>
            <Field label="State">
              <Input value={form.state} onChange={(event) => setForm({ ...form, state: event.target.value })} />
            </Field>
            <Field label="Country">
              <Input value={form.country} onChange={(event) => setForm({ ...form, country: event.target.value })} />
            </Field>
            <Field label="ID proof type">
              <Select value={form.idProofType} onChange={(event) => setForm({ ...form, idProofType: event.target.value })}>
                {ID_TYPES.map((type) => <option key={type} value={type}>{type.replace(/_/g, ' ')}</option>)}
              </Select>
            </Field>
            <Field
              label="ID proof number"
              hint={editing ? `On file: ${editing.idProofMasked ?? 'none'} — leave blank to keep` : 'Encrypted at rest'}
            >
              <Input value={form.idProofNumber} onChange={(event) => setForm({ ...form, idProofNumber: event.target.value })} />
            </Field>
            <Field label="Category">
              <Select value={form.category} onChange={(event) => setForm({ ...form, category: event.target.value })}>
                {CATEGORIES.map((item) => <option key={item} value={item}>{item}</option>)}
              </Select>
            </Field>
            <Field label="Address" className="sm:col-span-2">
              <Input value={form.address} onChange={(event) => setForm({ ...form, address: event.target.value })} />
            </Field>
            <Field label="Notes" className="sm:col-span-2">
              <Textarea rows={2} value={form.notes} onChange={(event) => setForm({ ...form, notes: event.target.value })} />
            </Field>
            <div className="flex items-center gap-6 sm:col-span-2">
              <Checkbox checked={form.vip} onChange={(value) => setForm({ ...form, vip: value })} label="VIP guest" />
              <Checkbox checked={form.blacklisted} onChange={(value) => setForm({ ...form, blacklisted: value })} label="Blacklisted" description="Blocks new bookings" />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDialogOpen(false)}>Cancel</Button>
            <Button loading={saveMutation.isPending} disabled={!form.fullName || !form.mobile} onClick={() => saveMutation.mutate()}>
              {editing ? 'Save changes' : 'Create guest'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
};

export default GuestsPage;
