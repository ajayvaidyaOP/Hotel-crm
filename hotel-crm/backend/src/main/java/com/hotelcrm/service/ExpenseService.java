package com.hotelcrm.service;

import com.hotelcrm.common.PageResponse;
import com.hotelcrm.common.exception.NotFoundException;
import com.hotelcrm.domain.entity.Expense;
import com.hotelcrm.domain.entity.Hotel;
import com.hotelcrm.domain.enums.ExpenseCategory;
import com.hotelcrm.domain.enums.Permission;
import com.hotelcrm.dto.DashboardDtos;
import com.hotelcrm.dto.OpsDtos;
import com.hotelcrm.repository.ExpenseRepository;
import com.hotelcrm.repository.HotelRepository;
import com.hotelcrm.security.HotelAccessService;
import com.hotelcrm.util.MoneyUtils;
import jakarta.persistence.criteria.Predicate;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ExpenseService {

    private final ExpenseRepository expenseRepository;
    private final HotelRepository hotelRepository;
    private final HotelAccessService accessService;
    private final AuditService auditService;
    private final UserDirectoryService userDirectoryService;

    @Transactional(readOnly = true)
    public PageResponse<OpsDtos.ExpenseResponse> list(Long hotelId, LocalDate from, LocalDate to,
                                                      ExpenseCategory category, String search, int page, int size) {
        accessService.assertPermission(Permission.EXPENSE_READ);
        List<Long> scope = accessService.resolveHotelScope(hotelId);
        LocalDate start = from == null ? LocalDate.now().withDayOfMonth(1) : from;
        LocalDate end = to == null ? LocalDate.now() : to;
        Specification<Expense> spec = (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            predicates.add(root.get("hotel").get("id").in(scope));
            predicates.add(cb.between(root.get("expenseDate"), start, end));
            if (category != null) {
                predicates.add(cb.equal(root.get("category"), category));
            }
            if (search != null && !search.isBlank()) {
                String like = "%" + search.trim().toLowerCase() + "%";
                predicates.add(cb.or(
                        cb.like(cb.lower(root.get("description")), like),
                        cb.like(cb.lower(cb.coalesce(root.get("vendor"), "")), like),
                        cb.like(cb.lower(cb.coalesce(root.get("referenceNo"), "")), like)));
            }
            return cb.and(predicates.toArray(new Predicate[0]));
        };
        Page<Expense> result = expenseRepository.findAll(spec, PageRequest.of(Math.max(page, 0),
                Math.min(Math.max(size, 1), 100), Sort.by(Sort.Direction.DESC, "expenseDate", "id")));
        java.util.Map<Long, String> names = userDirectoryService.names(
                result.getContent().stream().map(Expense::getCreatedBy).toList());
        return PageResponse.of(result, expense -> OpsDtos.ExpenseResponse.from(expense, names.get(expense.getCreatedBy())));
    }

    @Transactional
    public OpsDtos.ExpenseResponse create(OpsDtos.ExpenseRequest request) {
        accessService.assertPermission(Permission.EXPENSE_WRITE);
        accessService.assertHotelAccess(request.hotelId());
        Hotel hotel = hotelRepository.findById(request.hotelId())
                .orElseThrow(() -> NotFoundException.of("Hotel", request.hotelId()));
        Expense expense = Expense.builder()
                .hotel(hotel)
                .category(request.category())
                .description(request.description().trim())
                .amount(MoneyUtils.scale(request.amount()))
                .expenseDate(request.expenseDate())
                .vendor(request.vendor())
                .paymentMethod(request.paymentMethod())
                .referenceNo(request.referenceNo())
                .createdBy(accessService.currentUserId())
                .build();
        expenseRepository.save(expense);
        auditService.record(hotel.getId(), "EXPENSE_CREATED", "Expense", expense.getId(),
                "Expense " + expense.getAmount() + " (" + expense.getCategory() + ") recorded");
        return OpsDtos.ExpenseResponse.from(expense, userDirectoryService.nameOf(expense.getCreatedBy()));
    }

    @Transactional
    public OpsDtos.ExpenseResponse update(Long id, OpsDtos.ExpenseRequest request) {
        accessService.assertPermission(Permission.EXPENSE_WRITE);
        Expense expense = expenseRepository.findById(id).orElseThrow(() -> NotFoundException.of("Expense", id));
        accessService.assertHotelAccess(expense.getHotel().getId());
        if (!expense.getHotel().getId().equals(request.hotelId())) {
            throw new com.hotelcrm.common.exception.BusinessException("Expenses cannot be moved between hotels");
        }
        expense.setCategory(request.category());
        expense.setDescription(request.description().trim());
        expense.setAmount(MoneyUtils.scale(request.amount()));
        expense.setExpenseDate(request.expenseDate());
        expense.setVendor(request.vendor());
        expense.setPaymentMethod(request.paymentMethod());
        expense.setReferenceNo(request.referenceNo());
        expenseRepository.save(expense);
        auditService.record(expense.getHotel().getId(), "EXPENSE_UPDATED", "Expense", expense.getId(),
                "Expense updated");
        return OpsDtos.ExpenseResponse.from(expense, userDirectoryService.nameOf(expense.getCreatedBy()));
    }

    @Transactional
    public void delete(Long id) {
        accessService.assertPermission(Permission.EXPENSE_WRITE);
        Expense expense = expenseRepository.findById(id).orElseThrow(() -> NotFoundException.of("Expense", id));
        accessService.assertHotelAccess(expense.getHotel().getId());
        expenseRepository.delete(expense);
        auditService.record(expense.getHotel().getId(), "EXPENSE_DELETED", "Expense", id, "Expense deleted");
    }

    @Transactional(readOnly = true)
    public List<DashboardDtos.NamedValue> summaryByCategory(Long hotelId, LocalDate from, LocalDate to) {
        accessService.assertPermission(Permission.EXPENSE_READ);
        List<Long> scope = accessService.resolveHotelScope(hotelId);
        LocalDate start = from == null ? LocalDate.now().withMonth(1).withDayOfMonth(1) : from;
        LocalDate end = to == null ? LocalDate.now() : to;
        return expenseRepository.sumByCategory(scope, start, end).stream()
                .map(row -> new DashboardDtos.NamedValue(((ExpenseCategory) row[0]).getLabel(),
                        MoneyUtils.scale((BigDecimal) row[1]), 0))
                .toList();
    }

    @Transactional(readOnly = true)
    public BigDecimal total(Long hotelId, LocalDate from, LocalDate to) {
        List<Long> scope = accessService.resolveHotelScope(hotelId);
        return MoneyUtils.nullToZero(expenseRepository.sumExpenses(scope, from, to));
    }
}
