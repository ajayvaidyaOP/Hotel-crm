import { Search, X } from 'lucide-react';
import type { ReactNode } from 'react';
import { Input, Select } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { cn } from '@/lib/utils';

export const TableToolbar = ({ children, className }: { children: ReactNode; className?: string }) => (
  <div className={cn('flex flex-col gap-2 border-b border-border/70 px-4 py-3 lg:flex-row lg:items-center lg:justify-between', className)}>
    {children}
  </div>
);

export const SearchInput = ({
  value,
  onChange,
  placeholder = 'Search…',
  className,
}: {
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  className?: string;
}) => (
  <div className={cn('relative w-full sm:max-w-xs', className)}>
    <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
    <Input
      value={value}
      onChange={(event) => onChange(event.target.value)}
      placeholder={placeholder}
      className="pl-9 pr-8"
    />
    {value && (
      <button
        type="button"
        onClick={() => onChange('')}
        className="absolute right-2 top-1/2 -translate-y-1/2 rounded p-0.5 text-muted-foreground hover:bg-muted"
        aria-label="Clear search"
      >
        <X className="h-3.5 w-3.5" />
      </button>
    )}
  </div>
);

export const FilterSelect = ({
  value,
  onChange,
  options,
  placeholder,
  className,
  ariaLabel,
}: {
  value: string;
  onChange: (value: string) => void;
  options: { value: string; label: string }[];
  placeholder: string;
  className?: string;
  ariaLabel?: string;
}) => (
  <Select
    value={value}
    onChange={(event) => onChange(event.target.value)}
    className={cn('w-full sm:w-auto sm:min-w-[150px]', className)}
    aria-label={ariaLabel ?? placeholder}
  >
    <option value="">{placeholder}</option>
    {options.map((option) => (
      <option key={option.value} value={option.value}>
        {option.label}
      </option>
    ))}
  </Select>
);

export const ClearFilters = ({ onClick, visible }: { onClick: () => void; visible: boolean }) =>
  visible ? (
    <Button variant="ghost" size="sm" onClick={onClick} className="text-muted-foreground">
      <X className="h-3.5 w-3.5" /> Clear
    </Button>
  ) : null;
