import { useState } from 'react';
import { Outlet, useLocation } from 'react-router-dom';
import { Sidebar } from './Sidebar';
import { Topbar } from './Topbar';
import { cn } from '@/lib/utils';

export const AppShell = () => {
  const [mobileOpen, setMobileOpen] = useState(false);
  const [collapsed, setCollapsed] = useState(false);
  const location = useLocation();

  return (
    <div className="min-h-screen bg-background">
      <Sidebar
        mobileOpen={mobileOpen}
        onClose={() => setMobileOpen(false)}
        collapsed={collapsed}
        onToggleCollapse={() => setCollapsed((value) => !value)}
      />
      <div className={cn('flex min-h-screen flex-col transition-[padding] duration-200', collapsed ? 'lg:pl-[74px]' : 'lg:pl-[246px]')}>
        <Topbar onOpenNav={() => setMobileOpen(true)} />
        <main key={location.pathname} className="flex-1 animate-fade-in px-4 py-5 lg:px-7 lg:py-6">
          <div className="mx-auto w-full max-w-[1500px]">
            <Outlet />
          </div>
        </main>
        <footer className="border-t border-border/70 px-4 py-3 text-xs text-muted-foreground lg:px-7">
          <div className="mx-auto flex max-w-[1500px] flex-col gap-1 sm:flex-row sm:items-center sm:justify-between">
            <span>Hotel CRM · Multi-hotel management suite</span>
            <span>All amounts in INR · Times shown in local timezone</span>
          </div>
        </footer>
      </div>
    </div>
  );
};
