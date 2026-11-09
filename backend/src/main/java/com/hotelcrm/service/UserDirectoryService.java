package com.hotelcrm.service;

import com.hotelcrm.domain.entity.User;
import com.hotelcrm.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.function.Function;
import java.util.stream.Collectors;

/** Small read model used to resolve actor names without N+1 relationship mapping. */
@Service
@RequiredArgsConstructor
public class UserDirectoryService {

    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public String nameOf(Long userId) {
        if (userId == null) {
            return null;
        }
        return userRepository.findById(userId).map(User::getFullName).orElse("System");
    }

    @Transactional(readOnly = true)
    public Map<Long, String> names(Collection<Long> userIds) {
        Set<Long> ids = userIds.stream().filter(Objects::nonNull).collect(Collectors.toSet());
        if (ids.isEmpty()) {
            return Map.of();
        }
        List<User> users = userRepository.findAllById(ids);
        Map<Long, String> result = new HashMap<>();
        users.forEach(u -> result.put(u.getId(), u.getFullName()));
        return result;
    }

    @Transactional(readOnly = true)
    public Map<Long, User> usersById(Collection<Long> ids) {
        if (ids == null || ids.isEmpty()) {
            return Map.of();
        }
        return userRepository.findAllById(ids).stream()
                .collect(Collectors.toMap(User::getId, Function.identity()));
    }

    @Transactional(readOnly = true)
    public User require(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> com.hotelcrm.common.exception.NotFoundException.of("User", userId));
    }
}
