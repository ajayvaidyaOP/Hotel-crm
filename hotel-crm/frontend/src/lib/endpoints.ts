import { api } from './api';
import type {
  Attendance, AttendanceSummary, AuditLog, AuthTokens, Booking, BookingCalendar, BookingSummary,
  CalendarEntry, CancellationRow, CategoryRow, Coupon, Dashboard, DayOperations, Expense, ExpenseCategory,
  ExpenseRow, Feedback, GlobalSearchResult, Guest, Hotel, HotelStats, Invoice, Kpi, LostFoundItem,
  MaintenanceRequest, MeResponse, NamedValue, Notification, OccupancyRow, PageResponse, Payment,
  PendingPaymentRow, ProfitRow, Quote, RatePlan, Refund, RevenueRow, Room, RoomCategory,
  StaffMember, ServiceOrder,
} from './types';

type Params = Record<string, unknown>;

const clean = (params?: Params) => {
  if (!params) return undefined;
  const out: Params = {};
  Object.entries(params).forEach(([key, value]) => {
    if (value !== undefined && value !== null && value !== '' && !(Array.isArray(value) && value.length === 0)) {
      out[key] = value;
    }
  });
  return out;
};

export const authApi = {
  login: async (email: string, password: string) =>
    (await api.post<AuthTokens>('/auth/login', { email, password })).data,
  me: async () => (await api.get<MeResponse>('/auth/me')).data,
  updateProfile: async (payload: { fullName: string; phone?: string; designation?: string }) =>
    (await api.put<MeResponse>('/auth/me', payload)).data,
  changePassword: async (payload: { currentPassword: string; newPassword: string }) =>
    (await api.post('/auth/change-password', payload)).data,
  forgotPassword: async (email: string) => (await api.post('/auth/forgot-password', { email })).data,
  resetPassword: async (token: string, newPassword: string) =>
    (await api.post('/auth/reset-password', { token, newPassword })).data,
  logout: async () => (await api.post('/auth/logout')).data,
};

export const hotelApi = {
  list: async (params?: Params) => (await api.get<Hotel[]>('/hotels', { params: clean(params) })).data,
  get: async (id: number) => (await api.get<Hotel>(`/hotels/${id}`)).data,
  create: async (payload: Params) => (await api.post<Hotel>('/hotels', payload)).data,
  update: async (id: number, payload: Params) => (await api.put<Hotel>(`/hotels/${id}`, payload)).data,
  updateStatus: async (id: number, status: string) =>
    (await api.patch<Hotel>(`/hotels/${id}/status`, { status })).data,
};

export const roomApi = {
  categories: async (hotelId: number) =>
    (await api.get<RoomCategory[]>(`/hotels/${hotelId}/room-categories`)).data,
  createCategory: async (hotelId: number, payload: Params) =>
    (await api.post<RoomCategory>(`/hotels/${hotelId}/room-categories`, payload)).data,
  updateCategory: async (hotelId: number, id: number, payload: Params) =>
    (await api.put<RoomCategory>(`/room-categories/${id}`, payload, { params: { hotelId } })).data,
  deleteCategory: async (hotelId: number, id: number) =>
    api.delete(`/room-categories/${id}`, { params: { hotelId } }),
  list: async (params?: Params) => (await api.get<Room[]>('/rooms', { params: clean(params) })).data,
  get: async (id: number) => (await api.get<Room>(`/rooms/${id}`)).data,
  create: async (hotelId: number, payload: Params) =>
    (await api.post<Room>(`/hotels/${hotelId}/rooms`, payload)).data,
  bulkCreate: async (hotelId: number, params: Params) =>
    (await api.post<Room[]>(`/hotels/${hotelId}/rooms/bulk`, null, { params: clean(params) })).data,
  update: async (id: number, payload: Params) => (await api.put<Room>(`/rooms/${id}`, payload)).data,
  updateStatus: async (id: number, payload: { status?: string; housekeepingStatus?: string }) =>
    (await api.patch<Room>(`/rooms/${id}/status`, payload)).data,
  history: async (id: number) => (await api.get<CalendarEntry[]>(`/rooms/${id}/history`)).data,
  delete: async (id: number) => api.delete(`/rooms/${id}`),
};

export const pricingApi = {
  ratePlans: async (hotelId: number) => (await api.get<RatePlan[]>(`/hotels/${hotelId}/rate-plans`)).data,
  createPlan: async (hotelId: number, payload: Params) =>
    (await api.post<RatePlan>(`/hotels/${hotelId}/rate-plans`, payload)).data,
  updatePlan: async (hotelId: number, id: number, payload: Params) =>
    (await api.put<RatePlan>(`/hotels/${hotelId}/rate-plans/${id}`, payload)).data,
  deletePlan: async (hotelId: number, id: number) => api.delete(`/hotels/${hotelId}/rate-plans/${id}`),
  quote: async (hotelId: number, payload: Params) =>
    (await api.post<Quote>(`/hotels/${hotelId}/pricing/quote`, payload)).data,
};

