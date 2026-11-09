import { useEffect, useMemo, useRef, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useQuery } from '@tanstack/react-query';
import {
  Bell, Building2, ChevronDown, LogOut, Menu, Search, Settings, UserCircle2, X,
} from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge, StatusBadge } from '@/components/ui/badge';
import {
  DropdownMenu, DropdownMenuContent, DropdownMenuItem, DropdownMenuLabel, DropdownMenuSeparator, DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';
import { Avatar, Separator } from '@/components/ui/misc';
import { useAuth } from '@/context/AuthContext';
import { useHotelScope } from '@/context/HotelContext';
import { notificationApi, searchApi } from '@/lib/endpoints';
import { formatDateTime, relativeTime } from '@/lib/format';
import { cn } from '@/lib/utils';

const GlobalSearch = () => {
  const [term, setTerm] = useState('');
  const [open, setOpen] = useState(false);
  const navigate = useNavigate();
  const containerRef = useRef<HTMLDivElement>(null);
  const debounced = useDebounced(term, 260);
  const enabled = debounced.trim().length >= 2;

  const { data, isFetching } = useQuery({
    queryKey: ['global-search', debounced],
    queryFn: () => searchApi.global(debounced.trim()),
    enabled,
    staleTime: 20_000,
  });

  useEffect(() => {
    const handler = (event: MouseEvent) => {
      if (containerRef.current && !containerRef.current.contains(event.target as Node)) setOpen(false);
    };
    document.addEventListener('mousedown', handler);
    return () => document.removeEventListener('mousedown', handler);
  }, []);

  return (
    <div ref={containerRef} className="relative w-full max-w-md">
      <Search className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
      <Input
        value={term}
        onChange={(event) => {
          setTerm(event.target.value);
          setOpen(true);
        }}
        onFocus={() => setOpen(true)}
        placeholder="Search hotels, bookings, guests, rooms…"
        className="h-9 bg-card/80 pl-9 pr-8 shadow-sm"
        aria-label="Global search"
      />
      {term && (
        <button
          type="button"
          onClick={() => {
            setTerm('');
            setOpen(false);
          }}
          className="absolute right-2 top-1/2 -translate-y-1/2 rounded p-0.5 text-muted-foreground hover:bg-muted"
          aria-label="Clear search"
        >
          <X className="h-3.5 w-3.5" />
        </button>
      )}

      {open && enabled && (
        <div className="absolute left-0 right-0 top-11 z-50 max-h-[420px] overflow-y-auto rounded-lg border border-border bg-popover p-1 shadow-popover">
          {isFetching && <p className="px-3 py-2 text-xs text-muted-foreground">Searching…</p>}
          {!isFetching && (data?.length ?? 0) === 0 && (
            <p className="px-3 py-2 text-xs text-muted-foreground">No matches for “{term}”.</p>
          )}
          {data?.map((result) => (
            <button
              key={`${result.type}-${result.id}`}
              onClick={() => {
                navigate(result.link);
                setOpen(false);
                setTerm('');
              }}
              className="flex w-full items-start gap-3 rounded-md px-3 py-2 text-left transition-colors hover:bg-muted"
            >
              <Badge tone="info" className="mt-0.5 shrink-0">
                {result.type}
              </Badge>
              <span className="min-w-0">
                <span className="block truncate text-sm font-medium text-navy-900">{result.title}</span>
                <span className="block truncate text-xs text-muted-foreground">
                  {[result.subtitle, result.hotelName].filter(Boolean).join(' · ')}
                </span>
              </span>
            </button>
          ))}
        </div>
      )}
    </div>
  );
};

const NotificationBell = () => {
  const [open, setOpen] = useState(false);
  const containerRef = useRef<HTMLDivElement>(null);
  const { data: count } = useQuery({
    queryKey: ['notifications', 'unread'],
    queryFn: notificationApi.unreadCount,
    refetchInterval: 60_000,
  });
  const { data: notifications } = useQuery({
    queryKey: ['notifications', 'preview'],
    queryFn: () => notificationApi.list(8),
    enabled: open,
  });

  useEffect(() => {
    const handler = (event: MouseEvent) => {
      if (containerRef.current && !containerRef.current.contains(event.target as Node)) setOpen(false);
    };
    document.addEventListener('mousedown', handler);
    return () => document.removeEventListener('mousedown', handler);
  }, []);

  const unread = count?.unread ?? 0;

  return (
    <div ref={containerRef} className="relative">
      <Button variant="ghost" size="icon" onClick={() => setOpen((value) => !value)} aria-label="Notifications" className="relative">
        <Bell className="h-[18px] w-[18px]" />
        {unread > 0 && (
          <span className="absolute right-1.5 top-1.5 grid h-4 min-w-4 place-items-center rounded-full bg-red-500 px-1 text-[10px] font-semibold text-white">
            {unread > 9 ? '9+' : unread}
          </span>
        )}
      </Button>
      {open && (
        <div className="absolute right-0 top-11 z-50 w-[340px] overflow-hidden rounded-lg border border-border bg-popover shadow-popover">
          <div className="flex items-center justify-between border-b border-border px-3 py-2">
            <p className="text-sm font-semibold text-navy-900">Notifications</p>
            <Link to="/notifications" onClick={() => setOpen(false)} className="text-xs font-medium text-brand-700 hover:underline">
              View all
            </Link>
          </div>
          <div className="max-h-[340px] overflow-y-auto">
            {(notifications ?? []).length === 0 && (
              <p className="px-3 py-6 text-center text-xs text-muted-foreground">You are all caught up.</p>
            )}
            {notifications?.map((notification) => (
              <div
                key={notification.id}
                className={cn('border-b border-border/60 px-3 py-2.5 last:border-0', !notification.isRead && 'bg-brand-50/50')}
              >
                <div className="flex items-start justify-between gap-2">
                  <p className="text-sm font-medium text-navy-900">{notification.title}</p>
                  <StatusBadge value={notification.severity} />
                </div>
                <p className="mt-0.5 line-clamp-2 text-xs text-muted-foreground">{notification.message}</p>
                <p className="mt-1 text-[11px] text-muted-foreground">{relativeTime(notification.createdAt)}</p>
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};

export const Topbar = ({ onOpenNav }: { onOpenNav: () => void }) => {
  const { user, logout } = useAuth();
  const { hotels, hotelId, setHotelId, hotel } = useHotelScope();
  const navigate = useNavigate();

  const hotelOptions = useMemo(
    () => [{ id: 0, label: 'All hotels (group)' }, ...hotels.map((item) => ({ id: item.id, label: `${item.name} · ${item.city ?? ''}` }))],
    [hotels],
  );

  return (
    <header className="sticky top-0 z-30 border-b border-border bg-background/85 backdrop-blur">
      <div className="flex h-16 items-center gap-3 px-4 lg:px-6">
        <Button variant="ghost" size="icon" className="lg:hidden" onClick={onOpenNav} aria-label="Open navigation">
          <Menu className="h-5 w-5" />
        </Button>

        <GlobalSearch />

        <div className="ml-auto flex items-center gap-1.5">
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button variant="outline" size="sm" className="hidden max-w-[240px] gap-2 sm:flex">
                <Building2 className="h-4 w-4 text-brand-600" />
                <span className="truncate">{hotelId === null ? 'All hotels' : hotel?.name ?? 'Hotel'}</span>
                <ChevronDown className="h-3.5 w-3.5 text-muted-foreground" />
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-64">
              <DropdownMenuLabel>Hotel scope</DropdownMenuLabel>
              {hotelOptions.map((option) => (
                <DropdownMenuItem
                  key={option.id}
                  onSelect={() => setHotelId(option.id === 0 ? null : option.id)}
                  className={cn((option.id === 0 && hotelId === null) || option.id === hotelId ? 'bg-muted font-medium' : '')}
                >
                  <Building2 className="h-4 w-4 text-muted-foreground" />
                  <span className="truncate">{option.label}</span>
                </DropdownMenuItem>
              ))}
              <DropdownMenuSeparator />
              <DropdownMenuItem onSelect={() => navigate('/hotels')}>
                <Settings className="h-4 w-4" /> Manage hotels
              </DropdownMenuItem>
            </DropdownMenuContent>
          </DropdownMenu>

          <NotificationBell />
          <Separator orientation="vertical" className="mx-1 hidden h-6 sm:block" />

          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <button className="flex items-center gap-2 rounded-lg py-1 pl-1 pr-2 transition-colors hover:bg-muted">
                <Avatar name={user?.fullName} className="h-8 w-8" />
                <span className="hidden text-left leading-tight sm:block">
                  <span className="block max-w-[140px] truncate text-sm font-medium text-navy-900">{user?.fullName}</span>
                  <span className="block text-[11px] text-muted-foreground">{user?.roleLabel}</span>
                </span>
                <ChevronDown className="hidden h-3.5 w-3.5 text-muted-foreground sm:block" />
              </button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-60">
              <div className="px-2 py-1.5">
                <p className="text-sm font-semibold text-navy-900">{user?.fullName}</p>
                <p className="truncate text-xs text-muted-foreground">{user?.email}</p>
                <p className="mt-1 text-[11px] text-muted-foreground">
                  {user?.hotels.length ?? 0} hotel{(user?.hotels.length ?? 0) === 1 ? '' : 's'} · {user?.roleLabel}
                </p>
              </div>
              <DropdownMenuSeparator />
              <DropdownMenuItem onSelect={() => navigate('/settings')}>
                <UserCircle2 className="h-4 w-4" /> My profile
              </DropdownMenuItem>
              <DropdownMenuItem onSelect={() => navigate('/settings?tab=security')}>
                <Settings className="h-4 w-4" /> Password & security
              </DropdownMenuItem>
              <DropdownMenuSeparator />
              <DropdownMenuItem destructive onSelect={() => void logout()}>
                <LogOut className="h-4 w-4" /> Sign out
              </DropdownMenuItem>
              <p className="px-2 pb-1 pt-1 text-[10px] text-muted-foreground">Last sign-in {formatDateTime(null)}</p>
            </DropdownMenuContent>
          </DropdownMenu>
        </div>
      </div>
    </header>
  );
};

function useDebounced<T>(value: T, delay = 300) {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => {
    const timer = setTimeout(() => setDebounced(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);
  return debounced;
}
