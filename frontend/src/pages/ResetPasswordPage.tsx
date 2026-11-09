import { useState } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import { ArrowLeft, CheckCircle2, Eye, EyeOff, KeyRound, ShieldCheck } from 'lucide-react';
import { toast } from 'sonner';
import { Button } from '@/components/ui/button';
import { Field, Input } from '@/components/ui/input';
import { authApi } from '@/lib/endpoints';
import { getErrorMessage } from '@/lib/api';

const ResetPasswordPage = () => {
  const [params] = useSearchParams();
  const navigate = useNavigate();
  const [token, setToken] = useState(params.get('token') ?? '');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [show, setShow] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const tooShort = newPassword.length > 0 && newPassword.length < 8;
  const mismatch = confirmPassword.length > 0 && confirmPassword !== newPassword;
  const canSubmit = token.trim().length > 0 && newPassword.length >= 8 && confirmPassword === newPassword;

  const submit = async () => {
    setError('');
    if (!canSubmit) return;
    setLoading(true);
    try {
      await authApi.resetPassword(token.trim(), newPassword);
      toast.success('Password updated. Sign in with your new password.');
      navigate('/login', { replace: true });
    } catch (err) {
      setError(getErrorMessage(err));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="grid min-h-screen lg:grid-cols-[1.05fr_1fr]">
      <div className="relative hidden flex-col justify-between bg-gradient-to-br from-navy-950 via-navy-900 to-brand-900 p-10 text-white lg:flex">
        <div className="flex items-center gap-2.5">
          <span className="grid h-10 w-10 place-items-center rounded-xl bg-brand-500 text-sm font-bold">HC</span>
          <div className="leading-tight">
            <p className="text-sm font-semibold">Hotel CRM</p>
            <p className="text-[11px] text-navy-300">Group operations console</p>
          </div>
        </div>
        <div className="max-w-sm">
          <h1 className="text-3xl font-semibold leading-tight">Choose a new password</h1>
          <p className="mt-3 text-sm text-navy-200">
            Reset links are single use and expire 60 minutes after they are issued. Setting a new password signs out every
            other session for your account.
          </p>
          <ul className="mt-6 space-y-2 text-xs text-navy-200">
            <li className="flex items-center gap-2"><ShieldCheck className="h-3.5 w-3.5 text-brand-300" /> Passwords are stored as bcrypt hashes</li>
            <li className="flex items-center gap-2"><CheckCircle2 className="h-3.5 w-3.5 text-brand-300" /> Token versions invalidate old sessions</li>
            <li className="flex items-center gap-2"><KeyRound className="h-3.5 w-3.5 text-brand-300" /> 8–72 characters, any mix</li>
          </ul>
        </div>
        <p className="text-[11px] text-navy-400">© {new Date().getFullYear()} Hotel CRM · Multi-property operations</p>
      </div>

      <div className="flex items-center justify-center bg-background p-6 sm:p-10">
        <div className="w-full max-w-sm">
          <Link to="/login" className="mb-6 inline-flex items-center gap-1.5 text-xs font-medium text-muted-foreground hover:text-foreground">
            <ArrowLeft className="h-3.5 w-3.5" /> Back to sign in
          </Link>
          <h2 className="text-xl font-semibold tracking-tight">Reset your password</h2>
          <p className="mt-1 text-[13px] text-muted-foreground">
            Paste the reset token from your email (in development it is printed in the API log) and pick a new password.
          </p>

          <div className="mt-6 space-y-4">
            <Field label="Reset token" required>
              <Input value={token} onChange={(event) => setToken(event.target.value)} placeholder="Paste the reset token" autoFocus />
            </Field>
            <Field label="New password" required hint="At least 8 characters" error={tooShort ? 'Password must be at least 8 characters' : undefined}>
              <div className="relative">
                <Input
                  type={show ? 'text' : 'password'}
                  value={newPassword}
                  onChange={(event) => setNewPassword(event.target.value)}
                  placeholder="••••••••"
                  autoComplete="new-password"
                  className="pr-10"
                />
                <button
                  type="button"
                  onClick={() => setShow((value) => !value)}
                  className="absolute right-2 top-1/2 -translate-y-1/2 rounded p-1 text-muted-foreground hover:text-foreground"
                  aria-label={show ? 'Hide password' : 'Show password'}
                >
                  {show ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                </button>
              </div>
            </Field>
            <Field label="Confirm password" required error={mismatch ? 'Passwords do not match' : undefined}>
              <Input
                type={show ? 'text' : 'password'}
                value={confirmPassword}
                onChange={(event) => setConfirmPassword(event.target.value)}
                placeholder="••••••••"
                autoComplete="new-password"
                onKeyDown={(event) => {
                  if (event.key === 'Enter') void submit();
                }}
              />
            </Field>

            {error ? (
              <div className="rounded-lg border border-destructive/30 bg-destructive/5 px-3 py-2 text-xs text-destructive">{error}</div>
            ) : null}

            <Button className="w-full" loading={loading} disabled={!canSubmit} onClick={() => void submit()}>
              <KeyRound className="h-4 w-4" /> Update password
            </Button>
            <p className="text-center text-[11px] text-muted-foreground">
              Token expired? Request a fresh link from the sign-in screen.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ResetPasswordPage;
