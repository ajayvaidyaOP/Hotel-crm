import { createContext, useCallback, useContext, useEffect, useMemo, useState, type ReactNode } from 'react';
import { useAuth } from './AuthContext';
import type { HotelSummary } from '@/lib/types';

const STORAGE_KEY = 'hotelcrm.hotel';

interface HotelContextValue {
  hotels: HotelSummary[];
  /** null means "all accessible hotels" (group view) */
  hotelId: number | null;
  hotel: HotelSummary | null;
  setHotelId: (id: number | null) => void;
  isGroupView: boolean;
}

const HotelContext = createContext<HotelContextValue | undefined>(undefined);

export const HotelProvider = ({ children }: { children: ReactNode }) => {
  const { user } = useAuth();
  const hotels = user?.hotels ?? [];
  const [hotelId, setHotelIdState] = useState<number | null>(() => {
    const stored = localStorage.getItem(STORAGE_KEY);
    return stored && stored !== 'all' ? Number(stored) : null;
  });

  useEffect(() => {
    if (hotels.length === 0) return;
    const exists = hotelId !== null && hotels.some((hotel) => hotel.id === hotelId);
    if (!exists && hotelId !== null) {
      setHotelIdState(hotels[0].id);
      localStorage.setItem(STORAGE_KEY, String(hotels[0].id));
    }
  }, [hotels, hotelId]);

  const setHotelId = useCallback((id: number | null) => {
    setHotelIdState(id);
    localStorage.setItem(STORAGE_KEY, id === null ? 'all' : String(id));
  }, []);

  const value = useMemo<HotelContextValue>(() => {
    const resolvedId = hotelId ?? hotels[0]?.id ?? null;
    return {
      hotels,
      hotelId: resolvedId,
      hotel: hotels.find((item) => item.id === resolvedId) ?? null,
      setHotelId,
      isGroupView: hotelId === null,
    };
  }, [hotels, hotelId, setHotelId]);

  return <HotelContext.Provider value={value}>{children}</HotelContext.Provider>;
};

export const useHotelScope = () => {
  const context = useContext(HotelContext);
  if (!context) throw new Error('useHotelScope must be used inside HotelProvider');
  return context;
};
