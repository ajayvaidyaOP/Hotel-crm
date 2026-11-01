package com.hotelcrm.service;

import com.hotelcrm.domain.entity.Booking;
import com.hotelcrm.domain.entity.Guest;
import com.hotelcrm.domain.entity.Hotel;
import com.hotelcrm.domain.entity.Room;
import com.hotelcrm.domain.entity.User;
import com.hotelcrm.dto.NotificationDtos;
import com.hotelcrm.repository.BookingRepository;
import com.hotelcrm.repository.GuestRepository;
import com.hotelcrm.repository.HotelRepository;
import com.hotelcrm.repository.HotelStaffRepository;
import com.hotelcrm.repository.RoomRepository;
import com.hotelcrm.repository.UserRepository;
import com.hotelcrm.security.HotelAccessService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/** Cross-module search used by the top navigation bar. */
@Service
@RequiredArgsConstructor
public class SearchService {

    private final HotelRepository hotelRepository;
    private final RoomRepository roomRepository;
    private final GuestRepository guestRepository;
    private final BookingRepository bookingRepository;
    private final UserRepository userRepository;
    private final HotelStaffRepository hotelStaffRepository;
    private final HotelAccessService accessService;

    @Transactional(readOnly = true)
    public List<NotificationDtos.GlobalSearchResult> search(String term) {
        List<NotificationDtos.GlobalSearchResult> results = new ArrayList<>();
        if (term == null || term.trim().length() < 2) {
            return results;
        }
        String query = term.trim().toLowerCase(Locale.ROOT);
        List<Long> scope = accessService.accessibleHotelIds();

        for (Hotel hotel : hotelRepository.findAllById(scope)) {
            if (hotel.getName().toLowerCase(Locale.ROOT).contains(query)
                    || hotel.getCode().toLowerCase(Locale.ROOT).contains(query)
                    || (hotel.getCity() != null && hotel.getCity().toLowerCase(Locale.ROOT).contains(query))) {
                results.add(new NotificationDtos.GlobalSearchResult("Hotel", hotel.getId(), hotel.getName(),
                        hotel.getCity() + ", " + hotel.getState(), hotel.getName(), "/hotels/" + hotel.getId()));
            }
        }
        for (Booking booking : bookingRepository.findAll((root, q, cb) ->
                        cb.and(root.get("hotel").get("id").in(scope),
                                cb.or(cb.like(cb.lower(root.get("bookingCode")), "%" + query + "%"),
                                        cb.like(cb.lower(root.get("guest").get("fullName")), "%" + query + "%"),
                                        cb.like(cb.lower(cb.coalesce(root.get("guest").get("mobile"), "")), "%" + query + "%"))),
                org.springframework.data.domain.PageRequest.of(0, 6)).getContent()) {
            results.add(new NotificationDtos.GlobalSearchResult("Booking", booking.getId(),
                    booking.getBookingCode(), booking.getGuest().getFullName() + " - "
                    + booking.getCheckInDate() + " to " + booking.getCheckOutDate(),
                    booking.getHotel().getName(), "/bookings/" + booking.getId()));
        }
        for (Guest guest : guestRepository.search(term.trim()).stream().limit(6).toList()) {
            results.add(new NotificationDtos.GlobalSearchResult("Guest", guest.getId(), guest.getFullName(),
                    guest.getMobile(), guest.getCity(), "/guests/" + guest.getId()));
        }
        for (Room room : roomRepository.findActiveByHotels(scope)) {
            if (room.getRoomNumber().toLowerCase(Locale.ROOT).contains(query)) {
                results.add(new NotificationDtos.GlobalSearchResult("Room", room.getId(),
                        "Room " + room.getRoomNumber() + " - " + room.getCategory().getName(),
                        room.getHotel().getCity(), room.getHotel().getName(),
                        "/rooms?hotelId=" + room.getHotel().getId()));
            }
            if (results.size() > 25) {
                break;
            }
        }
        List<Long> userIds = hotelStaffRepository.findActiveByHotelIds(scope).stream()
                .map(assignment -> assignment.getUser().getId()).distinct().toList();
        for (User user : userRepository.findAllById(userIds)) {
            if (user.getFullName().toLowerCase(Locale.ROOT).contains(query)
                    || user.getEmail().toLowerCase(Locale.ROOT).contains(query)) {
                results.add(new NotificationDtos.GlobalSearchResult("Staff", user.getId(), user.getFullName(),
                        user.getEmail(), user.getPrimaryRole().getLabel(), "/staff"));
            }
        }
        return results.stream().limit(25).toList();
    }
}
