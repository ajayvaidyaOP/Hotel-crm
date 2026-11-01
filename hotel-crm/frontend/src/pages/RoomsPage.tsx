import { useMemo, useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import {
  BedDouble, Building2, Layers, Plus, Sparkles, Tag, Trash2, Wrench, Pencil, LayoutGrid, Table2,
} from 'lucide-react';
import { toast } from 'sonner';
import { PageHeader } from '@/components/common/PageHeader';
import { EmptyState, ErrorState, TableSkeleton } from '@/components/common/States';
import { FilterSelect, SearchInput, TableToolbar, ClearFilters } from '@/components/common/TableToolbar';
import { ConfirmDialog } from '@/components/common/ConfirmDialog';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge, StatusBadge } from '@/components/ui/badge';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Checkbox, Field, Input, Select, Textarea } from '@/components/ui/input';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Switch } from '@/components/ui/misc';
import { useHotelScope } from '@/context/HotelContext';
import { useAuth } from '@/context/AuthContext';
import { pricingApi, roomApi } from '@/lib/endpoints';
import { fieldErrors, getErrorMessage } from '@/lib/api';
import { currency, formatDate, labelize } from '@/lib/format';
import { cn } from '@/lib/utils';
import type { RatePlan, Room, RoomCategory } from '@/lib/types';

const BED_TYPES = ['SINGLE', 'DOUBLE', 'QUEEN', 'KING', 'TWIN', 'SOFA_BED'];
const ROOM_TYPES = ['SINGLE', 'DOUBLE', 'TWIN', 'TRIPLE', 'FAMILY', 'SUITE'];
const ROOM_STATUSES = ['AVAILABLE', 'OCCUPIED', 'CLEANING', 'MAINTENANCE', 'OUT_OF_SERVICE'];
const HK_STATUSES = ['CLEAN', 'DIRTY', 'INSPECTED'];
const PRICING_TYPES = ['STANDARD', 'WEEKEND', 'SEASONAL', 'HOLIDAY', 'PROMO'];
const ADJUSTMENT_TYPES = ['FIXED', 'PERCENTAGE', 'INCREMENT'];

const STATUS_TONE: Record<string, string> = {
  AVAILABLE: 'border-emerald-200 bg-emerald-50/70',
  OCCUPIED: 'border-brand-200 bg-brand-50/70',
  CLEANING: 'border-amber-200 bg-amber-50/70',
  MAINTENANCE: 'border-red-200 bg-red-50/70',
  OUT_OF_SERVICE: 'border-slate-200 bg-slate-50',
};

const emptyRoomForm = (categoryId = '') => ({
  categoryId,
  roomNumber: '',
  floor: '1',
  roomType: 'DOUBLE',
  bedType: 'KING',
  maxOccupancy: '2',
  ac: true,
  basePrice: '',
  weekendPrice: '',
  extraPersonCharge: '',
  description: '',
  amenities: '',
  status: 'AVAILABLE',
  housekeepingStatus: 'CLEAN',
  active: true,
});

const emptyCategoryForm = {
  name: '',
  code: '',
  description: '',
  basePrice: '',
  weekendPrice: '',
  extraPersonCharge: '500',
  extraBedCharge: '800',
  earlyCheckinCharge: '500',
  lateCheckoutCharge: '500',
  maxOccupancy: '2',
  amenities: 'Wi-Fi, TV, Air conditioning',
  sortOrder: '1',
  active: true,
};