export const guestApi = {
  list: async (params?: Params) => (await api.get<PageResponse<Guest>>('/guests', { params: clean(params) })).data,
  get: async (id: number) =>
    (await api.get<{ guest: Guest; bookings: BookingSummary[]; payments: Payment[]; feedback: Feedback[]; services: ServiceOrder[] }>(`/guests/${id}`)).data,
  create: async (payload: Params) =>
    (await api.post<Guest>('/guests', payload)).data,
  update: async (id: number, payload: Params) =>
    (await api.put<Guest>(`/guests/${id}`, payload)).data,
};

export const bookingApi = {
  list: async (params?: Params) =>
    (await api.get<PageResponse<BookingSummary>>('/bookings', { params: clean(params) })).data,
  get: async (id: number) => (await api.get<Booking>(`/bookings/${id}`)).data,
  create: async (payload: Params) => (await api.post<Booking>('/bookings', payload)).data,
  update: async (id: number, payload: Params) => (await api.put<Booking>(`/bookings/${id}`, payload)).data,
  cancel: async (id: number, payload: { reason: string; refundAmount?: number; refundMethod?: string }) =>
    (await api.post<Booking>(`/bookings/${id}/cancel`, payload)).data,
  checkIn: async (id: number, payload?: Params) => (await api.post<Booking>(`/bookings/${id}/check-in`, payload ?? {})).data,
  checkOut: async (id: number, payload: Params) =>
    (await api.post(`/bookings/${id}/check-out`, payload)).data,
  transferRoom: async (id: number, payload: Params) =>
    (await api.post<Booking>(`/bookings/${id}/transfer-room`, payload)).data,
  reschedule: async (id: number, payload: Params) => (await api.post<Booking>(`/bookings/${id}/reschedule`, payload)).data,
  calendar: async (hotelId: number, from: string, to: string) =>
    (await api.get<BookingCalendar>('/bookings/calendar', { params: { hotelId, from, to } })).data,
  dayOperations: async (params?: Params) =>
    (await api.get<DayOperations>('/bookings/day-operations', { params: clean(params) })).data,
  quote: async (hotelId: number, payload: Params) =>
    (await api.post<Quote>(`/hotels/${hotelId}/pricing/quote`, payload)).data,
};

export const paymentApi = {
  list: async (params?: Params) => (await api.get<PageResponse<Payment>>('/payments', { params: clean(params) })).data,
  create: async (payload: Params) => (await api.post<Payment>('/payments', payload)).data,
  pending: async (params?: Params) =>
    (await api.get<PendingPaymentRow[]>('/payments/pending', { params: clean(params) })).data,
  refunds: async (params?: Params) => (await api.get<Refund[]>('/payments/refunds', { params: clean(params) })).data,
  refund: async (payload: Params) => (await api.post<Refund>('/payments/refunds', payload)).data,
  summary: async (params?: Params) => (await api.get('/payments/summary', { params: clean(params) })).data,
};

export const invoiceApi = {
  list: async (params?: Params) => (await api.get<PageResponse<Invoice>>('/invoices', { params: clean(params) })).data,
  get: async (id: number) => (await api.get<Invoice>(`/invoices/${id}`)).data,
  generate: async (payload: Params) => (await api.post<Invoice>('/invoices', payload)).data,
  settle: async (id: number, payload: Params) => (await api.post<Invoice>(`/invoices/${id}/settle`, payload)).data,
  cancel: async (id: number) => (await api.post<Invoice>(`/invoices/${id}/cancel`)).data,
};

export const expenseApi = {
  list: async (params?: Params) =>
    (await api.get<PageResponse<Expense>>('/expenses', { params: clean(params) })).data,
  create: async (payload: Params) => (await api.post<Expense>('/expenses', payload)).data,
  update: async (id: number, payload: Params) => (await api.put<Expense>(`/expenses/${id}`, payload)).data,
  remove: async (id: number) => api.delete(`/expenses/${id}`),
  summary: async (params?: Params) =>
    (await api.get<NamedValue[]>('/expenses/summary', { params: clean(params) })).data,
};

export const housekeepingApi = {
  list: async (params?: Params) =>
    (await api.get('/housekeeping', { params: clean(params) })).data as Promise<import('./types').HousekeepingTask[]>,
  create: async (payload: Params) => (await api.post('/housekeeping', payload)).data,
  updateStatus: async (id: number, payload: Params) => (await api.patch(`/housekeeping/${id}/status`, payload)).data,
  remove: async (id: number) => api.delete(`/housekeeping/${id}`),
  myTasks: async () => (await api.get('/housekeeping/my-tasks')).data,
};

export const maintenanceApi = {
  list: async (params?: Params) =>
    (await api.get<MaintenanceRequest[]>('/maintenance', { params: clean(params) })).data,
  create: async (payload: Params) => (await api.post<MaintenanceRequest>('/maintenance', payload)).data,
  update: async (id: number, payload: Params) => (await api.put<MaintenanceRequest>(`/maintenance/${id}`, payload)).data,
  lostFound: async (params?: Params) => (await api.get<LostFoundItem[]>('/lost-found', { params: clean(params) })).data,
  createLostFound: async (payload: Params) => (await api.post<LostFoundItem>('/lost-found', payload)).data,
  updateLostFound: async (id: number, status: string) =>
    (await api.patch<LostFoundItem>(`/lost-found/${id}/status`, { status })).data,
};

