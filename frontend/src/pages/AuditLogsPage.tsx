import { useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { ScrollText, ShieldCheck } from 'lucide-react';
import { PageHeader } from '@/components/common/PageHeader';
import { EmptyState, ErrorState, TableSkeleton } from '@/components/common/States';
import { ClearFilters, SearchInput, TableToolbar } from '@/components/common/TableToolbar';
import { Pagination } from '@/components/common/Pagination';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { useHotelScope } from '@/context/HotelContext';
import { auditApi } from '@/lib/endpoints';
import { getErrorMessage } from '@/lib/api';
import { formatDateTime, relativeTime } from '@/lib/format';

const AuditLogsPage = () => {
  const { hotelId, isGroupView } = useHotelScope();
  const [action, setAction] = useState('');
  const [page, setPage] = useState(0);
  const [size, setSize] = useState(25);

  const query = useQuery({
    queryKey: ['audit-logs', { hotelId, action, page, size }],
    queryFn: () =>
      auditApi.list({
        hotelId: isGroupView ? undefined : hotelId ?? undefined,
        action: action.trim() || undefined,
        page,
        size,
      }),
  });

  const rows = query.data?.content ?? [];

  return (
    <div className="space-y-5">
      <PageHeader
        title="Audit logs"
        description="Append-only trail of logins, booking changes, payments, refunds and staff actions."
        actions={<Badge tone="info"><ShieldCheck className="h-3 w-3" /> Immutable</Badge>}
      />

      <Card>
        <TableToolbar>
          <div className="flex flex-1 flex-wrap items-center gap-2">
            <SearchInput value={action} onChange={setAction} placeholder="Filter by action, e.g. PAYMENT_RECORDED" />
            <ClearFilters visible={Boolean(action)} onClick={() => setAction('')} />
          </div>
          <Button variant="ghost" size="sm" onClick={() => query.refetch()}>Refresh</Button>
        </TableToolbar>

        {query.isError ? (
          <ErrorState message={getErrorMessage(query.error)} onRetry={() => query.refetch()} />
        ) : query.isLoading ? (
          <TableSkeleton rows={8} columns={4} />
        ) : rows.length === 0 ? (
          <EmptyState icon={ScrollText} title="No audit entries" description="Security relevant actions are recorded here automatically." />
        ) : (
          <>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>When</TableHead>
                  <TableHead>Actor</TableHead>
                  <TableHead>Action</TableHead>
                  <TableHead>Entity</TableHead>
                  <TableHead>Description</TableHead>
                  <TableHead>IP</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {rows.map((log) => (
                  <TableRow key={log.id}>
                    <TableCell className="whitespace-nowrap text-xs">
                      {formatDateTime(log.createdAt)}
                      <span className="block text-[10px] text-muted-foreground">{relativeTime(log.createdAt)}</span>
                    </TableCell>
                    <TableCell className="text-xs">{log.actorEmail ?? 'system'}</TableCell>
                    <TableCell>
                      <Badge tone={log.action.includes('DELETE') || log.action.includes('CANCEL') ? 'danger' : log.action.includes('PAYMENT') ? 'success' : 'neutral'}>
                        {log.action}
                      </Badge>
                    </TableCell>
                    <TableCell className="text-xs">
                      {log.entityType ?? '—'}{log.entityId ? ` #${log.entityId}` : ''}
                    </TableCell>
                    <TableCell className="max-w-[360px] truncate text-xs text-muted-foreground">{log.description ?? '—'}</TableCell>
                    <TableCell className="text-[11px] text-muted-foreground">{log.ipAddress ?? '—'}</TableCell>
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
    </div>
  );
};

export default AuditLogsPage;
