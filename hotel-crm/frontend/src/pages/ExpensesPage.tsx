import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Cell, Pie, PieChart, ResponsiveContainer, Tooltip } from 'recharts';
import { Pencil, Plus, Trash2, Wallet } from 'lucide-react';
import { toast } from 'sonner';
import { PageHeader } from '@/components/common/PageHeader';
import { StatCard } from '@/components/common/StatCard';
import { EmptyState, ErrorState, TableSkeleton } from '@/components/common/States';
import { ClearFilters, FilterSelect, SearchInput, TableToolbar } from '@/components/common/TableToolbar';
import { Pagination } from '@/components/common/Pagination';
import { ConfirmDialog } from '@/components/common/ConfirmDialog';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { StatusBadge } from '@/components/ui/badge';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Field, Input, Select, Textarea } from '@/components/ui/input';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { useHotelScope } from '@/context/HotelContext';
import { useAuth } from '@/context/AuthContext';
import { expenseApi } from '@/lib/endpoints';
import { fieldErrors, getErrorMessage } from '@/lib/api';
import { currency, formatDate, labelize } from '@/lib/format';
import { addDaysISO, todayISO } from '@/lib/utils';
import type { Expense } from '@/lib/types';

const CATEGORIES = [
  'ELECTRICITY', 'WATER', 'MAINTENANCE', 'SALARY', 'FOOD_SUPPLIES', 'LAUNDRY', 'VENDOR', 'OTHER',
];
const METHODS = ['CASH', 'UPI', 'CARD', 'BANK_TRANSFER', 'CHEQUE', 'ONLINE'];
const COLORS = ['#1a5cf5', '#0ea5e9', '#8b5cf6', '#f59e0b', '#10b981', '#ef4444', '#64748b', '#14b8a6'];

