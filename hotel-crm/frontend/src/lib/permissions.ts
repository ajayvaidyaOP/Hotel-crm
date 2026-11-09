import type { Role } from './types';

export const ROLE_LABELS: Record<Role, string> = {
  SUPER_ADMIN: 'Owner / Super Admin',
  HOTEL_MANAGER: 'Hotel Manager',
  RECEPTIONIST: 'Receptionist',
  HOUSEKEEPING: 'Housekeeping',
  ACCOUNTANT: 'Accountant',
};

export const NAV_PERMISSIONS = {
  dashboard: null,
  hotels: 'hotel:read',
  rooms: 'room:read',
  bookings: 'booking:read',
  guests: 'guest:read',
  payments: 'payment:read',
  invoices: 'invoice:read',
  expenses: 'expense:read',
  housekeeping: 'housekeeping:read',
  staff: 'staff:read',
  reports: 'report:read',
  audit: 'audit:read',
  settings: null,
} as const;

export type NavKey = keyof typeof NAV_PERMISSIONS;

export const can = (permissions: string[] | undefined, permission: string | null | undefined) => {
  if (!permission) return true;
  return (permissions ?? []).includes(permission);
};