const RoomsPage = () => {
  const { hotelId, hotel, hotels, setHotelId, isGroupView } = useHotelScope();
  const { has } = useAuth();
  const [params] = useSearchParams();
  const queryClient = useQueryClient();

  const initialTab = params.get('tab') ?? 'inventory';
  const [tab, setTab] = useState(initialTab);
  const [statusFilter, setStatusFilter] = useState('');
  const [hkFilter, setHkFilter] = useState('');
  const [search, setSearch] = useState('');
  const [view, setView] = useState<'grid' | 'table'>('grid');

  const [roomDialog, setRoomDialog] = useState(false);
  const [editingRoom, setEditingRoom] = useState<Room | null>(null);
  const [roomForm, setRoomForm] = useState(emptyRoomForm());
  const [roomErrors, setRoomErrors] = useState<Record<string, string>>({});

  const [bulkDialog, setBulkDialog] = useState(false);
  const [bulkForm, setBulkForm] = useState({ categoryId: '', floor: '1', count: '5', startNumber: '' });

  const [categoryDialog, setCategoryDialog] = useState(false);
  const [editingCategory, setEditingCategory] = useState<RoomCategory | null>(null);
  const [categoryForm, setCategoryForm] = useState(emptyCategoryForm);
  const [categoryErrors, setCategoryErrors] = useState<Record<string, string>>({});

  const [planDialog, setPlanDialog] = useState(false);
  const [editingPlan, setEditingPlan] = useState<RatePlan | null>(null);
  const [planForm, setPlanForm] = useState({
    name: '',
    pricingType: 'WEEKEND',
    adjustmentType: 'PERCENTAGE',
    amount: '20',
    startDate: '',
    endDate: '',
    daysOfWeek: 'SAT,SUN',
    priority: '10',
    categoryId: '',
    active: true,
  });

  const [deleteTarget, setDeleteTarget] = useState<{ type: 'room' | 'category' | 'plan'; id: number; label: string } | null>(null);

  const roomsQuery = useQuery({
    queryKey: ['rooms', { hotelId: isGroupView ? 'all' : hotelId }],
    queryFn: () => roomApi.list({ hotelId: isGroupView ? undefined : hotelId ?? undefined }),
  });
  const categoriesQuery = useQuery({
    queryKey: ['room-categories', hotelId],
    queryFn: () => roomApi.categories(hotelId as number),
    enabled: Boolean(hotelId),
  });
  const plansQuery = useQuery({
    queryKey: ['rate-plans', hotelId],
    queryFn: () => pricingApi.ratePlans(hotelId as number),
    enabled: Boolean(hotelId),
  });

  const categories = categoriesQuery.data ?? [];
  const rooms = roomsQuery.data ?? [];
  const plans = plansQuery.data ?? [];

  const invalidate = () => {
    queryClient.invalidateQueries({ queryKey: ['rooms'] });
    queryClient.invalidateQueries({ queryKey: ['room-categories'] });
    queryClient.invalidateQueries({ queryKey: ['rate-plans'] });
    queryClient.invalidateQueries({ queryKey: ['dashboard'] });
  };

  const saveRoom = useMutation({
    mutationFn: async () => {
      const payload = {
        categoryId: Number(roomForm.categoryId),
        roomNumber: roomForm.roomNumber.trim(),
        floor: Number(roomForm.floor),
        roomType: roomForm.roomType,
        bedType: roomForm.bedType,
        maxOccupancy: Number(roomForm.maxOccupancy),
        ac: roomForm.ac,
        basePrice: roomForm.basePrice ? Number(roomForm.basePrice) : null,
        weekendPrice: roomForm.weekendPrice ? Number(roomForm.weekendPrice) : null,
        extraPersonCharge: roomForm.extraPersonCharge ? Number(roomForm.extraPersonCharge) : null,
        description: roomForm.description || null,
        amenities: roomForm.amenities.split(',').map((item) => item.trim()).filter(Boolean),
        status: roomForm.status,
        housekeepingStatus: roomForm.housekeepingStatus,
        active: roomForm.active,
      };
      if (editingRoom) return roomApi.update(editingRoom.id, payload);
      if (!hotelId) throw new Error('Select a hotel first');
      return roomApi.create(hotelId, payload);
    },
    onSuccess: () => {
      toast.success(editingRoom ? 'Room updated' : 'Room added');
      setRoomDialog(false);
      setEditingRoom(null);
      setRoomErrors({});
      invalidate();
    },
    onError: (err) => {
      setRoomErrors(fieldErrors(err));
      toast.error(getErrorMessage(err));
    },
  });

  const bulkCreate = useMutation({
    mutationFn: () => {
      if (!hotelId) throw new Error('Select a hotel first');
      return roomApi.bulkCreate(hotelId, {
        categoryId: Number(bulkForm.categoryId),
        floor: Number(bulkForm.floor),
        count: Number(bulkForm.count),
        startNumber: bulkForm.startNumber ? Number(bulkForm.startNumber) : undefined,
      });
    },
    onSuccess: (created) => {
      toast.success(`${created.length} rooms created`);
      setBulkDialog(false);
      invalidate();
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  const updateRoomStatus = useMutation({
    mutationFn: ({ id, status, housekeepingStatus }: { id: number; status?: string; housekeepingStatus?: string }) =>
      roomApi.updateStatus(id, { status, housekeepingStatus }),
    onSuccess: () => {
      toast.success('Room status updated');
      invalidate();
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  const saveCategory = useMutation({
    mutationFn: async () => {
      if (!hotelId) throw new Error('Select a hotel first');
      const payload = {
        name: categoryForm.name.trim(),
        code: categoryForm.code.trim().toUpperCase(),
        description: categoryForm.description || null,
        basePrice: Number(categoryForm.basePrice || 0),
        weekendPrice: categoryForm.weekendPrice ? Number(categoryForm.weekendPrice) : null,
        extraPersonCharge: Number(categoryForm.extraPersonCharge || 0),
        extraBedCharge: Number(categoryForm.extraBedCharge || 0),
        earlyCheckinCharge: Number(categoryForm.earlyCheckinCharge || 0),
        lateCheckoutCharge: Number(categoryForm.lateCheckoutCharge || 0),
        maxOccupancy: Number(categoryForm.maxOccupancy || 2),
        amenities: categoryForm.amenities.split(',').map((item) => item.trim()).filter(Boolean),
        sortOrder: Number(categoryForm.sortOrder || 1),
        active: categoryForm.active,
      };
      return editingCategory ? roomApi.updateCategory(hotelId, editingCategory.id, payload) : roomApi.createCategory(hotelId, payload);
    },
    onSuccess: () => {
      toast.success(editingCategory ? 'Category updated' : 'Category created');
      setCategoryDialog(false);
      setEditingCategory(null);
      setCategoryErrors({});
      invalidate();
    },
    onError: (err) => {
      setCategoryErrors(fieldErrors(err));
      toast.error(getErrorMessage(err));
    },
  });

  const savePlan = useMutation({
    mutationFn: async () => {
      if (!hotelId) throw new Error('Select a hotel first');
      const payload = {
        name: planForm.name.trim(),
        pricingType: planForm.pricingType,
        adjustmentType: planForm.adjustmentType,
        amount: Number(planForm.amount || 0),
        startDate: planForm.startDate || null,
        endDate: planForm.endDate || null,
        daysOfWeek: planForm.daysOfWeek || null,
        priority: Number(planForm.priority || 10),
        categoryId: planForm.categoryId ? Number(planForm.categoryId) : null,
        active: planForm.active,
      };
      return editingPlan ? pricingApi.updatePlan(hotelId, editingPlan.id, payload) : pricingApi.createPlan(hotelId, payload);
    },
    onSuccess: () => {
      toast.success(editingPlan ? 'Rate plan updated' : 'Rate plan created');
      setPlanDialog(false);
      setEditingPlan(null);
      invalidate();
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  const removeMutation = useMutation({
    mutationFn: async () => {
      if (!deleteTarget) return;
      if (deleteTarget.type === 'room') return roomApi.delete(deleteTarget.id);
      if (deleteTarget.type === 'category') return roomApi.deleteCategory(hotelId as number, deleteTarget.id);
      return pricingApi.deletePlan(hotelId as number, deleteTarget.id);
    },
    onSuccess: () => {
      toast.success('Deleted');
      setDeleteTarget(null);
      invalidate();
    },
    onError: (err) => {
      toast.error(getErrorMessage(err));
      setDeleteTarget(null);
    },
  });

  const filteredRooms = useMemo(
    () =>
      rooms.filter((room) => {
        if (statusFilter && room.status !== statusFilter) return false;
        if (hkFilter && room.housekeepingStatus !== hkFilter) return false;
        if (search.trim()) {
          const term = search.toLowerCase();
          return (
            room.roomNumber.toLowerCase().includes(term) ||
            room.categoryName.toLowerCase().includes(term) ||
            room.hotelName.toLowerCase().includes(term)
          );
        }
        return true;
      }),
    [rooms, statusFilter, hkFilter, search],
  );

  const statusCounts = useMemo(() => {
    const counts: Record<string, number> = {};
    rooms.forEach((room) => {
      counts[room.status] = (counts[room.status] ?? 0) + 1;
    });
    return counts;
  }, [rooms]);

  const openRoomDialog = (room?: Room) => {
    setEditingRoom(room ?? null);
    if (room) {
      setRoomForm({
        categoryId: String(room.categoryId),
        roomNumber: room.roomNumber,
        floor: String(room.floor ?? 1),
        roomType: room.roomType,
        bedType: room.bedType,
        maxOccupancy: String(room.maxOccupancy ?? 2),
        ac: room.ac,
        basePrice: room.basePrice ? String(room.basePrice) : '',
        weekendPrice: room.weekendPrice ? String(room.weekendPrice) : '',
        extraPersonCharge: room.extraPersonCharge ? String(room.extraPersonCharge) : '',
        description: room.description ?? '',
        amenities: (room.amenities ?? []).join(', '),
        status: room.status,
        housekeepingStatus: room.housekeepingStatus,
        active: room.active,
      });
    } else {
      setRoomForm(emptyRoomForm(categories[0] ? String(categories[0].id) : ''));
    }
    setRoomErrors({});
    setRoomDialog(true);
  };

  const openCategoryDialog = (category?: RoomCategory) => {
    setEditingCategory(category ?? null);
    setCategoryForm(
      category
        ? {
            name: category.name,
            code: category.code,
            description: category.description ?? '',
            basePrice: String(category.basePrice ?? ''),
            weekendPrice: category.weekendPrice ? String(category.weekendPrice) : '',
            extraPersonCharge: String(category.extraPersonCharge ?? 0),
            extraBedCharge: String(category.extraBedCharge ?? 0),
            earlyCheckinCharge: String(category.earlyCheckinCharge ?? 0),
            lateCheckoutCharge: String(category.lateCheckoutCharge ?? 0),
            maxOccupancy: String(category.maxOccupancy ?? 2),
            amenities: (category.amenities ?? []).join(', '),
            sortOrder: String(category.sortOrder ?? 1),
            active: category.active,
          }
        : emptyCategoryForm,
    );
    setCategoryErrors({});
    setCategoryDialog(true);
  };

  const openPlanDialog = (plan?: RatePlan) => {
    setEditingPlan(plan ?? null);
    setPlanForm(
      plan
        ? {
            name: plan.name,
            pricingType: plan.pricingType,
            adjustmentType: plan.adjustmentType,
            amount: String(plan.amount ?? 0),
            startDate: plan.startDate ?? '',
            endDate: plan.endDate ?? '',
            daysOfWeek: plan.daysOfWeek ?? '',
            priority: String(plan.priority ?? 10),
            categoryId: plan.categoryId ? String(plan.categoryId) : '',
            active: plan.active,
          }
        : {
            name: '',
            pricingType: 'WEEKEND',
            adjustmentType: 'PERCENTAGE',
            amount: '20',
            startDate: '',
            endDate: '',
            daysOfWeek: 'SAT,SUN',
            priority: '10',
            categoryId: '',
            active: true,
          },
    );
    setPlanDialog(true);
  };

  const canWrite = has('room:write');

  return (
    <div className="space-y-5">
      <PageHeader
        title="Rooms & rates"
        description={
          isGroupView
            ? `${rooms.length} rooms across ${hotels.length} hotels`
            : `${hotel?.name ?? 'Hotel'} · ${rooms.length} rooms · ${statusCounts.AVAILABLE ?? 0} available`
        }
        actions={
          <>
            <Select
              value={hotelId ?? ''}
              onChange={(event) => setHotelId(Number(event.target.value))}
              className="h-9 w-full sm:w-56"
              aria-label="Hotel"
            >
              {hotels.map((item) => (
                <option key={item.id} value={item.id}>{item.name}</option>
              ))}
            </Select>
            {canWrite && (
              <>
                <Button variant="outline" size="sm" onClick={() => {
                  setBulkForm({ categoryId: categories[0] ? String(categories[0].id) : '', floor: '1', count: '5', startNumber: '' });
                  setBulkDialog(true);
                }}>
                  <Layers className="h-4 w-4" /> Bulk add
                </Button>
                <Button size="sm" onClick={() => openRoomDialog()}>
                  <Plus className="h-4 w-4" /> Add room
                </Button>
              </>
            )}
          </>
        }
      />

      <Tabs value={tab} onValueChange={setTab}>
        <TabsList>
          <TabsTrigger value="inventory"><BedDouble className="h-4 w-4" /> Inventory</TabsTrigger>
          <TabsTrigger value="categories"><Tag className="h-4 w-4" /> Categories</TabsTrigger>
          <TabsTrigger value="rates"><Sparkles className="h-4 w-4" /> Rate plans</TabsTrigger>
        </TabsList>

        <TabsContent value="inventory">
          <Card>
            <TableToolbar>
              <div className="flex flex-1 flex-wrap items-center gap-2">
                <SearchInput value={search} onChange={setSearch} placeholder="Search room number or category…" />
                <FilterSelect
                  value={statusFilter}
                  onChange={setStatusFilter}
                  placeholder="All statuses"
                  options={ROOM_STATUSES.map((status) => ({ value: status, label: labelize(status) }))}
                />
                <FilterSelect
                  value={hkFilter}
                  onChange={setHkFilter}
                  placeholder="All housekeeping"
                  options={HK_STATUSES.map((status) => ({ value: status, label: labelize(status) }))}
                />
                <ClearFilters
                  visible={Boolean(statusFilter || hkFilter || search)}
                  onClick={() => {
                    setStatusFilter('');
                    setHkFilter('');
                    setSearch('');
                  }}
                />
              </div>
              <div className="flex items-center gap-1 rounded-lg bg-muted p-1">
                <button
                  onClick={() => setView('grid')}
                  className={cn('rounded px-2 py-1 text-xs font-medium', view === 'grid' ? 'bg-card shadow-sm' : 'text-muted-foreground')}
                >
                  <LayoutGrid className="h-3.5 w-3.5" />
                </button>
                <button
                  onClick={() => setView('table')}
                  className={cn('rounded px-2 py-1 text-xs font-medium', view === 'table' ? 'bg-card shadow-sm' : 'text-muted-foreground')}
                >
                  <Table2 className="h-3.5 w-3.5" />
                </button>
              </div>
            </TableToolbar>

            {roomsQuery.isError ? (
              <ErrorState message={getErrorMessage(roomsQuery.error)} onRetry={() => roomsQuery.refetch()} />
            ) : roomsQuery.isLoading ? (
              <TableSkeleton rows={6} columns={4} />
            ) : filteredRooms.length === 0 ? (
              <EmptyState
                icon={BedDouble}
                title="No rooms match your filters"
                description="Adjust the filters, or add rooms to this hotel."
                action={canWrite ? <Button size="sm" onClick={() => openRoomDialog()}><Plus className="h-4 w-4" /> Add room</Button> : undefined}
              />
            ) : view === 'grid' ? (
              <div className="grid gap-2.5 p-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
                {filteredRooms.map((room) => (
                  <div key={room.id} className={cn('rounded-lg border p-3 transition-shadow hover:shadow-card', STATUS_TONE[room.status] ?? 'border-border')}>
                    <div className="flex items-start justify-between gap-2">
                      <div>
                        <p className="text-sm font-semibold text-navy-900">Room {room.roomNumber}</p>
                        <p className="text-[11px] text-muted-foreground">
                          {room.categoryName} · Floor {room.floor}
                          {isGroupView && ` · ${room.hotelName}`}
                        </p>
                      </div>
                      <StatusBadge value={room.status} />
                    </div>
                    <div className="mt-2 flex items-center justify-between text-[11px] text-muted-foreground">
                      <span>{room.maxOccupancy} guests · {labelize(room.bedType)}</span>
                      <span className="font-semibold text-navy-800">{currency(room.basePrice)}</span>
                    </div>
                    {room.currentStay && (
                      <p className="mt-1 truncate rounded bg-white/70 px-1.5 py-0.5 text-[10px] text-navy-700">
                        Occupied · out {formatDate(room.currentStay.checkOutDate)}
                      </p>
                    )}
                    {canWrite && (
                      <div className="mt-2 flex flex-wrap items-center gap-1">
                        <select
                          value={room.status}
                          onChange={(event) => updateRoomStatus.mutate({ id: room.id, status: event.target.value })}
                          className="rounded border border-input bg-white px-1.5 py-0.5 text-[10px]"
                          aria-label={`Status for room ${room.roomNumber}`}
                        >
                          {ROOM_STATUSES.map((status) => (
                            <option key={status} value={status}>{labelize(status)}</option>
                          ))}
                        </select>
                        <select
                          value={room.housekeepingStatus}
                          onChange={(event) => updateRoomStatus.mutate({ id: room.id, housekeepingStatus: event.target.value })}
                          className="rounded border border-input bg-white px-1.5 py-0.5 text-[10px]"
                          aria-label={`Housekeeping for room ${room.roomNumber}`}
                        >
                          {HK_STATUSES.map((status) => (
                            <option key={status} value={status}>{labelize(status)}</option>
                          ))}
                        </select>
                        <Button variant="ghost" size="icon-sm" onClick={() => openRoomDialog(room)} aria-label="Edit room">
                          <Pencil className="h-3.5 w-3.5" />
                        </Button>
                        <Button
                          variant="ghost"
                          size="icon-sm"
                          className="text-destructive"
                          onClick={() => setDeleteTarget({ type: 'room', id: room.id, label: `Room ${room.roomNumber}` })}
                          aria-label="Delete room"
                        >
                          <Trash2 className="h-3.5 w-3.5" />
                        </Button>
                      </div>
                    )}
                  </div>
                ))}
              </div>
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
                    <TableHead className="text-right">Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filteredRooms.map((room) => (
                    <TableRow key={room.id}>
                      <TableCell className="font-medium text-navy-900">
                        {room.roomNumber}
                        {isGroupView && <span className="block text-[11px] text-muted-foreground">{room.hotelName}</span>}
                      </TableCell>
                      <TableCell className="text-xs">{room.categoryName}</TableCell>
                      <TableCell className="text-xs">{room.floor}</TableCell>
                      <TableCell><StatusBadge value={room.status} /></TableCell>
                      <TableCell><StatusBadge value={room.housekeepingStatus} /></TableCell>
                      <TableCell className="text-right text-xs font-medium">{currency(room.basePrice)}</TableCell>
                      <TableCell className="text-right">
                        {canWrite && (
                          <div className="flex justify-end gap-1">
                            <Button variant="ghost" size="icon-sm" onClick={() => openRoomDialog(room)} aria-label="Edit"><Pencil className="h-3.5 w-3.5" /></Button>
                            <Button variant="ghost" size="icon-sm" className="text-destructive" onClick={() => setDeleteTarget({ type: 'room', id: room.id, label: `Room ${room.roomNumber}` })} aria-label="Delete"><Trash2 className="h-3.5 w-3.5" /></Button>
                          </div>
                        )}
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </Card>
        </TabsContent>

        <TabsContent value="categories">
          <Card>
            <div className="flex items-center justify-between border-b border-border/70 px-4 py-3">
              <div>
                <p className="text-sm font-semibold text-navy-900">Room categories</p>
                <p className="text-xs text-muted-foreground">Base pricing and occupancy rules used by every room in the category.</p>
              </div>
              {canWrite && (
                <Button size="sm" onClick={() => openCategoryDialog()}>
                  <Plus className="h-4 w-4" /> Add category
                </Button>
              )}
            </div>
            {categoriesQuery.isError ? (
              <ErrorState message={getErrorMessage(categoriesQuery.error)} onRetry={() => categoriesQuery.refetch()} />
            ) : categoriesQuery.isLoading ? (
              <TableSkeleton rows={4} columns={5} />
            ) : categories.length === 0 ? (
              <EmptyState icon={Tag} title="No categories yet" description="Create Standard, Deluxe, Premium, Suite or Family categories." />
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Category</TableHead>
                    <TableHead>Base rate</TableHead>
                    <TableHead>Weekend</TableHead>
                    <TableHead>Extra person</TableHead>
                    <TableHead>Max occupancy</TableHead>
                    <TableHead>Rooms</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead className="text-right">Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {categories.map((category) => (
                    <TableRow key={category.id}>
                      <TableCell>
                        <p className="font-medium text-navy-900">{category.name}</p>
                        <p className="text-[11px] text-muted-foreground">{category.code}</p>
                      </TableCell>
                      <TableCell className="text-xs font-medium">{currency(category.basePrice)}</TableCell>
                      <TableCell className="text-xs">{category.weekendPrice ? currency(category.weekendPrice) : '—'}</TableCell>
                      <TableCell className="text-xs">{currency(category.extraPersonCharge)}</TableCell>
                      <TableCell className="text-xs">{category.maxOccupancy}</TableCell>
                      <TableCell className="text-xs">{category.roomCount}</TableCell>
                      <TableCell><StatusBadge value={category.active ? 'ACTIVE' : 'INACTIVE'} /></TableCell>
                      <TableCell className="text-right">
                        {canWrite && (
                          <div className="flex justify-end gap-1">
                            <Button variant="ghost" size="icon-sm" onClick={() => openCategoryDialog(category)} aria-label="Edit"><Pencil className="h-3.5 w-3.5" /></Button>
                            <Button variant="ghost" size="icon-sm" className="text-destructive" onClick={() => setDeleteTarget({ type: 'category', id: category.id, label: category.name })} aria-label="Delete"><Trash2 className="h-3.5 w-3.5" /></Button>
                          </div>
                        )}
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </Card>
        </TabsContent>

        <TabsContent value="rates">
          <Card>
            <div className="flex items-center justify-between border-b border-border/70 px-4 py-3">
              <div>
                <p className="text-sm font-semibold text-navy-900">Dynamic rate plans</p>
                <p className="text-xs text-muted-foreground">
                  Weekend, seasonal, holiday and promo adjustments are applied on top of the category base rate.
                </p>
              </div>
              {has('pricing:write') && (
                <Button size="sm" onClick={() => openPlanDialog()}>
                  <Plus className="h-4 w-4" /> Add rate plan
                </Button>
              )}
            </div>
            {plansQuery.isError ? (
              <ErrorState message={getErrorMessage(plansQuery.error)} onRetry={() => plansQuery.refetch()} />
            ) : plansQuery.isLoading ? (
              <TableSkeleton rows={4} columns={5} />
            ) : plans.length === 0 ? (
              <EmptyState icon={Sparkles} title="No rate plans" description="Base category rates apply until you add a plan." />
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Plan</TableHead>
                    <TableHead>Type</TableHead>
                    <TableHead>Adjustment</TableHead>
                    <TableHead>Applies to</TableHead>
                    <TableHead>Window</TableHead>
                    <TableHead>Priority</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead className="text-right">Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {plans.map((plan) => (
                    <TableRow key={plan.id}>
                      <TableCell className="font-medium text-navy-900">{plan.name}</TableCell>
                      <TableCell><Badge tone="info">{labelize(plan.pricingType)}</Badge></TableCell>
                      <TableCell className="text-xs">
                        {plan.adjustmentType === 'PERCENTAGE' ? `${plan.amount}%` : currency(plan.amount)}
                        <span className="ml-1 text-muted-foreground">{labelize(plan.adjustmentType)}</span>
                      </TableCell>
                      <TableCell className="text-xs">{plan.categoryName ?? plan.roomNumber ?? 'All rooms'}</TableCell>
                      <TableCell className="text-xs">
                        {plan.startDate || plan.endDate ? `${formatDate(plan.startDate)} → ${formatDate(plan.endDate)}` : plan.daysOfWeek ?? 'Always'}
                      </TableCell>
                      <TableCell className="text-xs">{plan.priority}</TableCell>
                      <TableCell><StatusBadge value={plan.active ? 'ACTIVE' : 'INACTIVE'} /></TableCell>
                      <TableCell className="text-right">
                        {has('pricing:write') && (
                          <div className="flex justify-end gap-1">
                            <Button variant="ghost" size="icon-sm" onClick={() => openPlanDialog(plan)} aria-label="Edit"><Pencil className="h-3.5 w-3.5" /></Button>
                            <Button variant="ghost" size="icon-sm" className="text-destructive" onClick={() => setDeleteTarget({ type: 'plan', id: plan.id, label: plan.name })} aria-label="Delete"><Trash2 className="h-3.5 w-3.5" /></Button>
                          </div>
                        )}
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </Card>
        </TabsContent>
      </Tabs>

      {/* Room dialog */}
      <Dialog open={roomDialog} onOpenChange={setRoomDialog}>
        <DialogContent size="lg">
          <DialogHeader>
            <DialogTitle>{editingRoom ? `Edit room ${editingRoom.roomNumber}` : 'Add room'}</DialogTitle>
            <DialogDescription>Operational status is separate from booking state and drives the room rack.</DialogDescription>
          </DialogHeader>
          <div className="grid gap-3 sm:grid-cols-2">
            <Field label="Category" required error={roomErrors.categoryId}>
              <Select
                value={roomForm.categoryId}
                onChange={(event) => {
                  const category = categories.find((item) => item.id === Number(event.target.value));
                  setRoomForm({
                    ...roomForm,
                    categoryId: event.target.value,
                    basePrice: roomForm.basePrice || (category ? String(category.basePrice) : ''),
                    weekendPrice: roomForm.weekendPrice || (category?.weekendPrice ? String(category.weekendPrice) : ''),
                    maxOccupancy: category ? String(category.maxOccupancy) : roomForm.maxOccupancy,
                  });
                }}
              >
                <option value="">Select category</option>
                {categories.map((category) => (
                  <option key={category.id} value={category.id}>{category.name}</option>
                ))}
              </Select>
            </Field>
            <Field label="Room number" required error={roomErrors.roomNumber}>
              <Input value={roomForm.roomNumber} onChange={(event) => setRoomForm({ ...roomForm, roomNumber: event.target.value })} placeholder="101" />
            </Field>
            <Field label="Floor">
              <Input type="number" min={0} value={roomForm.floor} onChange={(event) => setRoomForm({ ...roomForm, floor: event.target.value })} />
            </Field>
            <Field label="Max occupancy">
              <Input type="number" min={1} max={10} value={roomForm.maxOccupancy} onChange={(event) => setRoomForm({ ...roomForm, maxOccupancy: event.target.value })} />
            </Field>
            <Field label="Room type">
              <Select value={roomForm.roomType} onChange={(event) => setRoomForm({ ...roomForm, roomType: event.target.value })}>
                {ROOM_TYPES.map((type) => <option key={type} value={type}>{labelize(type)}</option>)}
              </Select>
            </Field>
            <Field label="Bed type">
              <Select value={roomForm.bedType} onChange={(event) => setRoomForm({ ...roomForm, bedType: event.target.value })}>
                {BED_TYPES.map((type) => <option key={type} value={type}>{labelize(type)}</option>)}
              </Select>
            </Field>
            <Field label="Rate override" hint="Blank uses the category rate">
              <Input type="number" min={0} value={roomForm.basePrice} onChange={(event) => setRoomForm({ ...roomForm, basePrice: event.target.value })} />
            </Field>
            <Field label="Weekend override">
              <Input type="number" min={0} value={roomForm.weekendPrice} onChange={(event) => setRoomForm({ ...roomForm, weekendPrice: event.target.value })} />
            </Field>
            <Field label="Status">
              <Select value={roomForm.status} onChange={(event) => setRoomForm({ ...roomForm, status: event.target.value })}>
                {ROOM_STATUSES.map((status) => <option key={status} value={status}>{labelize(status)}</option>)}
              </Select>
            </Field>
            <Field label="Housekeeping">
              <Select value={roomForm.housekeepingStatus} onChange={(event) => setRoomForm({ ...roomForm, housekeepingStatus: event.target.value })}>
                {HK_STATUSES.map((status) => <option key={status} value={status}>{labelize(status)}</option>)}
              </Select>
            </Field>
            <Field label="Amenities" hint="Comma separated" className="sm:col-span-2">
              <Input value={roomForm.amenities} onChange={(event) => setRoomForm({ ...roomForm, amenities: event.target.value })} />
            </Field>
            <Field label="Description" className="sm:col-span-2">
              <Textarea value={roomForm.description} onChange={(event) => setRoomForm({ ...roomForm, description: event.target.value })} rows={2} />
            </Field>
            <div className="flex items-center gap-6 sm:col-span-2">
              <Checkbox checked={roomForm.ac} onChange={(value) => setRoomForm({ ...roomForm, ac: value })} label="Air conditioned" />
              <Checkbox checked={roomForm.active} onChange={(value) => setRoomForm({ ...roomForm, active: value })} label="Bookable" description="Inactive rooms stay out of the rack" />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setRoomDialog(false)}>Cancel</Button>
            <Button loading={saveRoom.isPending} onClick={() => saveRoom.mutate()} disabled={!roomForm.categoryId || !roomForm.roomNumber}>
              {editingRoom ? 'Save changes' : 'Add room'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Bulk dialog */}
      <Dialog open={bulkDialog} onOpenChange={setBulkDialog}>
        <DialogContent size="sm">
          <DialogHeader>
            <DialogTitle>Bulk create rooms</DialogTitle>
            <DialogDescription>Sequentially numbered rooms inherit the category pricing.</DialogDescription>
          </DialogHeader>
          <div className="space-y-3">
            <Field label="Category" required>
              <Select value={bulkForm.categoryId} onChange={(event) => setBulkForm({ ...bulkForm, categoryId: event.target.value })}>
                <option value="">Select category</option>
                {categories.map((category) => <option key={category.id} value={category.id}>{category.name}</option>)}
              </Select>
            </Field>
            <div className="grid grid-cols-3 gap-2">
              <Field label="Floor"><Input type="number" min={0} value={bulkForm.floor} onChange={(event) => setBulkForm({ ...bulkForm, floor: event.target.value })} /></Field>
              <Field label="Count"><Input type="number" min={1} max={50} value={bulkForm.count} onChange={(event) => setBulkForm({ ...bulkForm, count: event.target.value })} /></Field>
              <Field label="Start #"><Input type="number" min={1} value={bulkForm.startNumber} onChange={(event) => setBulkForm({ ...bulkForm, startNumber: event.target.value })} placeholder="auto" /></Field>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setBulkDialog(false)}>Cancel</Button>
            <Button loading={bulkCreate.isPending} onClick={() => bulkCreate.mutate()} disabled={!bulkForm.categoryId}>
              <Layers className="h-4 w-4" /> Create rooms
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Category dialog */}
      <Dialog open={categoryDialog} onOpenChange={setCategoryDialog}>
        <DialogContent size="lg">
          <DialogHeader>
            <DialogTitle>{editingCategory ? `Edit ${editingCategory.name}` : 'New room category'}</DialogTitle>
            <DialogDescription>Standard, Deluxe, Premium, Suite and Family categories.</DialogDescription>
          </DialogHeader>
          <div className="grid gap-3 sm:grid-cols-2">
            <Field label="Name" required error={categoryErrors.name}>
              <Input value={categoryForm.name} onChange={(event) => setCategoryForm({ ...categoryForm, name: event.target.value })} placeholder="Deluxe" />
            </Field>
            <Field label="Code" required error={categoryErrors.code}>
              <Input value={categoryForm.code} maxLength={8} onChange={(event) => setCategoryForm({ ...categoryForm, code: event.target.value.toUpperCase() })} placeholder="DLX" />
            </Field>
            <Field label="Base rate" required error={categoryErrors.basePrice}>
              <Input type="number" min={0} value={categoryForm.basePrice} onChange={(event) => setCategoryForm({ ...categoryForm, basePrice: event.target.value })} placeholder="4500" />
            </Field>
            <Field label="Weekend rate">
              <Input type="number" min={0} value={categoryForm.weekendPrice} onChange={(event) => setCategoryForm({ ...categoryForm, weekendPrice: event.target.value })} />
            </Field>
            <Field label="Extra person / night">
              <Input type="number" min={0} value={categoryForm.extraPersonCharge} onChange={(event) => setCategoryForm({ ...categoryForm, extraPersonCharge: event.target.value })} />
            </Field>
            <Field label="Extra bed / night">
              <Input type="number" min={0} value={categoryForm.extraBedCharge} onChange={(event) => setCategoryForm({ ...categoryForm, extraBedCharge: event.target.value })} />
            </Field>
            <Field label="Early check-in charge">
              <Input type="number" min={0} value={categoryForm.earlyCheckinCharge} onChange={(event) => setCategoryForm({ ...categoryForm, earlyCheckinCharge: event.target.value })} />
            </Field>
            <Field label="Late check-out charge">
              <Input type="number" min={0} value={categoryForm.lateCheckoutCharge} onChange={(event) => setCategoryForm({ ...categoryForm, lateCheckoutCharge: event.target.value })} />
            </Field>
            <Field label="Max occupancy">
              <Input type="number" min={1} max={10} value={categoryForm.maxOccupancy} onChange={(event) => setCategoryForm({ ...categoryForm, maxOccupancy: event.target.value })} />
            </Field>
            <Field label="Sort order">
              <Input type="number" min={0} value={categoryForm.sortOrder} onChange={(event) => setCategoryForm({ ...categoryForm, sortOrder: event.target.value })} />
            </Field>
            <Field label="Amenities" hint="Comma separated" className="sm:col-span-2">
              <Input value={categoryForm.amenities} onChange={(event) => setCategoryForm({ ...categoryForm, amenities: event.target.value })} />
            </Field>
            <Field label="Description" className="sm:col-span-2">
              <Textarea value={categoryForm.description} onChange={(event) => setCategoryForm({ ...categoryForm, description: event.target.value })} rows={2} />
            </Field>
            <div className="sm:col-span-2">
              <Checkbox checked={categoryForm.active} onChange={(value) => setCategoryForm({ ...categoryForm, active: value })} label="Active" />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setCategoryDialog(false)}>Cancel</Button>
            <Button loading={saveCategory.isPending} onClick={() => saveCategory.mutate()} disabled={!categoryForm.name || !categoryForm.code || !categoryForm.basePrice}>
              {editingCategory ? 'Save changes' : 'Create category'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Rate plan dialog */}
      <Dialog open={planDialog} onOpenChange={setPlanDialog}>
        <DialogContent size="md">
          <DialogHeader>
            <DialogTitle>{editingPlan ? `Edit ${editingPlan.name}` : 'New rate plan'}</DialogTitle>
            <DialogDescription>Plans stack by priority — the highest priority matching plan wins for each night.</DialogDescription>
          </DialogHeader>
          <div className="grid gap-3 sm:grid-cols-2">
            <Field label="Plan name" required className="sm:col-span-2">
              <Input value={planForm.name} onChange={(event) => setPlanForm({ ...planForm, name: event.target.value })} placeholder="Monsoon promo" />
            </Field>
            <Field label="Pricing type">
              <Select value={planForm.pricingType} onChange={(event) => setPlanForm({ ...planForm, pricingType: event.target.value })}>
                {PRICING_TYPES.map((type) => <option key={type} value={type}>{labelize(type)}</option>)}
              </Select>
            </Field>
            <Field label="Adjustment">
              <Select value={planForm.adjustmentType} onChange={(event) => setPlanForm({ ...planForm, adjustmentType: event.target.value })}>
                {ADJUSTMENT_TYPES.map((type) => <option key={type} value={type}>{labelize(type)}</option>)}
              </Select>
            </Field>
            <Field label={planForm.adjustmentType === 'PERCENTAGE' ? 'Percent' : 'Amount'} required>
              <Input type="number" min={0} value={planForm.amount} onChange={(event) => setPlanForm({ ...planForm, amount: event.target.value })} />
            </Field>
            <Field label="Priority" hint="Higher wins">
              <Input type="number" min={0} value={planForm.priority} onChange={(event) => setPlanForm({ ...planForm, priority: event.target.value })} />
            </Field>
            <Field label="Valid from">
              <Input type="date" value={planForm.startDate} onChange={(event) => setPlanForm({ ...planForm, startDate: event.target.value })} />
            </Field>
            <Field label="Valid to">
              <Input type="date" value={planForm.endDate} onChange={(event) => setPlanForm({ ...planForm, endDate: event.target.value })} />
            </Field>
            <Field label="Days of week" hint="e.g. SAT,SUN">
              <Input value={planForm.daysOfWeek} onChange={(event) => setPlanForm({ ...planForm, daysOfWeek: event.target.value.toUpperCase() })} />
            </Field>
            <Field label="Category">
              <Select value={planForm.categoryId} onChange={(event) => setPlanForm({ ...planForm, categoryId: event.target.value })}>
                <option value="">All categories</option>
                {categories.map((category) => <option key={category.id} value={category.id}>{category.name}</option>)}
              </Select>
            </Field>
            <div className="sm:col-span-2 flex items-center gap-2">
              <Switch checked={planForm.active} onChange={(value) => setPlanForm({ ...planForm, active: value })} />
              <span className="text-sm text-navy-800">Plan active</span>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setPlanDialog(false)}>Cancel</Button>
            <Button loading={savePlan.isPending} onClick={() => savePlan.mutate()} disabled={!planForm.name}>
              {editingPlan ? 'Save changes' : 'Create plan'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <ConfirmDialog
        open={Boolean(deleteTarget)}
        onOpenChange={(open) => !open && setDeleteTarget(null)}
        title={`Delete ${deleteTarget?.label ?? ''}?`}
        description="Rooms with booking history or categories that still contain rooms cannot be deleted."
        confirmLabel="Delete"
        loading={removeMutation.isPending}
        onConfirm={() => removeMutation.mutate()}
      />
    </div>
  );
};

export default RoomsPage;
