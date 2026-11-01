import { useMemo, useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import {
  CheckCircle2, ClipboardList, PackageSearch, Plus, Sparkles, Trash2, Wrench,
} from 'lucide-react';
import { toast } from 'sonner';
import { PageHeader } from '@/components/common/PageHeader';
import { EmptyState, ErrorState, TableSkeleton } from '@/components/common/States';
import { ClearFilters, FilterSelect, SearchInput, TableToolbar } from '@/components/common/TableToolbar';
import { ConfirmDialog } from '@/components/common/ConfirmDialog';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Badge, StatusBadge } from '@/components/ui/badge';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Field, Input, Select, Textarea } from '@/components/ui/input';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { useHotelScope } from '@/context/HotelContext';
import { useAuth } from '@/context/AuthContext';
import { housekeepingApi, maintenanceApi, roomApi, staffApi } from '@/lib/endpoints';
import { getErrorMessage } from '@/lib/api';
import { currency, formatDate, formatDateTime, labelize } from '@/lib/format';
import { todayISO } from '@/lib/utils';
import type { HousekeepingTask } from '@/lib/types';

const TASK_TYPES = ['CLEANING', 'DEEP_CLEAN', 'INSPECTION', 'LINEN_CHANGE', 'MAINTENANCE_FOLLOWUP'];
const PRIORITIES = ['LOW', 'NORMAL', 'HIGH', 'URGENT'];
const TASK_STATUSES = ['PENDING', 'IN_PROGRESS', 'COMPLETED', 'INSPECTED', 'CANCELLED'];
const COLUMNS = ['PENDING', 'IN_PROGRESS', 'COMPLETED', 'INSPECTED'];
const MAINTENANCE_STATUSES = ['OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED'];

