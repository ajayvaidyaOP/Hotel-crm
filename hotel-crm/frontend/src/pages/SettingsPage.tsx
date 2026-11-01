import { useEffect, useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { KeyRound, MessageSquareWarning, Pencil, Plus, Shield, Tag, Trash2, UserCircle2 } from 'lucide-react';
import { toast } from 'sonner';
import { PageHeader } from '@/components/common/PageHeader';
import { EmptyState, ErrorState, TableSkeleton } from '@/components/common/States';
import { ConfirmDialog } from '@/components/common/ConfirmDialog';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge, StatusBadge } from '@/components/ui/badge';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Checkbox, Field, Input, Select, Textarea } from '@/components/ui/input';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Avatar, Separator } from '@/components/ui/misc';
import { useAuth } from '@/context/AuthContext';
import { useHotelScope } from '@/context/HotelContext';
import { authApi, couponApi, feedbackApi } from '@/lib/endpoints';
import { fieldErrors, getErrorMessage } from '@/lib/api';
import { formatDate, formatDateTime, labelize } from '@/lib/format';
import { todayISO } from '@/lib/utils';
import type { Coupon } from '@/lib/types';

const ROLE_MATRIX: { role: string; scope: string; highlights: string[] }[] = [
  { role: 'Owner / Super Admin', scope: 'All hotels', highlights: ['Full financials', 'Hotel CRUD', 'Staff & roles', 'Audit logs'] },
  { role: 'Hotel Manager', scope: 'Assigned hotels', highlights: ['Bookings & rooms', 'Pricing', 'Housekeeping', 'Reports'] },
  { role: 'Receptionist', scope: 'Assigned hotels', highlights: ['Front desk', 'Check-in / out', 'Guests', 'Payments'] },
  { role: 'Housekeeping', scope: 'Assigned hotels', highlights: ['Task board', 'Room condition', 'Maintenance'] },
  { role: 'Accountant', scope: 'Assigned hotels', highlights: ['Payments', 'Invoices', 'Expenses', 'Reports'] },
];

