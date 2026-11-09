import { NavLink } from 'react-router-dom';
import {
  BedDouble, Building2, CalendarDays, ChevronLeft, ClipboardList, CreditCard, FileText, LayoutDashboard,
  Receipt, ScrollText, Settings, Sparkles, Users, UserCog, Wallet, X,
} from 'lucide-react';
import { cn } from '@/lib/utils';
import { useAuth } from '@/context/AuthContext';
import type { NavKey } from '@/lib/permissions';
import { NAV_PERMISSIONS } from '@/lib/permissions';

const NAV_GROUPS: { label: string; items: { key: NavKey; to: string; label: string; icon: typeof LayoutDashboard }[] }[] = [
  {
    label: 'Overview',
    items: [
      { key: 'dashboard', to: '/dashboard', label: 'Dashboard', icon: LayoutDashboard },
      { key: 'hotels', to: '/hotels', label: 'Hotels', icon: Building2 },
    ],
  },
  {
    label: 'Front desk',
    items: [
      { key: 'bookings', to: '/bookings', label: 'Bookings', icon: CalendarDays },
      { key: 'guests', to: '/guests', label: 'Guests', icon: Users },
      { key: 'rooms', to: '/rooms', label: 'Rooms & Rates', icon: BedDouble },
      { key: 'housekeeping', to: '/housekeeping', label: 'Housekeeping', icon: Sparkles },
    ],
  },
  {
    label: 'Finance',
    items: [
      { key: 'payments', to: '/payments', label: 'Payments', icon: CreditCard },
      { key: 'invoices', to: '/invoices', label: 'Invoices', icon: FileText },
      { key: 'expenses', to: '/expenses', label: 'Expenses', icon: Wallet },
      { key: 'reports', to: '/reports', label: 'Reports', icon: Receipt },
    ],
  },
  {
    label: 'Administration',
    items: [
      { key: 'staff', to: '/staff', label: 'Staff', icon: UserCog },
      { key: 'audit', to: '/audit', label: 'Audit logs', icon: ScrollText },
      { key: 'settings', to: '/settings', label: 'Settings', icon: Settings },
    ],
  },
];

export const Sidebar = ({
  mobileOpen,
  onClose,
  collapsed,
  onToggleCollapse,
}: {
  mobileOpen: boolean;
  onClose: () => void;
  collapsed: boolean;
  onToggleCollapse: () => void;
}) => {
  const { has, user } = useAuth();

  const content = (
    <div className="flex h-full flex-col bg-gradient-to-b from-navy-950 via-navy-900 to-navy-950 text-white">
      <div className="flex items-center justify-between gap-2 px-4 py-4">
        <div className="flex items-center gap-2.5">
          <span className="grid h-9 w-9 place-items-center rounded-lg bg-brand-500/90 text-sm font-bold shadow-lg shadow-brand-900/40">
            HC
          </span>
          {!collapsed && (
            <div className="leading-tight">
              <p className="text-sm font-semibold tracking-tight">Hotel CRM</p>
              <p className="text-[11px] text-navy-300">Group operations</p>
            </div>
          )}
        </div>
        <button onClick={onClose} className="rounded-md p-1 text-navy-300 hover:bg-white/10 lg:hidden" aria-label="Close navigation">
          <X className="h-4 w-4" />
        </button>
      </div>

      <nav className="scroll-thin flex-1 space-y-5 overflow-y-auto px-2.5 pb-4">
        {NAV_GROUPS.map((group) => {
          const visible = group.items.filter((item) => has(NAV_PERMISSIONS[item.key]));
          if (visible.length === 0) return null;
          return (
            <div key={group.label} className="space-y-1">
              {!collapsed && (
                <p className="px-3 pb-1 text-[10px] font-semibold uppercase tracking-[0.14em] text-navy-400">{group.label}</p>
              )}
              {visible.map((item) => (
                <NavLink
                  key={`${group.label}-${item.label}`}
                  to={item.to}
                  onClick={onClose}
                  className={({ isActive }) => cn('sidebar-link', isActive && 'sidebar-link-active', collapsed && 'justify-center px-2')}
                  title={collapsed ? item.label : undefined}
                >
                  <item.icon className="h-4 w-4 shrink-0" />
                  {!collapsed && <span className="truncate">{item.label}</span>}
                </NavLink>
              ))}
            </div>
          );
        })}
      </nav>

      <div className="border-t border-white/10 p-3">
        {!collapsed ? (
          <div className="rounded-lg bg-white/5 p-3">
            <p className="truncate text-xs font-medium text-white">{user?.fullName}</p>
            <p className="truncate text-[11px] text-navy-300">{user?.roleLabel}</p>
            <p className="mt-1 text-[11px] text-navy-400">
              {user?.hotels.length ?? 0} hotel{(user?.hotels.length ?? 0) === 1 ? '' : 's'} accessible
            </p>
          </div>
        ) : null}
        <button
          onClick={onToggleCollapse}
          className="mt-2 hidden w-full items-center justify-center gap-1 rounded-md border border-white/10 py-1 text-[11px] text-navy-300 hover:bg-white/10 lg:flex"
        >
          <ChevronLeft className={cn('h-3.5 w-3.5 transition-transform', collapsed && 'rotate-180')} />
          {!collapsed && 'Collapse'}
        </button>
      </div>
    </div>
  );

  return (
    <>
      <aside
        className={cn(
          'fixed inset-y-0 left-0 z-40 hidden shrink-0 border-r border-navy-900/40 transition-[width] duration-200 lg:block',
          collapsed ? 'w-[74px]' : 'w-[246px]',
        )}
      >
        {content}
      </aside>
      {mobileOpen && (
        <div className="fixed inset-0 z-50 lg:hidden">
          <div className="absolute inset-0 bg-navy-950/60 backdrop-blur-sm" onClick={onClose} />
          <aside className="absolute inset-y-0 left-0 w-[264px] shadow-2xl">{content}</aside>
        </div>
      )}
    </>
  );
};