const ExpensesPage = () => {
  const { hotelId, hotels, isGroupView } = useHotelScope();
  const { has } = useAuth();
  const queryClient = useQueryClient();

  const [search, setSearch] = useState('');
  const [category, setCategory] = useState('');
  const [range, setRange] = useState({ from: addDaysISO(-29), to: todayISO() });
  const [page, setPage] = useState(0);
  const [size, setSize] = useState(20);

  const [dialogOpen, setDialogOpen] = useState(false);
  const [editing, setEditing] = useState<Expense | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<Expense | null>(null);
  const [form, setForm] = useState({
    hotelId: String(hotelId ?? ''),
    category: 'OTHER',
    description: '',
    amount: '',
    expenseDate: todayISO(),
    vendor: '',
    paymentMethod: 'CASH',
    referenceNo: '',
  });
  const [errors, setErrors] = useState<Record<string, string>>({});

  const scope = { hotelId: isGroupView ? undefined : hotelId ?? undefined };

  const query = useQuery({
    queryKey: ['expenses', { scope, search, category, range, page, size }],
    queryFn: () =>
      expenseApi.list({
        ...scope,
        search: search.trim() || undefined,
        category: category || undefined,
        from: range.from || undefined,
        to: range.to || undefined,
        page,
        size,
      }),
  });

  const summaryQuery = useQuery({
    queryKey: ['expenses', 'summary', { scope, range }],
    queryFn: () => expenseApi.summary({ ...scope, from: range.from, to: range.to }),
  });

  const saveMutation = useMutation({
    mutationFn: () => {
      const payload = {
        hotelId: Number(form.hotelId || hotelId),
        category: form.category,
        description: form.description.trim(),
        amount: Number(form.amount),
        expenseDate: form.expenseDate,
        vendor: form.vendor || undefined,
        paymentMethod: form.paymentMethod,
        referenceNo: form.referenceNo || undefined,
      };
      return editing ? expenseApi.update(editing.id, payload) : expenseApi.create(payload);
    },
    onSuccess: () => {
      toast.success(editing ? 'Expense updated' : 'Expense recorded');
      setDialogOpen(false);
      setEditing(null);
      setErrors({});
      queryClient.invalidateQueries({ queryKey: ['expenses'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard'] });
    },
    onError: (err) => {
      setErrors(fieldErrors(err));
      toast.error(getErrorMessage(err));
    },
  });

  const deleteMutation = useMutation({
    mutationFn: () => expenseApi.remove(deleteTarget!.id),
    onSuccess: () => {
      toast.success('Expense deleted');
      setDeleteTarget(null);
      queryClient.invalidateQueries({ queryKey: ['expenses'] });
    },
    onError: (err) => {
      toast.error(getErrorMessage(err));
      setDeleteTarget(null);
    },
  });

  const rows = query.data?.content ?? [];
  const summary = summaryQuery.data ?? [];
  const total = summary.reduce((sum, item) => sum + Number(item.value), 0);

  const openCreate = () => {
    setEditing(null);
    setForm({
      hotelId: String(hotelId ?? ''),
      category: 'OTHER',
      description: '',
      amount: '',
      expenseDate: todayISO(),
      vendor: '',
      paymentMethod: 'CASH',
      referenceNo: '',
    });
    setErrors({});
    setDialogOpen(true);
  };

  const openEdit = (expense: Expense) => {
    setEditing(expense);
    setForm({
      hotelId: String(expense.hotelId),
      category: expense.category,
      description: expense.description,
      amount: String(expense.amount),
      expenseDate: expense.expenseDate,
      vendor: expense.vendor ?? '',
      paymentMethod: expense.paymentMethod ?? 'CASH',
      referenceNo: expense.referenceNo ?? '',
    });
    setErrors({});
    setDialogOpen(true);
  };

  return (
    <div className="space-y-5">
      <PageHeader
        title="Expenses"
        description="Operational spend by category feeds the profit report and dashboard margins."
        actions={has('expense:write') ? (
          <Button size="sm" onClick={openCreate}>
            <Plus className="h-4 w-4" /> Add expense
          </Button>
        ) : undefined}
      />

      <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard label="Total spend" value={currency(total, true)} hint={`${rows.length} entries in view`} icon={Wallet} tone="warning" />
        {summary.slice(0, 3).map((item) => (
          <StatCard
            key={item.name}
            label={labelize(item.name)}
            value={currency(item.value, true)}
            hint="Period total"
            tone="navy"
          />
        ))}
      </div>

      <div className="grid gap-4 xl:grid-cols-3">
        <Card className="xl:col-span-2">
          <TableToolbar>
            <div className="flex flex-1 flex-wrap items-center gap-2">
              <SearchInput value={search} onChange={setSearch} placeholder="Search description or vendor…" />
              <FilterSelect value={category} onChange={setCategory} placeholder="All categories" options={CATEGORIES.map((item) => ({ value: item, label: labelize(item) }))} />
              <div className="flex items-center gap-1.5 rounded-lg border border-input px-2 py-1">
                <input type="date" value={range.from} onChange={(event) => setRange({ ...range, from: event.target.value })} className="bg-transparent text-xs focus:outline-none" aria-label="From" />
                <span className="text-xs text-muted-foreground">→</span>
                <input type="date" value={range.to} onChange={(event) => setRange({ ...range, to: event.target.value })} className="bg-transparent text-xs focus:outline-none" aria-label="To" />
              </div>
              <ClearFilters visible={Boolean(search || category)} onClick={() => { setSearch(''); setCategory(''); }} />
            </div>
          </TableToolbar>

          {query.isError ? (
            <ErrorState message={getErrorMessage(query.error)} onRetry={() => query.refetch()} />
          ) : query.isLoading ? (
            <TableSkeleton rows={7} columns={5} />
          ) : rows.length === 0 ? (
            <EmptyState icon={Wallet} title="No expenses recorded" description="Track utilities, salaries, vendors and supplies here." />
          ) : (
            <>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Date</TableHead>
                    <TableHead>Category</TableHead>
                    <TableHead>Description</TableHead>
                    {isGroupView && <TableHead>Hotel</TableHead>}
                    <TableHead>Vendor</TableHead>
                    <TableHead>Method</TableHead>
                    <TableHead className="text-right">Amount</TableHead>
                    <TableHead className="text-right">Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {rows.map((expense) => (
                    <TableRow key={expense.id}>
                      <TableCell className="text-xs">{formatDate(expense.expenseDate)}</TableCell>
                      <TableCell><StatusBadge value={expense.category} /></TableCell>
                      <TableCell className="text-xs text-navy-900">{expense.description}</TableCell>
                      {isGroupView && <TableCell className="text-xs">{expense.hotelName}</TableCell>}
                      <TableCell className="text-xs">{expense.vendor ?? '—'}</TableCell>
                      <TableCell className="text-xs">{expense.paymentMethod ? labelize(expense.paymentMethod) : '—'}</TableCell>
                      <TableCell className="text-right text-xs font-medium">{currency(expense.amount)}</TableCell>
                      <TableCell className="text-right">
                        {has('expense:write') && (
                          <div className="flex justify-end gap-1">
                            <Button variant="ghost" size="icon-sm" onClick={() => openEdit(expense)} aria-label="Edit expense"><Pencil className="h-3.5 w-3.5" /></Button>
                            <Button variant="ghost" size="icon-sm" className="text-destructive" onClick={() => setDeleteTarget(expense)} aria-label="Delete expense"><Trash2 className="h-3.5 w-3.5" /></Button>
                          </div>
                        )}
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

        <Card>
          <CardContent className="pt-5">
            <p className="text-sm font-semibold text-navy-900">Spend by category</p>
            {summary.length === 0 ? (
              <EmptyState title="No expense data" />
            ) : (
              <>
                <ResponsiveContainer width="100%" height={220}>
                  <PieChart>
                    <Pie data={summary} dataKey="value" nameKey="name" innerRadius={52} outerRadius={82} paddingAngle={2} strokeWidth={0}>
                      {summary.map((entry, index) => (
                        <Cell key={entry.name} fill={COLORS[index % COLORS.length]} />
                      ))}
                    </Pie>
                    <Tooltip formatter={(value: number) => currency(value)} />
                  </PieChart>
                </ResponsiveContainer>
                <div className="space-y-1">
                  {summary.map((item, index) => (
                    <div key={item.name} className="flex items-center justify-between text-xs">
                      <span className="flex items-center gap-1.5 text-navy-700">
                        <span className="h-2 w-2 rounded-full" style={{ background: COLORS[index % COLORS.length] }} />
                        {labelize(item.name)}
                      </span>
                      <span className="font-medium">{currency(item.value, true)}</span>
                    </div>
                  ))}
                </div>
              </>
            )}
          </CardContent>
        </Card>
      </div>

      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogContent size="md">
          <DialogHeader>
            <DialogTitle>{editing ? 'Edit expense' : 'Add expense'}</DialogTitle>
            <DialogDescription>Expenses reduce monthly profit on the dashboard and reports.</DialogDescription>
          </DialogHeader>
          <div className="grid gap-3 sm:grid-cols-2">
            <Field label="Hotel" required className="sm:col-span-2">
              <Select value={form.hotelId} onChange={(event) => setForm({ ...form, hotelId: event.target.value })}>
                {hotels.map((hotel) => <option key={hotel.id} value={hotel.id}>{hotel.name}</option>)}
              </Select>
            </Field>
            <Field label="Category" required error={errors.category}>
              <Select value={form.category} onChange={(event) => setForm({ ...form, category: event.target.value })}>
                {CATEGORIES.map((item) => <option key={item} value={item}>{labelize(item)}</option>)}
              </Select>
            </Field>
            <Field label="Date" required error={errors.expenseDate}>
              <Input type="date" value={form.expenseDate} onChange={(event) => setForm({ ...form, expenseDate: event.target.value })} />
            </Field>
            <Field label="Description" required className="sm:col-span-2" error={errors.description}>
              <Textarea rows={2} value={form.description} onChange={(event) => setForm({ ...form, description: event.target.value })} placeholder="Diesel for generator" />
            </Field>
            <Field label="Amount" required error={errors.amount}>
              <Input type="number" min={1} value={form.amount} onChange={(event) => setForm({ ...form, amount: event.target.value })} />
            </Field>
            <Field label="Vendor">
              <Input value={form.vendor} onChange={(event) => setForm({ ...form, vendor: event.target.value })} />
            </Field>
            <Field label="Payment method">
              <Select value={form.paymentMethod} onChange={(event) => setForm({ ...form, paymentMethod: event.target.value })}>
                {METHODS.map((item) => <option key={item} value={item}>{labelize(item)}</option>)}
              </Select>
            </Field>
            <Field label="Reference">
              <Input value={form.referenceNo} onChange={(event) => setForm({ ...form, referenceNo: event.target.value })} />
            </Field>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDialogOpen(false)}>Cancel</Button>
            <Button
              loading={saveMutation.isPending}
              disabled={!form.description || !form.amount || !form.hotelId}
              onClick={() => saveMutation.mutate()}
            >
              {editing ? 'Save changes' : 'Record expense'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <ConfirmDialog
        open={Boolean(deleteTarget)}
        onOpenChange={(open) => !open && setDeleteTarget(null)}
        title="Delete expense?"
        description="This removes the entry from reports. Consider reversing it instead for auditability."
        confirmLabel="Delete"
        loading={deleteMutation.isPending}
        onConfirm={() => deleteMutation.mutate()}
      />
    </div>
  );
};

export default ExpensesPage;
