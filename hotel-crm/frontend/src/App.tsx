import { Navigate, Route, Routes } from 'react-router-dom';
import { AuthProvider } from '@/context/AuthContext';
import { HotelProvider } from '@/context/HotelContext';
import { AppShell } from '@/components/layout/AppShell';
import { ProtectedRoute } from '@/components/layout/ProtectedRoute';
import LoginPage from '@/pages/LoginPage';
import ResetPasswordPage from '@/pages/ResetPasswordPage';
import DashboardPage from '@/pages/DashboardPage';
import HotelsPage from '@/pages/HotelsPage';
import HotelDetailPage from '@/pages/HotelDetailPage';
import RoomsPage from '@/pages/RoomsPage';
import BookingsPage from '@/pages/BookingsPage';
import BookingDetailPage from '@/pages/BookingDetailPage';
import CalendarPage from '@/pages/CalendarPage';
import GuestsPage from '@/pages/GuestsPage';
import GuestDetailPage from '@/pages/GuestDetailPage';
import PaymentsPage from '@/pages/PaymentsPage';
import InvoicesPage from '@/pages/InvoicesPage';
import ExpensesPage from '@/pages/ExpensesPage';
import HousekeepingPage from '@/pages/HousekeepingPage';
import StaffPage from '@/pages/StaffPage';
import ReportsPage from '@/pages/ReportsPage';
import NotificationsPage from '@/pages/NotificationsPage';
import AuditLogsPage from '@/pages/AuditLogsPage';
import SettingsPage from '@/pages/SettingsPage';
import NotFoundPage from '@/pages/NotFoundPage';

const App = () => (
  <AuthProvider>
    <HotelProvider>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route path="/reset-password" element={<ResetPasswordPage />} />
        <Route
          element={
            <ProtectedRoute>
              <AppShell />
            </ProtectedRoute>
          }
        >
          <Route index element={<Navigate to="/dashboard" replace />} />
          <Route
            path="/dashboard"
            element={
              <ProtectedRoute>
                <DashboardPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/hotels"
            element={
              <ProtectedRoute permission="hotel:read">
                <HotelsPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/hotels/:id"
            element={
              <ProtectedRoute permission="hotel:read">
                <HotelDetailPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/rooms"
            element={
              <ProtectedRoute permission="room:read">
                <RoomsPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/bookings"
            element={
              <ProtectedRoute permission="booking:read">
                <BookingsPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/bookings/:id"
            element={
              <ProtectedRoute permission="booking:read">
                <BookingDetailPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/calendar"
            element={
              <ProtectedRoute permission="booking:read">
                <CalendarPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/guests"
            element={
              <ProtectedRoute permission="guest:read">
                <GuestsPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/guests/:id"
            element={
              <ProtectedRoute permission="guest:read">
                <GuestDetailPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/payments"
            element={
              <ProtectedRoute permission="payment:read">
                <PaymentsPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/invoices"
            element={
              <ProtectedRoute permission="invoice:read">
                <InvoicesPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/expenses"
            element={
              <ProtectedRoute permission="expense:read">
                <ExpensesPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/housekeeping"
            element={
              <ProtectedRoute permission="housekeeping:read">
                <HousekeepingPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/staff"
            element={
              <ProtectedRoute permission="staff:read">
                <StaffPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/reports"
            element={
              <ProtectedRoute permission="report:read">
                <ReportsPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/notifications"
            element={
              <ProtectedRoute>
                <NotificationsPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/audit"
            element={
              <ProtectedRoute permission="audit:read">
                <AuditLogsPage />
              </ProtectedRoute>
            }
          />
          <Route
            path="/settings"
            element={
              <ProtectedRoute>
                <SettingsPage />
              </ProtectedRoute>
            }
          />
          <Route path="*" element={<NotFoundPage />} />
        </Route>
      </Routes>
    </HotelProvider>
  </AuthProvider>
);

export default App;
