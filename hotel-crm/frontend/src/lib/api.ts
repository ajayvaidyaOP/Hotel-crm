import axios, { AxiosError, type AxiosRequestConfig, type InternalAxiosRequestConfig } from 'axios';

export const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || '/api';
const TOKEN_KEY = 'hotelcrm.auth';

export interface StoredTokens {
  accessToken: string;
  refreshToken: string;
}

export const getStoredTokens = (): StoredTokens | null => {
  try {
    const raw = localStorage.getItem(TOKEN_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw) as StoredTokens;
    return parsed.accessToken ? parsed : null;
  } catch {
    return null;
  }
};

export const setStoredTokens = (tokens: StoredTokens | null) => {
  if (!tokens) {
    localStorage.removeItem(TOKEN_KEY);
    return;
  }
  localStorage.setItem(TOKEN_KEY, JSON.stringify(tokens));
};

export const clearStoredTokens = () => localStorage.removeItem(TOKEN_KEY);

export const api = axios.create({
  baseURL: API_BASE_URL,
  headers: { 'Content-Type': 'application/json' },
  timeout: 30000,
});

api.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  const tokens = getStoredTokens();
  if (tokens?.accessToken && !config.headers.Authorization) {
    config.headers.Authorization = `Bearer ${tokens.accessToken}`;
  }
  return config;
});

let refreshPromise: Promise<string | null> | null = null;

const refreshAccessToken = async (): Promise<string | null> => {
  const tokens = getStoredTokens();
  if (!tokens?.refreshToken) return null;
  try {
    const response = await axios.post(`${API_BASE_URL}/auth/refresh`, {
      refreshToken: tokens.refreshToken,
    });
    const data = response.data as { accessToken: string; refreshToken: string };
    setStoredTokens({ accessToken: data.accessToken, refreshToken: data.refreshToken });
    return data.accessToken;
  } catch {
    clearStoredTokens();
    return null;
  }
};

api.interceptors.response.use(
  (response) => response,
  async (error: AxiosError) => {
    const original = error.config as (AxiosRequestConfig & { _retry?: boolean }) | undefined;
    const status = error.response?.status;
    const isAuthCall = original?.url?.includes('/auth/login') || original?.url?.includes('/auth/refresh');
    if (status === 401 && original && !original._retry && !isAuthCall) {
      original._retry = true;
      refreshPromise = refreshPromise ?? refreshAccessToken();
      const token = await refreshPromise;
      refreshPromise = null;
      if (token) {
        original.headers = { ...(original.headers ?? {}), Authorization: `Bearer ${token}` };
        return api.request(original);
      }
      if (typeof window !== 'undefined' && !window.location.pathname.startsWith('/login')) {
        window.location.href = `/login?redirect=${encodeURIComponent(window.location.pathname)}`;
      }
    }
    return Promise.reject(error);
  },
);

export interface ApiErrorBody {
  status?: number;
  error?: string;
  message?: string;
  fieldErrors?: Record<string, string>;
}

export const getErrorMessage = (error: unknown): string => {
  if (axios.isAxiosError(error)) {
    const body = error.response?.data as ApiErrorBody | undefined;
    if (body?.fieldErrors && Object.keys(body.fieldErrors).length > 0) {
      return Object.values(body.fieldErrors)[0];
    }
    if (body?.message) return body.message;
    if (error.code === 'ERR_NETWORK') {
      return 'Cannot reach the API server. Check that the backend is running.';
    }
    return error.message;
  }
  if (error instanceof Error) return error.message;
  return 'Something went wrong. Please try again.';
};

export const fieldErrors = (error: unknown): Record<string, string> => {
  if (axios.isAxiosError(error)) {
    const body = error.response?.data as ApiErrorBody | undefined;
    return body?.fieldErrors ?? {};
  }
  return {};
};

/** Downloads a binary/attachment response (PDF / Excel / CSV). */
export const downloadFile = async (url: string, params: Record<string, unknown>, fallbackName: string) => {
  const response = await api.get(url, { params, responseType: 'blob' });
  const disposition = response.headers['content-disposition'] as string | undefined;
  const match = disposition?.match(/filename="?([^"]+)"?/);
  const fileName = match?.[1] ?? fallbackName;
  const blobUrl = window.URL.createObjectURL(new Blob([response.data]));
  const link = document.createElement('a');
  link.href = blobUrl;
  link.download = fileName;
  document.body.appendChild(link);
  link.click();
  link.remove();
  window.URL.revokeObjectURL(blobUrl);
};

/** Opens a printable PDF in a new tab. */
export const openPdf = async (url: string) => {
  const response = await api.get(url, { responseType: 'blob' });
  const blobUrl = window.URL.createObjectURL(new Blob([response.data], { type: 'application/pdf' }));
  window.open(blobUrl, '_blank');
};
