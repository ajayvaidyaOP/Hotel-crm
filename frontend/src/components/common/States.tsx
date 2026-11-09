import type { LucideIcon } from 'lucide-react';
import { AlertTriangle, Inbox, RefreshCw } from 'lucide-react';
import type { ReactNode } from 'react';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/misc';
import { cn } from '@/lib/utils';

export const EmptyState = ({
  title,
  description,
  icon: Icon = Inbox,
  action,
  className,
}: {
  title: string;
  description?: string;
  icon?: LucideIcon;
  action?: ReactNode;
  className?: string;
}) => (
  <div className={cn('flex flex-col items-center justify-center gap-2 px-6 py-14 text-center', className)}>
    <span className="rounded-full bg-muted p-3">
      <Icon className="h-5 w-5 text-muted-foreground" />
    </span>
    <p className="text-sm font-semibold text-navy-800">{title}</p>
    {description && <p className="max-w-sm text-sm text-muted-foreground">{description}</p>}
    {action && <div className="mt-2">{action}</div>}
  </div>
);

export const ErrorState = ({
  message,
  onRetry,
  className,
}: {
  message?: string;
  onRetry?: () => void;
  className?: string;
}) => (
  <div className={cn('flex flex-col items-center justify-center gap-2 px-6 py-12 text-center', className)}>
    <span className="rounded-full bg-red-50 p-3">
      <AlertTriangle className="h-5 w-5 text-red-600" />
    </span>
    <p className="text-sm font-semibold text-navy-900">Could not load data</p>
    <p className="max-w-sm text-sm text-muted-foreground">{message ?? 'Please try again in a moment.'}</p>
    {onRetry && (
      <Button variant="outline" size="sm" onClick={onRetry} className="mt-2">
        <RefreshCw className="h-4 w-4" /> Retry
      </Button>
    )}
  </div>
);

export const TableSkeleton = ({ rows = 6, columns = 5 }: { rows?: number; columns?: number }) => (
  <div className="space-y-2 p-4">
    {Array.from({ length: rows }).map((_, rowIndex) => (
      <div key={rowIndex} className="flex items-center gap-4">
        {Array.from({ length: columns }).map((__, colIndex) => (
          <Skeleton key={colIndex} className={cn('h-5 flex-1', colIndex === 0 && 'max-w-[120px]')} />
        ))}
      </div>
    ))}
  </div>
);

export const ChartSkeleton = ({ className }: { className?: string }) => (
  <div className={cn('flex h-64 items-end gap-3 px-4 pb-6', className)}>
    {[42, 68, 55, 80, 62, 90, 72].map((height, index) => (
      <Skeleton key={index} className="flex-1 rounded-t-md" style={{ height: `${height}%` }} />
    ))}
  </div>
);
