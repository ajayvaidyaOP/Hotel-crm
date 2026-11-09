import { useEffect, useState } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import { Building2, CheckCircle2, Eye, EyeOff, KeyRound, LineChart, Lock, Mail, ShieldCheck, Sparkles } from 'lucide-react';
import { toast } from 'sonner';
import { Button } from '@/components/ui/button';
import { Field, Input } from '@/components/ui/input';
import { Dialog, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { useQuery } from '@tanstack/react-query';
import { useAuth } from '@/context/AuthContext';
import { authApi, systemApi } from '@/lib/endpoints';
import { getErrorMessage } from '@/lib/api';
import { Spinner } from '@/components/ui/misc';

const HIGHLIGHTS = [
  { icon: Building2, title: 'Five hotels, one console', description: 'Switch properties or view the whole group in a click.' },
  { icon: LineChart, title: 'Revenue intelligence', description: 'Live occupancy, ADR, RevPAR and profit by hotel.' },
  { icon: ShieldCheck, title: 'Role-based access', description: 'Every permission enforced by the API, not the browser.' },
];

const DEMO_ACCOUNTS = [
  { label: 'Owner', email: 'owner@hotelgroup.com', password: 'Owner@123' },
  { label: 'Manager', email: 'manager.goa@hotelgroup.com', password: 'Hotel@123' },
  { label: 'Reception', email: 'reception.mumbai@hotelgroup.com', password: 'Hotel@123' },
];

const LoginPage = () => {
  const { login, loggingIn, user, initializing } = useAuth();
  const navigate = useNavigate();
  const [params] = useSearchParams();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');
  const [forgotOpen, setForgotOpen] = useState(false);
  const [forgotEmail, setForgotEmail] = useState('');
  const [forgotLoading, setForgotLoading] = useState(false);

  const redirect = params.get('redirect') || '/dashboard';
  const healthQuery = useQuery({
    queryKey: ['api-health'],
    queryFn: systemApi.health,
    retry: false,
    refetchInterval: 30_000,
  });

  useEffect(() => {
    if (!initializing && user) navigate(redirect, { replace: true });
  }, [user, initializing, navigate, redirect]);

  const submit = async (event: React.FormEvent) => {
    event.preventDefault();
    setError('');
    try {
      const me = await login(email.trim(), password);
      toast.success(`Welcome back, ${me.fullName.split(' ')[0]}`);
      navigate(redirect, { replace: true });
    } catch (err) {
      setError(getErrorMessage(err));
    }
  };

  const sendReset = async () => {
    if (!forgotEmail.trim()) return;
    setForgotLoading(true);
    try {
      await authApi.forgotPassword(forgotEmail.trim());
      toast.success('If that email exists, a reset link is on its way.');
      setForgotOpen(false);
      setForgotEmail('');
    } catch (err) {
      toast.error(getErrorMessage(err));
    } finally {
      setForgotLoading(false);
    }
  };

  return (
    <div className="grid min-h-screen lg:grid-cols-[1.05fr_1fr]">
      <div className="relative hidden flex-col justify-between overflow-hidden bg-navy-950 p-10 text-white lg:flex">
        <div className="absolute -right-24 -top-24 h-72 w-72 rounded-full bg-brand-600/30 blur-3xl" />
        <div className="absolute -bottom-32 -left-20 h-80 w-80 rounded-full bg-brand-500/20 blur-3xl" />

        <div className="relative">
          <div className="flex items-center gap-3">
            <span className="grid h-11 w-11 place-items-center rounded-xl bg-brand-500 text-sm font-bold shadow-lg shadow-brand-900/50">HC</span>
            <div>
              <p className="text-lg font-semibold tracking-tight">Hotel CRM</p>
              <p className="text-xs text-navy-300">Multi-property management suite</p>
            </div>
          </div>

          <h1 className="mt-14 max-w-md text-3xl font-semibold leading-tight tracking-tight">
            Run five hotels with the precision of one.
          </h1>
          <p className="mt-3 max-w-md text-sm leading-relaxed text-navy-300">
            Centralised reservations, front-desk operations, housekeeping, billing and analytics — built for owners who
            manage multiple properties from a single account.
          </p>

          <div className="mt-10 space-y-4">
            {HIGHLIGHTS.map((item) => (
              <div key={item.title} className="flex items-start gap-3">
                <span className="mt-0.5 grid h-8 w-8 place-items-center rounded-lg bg-white/10">
                  <item.icon className="h-4 w-4 text-brand-300" />
                </span>
                <div>
                  <p className="text-sm font-medium">{item.title}</p>
                  <p className="text-xs text-navy-300">{item.description}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        <div className="relative grid grid-cols-3 gap-3 rounded-xl border border-white/10 bg-white/5 p-4 text-center">
          {[
            { value: '5', label: 'Hotels' },
            { value: '100', label: 'Rooms' },
            { value: '28+', label: 'Workflows' },
          ].map((stat) => (
            <div key={stat.label}>
              <p className="text-xl font-semibold">{stat.value}</p>
              <p className="text-[11px] uppercase tracking-wide text-navy-300">{stat.label}</p>
            </div>
          ))}
        </div>
      </div>

      <div className="flex items-center justify-center bg-background px-5 py-10 sm:px-8">
        <div className="w-full max-w-sm">
          <div className="mb-8 flex items-center gap-2 lg:hidden">
            <span className="grid h-10 w-10 place-items-center rounded-xl bg-navy-900 text-sm font-bold text-white">HC</span>
            <div>
              <p className="text-base font-semibold text-navy-900">Hotel CRM</p>
              <p className="text-xs text-muted-foreground">Multi-property management</p>
            </div>
          </div>

          <div className="space-y-1">
            <h2 className="text-2xl font-semibold tracking-tight text-navy-900">Sign in</h2>
            <p className="text-sm text-muted-foreground">Use your work email to access the group console.</p>
          </div>

          {healthQuery.isError && (
            <div className="mt-4 rounded-lg border border-amber-200 bg-amber-50 px-3 py-2 text-[11px] leading-relaxed text-amber-900">
              <p className="font-semibold">API server not reachable</p>
              <p>
                Start the Spring Boot backend on port 8080 (MySQL must be running) and this screen will connect
                automatically. See <span className="font-medium">README.md → Quick start</span>.
              </p>
            </div>
          )}

          <form onSubmit={submit} className="mt-6 space-y-4">
            <Field label="Work email" required>
              <div className="relative">
                <Mail className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                  type="email"
                  value={email}
                  onChange={(event) => setEmail(event.target.value)}
                  placeholder="you@hotelgroup.com"
                  className="pl-9"
                  autoComplete="email"
                  required
                />
              </div>
            </Field>

            <Field label="Password" required>
              <div className="relative">
                <Lock className="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                  type={showPassword ? 'text' : 'password'}
                  value={password}
                  onChange={(event) => setPassword(event.target.value)}
                  placeholder="••••••••"
                  className="pl-9 pr-9"
                  autoComplete="current-password"
                  required
                />
                <button
                  type="button"
                  onClick={() => setShowPassword((value) => !value)}
                  className="absolute right-2 top-1/2 -translate-y-1/2 rounded p-1 text-muted-foreground hover:bg-muted"
                  aria-label={showPassword ? 'Hide password' : 'Show password'}
                >
                  {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                </button>
              </div>
            </Field>

            {error && (
              <div className="rounded-lg border border-red-200 bg-red-50 px-3 py-2 text-xs font-medium text-red-700">{error}</div>
            )}

            <div className="flex items-center justify-between">
              <button type="button" onClick={() => setForgotOpen(true)} className="text-xs font-medium text-brand-700 hover:underline">
                Forgot password?
              </button>
              <span className="text-[11px] text-muted-foreground">Protected by JWT + rate limiting</span>
            </div>

            <Button type="submit" className="h-10 w-full" loading={loggingIn || initializing}>
              {initializing ? 'Loading…' : 'Sign in to console'}
            </Button>
          </form>

          <div className="mt-7 rounded-xl border border-dashed border-border bg-card p-3">
            <p className="flex items-center gap-1.5 text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">
              <Sparkles className="h-3.5 w-3.5" /> Demo accounts
            </p>
            <div className="mt-2 grid gap-1.5">
              {DEMO_ACCOUNTS.map((account) => (
                <button
                  key={account.email}
                  type="button"
                  onClick={() => {
                    setEmail(account.email);
                    setPassword(account.password);
                    setError('');
                  }}
                  className="flex items-center justify-between rounded-md px-2 py-1.5 text-left text-xs transition-colors hover:bg-muted"
                >
                  <span className="font-medium text-navy-800">{account.label}</span>
                  <span className="truncate text-muted-foreground">{account.email}</span>
                </button>
              ))}
            </div>
          </div>

          <p className="mt-6 flex items-center justify-center gap-1.5 text-center text-[11px] text-muted-foreground">
            <span className={`h-1.5 w-1.5 rounded-full ${healthQuery.isSuccess ? 'bg-emerald-500' : healthQuery.isError ? 'bg-amber-500' : 'bg-navy-300'}`} />
            {healthQuery.isSuccess ? 'Connected to the Hotel CRM API' : healthQuery.isError ? 'Waiting for the API server' : 'Checking API status…'}
          </p>
          <p className="mt-1 text-center text-[11px] text-muted-foreground">
            Need an account? Ask your property owner to invite you from Staff management.
          </p>
          <p className="mt-1 text-center text-[11px] text-muted-foreground">
            <Link to="/dashboard" className="hover:underline">Return to console</Link>
          </p>
        </div>
      </div>

      <Dialog open={forgotOpen} onOpenChange={setForgotOpen}>
        <DialogContent size="sm">
          <DialogHeader>
            <DialogTitle>Reset your password</DialogTitle>
            <DialogDescription>
              Enter your work email. We will issue a single-use reset link valid for 60 minutes.
            </DialogDescription>
          </DialogHeader>
          <Field label="Work email" required>
            <Input
              type="email"
              value={forgotEmail}
              onChange={(event) => setForgotEmail(event.target.value)}
              placeholder="you@hotelgroup.com"
              autoFocus
            />
          </Field>
          <div className="mt-3 flex items-start gap-2 rounded-lg bg-muted p-2.5 text-[11px] text-muted-foreground">
            <CheckCircle2 className="mt-0.5 h-3.5 w-3.5 shrink-0 text-emerald-600" />
            Reset tokens are hashed in the database and expire automatically. In development the token is written to the
            API log.
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setForgotOpen(false)}>Cancel</Button>
            <Button onClick={sendReset} loading={forgotLoading}>
              <KeyRound className="h-4 w-4" /> Send reset link
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
};

export default LoginPage;