const HousekeepingPage = () => {
  const { hotelId, isGroupView } = useHotelScope();
  const { has } = useAuth();
  const [params] = useSearchParams();
  const queryClient = useQueryClient();

  const [tab, setTab] = useState(params.get('tab') ?? 'tasks');
  const [status, setStatus] = useState('');
  const [assignee, setAssignee] = useState('');
  const [search, setSearch] = useState('');

  const [taskOpen, setTaskOpen] = useState(false);
  const [taskForm, setTaskForm] = useState({
    roomId: '',
    taskType: 'CLEANING',
    priority: 'NORMAL',
    assignedTo: '',
    notes: '',
    scheduledDate: todayISO(),
  });

  const [maintenanceOpen, setMaintenanceOpen] = useState(false);
  const [maintenanceForm, setMaintenanceForm] = useState({
    roomId: '',
    title: '',
    description: '',
    category: 'PLUMBING',
    priority: 'NORMAL',
    assignedTo: '',
  });
  const [resolveTarget, setResolveTarget] = useState<{ id: number; title: string } | null>(null);
  const [resolveForm, setResolveForm] = useState({ cost: '', resolutionNote: '' });

  const [lostOpen, setLostOpen] = useState(false);
  const [lostForm, setLostForm] = useState({ roomId: '', itemDescription: '', storageLocation: '', notes: '' });
  const [deleteTask, setDeleteTask] = useState<HousekeepingTask | null>(null);

  const scope = { hotelId: isGroupView ? undefined : hotelId ?? undefined };

  const tasksQuery = useQuery({
    queryKey: ['housekeeping', { scope, status, assignee, search }],
    queryFn: () =>
      housekeepingApi.list({
        ...scope,
        status: status || undefined,
        assignedTo: assignee || undefined,
        search: search.trim() || undefined,
      }),
  });

  const roomsQuery = useQuery({
    queryKey: ['rooms', 'hk', hotelId],
    queryFn: () => roomApi.list({ hotelId: scope.hotelId }),
  });

  const staffQuery = useQuery({ queryKey: ['staff', 'hk'], queryFn: () => staffApi.list() });

  const maintenanceQuery = useQuery({
    queryKey: ['maintenance', scope],
    queryFn: () => maintenanceApi.list(scope),
    enabled: tab === 'maintenance',
  });

  const lostFoundQuery = useQuery({
    queryKey: ['lost-found', scope],
    queryFn: () => maintenanceApi.lostFound(scope),
    enabled: tab === 'lost',
  });

  const invalidate = () => {
    queryClient.invalidateQueries({ queryKey: ['housekeeping'] });
    queryClient.invalidateQueries({ queryKey: ['maintenance'] });
    queryClient.invalidateQueries({ queryKey: ['lost-found'] });
    queryClient.invalidateQueries({ queryKey: ['rooms'] });
    queryClient.invalidateQueries({ queryKey: ['dashboard'] });
  };

  const createTask = useMutation({
    mutationFn: () =>
      housekeepingApi.create({
        hotelId: Number(hotelId),
        roomId: taskForm.roomId ? Number(taskForm.roomId) : undefined,
        taskType: taskForm.taskType,
        priority: taskForm.priority,
        assignedTo: taskForm.assignedTo ? Number(taskForm.assignedTo) : undefined,
        notes: taskForm.notes || undefined,
        scheduledDate: taskForm.scheduledDate || undefined,
      }),
    onSuccess: () => {
      toast.success('Housekeeping task created');
      setTaskOpen(false);
      setTaskForm({ roomId: '', taskType: 'CLEANING', priority: 'NORMAL', assignedTo: '', notes: '', scheduledDate: todayISO() });
      invalidate();
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  const updateTaskStatus = useMutation({
    mutationFn: ({ id, status: next }: { id: number; status: string }) =>
      housekeepingApi.updateStatus(id, { status: next }),
    onSuccess: () => {
      toast.success('Task updated');
      invalidate();
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  const deleteTaskMutation = useMutation({
    mutationFn: () => housekeepingApi.remove(deleteTask!.id),
    onSuccess: () => {
      toast.success('Task removed');
      setDeleteTask(null);
      invalidate();
    },
    onError: (err) => {
      toast.error(getErrorMessage(err));
      setDeleteTask(null);
    },
  });

  const createMaintenance = useMutation({
    mutationFn: () =>
      maintenanceApi.create({
        hotelId: Number(hotelId),
        roomId: maintenanceForm.roomId ? Number(maintenanceForm.roomId) : undefined,
        title: maintenanceForm.title,
        description: maintenanceForm.description || undefined,
        category: maintenanceForm.category,
        priority: maintenanceForm.priority,
        assignedTo: maintenanceForm.assignedTo ? Number(maintenanceForm.assignedTo) : undefined,
      }),
    onSuccess: () => {
      toast.success('Maintenance request raised');
      setMaintenanceOpen(false);
      setMaintenanceForm({ roomId: '', title: '', description: '', category: 'PLUMBING', priority: 'NORMAL', assignedTo: '' });
      invalidate();
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  const updateMaintenance = useMutation({
    mutationFn: ({ id, payload }: { id: number; payload: Record<string, unknown> }) => maintenanceApi.update(id, payload),
    onSuccess: () => {
      toast.success('Maintenance updated');
      setResolveTarget(null);
      invalidate();
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  const createLostFound = useMutation({
    mutationFn: () =>
      maintenanceApi.createLostFound({
        hotelId: Number(hotelId),
        roomId: lostForm.roomId ? Number(lostForm.roomId) : undefined,
        itemDescription: lostForm.itemDescription,
        storageLocation: lostForm.storageLocation || undefined,
        notes: lostForm.notes || undefined,
        foundAt: new Date().toISOString(),
      }),
    onSuccess: () => {
      toast.success('Item logged');
      setLostOpen(false);
      setLostForm({ roomId: '', itemDescription: '', storageLocation: '', notes: '' });
      queryClient.invalidateQueries({ queryKey: ['lost-found'] });
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  const updateLostStatus = useMutation({
    mutationFn: ({ id, status: next }: { id: number; status: string }) => maintenanceApi.updateLostFound(id, next),
    onSuccess: () => {
      toast.success('Status updated');
      queryClient.invalidateQueries({ queryKey: ['lost-found'] });
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  const tasks = tasksQuery.data ?? [];
  const rooms = roomsQuery.data ?? [];
  const staff = staffQuery.data ?? [];

  const tasksByStatus = useMemo(() => {
    const map: Record<string, HousekeepingTask[]> = {};
    COLUMNS.forEach((column) => {
      map[column] = tasks.filter((task) => task.status === column);
    });
    return map;
  }, [tasks]);

  return (
    <div className="space-y-5">
      <PageHeader
        title="Housekeeping & maintenance"
        description="Task board, room condition, maintenance requests and lost & found."
        actions={has('housekeeping:write') ? (
          <Button size="sm" onClick={() => setTaskOpen(true)}>
            <Plus className="h-4 w-4" /> New task
          </Button>
        ) : undefined}
      />

      <Tabs value={tab} onValueChange={setTab}>
        <TabsList>
          <TabsTrigger value="tasks"><Sparkles className="h-4 w-4" /> Tasks</TabsTrigger>
          <TabsTrigger value="maintenance"><Wrench className="h-4 w-4" /> Maintenance</TabsTrigger>
          <TabsTrigger value="lost"><PackageSearch className="h-4 w-4" /> Lost & found</TabsTrigger>
        </TabsList>

        <TabsContent value="tasks">
          <div className="space-y-4">
            <Card className="p-3">
              <div className="flex flex-wrap items-center gap-2">
                <SearchInput value={search} onChange={setSearch} placeholder="Search room or notes…" className="w-full sm:w-64" />
                <FilterSelect value={status} onChange={setStatus} placeholder="All statuses" options={TASK_STATUSES.map((item) => ({ value: item, label: labelize(item) }))} />
                <FilterSelect
                  value={assignee}
                  onChange={setAssignee}
                  placeholder="All staff"
                  options={staff.map((member) => ({ value: String(member.id), label: member.fullName }))}
                />
                <ClearFilters visible={Boolean(search || status || assignee)} onClick={() => { setSearch(''); setStatus(''); setAssignee(''); }} />
                <div className="ml-auto flex items-center gap-2 text-xs text-muted-foreground">
                  <ClipboardList className="h-4 w-4" /> {tasks.length} tasks
                </div>
              </div>
            </Card>

            {tasksQuery.isError ? (
              <Card><ErrorState message={getErrorMessage(tasksQuery.error)} onRetry={() => tasksQuery.refetch()} /></Card>
            ) : tasksQuery.isLoading ? (
              <Card><TableSkeleton rows={6} columns={3} /></Card>
            ) : tasks.length === 0 ? (
              <Card>
                <EmptyState
                  icon={Sparkles}
                  title="No housekeeping tasks"
                  description="Tasks are created automatically at checkout, or add one manually."
                  action={has('housekeeping:write') ? <Button size="sm" onClick={() => setTaskOpen(true)}><Plus className="h-4 w-4" /> New task</Button> : undefined}
                />
              </Card>
            ) : (
              <div className="grid gap-3 lg:grid-cols-4">
                {COLUMNS.map((column) => (
                  <div key={column} className="space-y-2">
                    <div className="flex items-center justify-between rounded-lg bg-muted px-3 py-1.5">
                      <p className="text-xs font-semibold uppercase tracking-wide text-navy-700">{labelize(column)}</p>
                      <Badge tone="neutral">{tasksByStatus[column]?.length ?? 0}</Badge>
                    </div>
                    <div className="space-y-2">
                      {(tasksByStatus[column] ?? []).map((task) => (
                        <div key={task.id} className="surface p-3">
                          <div className="flex items-start justify-between gap-2">
                            <div className="min-w-0">
                              <p className="truncate text-sm font-semibold text-navy-900">
                                {task.roomNumber ? `Room ${task.roomNumber}` : task.hotelName}
                              </p>
                              <p className="truncate text-[11px] text-muted-foreground">
                                {labelize(task.taskType)}{task.roomCategory ? ` · ${task.roomCategory}` : ''}
                              </p>
                            </div>
                            <StatusBadge value={task.priority} />
                          </div>
                          {task.notes && <p className="mt-1 line-clamp-2 text-[11px] text-muted-foreground">{task.notes}</p>}
                          <div className="mt-1.5 flex items-center justify-between text-[10px] text-muted-foreground">
                            <span>{task.assignedToName ?? 'Unassigned'}</span>
                            <span>{task.scheduledDate ? formatDate(task.scheduledDate) : formatDateTime(task.createdAt)}</span>
                          </div>
                          {has('housekeeping:write') && (
                            <div className="mt-2 flex flex-wrap gap-1">
                              {nextStatuses(task.status).map((next) => (
                                <Button
                                  key={next}
                                  size="sm"
                                  variant={next === 'CANCELLED' ? 'outline' : 'secondary'}
                                  className="h-6 px-2 text-[10px]"
                                  onClick={() => updateTaskStatus.mutate({ id: task.id, status: next })}
                                >
                                  {labelize(next)}
                                </Button>
                              ))}
                              <Button
                                size="icon-sm"
                                variant="ghost"
                                className="h-6 w-6 text-destructive"
                                onClick={() => setDeleteTask(task)}
                                aria-label="Delete task"
                              >
                                <Trash2 className="h-3 w-3" />
                              </Button>
                            </div>
                          )}
                        </div>
                      ))}
                      {(tasksByStatus[column] ?? []).length === 0 && (
                        <p className="rounded-lg border border-dashed border-border px-3 py-4 text-center text-[11px] text-muted-foreground">
                          Nothing here
                        </p>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </TabsContent>

        <TabsContent value="maintenance">
          <Card>
            <div className="flex items-center justify-between border-b border-border/70 px-4 py-3">
              <div>
                <p className="text-sm font-semibold text-navy-900">Maintenance requests</p>
                <p className="text-xs text-muted-foreground">A room under maintenance is blocked from new bookings automatically.</p>
              </div>
              {has('maintenance:write') && (
                <Button size="sm" onClick={() => setMaintenanceOpen(true)}>
                  <Plus className="h-4 w-4" /> Raise request
                </Button>
              )}
            </div>
            {maintenanceQuery.isError ? (
              <ErrorState message={getErrorMessage(maintenanceQuery.error)} onRetry={() => maintenanceQuery.refetch()} />
            ) : maintenanceQuery.isLoading ? (
              <TableSkeleton rows={5} columns={5} />
            ) : (maintenanceQuery.data ?? []).length === 0 ? (
              <EmptyState icon={Wrench} title="No maintenance requests" description="Raise a request when something needs fixing." />
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Issue</TableHead>
                    <TableHead>Room</TableHead>
                    <TableHead>Category</TableHead>
                    <TableHead>Priority</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Reported</TableHead>
                    <TableHead className="text-right">Cost</TableHead>
                    <TableHead className="text-right">Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {(maintenanceQuery.data ?? []).map((request) => (
                    <TableRow key={request.id}>
                      <TableCell>
                        <p className="text-xs font-medium text-navy-900">{request.title}</p>
                        {request.description && <p className="line-clamp-1 text-[11px] text-muted-foreground">{request.description}</p>}
                      </TableCell>
                      <TableCell className="text-xs">{request.roomNumber ?? '—'}</TableCell>
                      <TableCell className="text-xs">{labelize(request.category)}</TableCell>
                      <TableCell><StatusBadge value={request.priority} /></TableCell>
                      <TableCell><StatusBadge value={request.status} /></TableCell>
                      <TableCell className="text-xs">{formatDateTime(request.reportedAt)}</TableCell>
                      <TableCell className="text-right text-xs">{request.cost ? currency(request.cost) : '—'}</TableCell>
                      <TableCell className="text-right">
                        {has('maintenance:write') && request.status !== 'CLOSED' && (
                          <Button
                            size="sm"
                            variant="outline"
                            onClick={() => {
                              setResolveTarget({ id: request.id, title: request.title });
                              setResolveForm({ cost: request.cost ? String(request.cost) : '', resolutionNote: '' });
                            }}
                          >
                            {request.status === 'OPEN' ? 'Start' : 'Resolve'}
                          </Button>
                        )}
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </Card>
        </TabsContent>

        <TabsContent value="lost">
          <Card>
            <div className="flex items-center justify-between border-b border-border/70 px-4 py-3">
              <div>
                <p className="text-sm font-semibold text-navy-900">Lost & found register</p>
                <p className="text-xs text-muted-foreground">Track items left behind and their return status.</p>
              </div>
              {has('maintenance:write') && (
                <Button size="sm" onClick={() => setLostOpen(true)}>
                  <Plus className="h-4 w-4" /> Log item
                </Button>
              )}
            </div>
            {lostFoundQuery.isError ? (
              <ErrorState message={getErrorMessage(lostFoundQuery.error)} onRetry={() => lostFoundQuery.refetch()} />
            ) : lostFoundQuery.isLoading ? (
              <TableSkeleton rows={5} columns={4} />
            ) : (lostFoundQuery.data ?? []).length === 0 ? (
              <EmptyState icon={PackageSearch} title="Nothing logged" description="Items found in rooms will appear here." />
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Item</TableHead>
                    <TableHead>Room</TableHead>
                    <TableHead>Guest</TableHead>
                    <TableHead>Found</TableHead>
                    <TableHead>Storage</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead className="text-right">Update</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {(lostFoundQuery.data ?? []).map((item) => (
                    <TableRow key={item.id}>
                      <TableCell className="text-xs text-navy-900">{item.itemDescription}</TableCell>
                      <TableCell className="text-xs">{item.roomNumber ?? '—'}</TableCell>
                      <TableCell className="text-xs">{item.guestName ?? '—'}</TableCell>
                      <TableCell className="text-xs">{formatDateTime(item.foundAt)}</TableCell>
                      <TableCell className="text-xs">{item.storageLocation ?? '—'}</TableCell>
                      <TableCell><StatusBadge value={item.status} /></TableCell>
                      <TableCell className="text-right">
                        {has('maintenance:write') && (
                          <Select
                            className="ml-auto h-7 w-[124px] text-xs"
                            value={item.status}
                            onChange={(event) => updateLostStatus.mutate({ id: item.id, status: event.target.value })}
                          >
                            {['STORED', 'RETURNED', 'DISPOSED'].map((option) => (
                              <option key={option} value={option}>{labelize(option)}</option>
                            ))}
                          </Select>
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

      <Dialog open={taskOpen} onOpenChange={setTaskOpen}>
        <DialogContent size="sm">
          <DialogHeader>
            <DialogTitle>New housekeeping task</DialogTitle>
            <DialogDescription>Assign a room and staff member; completing the task updates room condition.</DialogDescription>
          </DialogHeader>
          <div className="space-y-3">
            <Field label="Room" required>
              <Select value={taskForm.roomId} onChange={(event) => setTaskForm({ ...taskForm, roomId: event.target.value })}>
                <option value="">Select room</option>
                {rooms.map((room) => (
                  <option key={room.id} value={room.id}>{room.roomNumber} · {room.categoryName} · {labelize(room.housekeepingStatus)}</option>
                ))}
              </Select>
            </Field>
            <div className="grid grid-cols-2 gap-2">
              <Field label="Task type">
                <Select value={taskForm.taskType} onChange={(event) => setTaskForm({ ...taskForm, taskType: event.target.value })}>
                  {TASK_TYPES.map((type) => <option key={type} value={type}>{labelize(type)}</option>)}
                </Select>
              </Field>
              <Field label="Priority">
                <Select value={taskForm.priority} onChange={(event) => setTaskForm({ ...taskForm, priority: event.target.value })}>
                  {PRIORITIES.map((priority) => <option key={priority} value={priority}>{labelize(priority)}</option>)}
                </Select>
              </Field>
            </div>
            <div className="grid grid-cols-2 gap-2">
              <Field label="Assign to">
                <Select value={taskForm.assignedTo} onChange={(event) => setTaskForm({ ...taskForm, assignedTo: event.target.value })}>
                  <option value="">Unassigned</option>
                  {staff.map((member) => <option key={member.id} value={member.id}>{member.fullName}</option>)}
                </Select>
              </Field>
              <Field label="Scheduled">
                <Input type="date" value={taskForm.scheduledDate} onChange={(event) => setTaskForm({ ...taskForm, scheduledDate: event.target.value })} />
              </Field>
            </div>
            <Field label="Notes">
              <Textarea rows={2} value={taskForm.notes} onChange={(event) => setTaskForm({ ...taskForm, notes: event.target.value })} />
            </Field>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setTaskOpen(false)}>Cancel</Button>
            <Button loading={createTask.isPending} disabled={!taskForm.roomId} onClick={() => createTask.mutate()}>
              Create task
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={maintenanceOpen} onOpenChange={setMaintenanceOpen}>
        <DialogContent size="sm">
          <DialogHeader>
            <DialogTitle>Raise maintenance request</DialogTitle>
            <DialogDescription>The room is marked under maintenance until the request is resolved.</DialogDescription>
          </DialogHeader>
          <div className="space-y-3">
            <Field label="Room">
              <Select value={maintenanceForm.roomId} onChange={(event) => setMaintenanceForm({ ...maintenanceForm, roomId: event.target.value })}>
                <option value="">No specific room</option>
                {rooms.map((room) => <option key={room.id} value={room.id}>{room.roomNumber} · {room.categoryName}</option>)}
              </Select>
            </Field>
            <Field label="Title" required>
              <Input value={maintenanceForm.title} onChange={(event) => setMaintenanceForm({ ...maintenanceForm, title: event.target.value })} placeholder="AC not cooling" />
            </Field>
            <div className="grid grid-cols-2 gap-2">
              <Field label="Category">
                <Select value={maintenanceForm.category} onChange={(event) => setMaintenanceForm({ ...maintenanceForm, category: event.target.value })}>
                  {['ELECTRICAL', 'PLUMBING', 'HVAC', 'FURNITURE', 'ELECTRONICS', 'OTHER'].map((category) => (
                    <option key={category} value={category}>{labelize(category)}</option>
                  ))}
                </Select>
              </Field>
              <Field label="Priority">
                <Select value={maintenanceForm.priority} onChange={(event) => setMaintenanceForm({ ...maintenanceForm, priority: event.target.value })}>
                  {PRIORITIES.map((priority) => <option key={priority} value={priority}>{labelize(priority)}</option>)}
                </Select>
              </Field>
            </div>
            <Field label="Assign to">
              <Select value={maintenanceForm.assignedTo} onChange={(event) => setMaintenanceForm({ ...maintenanceForm, assignedTo: event.target.value })}>
                <option value="">Unassigned</option>
                {staff.map((member) => <option key={member.id} value={member.id}>{member.fullName}</option>)}
              </Select>
            </Field>
            <Field label="Description">
              <Textarea rows={2} value={maintenanceForm.description} onChange={(event) => setMaintenanceForm({ ...maintenanceForm, description: event.target.value })} />
            </Field>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setMaintenanceOpen(false)}>Cancel</Button>
            <Button loading={createMaintenance.isPending} disabled={!maintenanceForm.title} onClick={() => createMaintenance.mutate()}>
              Raise request
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={Boolean(resolveTarget)} onOpenChange={(open) => !open && setResolveTarget(null)}>
        <DialogContent size="sm">
          <DialogHeader>
            <DialogTitle>Update maintenance</DialogTitle>
            <DialogDescription>{resolveTarget?.title}</DialogDescription>
          </DialogHeader>
          <div className="space-y-3">
            <Field label="Status">
              <Select
                value="RESOLVED"
                onChange={() => undefined}
                disabled
              >
                <option value="RESOLVED">Resolved (room returns to dirty → clean)</option>
              </Select>
            </Field>
            <Field label="Cost">
              <Input type="number" min={0} value={resolveForm.cost} onChange={(event) => setResolveForm({ ...resolveForm, cost: event.target.value })} />
            </Field>
            <Field label="Resolution note">
              <Textarea rows={2} value={resolveForm.resolutionNote} onChange={(event) => setResolveForm({ ...resolveForm, resolutionNote: event.target.value })} />
            </Field>
            <div className="flex gap-2">
              <Button
                variant="outline"
                size="sm"
                onClick={() => resolveTarget && updateMaintenance.mutate({ id: resolveTarget.id, payload: { status: 'IN_PROGRESS' } })}
              >
                Mark in progress
              </Button>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setResolveTarget(null)}>Cancel</Button>
            <Button
              loading={updateMaintenance.isPending}
              onClick={() =>
                resolveTarget &&
                updateMaintenance.mutate({
                  id: resolveTarget.id,
                  payload: {
                    status: 'RESOLVED',
                    cost: resolveForm.cost ? Number(resolveForm.cost) : undefined,
                    resolutionNote: resolveForm.resolutionNote || undefined,
                  },
                })
              }
            >
              <CheckCircle2 className="h-4 w-4" /> Resolve
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={lostOpen} onOpenChange={setLostOpen}>
        <DialogContent size="sm">
          <DialogHeader>
            <DialogTitle>Log lost & found item</DialogTitle>
            <DialogDescription>Record where the item is stored so it can be returned.</DialogDescription>
          </DialogHeader>
          <div className="space-y-3">
            <Field label="Room">
              <Select value={lostForm.roomId} onChange={(event) => setLostForm({ ...lostForm, roomId: event.target.value })}>
                <option value="">Unknown</option>
                {rooms.map((room) => <option key={room.id} value={room.id}>{room.roomNumber}</option>)}
              </Select>
            </Field>
            <Field label="Item description" required>
              <Input value={lostForm.itemDescription} onChange={(event) => setLostForm({ ...lostForm, itemDescription: event.target.value })} placeholder="Black leather wallet" />
            </Field>
            <Field label="Storage location">
              <Input value={lostForm.storageLocation} onChange={(event) => setLostForm({ ...lostForm, storageLocation: event.target.value })} placeholder="Front desk safe" />
            </Field>
            <Field label="Notes">
              <Textarea rows={2} value={lostForm.notes} onChange={(event) => setLostForm({ ...lostForm, notes: event.target.value })} />
            </Field>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setLostOpen(false)}>Cancel</Button>
            <Button loading={createLostFound.isPending} disabled={!lostForm.itemDescription} onClick={() => createLostFound.mutate()}>
              Log item
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <ConfirmDialog
        open={Boolean(deleteTask)}
        onOpenChange={(open) => !open && setDeleteTask(null)}
        title="Delete this task?"
        description="Completed work history stays in the room timeline."
        confirmLabel="Delete"
        loading={deleteTaskMutation.isPending}
        onConfirm={() => deleteTaskMutation.mutate()}
      />
    </div>
  );
};

function nextStatuses(status: string): string[] {
  if (status === 'PENDING') return ['IN_PROGRESS', 'CANCELLED'];
  if (status === 'IN_PROGRESS') return ['COMPLETED', 'CANCELLED'];
  if (status === 'COMPLETED') return ['INSPECTED'];
  return [];
}

export default HousekeepingPage;
