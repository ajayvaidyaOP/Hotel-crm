export type Role = 'SUPER_ADMIN' | 'HOTEL_MANAGER' | 'RECEPTIONIST' | 'HOUSEKEEPING' | 'ACCOUNTANT';

export type HotelStatus = 'ACTIVE' | 'INACTIVE' | 'ARCHIVED';
export type RoomStatus = 'AVAILABLE' | 'OCCUPIED' | 'CLEANING' | 'MAINTENANCE' | 'OUT_OF_SERVICE';
export type HousekeepingCondition = 'CLEAN' | 'DIRTY' | 'INSPECTED';
export type RoomType = 'SINGLE' | 'DOUBLE' | 'TWIN' | 'TRIPLE' | 'FAMILY' | 'SUITE';
export type BedType = 'SINGLE' | 'DOUBLE' | 'QUEEN' | 'KING' | 'TWIN' | 'SOFA_BED';
export type BookingStatus = 'PENDING' | 'CONFIRMED' | 'CHECKED_IN' | 'CHECKED_OUT' | 'CANCELLED' | 'NO_SHOW';
export type PaymentStatus = 'UNPAID' | 'PARTIALLY_PAID' | 'PAID' | 'REFUNDED';
export type BookingSource = 'DIRECT' | 'WALK_IN' | 'PHONE' | 'WEBSITE' | 'OTA' | 'AGENT' | 'CORPORATE';
export type PaymentMethod = 'CASH' | 'UPI' | 'CARD' | 'BANK_TRANSFER' | 'CHEQUE' | 'ONLINE';
export type InvoiceStatus = 'DRAFT' | 'ISSUED' | 'PARTIALLY_PAID' | 'PAID' | 'CANCELLED';
export type ExpenseCategory =
  | 'ELECTRICITY' | 'WATER' | 'MAINTENANCE' | 'SALARY' | 'FOOD_SUPPLIES' | 'LAUNDRY' | 'VENDOR' | 'OTHER';
export type HousekeepingTaskStatus = 'PENDING' | 'IN_PROGRESS' | 'COMPLETED' | 'INSPECTED' | 'CANCELLED';
export type HousekeepingTaskType = 'CLEANING' | 'DEEP_CLEAN' | 'INSPECTION' | 'LINEN_CHANGE' | 'MAINTENANCE_FOLLOWUP';
export type TaskPriority = 'LOW' | 'NORMAL' | 'HIGH' | 'URGENT';
export type MaintenanceStatus = 'OPEN' | 'IN_PROGRESS' | 'RESOLVED' | 'CLOSED';
export type ServiceOrderType = 'RESTAURANT' | 'ROOM_SERVICE' | 'LAUNDRY' | 'MINIBAR' | 'OTHER';
export type ServiceOrderStatus = 'PENDING' | 'PREPARING' | 'SERVED' | 'DELIVERED' | 'BILLED' | 'CANCELLED';
export type GuestCategory = 'REGULAR' | 'CORPORATE' | 'VIP' | 'LOYALTY' | 'BLACKLISTED';
export type IdProofType = 'AADHAAR' | 'PASSPORT' | 'DRIVING_LICENSE' | 'VOTER_ID' | 'PAN' | 'OTHER';
export type PricingType = 'STANDARD' | 'WEEKEND' | 'SEASONAL' | 'HOLIDAY' | 'PROMO';
export type AdjustmentType = 'FIXED' | 'PERCENTAGE' | 'INCREMENT';
export type DiscountType = 'PERCENTAGE' | 'FLAT';
export type AttendanceStatus = 'PRESENT' | 'ABSENT' | 'LEAVE' | 'HALF_DAY' | 'WEEK_OFF';
export type NotificationSeverity = 'INFO' | 'SUCCESS' | 'WARNING' | 'CRITICAL';
export type LostFoundStatus = 'STORED' | 'RETURNED' | 'DISPOSED';
export type FeedbackType = 'FEEDBACK' | 'COMPLAINT';
export type FeedbackStatus = 'OPEN' | 'IN_PROGRESS' | 'RESOLVED';

export interface PageResponse<T> {
  content: T[];
  page: number;
  size: number;
  totalElements: number;
  totalPages: number;
  last: boolean;
}

