export const currency = (value?: number | string | null, compact = false) => {
  const amount = typeof value === 'string' ? Number(value) : value ?? 0;
  if (Number.isNaN(amount)) return '₹0';
  if (compact) {
    if (Math.abs(amount) >= 10000000) return `₹${(amount / 10000000).toFixed(2)}Cr`;
    if (Math.abs(amount) >= 100000) return `₹${(amount / 100000).toFixed(2)}L`;
    if (Math.abs(amount) >= 1000) return `₹${(amount / 1000).toFixed(1)}K`;
  }
  return new Intl.NumberFormat('en-IN', {
    style: 'currency',
    currency: 'INR',
    maximumFractionDigits: 0,
  }).format(amount);
};

export const number = (value?: number | string | null) =>
  new Intl.NumberFormat('en-IN').format(Number(value ?? 0));

export const percent = (value?: number | string | null) => `${Number(value ?? 0).toFixed(1)}%`;

export const formatDate = (value?: string | null) => {
  if (!value) return '—';
  const date = new Date(value.length <= 10 ? `${value}T00:00:00` : value);
  if (Number.isNaN(date.getTime())) return '—';
  return date.toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric' });
};

export const formatDateShort = (value?: string | null) => {
  if (!value) return '—';
  const date = new Date(value.length <= 10 ? `${value}T00:00:00` : value);
  if (Number.isNaN(date.getTime())) return '—';
  return date.toLocaleDateString('en-IN', { day: '2-digit', month: 'short' });
};

export const formatDateTime = (value?: string | null) => {
  if (!value) return '—';
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return '—';
  return date.toLocaleString('en-IN', {
    day: '2-digit',
    month: 'short',
    hour: '2-digit',
    minute: '2-digit',
  });
};

export const formatTime = (value?: string | null) => {
  if (!value) return '—';
  const [hours, minutes] = value.split(':');
  const date = new Date();
  date.setHours(Number(hours), Number(minutes ?? 0), 0, 0);
  return date.toLocaleTimeString('en-IN', { hour: '2-digit', minute: '2-digit' });
};

export const relativeTime = (value?: string | null) => {
  if (!value) return '—';
  const date = new Date(value);
  const diff = Date.now() - date.getTime();
  const minutes = Math.round(diff / 60000);
  if (minutes < 1) return 'just now';
  if (minutes < 60) return `${minutes}m ago`;
  const hours = Math.round(minutes / 60);
  if (hours < 24) return `${hours}h ago`;
  const days = Math.round(hours / 24);
  if (days < 30) return `${days}d ago`;
  return formatDate(value);
};

export const labelize = (value?: string | null) => {
  if (!value) return '—';
  return value
    .toLowerCase()
    .split('_')
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(' ');
};

export const nightsBetween = (from?: string, to?: string) => {
  if (!from || !to) return 0;
  const start = new Date(`${from}T00:00:00`);
  const end = new Date(`${to}T00:00:00`);
  return Math.max(0, Math.round((end.getTime() - start.getTime()) / 86400000));
};
