package com.hotelcrm.repository;

import com.hotelcrm.domain.entity.Invoice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface InvoiceRepository extends JpaRepository<Invoice, Long>, JpaSpecificationExecutor<Invoice> {

    Optional<Invoice> findByInvoiceNumber(String invoiceNumber);

    @Query("select i from Invoice i left join fetch i.lines where i.id = :id")
    Optional<Invoice> findWithLines(@Param("id") Long id);

    List<Invoice> findByBookingId(Long bookingId);

    @Query("select coalesce(sum(i.total), 0) from Invoice i where i.hotel.id in :hotelIds " +
            " and i.status <> com.hotelcrm.domain.enums.InvoiceStatus.CANCELLED and i.issueDate between :from and :to")
    BigDecimal sumInvoiced(@Param("hotelIds") List<Long> hotelIds,
                           @Param("from") LocalDate from, @Param("to") LocalDate to);

    @Query("select coalesce(sum(i.balance), 0) from Invoice i where i.hotel.id in :hotelIds " +
            " and i.status in (com.hotelcrm.domain.enums.InvoiceStatus.ISSUED, com.hotelcrm.domain.enums.InvoiceStatus.PARTIALLY_PAID)")
    BigDecimal sumOutstanding(@Param("hotelIds") List<Long> hotelIds);

    long countByHotelId(Long hotelId);
}
