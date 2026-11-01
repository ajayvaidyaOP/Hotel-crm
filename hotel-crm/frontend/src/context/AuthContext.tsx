import { createContext, useCallback, useContext, useEffect, useMemo, useState, type ReactNode } from 'react';
import { useQueryClient } from '@tanstack/react-query';
import { authApi } from '@/lib/endpoints';
import { clearStoredTokens, getStoredTokens, setStoredTokens } from '@/lib/api';
import { can } from '@/lib/permissions';
import type { MeResponse } from '@/lib/types';

interface AuthContextValue {
  user: MeResponse | null;
  initializing: boolean;
  loggingIn: boolean;
  login: (email: string, password: string) => Promise<MeResponse>;
  logout: () => Promise<void>;
  refresh: () => Promise<void>;
  has: (permission?: string | null) => boolean;
  isSuperAdmin: boolean;
}

const AuthContext = createContext<AuthContextValue | undefined>(undefined);

export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [user, setUser] = useState<MeResponse | null>(null);
  const [initializing, setInitializing] = useState(true);
  const [loggingIn, setLoggingIn] = useState(false);
  const queryClient = useQueryClient();

  const refresh = useCallback(async () => {
    const tokens = getStoredTokens();
    if (!tokens) {
      setUser(null);
      return;
    }
    try {
      const me = await authApi.me();
      setUser(me);
    } catch {
      clearStoredTokens();
      setUser(null);
    }
  }, []);

  useEffect(() => {
    let cancelled = false;
    (async () => {
      await refresh();
      if (!cancelled) setInitializing(false);
    })();
    return () => {
      cancelled = true;
    };
  }, [refresh]);

  const login = useCallback(
    async (email: string, password: string) => {
      setLoggingIn(true);
      try {
        const tokens = await authApi.login(email, password);
        setStoredTokens({ accessToken: tokens.accessToken, refreshToken: tokens.refreshToken });
        setUser(tokens.user);
        return tokens.user;
      } finally {
        setLoggingIn(false);
      }
    },
    [],
  );

  const logout = useCallback(async () => {
    try {
      await authApi.logout();
    } catch {
      /* token may already be invalid - still clear locally */
    }
    clearStoredTokens();
    setUser(null);
    queryClient.clear();
  }, [queryClient]);

  const value = useMemo<AuthContextValue>(
    () => ({
      user,
      initializing,
      loggingIn,
      login,
      logout,
      refresh,
      has: (permission) => can(user?.permissions, permission),
      isSuperAdmin: user?.role === 'SUPER_ADMIN',
    }),
    [user, initializing, loggingIn, login, logout, refresh],
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used inside AuthProvider');
  return context;
};
