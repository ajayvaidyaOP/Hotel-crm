import * as React from 'react';
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';
import { labelize } from '@/lib/format';

const badgeVariants = cva(
  'inline-flex items-center gap-1 rounded-full border px-2 py-0.5 text-xs font-medium transition-colors',
  {
    variants: {
      tone: {
        neutral: 'border-navy-200 bg-navy-50 text-navy-700',
        brand: 'border-brand-200 bg-brand-50 text-brand-700',
        success: 'border-emerald-200 bg-emerald-50 text-emerald-700',
        warning: 'border-amber-200 bg-amber-50 text-amber-700',
        danger: 'border-red-200 bg-red-50 text-red-700',
        info: 'border-sky-200 bg-sky-50 text-sky-700',
        purple: 'border-violet-200 bg-violet-50 text-violet-700',
        outline: 'border-border bg-transparent text-muted-foreground',
      },
    },
    defaultVariants: { tone: 'neutral' },
  },
);

export interface BadgeProps
  extends React.HTMLAttributes<HTMLSpanElement>,
    VariantProps<typeof badgeVariants> {}

export const Badge = ({ className, tone, ...props }: BadgeProps) => (
  <span className={cn(badgeVariants({ tone }), className)} {...props} />
);

type Tone = NonNullable<BadgeProps['tone']>;

const TONES: Record<string, Tone> = {
  // booking
  PENDING: 'warning',
  CONFIRMED: 'info',
  CHECKED_IN: 'success',
  CHECKED_OUT: 'neutral',
  CANCELLED: 'danger',
  NO_SHOW: 'danger',
  RESERVED: 'info',
  // payment
  UNPAID: 'danger',
  PARTIALLY_PAID: 'warning',
  PAID: 'success',
  REFUNDED: 'purple',
  // invoice
  DRAFT: 'outline',
  ISSUED: 'info',
  // rooms
  AVAILABLE: 'success',
  OCCUPIED: 'brand',
  CLEANING: 'warning',
  MAINTENANCE: 'danger',
  OUT_OF_SERVICE: 'danger',
  CLEAN: 'success',
  DIRTY: 'warning',
  INSPECTED: 'brand',
  // tasks & maintenance
  IN_PROGRESS: 'info',
  COMPLETED: 'success',
  OPEN: 'danger',
  RESOLVED: 'success',
  CLOSED: 'neutral',
  // priority
  LOW: 'neutral',
  NORMAL: 'info',
  HIGH: 'warning',
  URGENT: 'danger',
  // misc
  ACTIVE: 'success',
  INACTIVE: 'neutral',
  ARCHIVED: 'neutral',
  SERVED: 'info',
  DELIVERED: 'success',
  BILLED: 'neutral',
  PREPARING: 'warning',
  STORED: 'info',
  RETURNED: 'success',
  DISPOSED: 'neutral',
  PRESENT: 'success',
  ABSENT: 'danger',
  LEAVE: 'warning',
  HALF_DAY: 'warning',
  WEEK_OFF: 'neutral',
  FEEDBACK: 'info',
  COMPLAINT: 'danger',
  VIP: 'purple',
  INFO: 'info',
  SUCCESS: 'success',
  WARNING: 'warning',
  CRITICAL: 'danger',
};

export const StatusBadge = ({ value, className }: { value?: string | null; className?: string }) => {
  if (!value) return <span className="text-muted-foreground">—</span>;
  return (
    <Badge tone={TONES[value] ?? 'neutral'} className={className}>
      <span className={cn('h-1.5 w-1.5 rounded-full', toneDot(TONES[value] ?? 'neutral'))} />
      {labelize(value)}
    </Badge>
  );
};

const toneDot = (tone: Tone) =>
  ({
    neutral: 'bg-navy-400',
    brand: 'bg-brand-500',
    success: 'bg-emerald-500',
    warning: 'bg-amber-500',
    danger: 'bg-red-500',
    info: 'bg-sky-500',
    purple: 'bg-violet-500',
    outline: 'bg-slate-400',
  })[tone];
