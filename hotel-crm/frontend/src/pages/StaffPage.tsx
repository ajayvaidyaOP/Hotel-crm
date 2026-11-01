import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import {
  CalendarCheck2, KeyRound, MoreHorizontal, Pencil, Plus, ShieldCheck, UserCog, UserPlus,
} from 'lucide-react';
import { toast } from 'sonner';
import { PageHeader } from '@/components/common/PageHeader';
import { StatCard } from '@/components/common/StatCard';
import { EmptyState, ErrorState, TableSkeleton } from '@/components/common/States';
import { ClearFilters, FilterSelect, SearchInput, TableToolbar } from '@/components/common/TableToolbar';
import { Pagination } from '@/components/common/Pagination';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Badge, StatusBadge } from '@/components/ui/badge';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Checkbox, Field, Input, Select } from '@/components/ui/input';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import {
  DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuLabel, DropdownMenuSeparator, DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { Avatar } from '@/components/ui/misc';
import { useHotelScope } from '@/context/HotelContext';
import { useAuth } from '@/context/AuthContext';
import { staffApi } from '@/lib/endpoints';
import { fieldErrors, getErrorMessage } from '@/lib/api';
import { formatDate, formatDateTime, relativeTime, labelize } from '@/lib/format';
import { todayISO } from '@/lib/utils';
import type { StaffMember } from '@/lib/types';

const ROLES = ['SUPER_ADMIN', 'HOTEL_MANAGER', 'RECEPTIONIST', 'HOUSEKEEPING', 'ACCOUNTANT'];
const ATTENDANCE_STATUSES = ['PRESENT', 'ABSENT', 'LEAVE', 'HALF_DAY', 'WEEK_OFF'];

const emptyForm = {
  fullName: '',
  email: '',
  phone: '',
  password: '',
  role: 'RECEPTIONIST',
  designation: '',
  employeeCode: '',
  department: '',
  shiftName: 'Morning',
  shiftStart: '09:00',
  shiftEnd: '17:00',
  joinedOn: todayISO(),
  hotelIds: [] as number[],
  active: true,
};

const StaffPage = () => {
  const { hotelId, hotels, isGroupView } = useHotelScope();
  const { has, user } = useAuth();
  const queryClient = useQueryClient();

  const [tab, setTab] = useState('directory');
  const [search, setSearch] = useState('');
  const [roleFilter, setRoleFilter] = useState('');
  const [staffDialog, setStaffDialog] = useState(false);
  const [editing, setEditing] = useState<StaffMember | null>(null);
  const [form, setForm] = useState(emptyForm);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [passwordTarget, setPasswordTarget] = useState<StaffMember | null>(null);
  const [newPassword, setNewPassword] = useState('');
  const [activityTarget, setActivityTarget] = useState<StaffMember | null>(null);
  const [activityPage, setActivityPage] = useState(0);

  const [attendanceDate, setAttendanceDate] = useState(todayISO());
  const [attendanceForm, setAttendanceForm] = useState({ userId: '', status: 'PRESENT', notes: '' });

  const staffQuery = useQuery({
    queryKey: ['staff', { hotelId, search, roleFilter }],
    queryFn: () => staffApi.list({ hotelId: isGroupView ? undefined : hotelId ?? undefined, search: search.trim() || undefined, role: roleFilter || undefined }),
  });

  const attendanceQuery = useQuery({
    queryKey: ['attendance', { hotelId, attendanceDate }],
    queryFn: () => staffApi.attendance({ hotelId: hotelId ?? undefined, date: attendanceDate }),
    enabled: Boolean(hotelId) && tab === 'attendance',
  });

  const attendanceSummaryQuery = useQuery({
    queryKey: ['attendance-summary', { hotelId, attendanceDate }],
    queryFn: () => staffApi.attendanceSummary({ hotelId, from: attendanceDate, to: attendanceDate }),
    enabled: Boolean(hotelId) && tab === 'attendance',
  });

  const activityQuery = useQuery({
    queryKey: ['staff-activity', activityTarget?.id, activityPage],
    queryFn: () => staffApi.activity(activityTarget!.id, { page: activityPage, size: 10 }),
    enabled: Boolean(activityTarget),
  });

  const saveMutation = useMutation({
    mutationFn: () => {
      const base = {
        fullName: form.fullName.trim(),
        phone: form.phone || undefined,
        role: form.role,
        designation: form.designation || undefined,
        employeeCode: form.employeeCode || undefined,
        department: form.department || undefined,
        shiftName: form.shiftName || undefined,
        shiftStart: form.shiftStart || undefined,
        shiftEnd: form.shiftEnd || undefined,
        joinedOn: form.joinedOn || undefined,
        hotelIds: form.hotelIds,
        active: form.active,
      };
      return editing
        ? staffApi.update(editing.id, base)
        : staffApi.create({ ...base, email: form.email.trim(), password: form.password });
    },
    onSuccess: () => {
      toast.success(editing ? 'Staff member updated' : 'Staff account created');
      setStaffDialog(false);
      setEditing(null);
      setForm(emptyForm);
      setErrors({});
      queryClient.invalidateQueries({ queryKey: ['staff'] });
    },
    onError: (err) => {
      setErrors(fieldErrors(err));
      toast.error(getErrorMessage(err));
    },
  });

  const toggleActive = useMutation({
    mutationFn: ({ id, active }: { id: number; active: boolean }) => staffApi.setActive(id, active),
    onSuccess: () => {
      toast.success('Status updated');
      queryClient.invalidateQueries({ queryKey: ['staff'] });
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  const resetPassword = useMutation({
    mutationFn: () => staffApi.resetPassword(passwordTarget!.id, newPassword),
    onSuccess: () => {
      toast.success('Password reset');
      setPasswordTarget(null);
      setNewPassword('');
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  const markAttendance = useMutation({
    mutationFn: () =>
      staffApi.markAttendance({
        hotelId,
        userId: Number(attendanceForm.userId),
        attendanceDate,
        status: attendanceForm.status,
        notes: attendanceForm.notes || undefined,
      }),
    onSuccess: () => {
      toast.success('Attendance saved');
      setAttendanceForm({ userId: '', status: 'PRESENT', notes: '' });
      queryClient.invalidateQueries({ queryKey: ['attendance'] });
      queryClient.invalidateQueries({ queryKey: ['attendance-summary'] });
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  const openCreate = () => {
    setEditing(null);
    setForm({ ...emptyForm, hotelIds: hotelId ? [hotelId] : [] });
    setErrors({});
    setStaffDialog(true);
  };

  const openEdit = (member: StaffMember) => {
    setEditing(member);
    setForm({
      fullName: member.fullName,
      email: member.email,
      phone: member.phone ?? '',
      password: '',
      role: member.role,
      designation: member.designation ?? '',
      employeeCode: member.employeeCode ?? '',
      department: member.department ?? '',
      shiftName: member.shiftName ?? '',
      shiftStart: member.shiftStart?.slice(0, 5) ?? '09:00',
      shiftEnd: member.shiftEnd?.slice(0, 5) ?? '17:00',
      joinedOn: member.joinedOn ?? todayISO(),
      hotelIds: member.hotels.map((hotel) => hotel.id),
      active: member.active,
    });
    setErrors({});
    setStaffDialog(true);
  };

  const staff = staffQuery.data ?? [];
  const summary = attendanceSummaryQuery.data;
  const canWrite = has('staff:write');

  return (
    <div className="space-y-5">
      <PageHeader
        title="Staff & attendance"
        description={`${staff.length} team members · role-based access enforced by the API`}
        actions={canWrite ? (
          <Button size="sm" onClick={openCreate}>
            <UserPlus className="h-4 w-4" /> Add staff
          </Button>
        ) : undefined}
      />

      <Tabs value={tab} onValueChange={setTab}>
        <TabsList>
          <TabsTrigger value="directory"><UserCog className="h-4 w-4" /> Directory</TabsTrigger>
          <TabsTrigger value="attendance"><CalendarCheck2 className="h-4 w-4" /> Attendance</TabsTrigger>
        </TabsList>

        <TabsContent value="directory">
          <Card>
            <TableToolbar>
              <div className="flex flex-1 flex-wrap items-center gap-2">
                <SearchInput value={search} onChange={setSearch} placeholder="Search name, email, code…" />
                <FilterSelect value={roleFilter} onChange={setRoleFilter} placeholder="All roles" options={ROLES.map((role) => ({ value: role, label: labelize(role) }))} />
                <ClearFilters visible={Boolean(search || roleFilter)} onClick={() => { setSearch(''); setRoleFilter(''); }} />
              </div>
            </TableToolbar>

            {staffQuery.isError ? (
              <ErrorState message={getErrorMessage(staffQuery.error)} onRetry={() => staffQuery.refetch()} />
            ) : staffQuery.isLoading ? (
              <TableSkeleton rows={7} columns={5} />
            ) : staff.length === 0 ? (
              <EmptyState icon={UserCog} title="No staff found" description="Invite receptionists, housekeeping and accountants to collaborate." />
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Member</TableHead>
                    <TableHead>Role</TableHead>
                    <TableHead>Hotels</TableHead>
                    <TableHead>Shift</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Last login</TableHead>
                    <TableHead className="text-right">Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {staff.map((member) => (
                    <TableRow key={member.id}>
                      <TableCell>
                        <div className="flex items-center gap-2">
                          <Avatar name={member.fullName} className="h-8 w-8" />
                          <div className="min-w-0">
                            <p className="truncate text-sm font-medium text-navy-900">
                              {member.fullName}
                              {member.id === user?.id && <span className="ml-1 text-[10px] text-muted-foreground">(you)</span>}
                            </p>
                            <p className="truncate text-[11px] text-muted-foreground">{member.email}</p>
                          </div>
                        </div>
                      </TableCell>
                      <TableCell>
                        <Badge tone={member.role === 'SUPER_ADMIN' ? 'purple' : member.role === 'HOTEL_MANAGER' ? 'brand' : 'neutral'}>
                          {labelize(member.role)}
                        </Badge>
                      </TableCell>
                      <TableCell className="max-w-[180px] text-[11px] text-muted-foreground">
                        {member.hotels.map((hotel) => hotel.name).join(', ') || '—'}
                      </TableCell>
                      <TableCell className="text-xs">
                        {member.shiftName ?? '—'}
                        {member.shiftStart && <span className="block text-[11px] text-muted-foreground">{member.shiftStart.slice(0, 5)}–{member.shiftEnd?.slice(0, 5)}</span>}
                      </TableCell>
                      <TableCell><StatusBadge value={member.active ? 'ACTIVE' : 'INACTIVE'} /></TableCell>
                      <TableCell className="text-xs">{member.lastLoginAt ? relativeTime(member.lastLoginAt) : 'Never'}</TableCell>
                      <TableCell className="text-right">
                        <DropdownMenu>
                          <DropdownMenuTrigger asChild>
                            <Button variant="ghost" size="icon-sm" aria-label="Staff actions"><MoreHorizontal className="h-4 w-4" /></Button>
                          </DropdownMenuTrigger>
                          <DropdownMenuContent align="end" className="w-52">
                            <DropdownMenuLabel>{member.employeeCode ?? member.fullName}</DropdownMenuLabel>
                            {canWrite && <DropdownMenuItem onSelect={() => openEdit(member)}><Pencil className="h-4 w-4" /> Edit member</DropdownMenuItem>}
                            {canWrite && (
                              <DropdownMenuItem onSelect={() => { setPasswordTarget(member); setNewPassword(''); }}>
                                <KeyRound className="h-4 w-4" /> Reset password
                              </DropdownMenuItem>
                            )}
                            <DropdownMenuItem onSelect={() => { setActivityTarget(member); setActivityPage(0); }}>
                              <ShieldCheck className="h-4 w-4" /> Activity log
                            </DropdownMenuItem>
                            {canWrite && (
                              <>
                                <DropdownMenuSeparator />
                                <DropdownMenuItem
                                  destructive={member.active}
                                  onSelect={() => toggleActive.mutate({ id: member.id, active: !member.active })}
                                >
                                  {member.active ? 'Deactivate account' : 'Activate account'}
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
            )}
          </Card>
        </TabsContent>

        <TabsContent value="attendance">
          <div className="space-y-4">
            <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-5">
              <StatCard label="Present" value={summary?.present ?? 0} icon={CalendarCheck2} tone="success" />
              <StatCard label="Absent" value={summary?.absent ?? 0} tone="danger" />
              <StatCard label="On leave" value={summary?.leave ?? 0} tone="warning" />
              <StatCard label="Half day" value={summary?.halfDay ?? 0} tone="navy" />
              <StatCard label="Total staff" value={summary?.totalStaff ?? staff.length} tone="brand" />
            </div>

            <Card>
              <TableToolbar>
                <div className="flex flex-wrap items-center gap-2">
                  <input
                    type="date"
                    value={attendanceDate}
                    onChange={(event) => setAttendanceDate(event.target.value)}
                    className="h-9 rounded-lg border border-input px-2 text-sm"
                    aria-label="Attendance date"
                  />
                  <Select value={attendanceForm.userId} onChange={(event) => setAttendanceForm({ ...attendanceForm, userId: event.target.value })} className="w-full sm:w-56">
                    <option value="">Select staff</option>
                    {staff.map((member) => <option key={member.id} value={member.id}>{member.fullName} · {labelize(member.role)}</option>)}
                  </Select>
                  <Select value={attendanceForm.status} onChange={(event) => setAttendanceForm({ ...attendanceForm, status: event.target.value })} className="w-full sm:w-40">
                    {ATTENDANCE_STATUSES.map((status) => <option key={status} value={status}>{labelize(status)}</option>)}
                  </Select>
                  <Input
                    value={attendanceForm.notes}
                    onChange={(event) => setAttendanceForm({ ...attendanceForm, notes: event.target.value })}
                    placeholder="Notes"
                    className="w-full sm:w-48"
                  />
                  <Button
                    size="sm"
                    disabled={!attendanceForm.userId || !hotelId}
                    loading={markAttendance.isPending}
                    onClick={() => markAttendance.mutate()}
                  >
                    <Plus className="h-4 w-4" /> Mark
                  </Button>
                </div>
              </TableToolbar>

              {attendanceQuery.isError ? (
                <ErrorState message={getErrorMessage(attendanceQuery.error)} onRetry={() => attendanceQuery.refetch()} />
              ) : attendanceQuery.isLoading ? (
                <TableSkeleton rows={6} columns={5} />
              ) : (attendanceQuery.data ?? []).length === 0 ? (
                <EmptyState icon={CalendarCheck2} title="No attendance recorded" description="Mark attendance for today to build the register." />
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Staff</TableHead>
                      <TableHead>Role</TableHead>
                      <TableHead>Date</TableHead>
                      <TableHead>Shift</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead>Marked</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {(attendanceQuery.data ?? []).map((record) => (
                      <TableRow key={record.id}>
                        <TableCell className="text-xs font-medium text-navy-900">{record.userName}</TableCell>
                        <TableCell className="text-xs">{record.role ? labelize(record.role) : '—'}</TableCell>
                        <TableCell className="text-xs">{formatDate(record.attendanceDate)}</TableCell>
                        <TableCell className="text-xs">{record.shiftName ?? '—'}</TableCell>
                        <TableCell><StatusBadge value={record.status} /></TableCell>
                        <TableCell className="text-xs">{record.checkInTime ? formatDateTime(record.checkInTime) : '—'}</TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              )}
            </Card>
          </div>
        </TabsContent>
      </Tabs>

      <Dialog open={staffDialog} onOpenChange={setStaffDialog}>
        <DialogContent size="lg">
          <DialogHeader>
            <DialogTitle>{editing ? `Edit ${editing.fullName}` : 'Add staff member'}</DialogTitle>
            <DialogDescription>
              Hotel access and role determine every API permission. Super admins see all hotels.
            </DialogDescription>
          </DialogHeader>
          <div className="grid gap-3 sm:grid-cols-2">
            <Field label="Full name" required error={errors.fullName}>
              <Input value={form.fullName} onChange={(event) => setForm({ ...form, fullName: event.target.value })} />
            </Field>
            <Field label="Email" required error={errors.email}>
              <Input type="email" value={form.email} disabled={Boolean(editing)} onChange={(event) => setForm({ ...form, email: event.target.value })} />
            </Field>
            <Field label="Phone">
              <Input value={form.phone} onChange={(event) => setForm({ ...form, phone: event.target.value })} />
            </Field>
            {!editing && (
              <Field label="Temporary password" required hint="Minimum 8 characters" error={errors.password}>
                <Input type="text" value={form.password} onChange={(event) => setForm({ ...form, password: event.target.value })} />
              </Field>
            )}
            <Field label="Role" required error={errors.role}>
              <Select value={form.role} onChange={(event) => setForm({ ...form, role: event.target.value })}>
                {ROLES.map((role) => <option key={role} value={role}>{labelize(role)}</option>)}
              </Select>
            </Field>
            <Field label="Designation">
              <Input value={form.designation} onChange={(event) => setForm({ ...form, designation: event.target.value })} />
            </Field>
            <Field label="Employee code">
              <Input value={form.employeeCode} onChange={(event) => setForm({ ...form, employeeCode: event.target.value })} />
            </Field>
            <Field label="Department">
              <Input value={form.department} onChange={(event) => setForm({ ...form, department: event.target.value })} />
            </Field>
            <Field label="Shift name">
              <Input value={form.shiftName} onChange={(event) => setForm({ ...form, shiftName: event.target.value })} />
            </Field>
            <Field label="Joined on">
              <Input type="date" value={form.joinedOn} onChange={(event) => setForm({ ...form, joinedOn: event.target.value })} />
            </Field>
            <Field label="Shift start">
              <Input type="time" value={form.shiftStart} onChange={(event) => setForm({ ...form, shiftStart: event.target.value })} />
            </Field>
            <Field label="Shift end">
              <Input type="time" value={form.shiftEnd} onChange={(event) => setForm({ ...form, shiftEnd: event.target.value })} />
            </Field>
            <div className="sm:col-span-2">
              <p className="mb-1.5 text-sm font-medium text-navy-800">Hotel access</p>
              <div className="grid gap-1.5 rounded-lg border border-border p-3 sm:grid-cols-2">
                {hotels.map((hotel) => (
                  <Checkbox
                    key={hotel.id}
                    checked={form.hotelIds.includes(hotel.id)}
                    onChange={(checked) =>
                      setForm({
                        ...form,
                        hotelIds: checked ? [...form.hotelIds, hotel.id] : form.hotelIds.filter((id) => id !== hotel.id),
                      })
                    }
                    label={hotel.name}
                    description={hotel.city ?? undefined}
                  />
                ))}
              </div>
            </div>
            <div className="sm:col-span-2">
              <Checkbox checked={form.active} onChange={(value) => setForm({ ...form, active: value })} label="Account active" />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setStaffDialog(false)}>Cancel</Button>
            <Button
              loading={saveMutation.isPending}
              disabled={!form.fullName || !form.email || (!editing && form.password.length < 8)}
              onClick={() => saveMutation.mutate()}
            >
              {editing ? 'Save changes' : 'Create account'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={Boolean(passwordTarget)} onOpenChange={(open) => !open && setPasswordTarget(null)}>
        <DialogContent size="sm">
          <DialogHeader>
            <DialogTitle>Reset password</DialogTitle>
            <DialogDescription>{passwordTarget?.fullName} · {passwordTarget?.email}</DialogDescription>
          </DialogHeader>
          <Field label="New password" hint="Minimum 8 characters. The user is signed out of existing sessions.">
            <Input value={newPassword} onChange={(event) => setNewPassword(event.target.value)} />
          </Field>
          <DialogFooter>
            <Button variant="outline" onClick={() => setPasswordTarget(null)}>Cancel</Button>
            <Button loading={resetPassword.isPending} disabled={newPassword.length < 8} onClick={() => resetPassword.mutate()}>
              <KeyRound className="h-4 w-4" /> Reset
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={Boolean(activityTarget)} onOpenChange={(open) => !open && setActivityTarget(null)}>
        <DialogContent size="md">
          <DialogHeader>
            <DialogTitle>Activity log</DialogTitle>
            <DialogDescription>{activityTarget?.fullName}</DialogDescription>
          </DialogHeader>
          {activityQuery.isLoading ? (
            <TableSkeleton rows={5} columns={2} />
          ) : (activityQuery.data?.content.length ?? 0) === 0 ? (
            <EmptyState title="No activity recorded" />
          ) : (
            <div className="max-h-80 space-y-2 overflow-y-auto">
              {activityQuery.data?.content.map((log) => (
                <div key={log.id} className="rounded-lg border border-border p-2.5">
                  <div className="flex items-center justify-between">
                    <p className="text-xs font-medium text-navy-900">{labelize(log.action)}</p>
                    <span className="text-[10px] text-muted-foreground">{formatDateTime(log.createdAt)}</span>
                  </div>
                  <p className="text-[11px] text-muted-foreground">{log.description ?? log.entityType}</p>
                </div>
              ))}
            </div>
          )}
          <DialogFooter>
            <div className="flex w-full items-center justify-between">
              <Pagination
                page={activityPage}
                size={10}
                totalElements={activityQuery.data?.totalElements ?? 0}
                totalPages={activityQuery.data?.totalPages ?? 0}
                onPageChange={setActivityPage}
              />
            </div>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
};

export default StaffPage;
