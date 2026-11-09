import { useState } from 'react';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { Bell, CheckCheck, Inbox } from 'lucide-react';
import { toast } from 'sonner';
import { PageHeader } from '@/components/common/PageHeader';
import { EmptyState, ErrorState, TableSkeleton } from '@/components/common/States';
import { FilterSelect, TableToolbar } from '@/components/common/TableToolbar';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Badge, StatusBadge } from '@/components/ui/badge';
import { notificationApi } from '@/lib/endpoints';
import { getErrorMessage } from '@/lib/api';
import { relativeTime } from '@/lib/format';
import { cn } from '@/lib/utils';

const SEVERITIES = ['INFO', 'SUCCESS', 'WARNING', 'CRITICAL'];

const NotificationsPage = () => {
  const queryClient = useQueryClient();
  const [severity, setSeverity] = useState('');

  const query = useQuery({ queryKey: ['notifications', 'all'], queryFn: () => notificationApi.list(60) });

  const markRead = useMutation({
    mutationFn: (id: number) => notificationApi.markRead(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['notifications'] });
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  const markAll = useMutation({
    mutationFn: () => notificationApi.markAllRead(),
    onSuccess: () => {
      toast.success('All notifications marked as read');
      queryClient.invalidateQueries({ queryKey: ['notifications'] });
    },
    onError: (err) => toast.error(getErrorMessage(err)),
  });

  const notifications = (query.data ?? []).filter((item) => !severity || item.severity === severity);
  const unread = (query.data ?? []).filter((item) => !item.isRead).length;

  return (
    <div className="space-y-5">
      <PageHeader
        title="Notifications"
        description={`${unread} unread · in-app alerts are queued for email and WhatsApp delivery when providers are configured`}
        actions={
          <Button size="sm" variant="outline" loading={markAll.isPending} disabled={unread === 0} onClick={() => markAll.mutate()}>
            <CheckCheck className="h-4 w-4" /> Mark all read
          </Button>
        }
      />

      <Card>
        <TableToolbar>
          <div className="flex flex-wrap items-center gap-2">
            <FilterSelect value={severity} onChange={setSeverity} placeholder="All severities" options={SEVERITIES.map((item) => ({ value: item, label: item }))} />
          </div>
          <Badge tone={unread > 0 ? 'brand' : 'neutral'}>{unread} unread</Badge>
        </TableToolbar>

        {query.isError ? (
          <ErrorState message={getErrorMessage(query.error)} onRetry={() => query.refetch()} />
        ) : query.isLoading ? (
          <TableSkeleton rows={6} columns={2} />
        ) : notifications.length === 0 ? (
          <EmptyState icon={Inbox} title="No notifications" description="Booking, payment and housekeeping alerts will appear here." />
        ) : (
          <div className="divide-y divide-border">
            {notifications.map((notification) => (
              <div key={notification.id} className={cn('flex items-start gap-3 p-4', !notification.isRead && 'bg-brand-50/40')}>
                <span className="mt-0.5 grid h-8 w-8 shrink-0 place-items-center rounded-lg bg-muted">
                  <Bell className="h-4 w-4 text-navy-700" />
                </span>
                <div className="min-w-0 flex-1">
                  <div className="flex flex-wrap items-center gap-2">
                    <p className="text-sm font-medium text-navy-900">{notification.title}</p>
                    <StatusBadge value={notification.severity} />
                    {!notification.isRead && <Badge tone="brand">New</Badge>}
                  </div>
                  <p className="mt-0.5 text-xs text-navy-700">{notification.message}</p>
                  <p className="mt-1 text-[11px] text-muted-foreground">
                    {notification.hotelName ?? 'Group'} · {relativeTime(notification.createdAt)}
                  </p>
                </div>
                {!notification.isRead && (
                  <Button variant="ghost" size="sm" onClick={() => markRead.mutate(notification.id)}>
                    Mark read
                  </Button>
                )}
              </div>
            ))}
          </div>
        )}
      </Card>
    </div>
  );
};

export default NotificationsPage;
