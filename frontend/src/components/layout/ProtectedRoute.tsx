import type { ReactNode } from 'react';
import { Navigate, useLocation } from 'react-router-dom';
import { ShieldAlert } from 'lucide-react';
import { useAuth } from '@/context/AuthContext';
import { Spinner } from '@/components/ui/misc';
import { Button } from '@/components/ui/button';
import { Link } from 'react-router-dom';

export const ProtectedRoute = ({ permission, children }: { permission?: string; children: ReactNode }) => {
  const { user, initializing, has } = useAuth();
  const location = useLocation();

  if (initializing) {
    return (
      <div className="grid min-h-screen place-items-center bg-background">
        <div className="flex flex-col items-center gap-3">
          <Spinner className="h-7 w-7" />
          <p className="text-sm text-muted-foreground">Restoring your session…</p>
        </div>
      </div>
    );
  }

  if (!user) {
    return <Navigate to={`/login?redirect=${encodeURIComponent(location.pathname + location.search)}`} replace />;
  }

  if (permission && !has(permission)) {
    return (
      <div className="grid min-h-[70vh] place-items-center">
        <div className="surface max-w-md p-8 text-center">
          <span className="mx-auto mb-3 grid h-12 w-12 place-items-center rounded-full bg-amber-50">
            <ShieldAlert className="h-6 w-6 text-amber-600" />
          </span>
          <h2 className="text-lg font-semibold text-navy-900">Access restricted</h2>
          <p className="mt-1 text-sm text-muted-foreground">
            Your role ({user.roleLabel}) does not include permission to open this section. Ask an owner or manager to
            grant access if you need it.
          </p>
          <Button asChild className="mt-4" variant="outline">
            <Link to="/dashboard">Back to dashboard</Link>
          </Button>
        </div>
      </div>
    );
  }

  return <>{children}</>;
};
