import type { LucideIcon } from 'lucide-react';
import { ArrowDownRight, ArrowUpRight, Minus } from 'lucide-react';
import { cn } from '@/lib/utils';

type Tone = 'brand' | 'navy' | 'success' | 'warning' | 'danger' | 'violet';

const TONES: Record<Tone, { icon: string; ring: string }> = {
  brand: { icon: 'bg-brand-50 text-brand-700', ring: 'ring-brand-100' },
  navy: { icon: 'bg-navy-50 text-navy-700', ring: 'ring-navy-100' },
  success: { icon: 'bg-emerald-50 text-emerald-700', ring: 'ring-emerald-100' },
  warning: { icon: 'bg-amber-50 text-amber-700', ring: 'ring-amber-100' },
  danger: { icon: 'bg-red-50 text-red-700', ring: 'ring-red-100' },
  violet: { icon: 'bg-violet-50 text-violet-700', ring: 'ring-violet-100' },
};

export const StatCard = ({
  label,
  value,
  hint,
  icon: Icon,
  tone = 'brand',
  trend,
  trendLabel,
  className,
  onClick,
}: {
  label: string;
  value: string | number;
  hint?: string;
  icon?: LucideIcon;
  tone?: Tone;
  trend?: number | null;
  trendLabel?: string;
  className?: string;
  onClick?: () => void;
}) => (
  <div
    className={cn('surface p-4 transition-shadow hover:shadow-popover', onClick && 'cursor-pointer', className)}
    onClick={onClick}
    role={onClick ? 'button' : undefined}
    tabIndex={onClick ? 0 : undefined}
  >
    <div className="flex items-start justify-between gap-3">
      <div className="min-w-0 space-y-1">
        <p className="truncate text-xs font-medium uppercase tracking-wide text-muted-foreground">{label}</p>
        <p className="text-2xl font-semibold tracking-tight text-navy-900">{value}</p>
        {hint && <p className="truncate text-xs text-muted-foreground">{hint}</p>}
      </div>
      {Icon && (
        <span className={cn('rounded-lg p-2 ring-1', TONES[tone].icon, TONES[tone].ring)}>
          <Icon className="h-4 w-4" />
        </span>
      )}
    </div>
    {trend !== undefined && trend !== null && (
      <div className="mt-3 flex items-center gap-1 text-xs font-medium">
        {trend > 0 ? (
          <ArrowUpRight className="h-3.5 w-3.5 text-emerald-600" />
        ) : trend < 0 ? (
          <ArrowDownRight className="h-3.5 w-3.5 text-red-600" />
        ) : (
          <Minus className="h-3.5 w-3.5 text-muted-foreground" />
        )}
        <span className={trend > 0 ? 'text-emerald-600' : trend < 0 ? 'text-red-600' : 'text-muted-foreground'}>
          {Math.abs(trend).toFixed(1)}%
        </span>
        {trendLabel && <span className="text-muted-foreground">{trendLabel}</span>}
      </div>
    )}
  </div>
);