export interface HotelSummary {
  id: number;
  name: string;
  code: string;
  city?: string | null;
  state?: string | null;
  imageUrl?: string | null;
  starRating?: number | null;
  status: HotelStatus;
  timezone?: string;
  taxRate?: number;
}

export interface Hotel {
  id: number;
  name: string;
  code: string;
  address?: string | null;
  city?: string | null;
  state?: string | null;
  country?: string | null;
  postalCode?: string | null;
  contactNumber?: string | null;
  email?: string | null;
  description?: string | null;
  imageUrls: string[];
  facilities: string[];
  checkInTime: string;
  checkOutTime: string;
  timezone: string;
  starRating?: number | null;
  gstNumber?: string | null;
  taxRate: number;
  status: HotelStatus;
  roomCount: number;
  staffCount: number;
  activeBookings: number;
  revenueThisMonth: number;
  createdAt: string;
}

export interface MeResponse {
  id: number;
  fullName: string;
  email: string;
  phone?: string | null;
  role: Role;
  roleLabel: string;
  designation?: string | null;
  permissions: string[];
  hotels: HotelSummary[];
  mustChangePassword: boolean;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
  tokenType: string;
  expiresIn: number;
  user: MeResponse;
}

export interface RoomCategory {
  id: number;
  hotelId: number;
  name: string;
  code: string;
  description?: string | null;
  basePrice: number;
  weekendPrice?: number | null;
  extraPersonCharge: number;
  extraBedCharge: number;
  earlyCheckinCharge: number;
  lateCheckoutCharge: number;
  maxOccupancy: number;
  amenities: string[];
  imageUrls: string[];
  sortOrder: number;
  active: boolean;
  roomCount: number;
}

export interface BookingRoomSegment {
  id: number;
  roomId?: number | null;
  roomNumber?: string | null;
  categoryId: number;
  categoryName: string;
  checkInDate: string;
  checkOutDate: string;
  nights: number;
  ratePerNight: number;
  totalAmount: number;
  status: string;
}

export interface Room {
  id: number;
  hotelId: number;
  hotelName: string;
  categoryId: number;
  categoryName: string;
  categoryCode: string;
  roomNumber: string;
  floor: number;
  roomType: RoomType;
  bedType: BedType;
  maxOccupancy: number;
  ac: boolean;
  description?: string | null;
  imageUrls: string[];
  amenities: string[];
  basePrice: number;
  weekendPrice?: number | null;
  extraPersonCharge: number;
  status: RoomStatus;
  housekeepingStatus: HousekeepingCondition;
  active: boolean;
  currentStay?: BookingRoomSegment | null;
}

export interface RatePlan {
  id: number;
  hotelId: number;
  categoryId?: number | null;
  categoryName?: string | null;
  roomId?: number | null;
  roomNumber?: string | null;
  name: string;
  pricingType: PricingType;
  adjustmentType: AdjustmentType;
  amount: number;
  startDate?: string | null;
  endDate?: string | null;
  daysOfWeek?: string | null;
  priority: number;
  active: boolean;
}

export interface QuoteNight {
  date: string;
  rate: number;
  appliedPlan?: string | null;
}

export interface Quote {
  categoryId: number;
  categoryName: string;
  checkIn: string;
  checkOut: string;
  nights: number;
  averageRate: number;
  roomTotal: number;
  extraPersonCharge: number;
  total: number;
  breakdown: QuoteNight[];
}

export interface Guest {
  id: number;
  fullName: string;
  mobile: string;
  email?: string | null;
  address?: string | null;
  city?: string | null;
  state?: string | null;
  country?: string | null;
  idProofType?: IdProofType | null;
  idProofMasked?: string | null;
  category: GuestCategory;
  vip: boolean;
  blacklisted: boolean;
  notes?: string | null;
  specialRequests?: string | null;
  loyaltyPoints: number;
  totalBookings: number;
  completedStays: number;
  totalSpending: number;
  outstanding: number;
  lastStayDate?: string | null;
  createdAt: string;
  hotelName?: string | null;
}

