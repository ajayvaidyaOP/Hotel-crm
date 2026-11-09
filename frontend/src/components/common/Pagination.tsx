import { ChevronLeft, ChevronRight } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Select } from '@/components/ui/input';

export const Pagination = ({
  page,
  size,
  totalElements,
  totalPages,
  onPageChange,
  onSizeChange,
}: {
  page: number;
  size: number;
  totalElements: number;
  totalPages: number;
  onPageChange: (page: number) => void;
  onSizeChange?: (size: number) => void;
}) => {
  const from = totalElements === 0 ? 0 : page * size + 1;
  const to = Math.min(totalElements, (page + 1) * size);
  return (
    <div className="flex flex-col items-center justify-between gap-3 border-t border-border/70 px-4 py-3 sm:flex-row">
      <p className="text-xs text-muted-foreground">
        Showing <span className="font-medium text-navy-800">{from}</span>–
        <span className="font-medium text-navy-800">{to}</span> of{' '}
        <span className="font-medium text-navy-800">{totalElements}</span>
      </p>
      <div className="flex items-center gap-2">
        {onSizeChange && (
          <Select
            className="h-8 w-[86px] text-xs"
            value={size}
            onChange={(event) => onSizeChange(Number(event.target.value))}
            aria-label="Rows per page"
          >
            {[10, 20, 50, 100].map((option) => (
              <option key={option} value={option}>
                {option} / page
              </option>
            ))}
          </Select>
        )}
        <Button variant="outline" size="icon-sm" disabled={page <= 0} onClick={() => onPageChange(page - 1)} aria-label="Previous page">
          <ChevronLeft className="h-4 w-4" />
        </Button>
        <span className="min-w-[70px] text-center text-xs font-medium text-navy-700">
          {totalPages === 0 ? 0 : page + 1} / {totalPages}
        </span>
        <Button
          variant="outline"
          size="icon-sm"
          disabled={page + 1 >= totalPages}
          onClick={() => onPageChange(page + 1)}
          aria-label="Next page"
        >
          <ChevronRight className="h-4 w-4" />
        </Button>
      </div>
    </div>
  );
};