export const staffApi = {
  list: async (params?: Params) => (await api.get<StaffMember[]>('/staff', { params: clean(params) })).data,
  get: async (id: number) => (await api.get<StaffMember>(`/staff/${id}`)).data,
  create: async (payload: Params) => (await api.post<StaffMember>('/staff', payload)).data,
  update: async (id: number, payload: Params) => (await api.put<StaffMember>(`/staff/${id}`, payload)).data,
  setActive: async (id: number, active: boolean) =>
    (await api.patch<StaffMember>(`/staff/${id}/status`, { active })).data,
  resetPassword: async (id: number, newPassword: string) =>
    api.post(`/staff/${id}/reset-password`, { newPassword }),
  activity: async (id: number, params?: Params) =>
    (await api.get<PageResponse<AuditLog>>(`/staff/${id}/activity`, { params: clean(params) })).data,
  attendance: async (params?: Params) => (await api.get<Attendance[]>('/staff/attendance', { params: clean(params) })).data,
  markAttendance: async (payload: Params) => (await api.post<Attendance>('/staff/attendance', payload)).data,
  attendanceSummary: async (params?: Params) =>
    (await api.get<AttendanceSummary>('/staff/attendance/summary', { params: clean(params) })).data,
};

export const dashboardApi = {
  get: async (params?: Params) => (await api.get<Dashboard>('/dashboard', { params: clean(params) })).data,
  hotelComparison: async (params?: Params) =>
    (await api.get<HotelStats[]>('/dashboard/hotel-comparison', { params: clean(params) })).data,
};

export const reportApi = {
  kpi: async (params?: Params) => (await api.get<Kpi>('/reports/kpi', { params: clean(params) })).data,
  revenue: async (params?: Params) => (await api.get<RevenueRow[]>('/reports/revenue', { params: clean(params) })).data,
  occupancy: async (params?: Params) =>
    (await api.get<OccupancyRow[]>('/reports/occupancy', { params: clean(params) })).data,
  categories: async (params?: Params) =>
    (await api.get<CategoryRow[]>('/reports/categories', { params: clean(params) })).data,
  expenses: async (params?: Params) => (await api.get<ExpenseRow[]>('/reports/expenses', { params: clean(params) })).data,
  profit: async (params?: Params) => (await api.get<ProfitRow[]>('/reports/profit', { params: clean(params) })).data,
  cancellations: async (params?: Params) =>
    (await api.get<CancellationRow[]>('/reports/cancellations', { params: clean(params) })).data,
  pendingPayments: async (params?: Params) =>
    (await api.get<PendingPaymentRow[]>('/reports/pending-payments', { params: clean(params) })).data,
};

export const notificationApi = {
  list: async (limit = 30) => (await api.get<Notification[]>('/notifications', { params: { limit } })).data,
  unreadCount: async () => (await api.get<{ unread: number }>('/notifications/unread-count')).data,
  markRead: async (id: number) => api.post(`/notifications/${id}/read`),
  markAllRead: async () => api.post('/notifications/read-all'),
};

export const searchApi = {
  global: async (term: string) =>
    (await api.get<GlobalSearchResult[]>('/search', { params: { q: term } })).data,
};

export const systemApi = {
  /** Spring Boot actuator health probe - used to show API connectivity on the login screen. */
  health: async () => {
    const response = await api.get('/actuator/health', { baseURL: '', timeout: 6000 });
    return response.data as { status: string };
  },
};

export const auditApi = {
  list: async (params?: Params) => (await api.get<PageResponse<AuditLog>>('/audit-logs', { params: clean(params) })).data,
};

export const feedbackApi = {
  list: async (params?: Params) => (await api.get<Feedback[]>('/feedback', { params: clean(params) })).data,
  create: async (payload: Params) => (await api.post<Feedback>('/feedback', payload)).data,
  resolve: async (id: number, resolution: string) =>
    (await api.post<Feedback>(`/feedback/${id}/resolve`, { resolution })).data,
};

export const couponApi = {
  list: async (hotelId: number) => (await api.get<Coupon[]>('/coupons', { params: { hotelId } })).data,
  create: async (payload: Params) => (await api.post<Coupon>('/coupons', payload)).data,
  update: async (id: number, payload: Params) => (await api.put<Coupon>(`/coupons/${id}`, payload)).data,
  remove: async (id: number) => api.delete(`/coupons/${id}`),
};

export const serviceApi = {
  list: async (params?: Params) => (await api.get<ServiceOrder[]>('/services', { params: clean(params) })).data,
  create: async (payload: Params) => (await api.post<ServiceOrder>('/services', payload)).data,
  updateStatus: async (id: number, status: string) =>
    (await api.patch<ServiceOrder>(`/services/${id}/status`, null, { params: { status } })).data,
  remove: async (id: number) => api.delete(`/services/${id}`),
};

export type { ExpenseCategory };