export interface BookingSummary {
  id: number;
  bookingCode: string;
  hotelId: number;
  hotelName: string;
  guestId: number;
  guestName: string;
  guestMobile: string;
  checkInDate: string;
  checkOutDate: string;
  nights: number;
  adults: number;
  children: number;
  status: BookingStatus;
  paymentStatus: PaymentStatus;
  totalAmount: number;
  paidAmount: number;
  pendingAmount: number;
  bookingSource: BookingSource;
  roomNumbers: string[];
  createdAt: string;
  actualCheckInAt?: string | null;
  actualCheckOutAt?: string | null;
}

export interface Payment {
  id: number;
  paymentCode: string;
  hotelId: number;
  hotelName: string;
  bookingId?: number | null;
  bookingCode?: string | null;
  invoiceId?: number | null;
  invoiceNumber?: string | null;
  guestName?: string | null;
  amount: number;
  method: PaymentMethod;
  paymentType: string;
  status: string;
  referenceNo?: string | null;
  notes?: string | null;
  paidAt: string;
  receivedByName?: string | null;
}

export interface Refund {
  id: number;
  hotelId: number;
  bookingId?: number | null;
  bookingCode?: string | null;
  paymentId?: number | null;
  amount: number;
  reason?: string | null;
  method?: PaymentMethod | null;
  status: string;
  processedAt: string;
  processedByName?: string | null;
}

export interface InvoiceLine {
  id: number;
  lineType: string;
  description: string;
  quantity: number;
  unitPrice: number;
  amount: number;
}

export interface Invoice {
  id: number;
  invoiceNumber: string;
  hotelId: number;
  hotelName: string;
  hotelAddress?: string | null;
  hotelGstin?: string | null;
  bookingId?: number | null;
  bookingCode?: string | null;
  guestId?: number | null;
  guestName?: string | null;
  billToAddress?: string | null;
  issueDate: string;
  dueDate?: string | null;
  subtotal: number;
  discount: number;
  taxRate: number;
  taxAmount: number;
  total: number;
  amountPaid: number;
  balance: number;
  status: InvoiceStatus;
  notes?: string | null;
  lines: InvoiceLine[];
}

export interface ServiceOrder {
  id: number;
  hotelId: number;
  hotelName: string;
  bookingId?: number | null;
  bookingCode?: string | null;
  roomId?: number | null;
  roomNumber?: string | null;
  guestName?: string | null;
  orderType: ServiceOrderType;
  description: string;
  amount: number;
  quantity: number;
  lineTotal: number;
  status: ServiceOrderStatus;
  billedToRoom: boolean;
  orderedAt: string;
  deliveredAt?: string | null;
}

export interface Booking {
  summary: BookingSummary;
  rooms: BookingRoomSegment[];
  payments: Payment[];
  services: ServiceOrder[];
  specialRequests?: string | null;
  internalNotes?: string | null;
  cancellationReason?: string | null;
  cancelledAt?: string | null;
  roomChargeTotal: number;
  extraCharges: number;
  discountAmount: number;
  taxAmount: number;
  advanceAmount: number;
  couponCode?: string | null;
  invoiceId?: number | null;
  invoiceNumber?: string | null;
  guestEmail?: string | null;
  guestIdProofMasked?: string | null;
  checkedInByName?: string | null;
  checkedOutByName?: string | null;
}

export interface CalendarRoom {
  roomId: number;
  roomNumber: string;
  floor: number;
  categoryName: string;
  status: RoomStatus;
  housekeepingStatus: HousekeepingCondition;
  basePrice: number;
}

export interface CalendarEntry {
  bookingId: number;
  bookingCode: string;
  segmentId: number;
  roomId?: number | null;
  roomNumber: string;
  guestName: string;
  guestMobile: string;
  checkInDate: string;
  checkOutDate: string;
  nights: number;
  status: BookingStatus;
  paymentStatus: PaymentStatus;
  totalAmount: number;
  pendingAmount: number;
  adults: number;
  children: number;
}

export interface BookingCalendar {
  hotelId: number;
  from: string;
  to: string;
  rooms: CalendarRoom[];
  entries: CalendarEntry[];
}

export interface DayOperations {
  date: string;
  arrivals: BookingSummary[];
  departures: BookingSummary[];
  inHouse: BookingSummary[];
}

