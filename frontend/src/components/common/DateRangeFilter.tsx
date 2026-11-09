import { CalendarDays } from 'lucide-react';
import { Input } from '@/components/ui/input';
import { addDaysISO } from '@/lib/utils';

const PRESETS = [
  { label: 'Today', key: 'today' },
  { label: '7 days', key: '7d' },
  { label: '30 days', key: '30d' },
  { label: 'This month', key: 'month' },
  { label: 'This year', key: 'year' },
] as const;

export const DateRangeFilter = ({
  from,
  to,
  onChange,
  compact = false,
}: {
  from: string;
  to: string;
  onChange: (range: { from: string; to: string }) => void;
  compact?: boolean;
}) => {
  const applyPreset = (key: string) => {
    const today = new Date();
    if (key === 'today') return onChange({ from: addDaysISO(0, today), to: addDaysISO(0, today) });
    if (key === '7d') return onChange({ from: addDaysISO(-6, today), to: addDaysISO(0, today) });
    if (key === '30d') return onChange({ from: addDaysISO(-29, today), to: addDaysISO(0, today) });
    if (key === 'month') {
      return onChange({
        from: new Date(today.getFullYear(), today.getMonth(), 1).toISOString().slice(0, 10),
        to: new Date(today.getFullYear(), today.getMonth() + 1, 0).toISOString().slice(0, 10),
      });
    }
    return onChange({
      from: new Date(today.getFullYear(), 0, 1).toISOString().slice(0, 10),
      to: new Date(today.getFullYear(), 11, 31).toISOString().slice(0, 10),
    });
  };

  return (
    <div className="flex flex-wrap items-center gap-2">
      <div className="flex items-center gap-2 rounded-lg border border-input bg-background px-2 py-1 shadow-sm">
        <CalendarDays className="h-4 w-4 text-muted-foreground" />
        <input
          type="date"
          value={from}
          max={to}
          onChange={(event) => onChange({ from: event.target.value, to })}
          className="h-7 bg-transparent text-sm text-navy-800 focus:outline-none"
          aria-label="From date"
        />
        <span className="text-muted-foreground">→</span>
        <input
          type="date"
          value={to}
          min={from}
          onChange={(event) => onChange({ from, to: event.target.value })}
          className="h-7 bg-transparent text-sm text-navy-800 focus:outline-none"
          aria-label="To date"
        />
      </div>
      {!compact && (
        <div className="flex flex-wrap gap-1">
          {PRESETS.map((preset) => (
            <button
              key={preset.key}
              type="button"
              onClick={() => applyPreset(preset.key)}
              className="rounded-md px-2 py-1 text-xs font-medium text-muted-foreground transition-colors hover:bg-muted hover:text-navy-800"
            >
              {preset.label}
            </button>
          ))}
        </div>
      )}
    </div>
  );
};

export const HiddenInput = Input;
