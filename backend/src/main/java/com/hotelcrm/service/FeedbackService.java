package com.hotelcrm.service;

import com.hotelcrm.common.exception.NotFoundException;
import com.hotelcrm.domain.entity.Booking;
import com.hotelcrm.domain.entity.GuestFeedback;
import com.hotelcrm.domain.enums.FeedbackStatus;
import com.hotelcrm.domain.enums.FeedbackType;
import com.hotelcrm.domain.enums.Permission;
import com.hotelcrm.dto.GuestDtos;
import com.hotelcrm.dto.OpsDtos;
import com.hotelcrm.repository.BookingRepository;
import com.hotelcrm.repository.GuestFeedbackRepository;
import com.hotelcrm.repository.GuestRepository;
import com.hotelcrm.repository.HotelRepository;
import com.hotelcrm.security.HotelAccessService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;

@Service
@RequiredArgsConstructor
public class FeedbackService {

    private final GuestFeedbackRepository feedbackRepository;
    private final HotelRepository hotelRepository;
    private final GuestRepository guestRepository;
    private final BookingRepository bookingRepository;
    private final HotelAccessService accessService;
    private final AuditService auditService;

    @Transactional(readOnly = true)
    public List<OpsDtos.FeedbackRow> list(Long hotelId, FeedbackType type, FeedbackStatus status) {
        accessService.assertPermission(Permission.GUEST_READ);
        List<Long> scope = accessService.resolveHotelScope(hotelId);
        return feedbackRepository.findByHotelIdInOrderByCreatedAtDesc(scope).stream()
                .filter(feedback -> type == null || feedback.getType() == type)
                .filter(feedback -> status == null || feedback.getStatus() == status)
                .map(OpsDtos.FeedbackRow::from)
                .toList();
    }

    @Transactional
    public OpsDtos.FeedbackRow create(GuestDtos.FeedbackRequest request) {
        accessService.assertPermission(Permission.GUEST_WRITE);
        accessService.assertHotelAccess(request.hotelId());
        Booking booking = request.bookingId() == null ? null
                : bookingRepository.findById(request.bookingId())
                .orElseThrow(() -> NotFoundException.of("Booking", request.bookingId()));
        if (booking != null && !booking.getHotel().getId().equals(request.hotelId())) {
            throw new com.hotelcrm.common.exception.BusinessException("The booking belongs to another hotel");
        }
        Long guestId = request.guestId() != null ? request.guestId()
                : booking == null ? null : booking.getGuest().getId();
        GuestFeedback feedback = GuestFeedback.builder()
                .hotel(hotelRepository.findById(request.hotelId())
                        .orElseThrow(() -> NotFoundException.of("Hotel", request.hotelId())))
                .guest(guestId == null ? null : guestRepository.findById(guestId).orElse(null))
                .booking(booking)
                .type(request.type() == null ? FeedbackType.FEEDBACK : request.type())
                .rating(request.rating())
                .comments(request.comments())
                .status(FeedbackStatus.OPEN)
                .build();
        feedbackRepository.save(feedback);
        auditService.record(request.hotelId(), "FEEDBACK_LOGGED", "GuestFeedback", feedback.getId(),
                feedback.getType() + " logged with rating " + feedback.getRating());
        return OpsDtos.FeedbackRow.from(feedback);
    }

    @Transactional
    public OpsDtos.FeedbackRow resolve(Long id, GuestDtos.FeedbackResolveRequest request) {
        accessService.assertPermission(Permission.GUEST_WRITE);
        GuestFeedback feedback = feedbackRepository.findById(id)
                .orElseThrow(() -> NotFoundException.of("Feedback", id));
        accessService.assertHotelAccess(feedback.getHotel().getId());
        feedback.setResolution(request.resolution());
        feedback.setStatus(FeedbackStatus.RESOLVED);
        feedback.setResolvedBy(accessService.currentUserId());
        feedback.setResolvedAt(Instant.now());
        feedbackRepository.save(feedback);
        return OpsDtos.FeedbackRow.from(feedback);
    }

    @Transactional(readOnly = true)
    public List<GuestDtos.FeedbackResponse> forGuest(Long guestId) {
        return feedbackRepository.findByGuestIdOrderByCreatedAtDesc(guestId).stream()
                .map(feedback -> new GuestDtos.FeedbackResponse(feedback.getId(), feedback.getHotel().getId(),
                        feedback.getHotel().getName(),
                        feedback.getGuest() == null ? null : feedback.getGuest().getId(),
                        feedback.getGuest() == null ? null : feedback.getGuest().getFullName(),
                        feedback.getBooking() == null ? null : feedback.getBooking().getId(),
                        feedback.getBooking() == null ? null : feedback.getBooking().getBookingCode(),
                        feedback.getType(), feedback.getRating(), feedback.getComments(), feedback.getStatus(),
                        feedback.getResolution(), feedback.getResolvedAt(), feedback.getCreatedAt()))
                .toList();
    }
}