export interface Expense {
  id: number;
  hotelId: number;
  hotelName: string;
  category: ExpenseCategory;
  description: string;
  amount: number;
  expenseDate: string;
  vendor?: string | null;
  paymentMethod?: PaymentMethod | null;
  referenceNo?: string | null;
  createdByName?: string | null;
  createdAt: string;
}

export interface HousekeepingTask {
  id: number;
  hotelId: number;
  hotelName: string;
  roomId?: number | null;
  roomNumber?: string | null;
  roomCategory?: string | null;
  taskType: HousekeepingTaskType;
  status: HousekeepingTaskStatus;
  priority: TaskPriority;
  assignedTo?: number | null;
  assignedToName?: string | null;
  notes?: string | null;
  scheduledDate?: string | null;
  startedAt?: string | null;
  completedAt?: string | null;
  inspectedAt?: string | null;
  createdAt: string;
}

export interface MaintenanceRequest {
  id: number;
  hotelId: number;
  hotelName: string;
  roomId?: number | null;
  roomNumber?: string | null;
  title: string;
  description?: string | null;
  category: string;
  priority: TaskPriority;
  status: MaintenanceStatus;
  reportedByName?: string | null;
  assignedToName?: string | null;
  cost?: number | null;
  reportedAt: string;
  resolvedAt?: string | null;
  resolutionNote?: string | null;
}

export interface LostFoundItem {
  id: number;
  hotelId: number;
  hotelName: string;
  roomId?: number | null;
  roomNumber?: string | null;
  guestId?: number | null;
  guestName?: string | null;
  itemDescription: string;
  foundByName?: string | null;
  foundAt: string;
  status: LostFoundStatus;
  storageLocation?: string | null;
  notes?: string | null;
}

export interface StaffMember {
  id: number;
  fullName: string;
  email: string;
  phone?: string | null;
  role: Role;
  roleLabel: string;
  designation?: string | null;
  active: boolean;
  lastLoginAt?: string | null;
  createdAt: string;
  hotels: HotelSummary[];
  employeeCode?: string | null;
  department?: string | null;
  shiftName?: string | null;
  shiftStart?: string | null;
  shiftEnd?: string | null;
  joinedOn?: string | null;
}

export interface Attendance {
  id: number;
  hotelId: number;
  userId: number;
  userName: string;
  role?: string | null;
  attendanceDate: string;
  status: AttendanceStatus;
  shiftName?: string | null;
  checkInTime?: string | null;
  checkOutTime?: string | null;
  notes?: string | null;
}

export interface AttendanceSummary {
  present: number;
  absent: number;
  leave: number;
  halfDay: number;
  weekOff: number;
  totalStaff: number;
}

export interface Feedback {
  id: number;
  hotelId: number;
  hotelName: string;
  guestId?: number | null;
  guestName?: string | null;
  bookingId?: number | null;
  bookingCode?: string | null;
  type: FeedbackType;
  rating?: number | null;
  comments?: string | null;
  status: FeedbackStatus;
  resolution?: string | null;
  resolvedAt?: string | null;
  createdAt: string;
}

export interface Coupon {
  id: number;
  hotelId?: number | null;
  code: string;
  description?: string | null;
  discountType: DiscountType;
  value: number;
  minAmount: number;
  maxDiscount?: number | null;
  validFrom?: string | null;
  validTo?: string | null;
  usageLimit?: number | null;
  usedCount: number;
  active: boolean;
}

export interface Notification {
  id: number;
  hotelId?: number | null;
  hotelName?: string | null;
  title: string;
  message: string;
  type: string;
  severity: NotificationSeverity;
  link?: string | null;
  isRead: boolean;
  readAt?: string | null;
  createdAt: string;
}

export interface AuditLog {
  id: number;
  hotelId?: number | null;
  userId?: number | null;
  actorEmail?: string | null;
  action: string;
  entityType?: string | null;
  entityId?: number | null;
  description?: string | null;
  ipAddress?: string | null;
  createdAt: string;
}

export interface NamedValue {
  name: string;
  value: number;
  count: number;
}

export interface TimePoint {
  label: string;
  date: string;
  revenue: number;
  bookings: number;
  occupancyPercent: number;
}

