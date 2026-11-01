import * as React from 'react';
import { cn } from '@/lib/utils';
import { Loader2 } from 'lucide-react';

export const Separator = ({ className, orientation = 'horizontal' }: { className?: string; orientation?: 'horizontal' | 'vertical' }) => (
  <div className={cn('shrink-0 bg-border', orientation === 'horizontal' ? 'h-px w-full' : 'h-full w-px', className)} />
);

export const Skeleton = ({ className, style }: { className?: string; style?: React.CSSProperties }) => (
  <div className={cn('animate-pulse rounded-md bg-muted', className)} style={style} />
);

export const Spinner = ({ className }: { className?: string }) => (
  <Loader2 className={cn('h-5 w-5 animate-spin text-brand-600', className)} />
);

export const Switch = ({
  checked,
  onChange,
  disabled,
  id,
}: {
  checked: boolean;
  onChange: (value: boolean) => void;
  disabled?: boolean;
  id?: string;
}) => (
  <button
    id={id}
    type="button"
    role="switch"
    aria-checked={checked}
    disabled={disabled}
    onClick={() => onChange(!checked)}
    className={cn(
      'relative inline-flex h-5 w-9 shrink-0 items-center rounded-full transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-brand-300 disabled:cursor-not-allowed disabled:opacity-50',
      checked ? 'bg-brand-600' : 'bg-navy-200',
    )}
  >
    <span
      className={cn(
        'inline-block h-4 w-4 transform rounded-full bg-white shadow transition-transform',
        checked ? 'translate-x-[1.15rem]' : 'translate-x-0.5',
      )}
    />
  </button>
);

export const Avatar = ({ name, className }: { name?: string | null; className?: string }) => {
  const label = (name ?? '?')
    .split(' ')
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0]?.toUpperCase())
    .join('');
  return (
    <span
      className={cn(
        'inline-flex h-9 w-9 shrink-0 items-center justify-center rounded-full bg-navy-800 text-xs font-semibold text-white',
        className,
      )}
    >
      {label}
    </span>
  );
};

export const ProgressBar = ({ value, className, tone = 'brand' }: { value: number; className?: string; tone?: 'brand' | 'success' | 'warning' | 'danger' }) => (
  <div className={cn('h-2 w-full overflow-hidden rounded-full bg-muted', className)}>
    <div
      className={cn(
        'h-full rounded-full transition-all',
        tone === 'brand' && 'bg-brand-500',
        tone === 'success' && 'bg-emerald-500',
        tone === 'warning' && 'bg-amber-500',
        tone === 'danger' && 'bg-red-500',
      )}
      style={{ width: `${Math.min(100, Math.max(0, value))}%` }}
    />
  </div>
);
