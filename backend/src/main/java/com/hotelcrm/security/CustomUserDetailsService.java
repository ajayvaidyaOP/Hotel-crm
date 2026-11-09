package com.hotelcrm.security;

import com.hotelcrm.domain.entity.User;
import com.hotelcrm.repository.HotelStaffRepository;
import com.hotelcrm.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;
    private final HotelStaffRepository hotelStaffRepository;

    @Override
    @Transactional(readOnly = true)
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        User user = userRepository.findByEmailIgnoreCase(username)
                .orElseThrow(() -> new UsernameNotFoundException("No account found for " + username));
        List<Long> hotelIds = hotelStaffRepository.findActiveHotelIdsForUser(user.getId());
        return new AppUserPrincipal(user, hotelIds);
    }
}