export interface HotelStats {
  hotelId: number;
  hotelName: string;
  totalRooms: number;
  availableRooms: number;
  occupiedRooms: number;
  revenueThisMonth: number;
  revenueThisYear: number;
  pendingPayments: number;
  occupancyPercent: number;
  adr: number;
}

export interface ActivityRow {
  at: string;
  actor?: string | null;
  action: string;
  description?: string | null;
  hotelName?: string | null;
  ipAddress?: string | null;
}

export interface UpcomingBooking {
  id: number;
  bookingCode: string;
  guestName: string;
  guestMobile: string;
  checkInDate: string;
  checkOutDate: string;
  rooms: number;
  status: BookingStatus;
  paymentStatus: PaymentStatus;
}

export interface Dashboard {
  hotelId?: number | null;
  scope: string;
  from: string;
  to: string;
  generatedAt: string;
  hotelCount: number;
  totalRooms: number;
  availableRooms: number;
  occupiedRooms: number;
  reservedRooms: number;
  maintenanceRooms: number;
  cleaningRooms: number;
  outOfServiceRooms: number;
  dirtyRooms: number;
  inHouseGuests: number;
  todayCheckIns: number;
  todayCheckOuts: number;
  todayBookings: number;
  pendingHousekeeping: number;
  openMaintenance: number;
  occupancyPercent: number;
  monthlyRevenue: number;
  yearlyRevenue: number;
  todayRevenue: number;
  pendingPayments: number;
  outstandingInvoices: number;
  monthlyExpenses: number;
  monthlyProfit: number;
  adr: number;
  revpar: number;
  serviceRevenueMonth: number;
  hotels: HotelStats[];
  revenueTrend: TimePoint[];
  revenueByHotel: NamedValue[];
  bookingSourceBreakdown: NamedValue[];
  roomStatusBreakdown: NamedValue[];
  paymentMethodBreakdown: NamedValue[];
  recentActivities: ActivityRow[];
  upcomingCheckIns: UpcomingBooking[];
  recentBookings: BookingSummary[];
}

export interface Kpi {
  from: string;
  to: string;
  hotelIds: number[];
  revenue: number;
  roomRevenue: number;
  serviceRevenue: number;
  refunds: number;
  netRevenue: number;
  expenses: number;
  profit: number;
  pendingPayments: number;
  bookings: number;
  cancelledBookings: number;
  completedStays: number;
  roomNightsSold: number;
  roomNightsAvailable: number;
  occupancyPercent: number;
  adr: number;
  revpar: number;
  cancellationPercent: number;
  averageLengthOfStay: number;
}

export interface RevenueRow {
  period: string;
  date: string;
  roomRevenue: number;
  serviceRevenue: number;
  tax: number;
  total: number;
  refunds: number;
  bookings: number;
}

export interface OccupancyRow {
  hotelId: number;
  hotelName: string;
  totalRooms: number;
  roomNights: number;
  occupiedNights: number;
  occupancyPercent: number;
  revenue: number;
  adr: number;
  revpar: number;
}

export interface CategoryRow {
  category: string;
  bookings: number;
  revenue: number;
  sharePercent: number;
}

export interface ExpenseRow {
  category: string;
  amount: number;
  sharePercent: number;
  entries: number;
}

export interface ProfitRow {
  hotelId: number;
  hotelName: string;
  revenue: number;
  refunds: number;
  expenses: number;
  profit: number;
  marginPercent: number;
}

export interface CancellationRow {
  bookingId: number;
  bookingCode: string;
  hotelName: string;
  guestName: string;
  amount: number;
  cancelledAt: string;
  reason?: string | null;
}

export interface PendingPaymentRow {
  bookingId: number;
  bookingCode: string;
  hotelId: number;
  hotelName: string;
  guestName: string;
  guestMobile: string;
  checkInDate: string;
  checkOutDate: string;
  totalAmount: number;
  paidAmount: number;
  pendingAmount: number;
  daysOverdue: number;
  status: string;
}

export interface GlobalSearchResult {
  type: string;
  id: number;
  title: string;
  subtitle?: string | null;
  hotelName?: string | null;
  link: string;
}
