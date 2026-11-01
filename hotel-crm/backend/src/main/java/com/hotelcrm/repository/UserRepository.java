package com.hotelcrm.repository;

import com.hotelcrm.domain.entity.User;
import com.hotelcrm.domain.enums.Role;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long>, JpaSpecificationExecutor<User> {

    Optional<User> findByEmailIgnoreCase(String email);

    boolean existsByEmailIgnoreCase(String email);

    List<User> findByPrimaryRole(Role primaryRole);

    List<User> findByEnabledTrueOrderByFullNameAsc();

    long countByEnabledTrue();
}
