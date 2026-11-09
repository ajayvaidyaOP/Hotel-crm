package com.hotelcrm.repository;

import com.hotelcrm.domain.entity.Expense;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public interface ExpenseRepository extends JpaRepository<Expense, Long>, JpaSpecificationExecutor<Expense> {

    @Query("select coalesce(sum(e.amount), 0) from Expense e where e.hotel.id in :hotelIds " +
            " and e.expenseDate between :from and :to")
    BigDecimal sumExpenses(@Param("hotelIds") List<Long> hotelIds,
                           @Param("from") LocalDate from, @Param("to") LocalDate to);

    @Query("select e.category, coalesce(sum(e.amount), 0) from Expense e where e.hotel.id in :hotelIds " +
            " and e.expenseDate between :from and :to group by e.category order by sum(e.amount) desc")
    List<Object[]> sumByCategory(@Param("hotelIds") List<Long> hotelIds,
                                 @Param("from") LocalDate from, @Param("to") LocalDate to);

    @Query("select e.hotel.id, coalesce(sum(e.amount), 0) from Expense e where e.hotel.id in :hotelIds " +
            " and e.expenseDate between :from and :to group by e.hotel.id")
    List<Object[]> sumByHotel(@Param("hotelIds") List<Long> hotelIds,
                              @Param("from") LocalDate from, @Param("to") LocalDate to);

    @Query("select count(e) from Expense e where e.hotel.id in :hotelIds")
    long countByHotels(@Param("hotelIds") List<Long> hotelIds);
}
