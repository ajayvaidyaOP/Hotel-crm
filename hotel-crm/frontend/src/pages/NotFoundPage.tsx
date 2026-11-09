import { Link } from 'react-router-dom';
import { Compass } from 'lucide-react';
import { Button } from '@/components/ui/button';

const NotFoundPage = () => (
  <div className="grid min-h-[60vh] place-items-center">
    <div className="surface max-w-md p-10 text-center">
      <span className="mx-auto mb-3 grid h-12 w-12 place-items-center rounded-full bg-navy-50">
        <Compass className="h-6 w-6 text-navy-700" />
      </span>
      <p className="text-4xl font-semibold tracking-tight text-navy-900">404</p>
      <h2 className="mt-1 text-lg font-semibold text-navy-900">Page not found</h2>
      <p className="mt-1 text-sm text-muted-foreground">
        The page you are looking for may have been moved, or you may not have access to it.
      </p>
      <Button asChild className="mt-5">
        <Link to="/dashboard">Back to dashboard</Link>
      </Button>
    </div>
  </div>
);

export default NotFoundPage;