const SettingsPage = () => {
  const { user, refresh, has } = useAuth();
  const { hotelId, hotels } = useHotelScope();
  const [params] = useSearchParams();
  const queryClient = useQueryClient();

  const [tab, setTab] = useState(params.get('tab') ?? 'profile');
  const [profile, setProfile] = useState({ fullName: '', phone: '', designation: '' });
  const [passwords, setPasswords] = useState({ currentPassword: '', newPassword: '', confirm: '' });
  const [errors, setErrors] = useState<Record<string, string>>({});

  const [couponDialog, setCouponDialog] = useState(false);
  const [editingCoupon, setEditingCoupon] = useState<Coupon | null>(null);
  const [deleteCoupon, setDeleteCoupon] = useState<Coupon | null>(null);
  const [couponForm, setCouponForm] = useState({
    code: '',
    description: '',
    discountType: 'PERCENTAGE',
    value: '10',
    minAmount: '0',
    maxDiscount: '',
    validFrom: todayISO(),
    validTo: '',
    usageLimit: '',
    active: true,
  });

  const [resolveTarget, setResolveTarget] = useState<{ id: number; guest: string } | null>(null);
  const [resolution, setResolution] = useState('');

  useEffect(() => {
    if (user) {
      setProfile({ fullName: user.fullName, phone: user.phone ?? '', designation: user.designation ?? '' });
    }
  }, [user]);

  useEffect(() => {
    if (params.get('tab')) setTab(params.get('tab') as string);
  }, [params]);

  const couponsQuery = useQuery({
    queryKey: ['coupons', hotelId],
    queryFn: () => couponApi.list(hotelId as number),
    enabled: Boolean(hotelId) && tab === 'coupons' && has('coupon:write'),
  });

  const feedbackQuery = useQuery({
    queryKey: ['feedback', hotelId],
    queryFn: () => feedbackApi.list({ hotelId: hotelId ?? undefined }),
    enabled: tab === 'feedback',
  });

  const profileMutation = useMutation({
    mutationFn: () => authApi.updateProfile({ fullName: profile.fullName.trim(), phone: profile.phone || undefined, designation: profile.designation || undefined }),
    onSuccess: async () => {
      toast.success('Profile updated');
      await refresh();
    },
    onError: (err) => {
      setErrors(fieldErrors(err));
      toast.error(getErrorMessage(err));
    },
  });

  const passwordMutation = useMutation({
    mutationFn: () => authApi.changePassword({ currentPassword: passwords.currentPassword, newPassword: passwords.newPassword }),
    onSuccess: () => {
      toast.success('Password changed — sign in again on other devices');
      setPasswords({ currentPassword: '', newPassword: '', confirm: '' });
      setErrors({});
    },
    onError: (err) => {
      setErrors(fieldErrors(err));
      toast.error(getErrorMessage(err));
    },
  });

  const saveCoupon = useMutation({
    mutationFn: () =>
      editingCoupon
        ? couponApi.update(editingCoupon.id, {
            hotelId,
            code: couponForm.code.trim().toUpperCase(),
            description: couponForm.description || undefined,
            discountType: couponForm.discountType,
            value: Number(couponForm.value),
            minAmount: couponForm.minAmount ? Number(couponForm.minAmount) : undefined,
            maxDiscount: couponForm.maxDiscount ? Number(couponForm.maxDiscount) : undefined,
            validFrom: couponForm.validFrom || undefined,
            validTo: couponForm.validTo || undefined,
            usageLimit: couponForm.usageLimit ? Number(couponForm.usageLimit) : undefined,
            active: couponForm.active,
          })
        : couponApi.create({
            hotelId,
            code: couponForm.code.trim().toUpperCase(),
            description: couponForm.description || undefined,
            discountType: couponForm.discountType,
            value: Number(couponForm.value),
            minAmount: couponForm.minAmount ? Number(couponForm.minAmount) : undefined,
            maxDiscount: couponForm.maxDiscount ? Number(couponForm.maxDiscount) : undefined,
            validFrom: couponForm.validFrom || undefined,
            validTo: couponForm.validTo || undefined,
            usageLimit: couponForm.usageLimit ? Number(couponForm.usageLimit) : undefined,
            active: couponForm.active,
          }),
    onSuccess: () => {
      toast.success(editingCoupon ? 'Coupon updated' : 'Coupon created');
      setCouponDialog(false);
      setEditingCoupon(null);
      queryClient.invalidateQueries({ queryKey: ['coupons'] });
    },
    onError: (err) => {
      setErrors(fieldErrors(err));
      toast.error(getErrorMessage(err));
    },
  });

  const removeCoupon = useMutation({
    mutationFn: () => couponApi.remove(deleteCoupon!.id),
    onSuccess: () => {
      toast.success('Coupon removed');
      setDeleteCoupon(null);
      queryClient.invalidateQueries({ queryKey: ['coupons'] });
    },
    onError: (err) => {
      toast.error(getErrorMessage(err));
      setDeleteCoupon(null);
    },
  });

  const resolveFeedback = useMutation({
    mutationFn: () => feedbackApi.resolve(resolveTarget!.id, resolution),
    onSuccess: () => {
      toast.success('Feedback resolved');
      setResolveTarget(null);
      setResolution('');
      queryClient.invalidateQueries({ queryKey: ['feedback'] });
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  const coupons = couponsQuery.data ?? [];
  const feedback = feedbackQuery.data ?? [];

  return (
    <div className="space-y-5">
      <PageHeader title="Settings" description="Your profile, security, coupons and guest feedback." />

      <Tabs value={tab} onValueChange={setTab}>
        <TabsList>
          <TabsTrigger value="profile"><UserCircle2 className="h-4 w-4" /> Profile</TabsTrigger>
          <TabsTrigger value="security"><KeyRound className="h-4 w-4" /> Security</TabsTrigger>
          <TabsTrigger value="access"><Shield className="h-4 w-4" /> Roles</TabsTrigger>
          {has('coupon:write') && <TabsTrigger value="coupons"><Tag className="h-4 w-4" /> Coupons</TabsTrigger>}
          <TabsTrigger value="feedback"><MessageSquareWarning className="h-4 w-4" /> Feedback</TabsTrigger>
        </TabsList>

        <TabsContent value="profile">
          <div className="grid gap-4 lg:grid-cols-3">
            <Card className="lg:col-span-2">
              <CardHeader><CardTitle>Profile details</CardTitle></CardHeader>
              <CardContent className="space-y-3">
                <div className="grid gap-3 sm:grid-cols-2">
                  <Field label="Full name" required error={errors.fullName}>
                    <Input value={profile.fullName} onChange={(event) => setProfile({ ...profile, fullName: event.target.value })} />
                  </Field>
                  <Field label="Email" hint="Email changes require an owner">
                    <Input value={user?.email ?? ''} disabled />
                  </Field>
                  <Field label="Phone">
                    <Input value={profile.phone} onChange={(event) => setProfile({ ...profile, phone: event.target.value })} />
                  </Field>
                  <Field label="Designation">
                    <Input value={profile.designation} onChange={(event) => setProfile({ ...profile, designation: event.target.value })} />
                  </Field>
                </div>
                <Button loading={profileMutation.isPending} disabled={!profile.fullName} onClick={() => profileMutation.mutate()}>
                  Save profile
                </Button>
              </CardContent>
            </Card>

            <Card>
              <CardHeader><CardTitle>Account</CardTitle></CardHeader>
              <CardContent className="space-y-3 pt-0">
                <div className="flex items-center gap-3">
                  <Avatar name={user?.fullName} className="h-12 w-12 text-sm" />
                  <div>
                    <p className="text-sm font-medium text-navy-900">{user?.fullName}</p>
                    <p className="text-xs text-muted-foreground">{user?.roleLabel}</p>
                  </div>
                </div>
                <Separator />
                <div className="space-y-1 text-xs">
                  <p className="flex justify-between"><span className="text-muted-foreground">Role</span><span className="font-medium">{user?.role}</span></p>
                  <p className="flex justify-between"><span className="text-muted-foreground">Permissions</span><span className="font-medium">{user?.permissions.length}</span></p>
                  <p className="flex justify-between"><span className="text-muted-foreground">Hotels</span><span className="font-medium">{user?.hotels.length}</span></p>
                </div>
                <div className="flex flex-wrap gap-1 pt-1">
                  {user?.hotels.map((hotel) => (
                    <Badge key={hotel.id} tone="neutral">{hotel.code}</Badge>
                  ))}
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="security">
          <div className="grid gap-4 lg:grid-cols-2">
            <Card>
              <CardHeader><CardTitle>Change password</CardTitle></CardHeader>
              <CardContent className="space-y-3">
                <Field label="Current password" required error={errors.currentPassword}>
                  <Input type="password" value={passwords.currentPassword} onChange={(event) => setPasswords({ ...passwords, currentPassword: event.target.value })} />
                </Field>
                <Field label="New password" required hint="At least 8 characters" error={errors.newPassword}>
                  <Input type="password" value={passwords.newPassword} onChange={(event) => setPasswords({ ...passwords, newPassword: event.target.value })} />
                </Field>
                <Field label="Confirm new password" required>
                  <Input type="password" value={passwords.confirm} onChange={(event) => setPasswords({ ...passwords, confirm: event.target.value })} />
                </Field>
                {passwords.confirm && passwords.confirm !== passwords.newPassword && (
                  <p className="text-xs font-medium text-destructive">Passwords do not match.</p>
                )}
                <Button
                  loading={passwordMutation.isPending}
                  disabled={
                    !passwords.currentPassword ||
                    passwords.newPassword.length < 8 ||
                    passwords.newPassword !== passwords.confirm
                  }
                  onClick={() => passwordMutation.mutate()}
                >
                  <KeyRound className="h-4 w-4" /> Update password
                </Button>
              </CardContent>
            </Card>

            <Card>
              <CardHeader><CardTitle>Session & data protection</CardTitle></CardHeader>
              <CardContent className="space-y-2.5 text-xs text-navy-700">
                <p className="flex items-start gap-2"><Shield className="mt-0.5 h-3.5 w-3.5 shrink-0 text-emerald-600" /> JWTs are short-lived; refresh tokens rotate on use and are revoked on logout.</p>
                <p className="flex items-start gap-2"><Shield className="mt-0.5 h-3.5 w-3.5 shrink-0 text-emerald-600" /> Guest ID proofs are encrypted with AES-GCM; only the last four digits are ever returned.</p>
                <p className="flex items-start gap-2"><Shield className="mt-0.5 h-3.5 w-3.5 shrink-0 text-emerald-600" /> No card data is stored — payments capture method and reference only.</p>
                <p className="flex items-start gap-2"><Shield className="mt-0.5 h-3.5 w-3.5 shrink-0 text-emerald-600" /> Login attempts are rate limited and every financial action is appended to the audit log.</p>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="access">
          <Card>
            <CardHeader>
              <CardTitle>Role matrix</CardTitle>
              <p className="text-xs text-muted-foreground">
                Permissions are enforced server-side on every request — the UI simply hides what you cannot use.
              </p>
            </CardHeader>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Role</TableHead>
                  <TableHead>Scope</TableHead>
                  <TableHead>Capabilities</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {ROLE_MATRIX.map((row) => (
                  <TableRow key={row.role}>
                    <TableCell className="text-xs font-medium text-navy-900">{row.role}</TableCell>
                    <TableCell className="text-xs">{row.scope}</TableCell>
                    <TableCell>
                      <div className="flex flex-wrap gap-1">
                        {row.highlights.map((item) => (
                          <Badge key={item} tone="neutral">{item}</Badge>
                        ))}
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </Card>
        </TabsContent>

        {has('coupon:write') && (
          <TabsContent value="coupons">
            <Card>
              <div className="flex items-center justify-between border-b border-border/70 px-4 py-3">
                <div>
                  <p className="text-sm font-semibold text-navy-900">Coupons</p>
                  <p className="text-xs text-muted-foreground">Applied to bookings for {hotels.find((hotel) => hotel.id === hotelId)?.name ?? 'the selected hotel'}.</p>
                </div>
                <Button
                  size="sm"
                  onClick={() => {
                    setEditingCoupon(null);
                    setCouponForm({
                      code: '',
                      description: '',
                      discountType: 'PERCENTAGE',
                      value: '10',
                      minAmount: '0',
                      maxDiscount: '',
                      validFrom: todayISO(),
                      validTo: '',
                      usageLimit: '',
                      active: true,
                    });
                    setCouponDialog(true);
                  }}
                >
                  <Plus className="h-4 w-4" /> New coupon
                </Button>
              </div>
              {couponsQuery.isError ? (
                <ErrorState message={getErrorMessage(couponsQuery.error)} onRetry={() => couponsQuery.refetch()} />
              ) : couponsQuery.isLoading ? (
                <TableSkeleton rows={4} columns={5} />
              ) : coupons.length === 0 ? (
                <EmptyState icon={Tag} title="No coupons" description="Create a promo code to attract direct bookings." />
              ) : (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Code</TableHead>
                      <TableHead>Discount</TableHead>
                      <TableHead>Minimum</TableHead>
                      <TableHead>Validity</TableHead>
                      <TableHead>Usage</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead className="text-right">Actions</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {coupons.map((coupon) => (
                      <TableRow key={coupon.id}>
                        <TableCell>
                          <p className="text-xs font-semibold text-navy-900">{coupon.code}</p>
                          <p className="text-[11px] text-muted-foreground">{coupon.description ?? '—'}</p>
                        </TableCell>
                        <TableCell className="text-xs">
                          {coupon.discountType === 'PERCENTAGE' ? `${coupon.value}%` : `₹${coupon.value}`}
                        </TableCell>
                        <TableCell className="text-xs">₹{coupon.minAmount}</TableCell>
                        <TableCell className="text-xs">
                          {coupon.validFrom ? formatDate(coupon.validFrom) : '—'} → {coupon.validTo ? formatDate(coupon.validTo) : '—'}
                        </TableCell>
                        <TableCell className="text-xs">{coupon.usedCount}{coupon.usageLimit ? ` / ${coupon.usageLimit}` : ''}</TableCell>
                        <TableCell><StatusBadge value={coupon.active ? 'ACTIVE' : 'INACTIVE'} /></TableCell>
                        <TableCell className="text-right">
                          <div className="flex justify-end gap-1">
                            <Button
                              variant="ghost"
                              size="icon-sm"
                              aria-label="Edit coupon"
                              onClick={() => {
                                setEditingCoupon(coupon);
                                setCouponForm({
                                  code: coupon.code,
                                  description: coupon.description ?? '',
                                  discountType: coupon.discountType,
                                  value: String(coupon.value),
                                  minAmount: String(coupon.minAmount),
                                  maxDiscount: coupon.maxDiscount ? String(coupon.maxDiscount) : '',
                                  validFrom: coupon.validFrom ?? '',
                                  validTo: coupon.validTo ?? '',
                                  usageLimit: coupon.usageLimit ? String(coupon.usageLimit) : '',
                                  active: coupon.active,
                                });
                                setCouponDialog(true);
                              }}
                            >
                              <Pencil className="h-3.5 w-3.5" />
                            </Button>
                            <Button variant="ghost" size="icon-sm" className="text-destructive" onClick={() => setDeleteCoupon(coupon)} aria-label="Delete coupon">
                              <Trash2 className="h-3.5 w-3.5" />
                            </Button>
                          </div>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              )}
            </Card>
          </TabsContent>
        )}

        <TabsContent value="feedback">
          <Card>
            <div className="border-b border-border/70 px-4 py-3">
              <p className="text-sm font-semibold text-navy-900">Guest feedback & complaints</p>
              <p className="text-xs text-muted-foreground">Resolve complaints to keep the guest satisfaction score healthy.</p>
            </div>
            {feedbackQuery.isError ? (
              <ErrorState message={getErrorMessage(feedbackQuery.error)} onRetry={() => feedbackQuery.refetch()} />
            ) : feedbackQuery.isLoading ? (
              <TableSkeleton rows={5} columns={4} />
            ) : feedback.length === 0 ? (
              <EmptyState icon={MessageSquareWarning} title="No feedback yet" description="Guest reviews and complaints captured at checkout appear here." />
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Guest</TableHead>
                    <TableHead>Type</TableHead>
                    <TableHead>Rating</TableHead>
                    <TableHead>Comments</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Received</TableHead>
                    <TableHead className="text-right">Action</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {feedback.map((item) => (
                    <TableRow key={item.id}>
                      <TableCell className="text-xs font-medium text-navy-900">{item.guestName ?? '—'}</TableCell>
                      <TableCell><StatusBadge value={item.type} /></TableCell>
                      <TableCell className="text-xs">{item.rating ? `${item.rating}/5` : '—'}</TableCell>
                      <TableCell className="max-w-[280px] text-xs text-muted-foreground">
                        <span className="line-clamp-2">{item.comments ?? '—'}</span>
                        {item.resolution && <span className="mt-0.5 block text-[11px] text-emerald-700">Resolved: {item.resolution}</span>}
                      </TableCell>
                      <TableCell><StatusBadge value={item.status} /></TableCell>
                      <TableCell className="text-xs">{formatDateTime(item.createdAt)}</TableCell>
                      <TableCell className="text-right">
                        {item.status !== 'RESOLVED' && has('guest:write') && (
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => {
                              setResolveTarget({ id: item.id, guest: item.guestName ?? 'guest' });
                              setResolution('');
                            }}
                          >
                            Resolve
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
      </Tabs>

      <Dialog open={couponDialog} onOpenChange={setCouponDialog}>
        <DialogContent size="md">
          <DialogHeader>
            <DialogTitle>{editingCoupon ? `Edit ${editingCoupon.code}` : 'New coupon'}</DialogTitle>
            <DialogDescription>Coupons are validated server-side during booking creation.</DialogDescription>
          </DialogHeader>
          <div className="grid gap-3 sm:grid-cols-2">
            <Field label="Code" required error={errors.code}>
              <Input value={couponForm.code} onChange={(event) => setCouponForm({ ...couponForm, code: event.target.value.toUpperCase() })} placeholder="WELCOME10" />
            </Field>
            <Field label="Description">
              <Input value={couponForm.description} onChange={(event) => setCouponForm({ ...couponForm, description: event.target.value })} />
            </Field>
            <Field label="Discount type">
              <Select value={couponForm.discountType} onChange={(event) => setCouponForm({ ...couponForm, discountType: event.target.value })}>
                <option value="PERCENTAGE">Percentage</option>
                <option value="FLAT">Flat amount</option>
              </Select>
            </Field>
            <Field label="Value" required error={errors.value}>
              <Input type="number" min={0} value={couponForm.value} onChange={(event) => setCouponForm({ ...couponForm, value: event.target.value })} />
            </Field>
            <Field label="Minimum booking amount">
              <Input type="number" min={0} value={couponForm.minAmount} onChange={(event) => setCouponForm({ ...couponForm, minAmount: event.target.value })} />
            </Field>
            <Field label="Maximum discount">
              <Input type="number" min={0} value={couponForm.maxDiscount} onChange={(event) => setCouponForm({ ...couponForm, maxDiscount: event.target.value })} />
            </Field>
            <Field label="Valid from">
              <Input type="date" value={couponForm.validFrom} onChange={(event) => setCouponForm({ ...couponForm, validFrom: event.target.value })} />
            </Field>
            <Field label="Valid to">
              <Input type="date" value={couponForm.validTo} onChange={(event) => setCouponForm({ ...couponForm, validTo: event.target.value })} />
            </Field>
            <Field label="Usage limit">
              <Input type="number" min={1} value={couponForm.usageLimit} onChange={(event) => setCouponForm({ ...couponForm, usageLimit: event.target.value })} placeholder="Unlimited" />
            </Field>
            <div className="flex items-end pb-1">
              <Checkbox checked={couponForm.active} onChange={(value) => setCouponForm({ ...couponForm, active: value })} label="Active" />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setCouponDialog(false)}>Cancel</Button>
            <Button loading={saveCoupon.isPending} disabled={!couponForm.code || !couponForm.value} onClick={() => saveCoupon.mutate()}>
              {editingCoupon ? 'Save changes' : 'Create coupon'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={Boolean(resolveTarget)} onOpenChange={(open) => !open && setResolveTarget(null)}>
        <DialogContent size="sm">
          <DialogHeader>
            <DialogTitle>Resolve feedback</DialogTitle>
            <DialogDescription>What action was taken for {resolveTarget?.guest}?</DialogDescription>
          </DialogHeader>
          <Field label="Resolution" required>
            <Textarea rows={3} value={resolution} onChange={(event) => setResolution(event.target.value)} placeholder="Offered a complimentary upgrade on the next stay." />
          </Field>
          <DialogFooter>
            <Button variant="outline" onClick={() => setResolveTarget(null)}>Cancel</Button>
            <Button loading={resolveFeedback.isPending} disabled={resolution.trim().length < 3} onClick={() => resolveFeedback.mutate()}>
              Mark resolved
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <ConfirmDialog
        open={Boolean(deleteCoupon)}
        onOpenChange={(open) => !open && setDeleteCoupon(null)}
        title={`Delete ${deleteCoupon?.code ?? 'coupon'}?`}
        description="Coupons that have already been used are deactivated instead of deleted."
        confirmLabel="Delete"
        loading={removeCoupon.isPending}
        onConfirm={() => removeCoupon.mutate()}
      />
    </div>
  );
};

export default SettingsPage;
