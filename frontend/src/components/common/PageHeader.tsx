import type { ReactNode } from 'react';
import { cn } from '@/lib/utils';

export const PageHeader = ({ title, description, actions, className, children }: {
  title: string;
  description?: string;
  actions?: ReactNode;
  className?: string;
  children?: ReactNode;
}) => (
  <div className={cn('flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between', className)}>
    <div className="space-y-1">
      <h1 className="text-2xl font-semibold tracking-tight text-navy-900">{title}</h1>
      {description && <p className="text-sm text-muted-foreground">{description}</p>}
      {children}
    </div>
    {actions && <div className="flex flex-wrap items-center gap-2">{actions}</div>}
  </div>
);
