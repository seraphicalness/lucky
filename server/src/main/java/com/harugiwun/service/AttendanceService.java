package com.harugiwun.service;

import com.harugiwun.domain.user.AppUser;
import com.harugiwun.repository.AppUserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;

@Service
public class AttendanceService {

    private final AppUserRepository userRepository;
    private static final long DAILY_CHECK_IN_POINTS = 100L;

    public AttendanceService(AppUserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Transactional
    public CheckInResult checkIn(Long userId) {
        AppUser user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found: " + userId));

        LocalDate today = LocalDate.now();
        
        if (user.getLastCheckInDate() != null && user.getLastCheckInDate().isEqual(today)) {
            return new CheckInResult(false, user.getPoints(), "Already checked in today.");
        }

        user.setLastCheckInDate(today);
        user.setPoints((user.getPoints() != null ? user.getPoints() : 0L) + DAILY_CHECK_IN_POINTS);
        userRepository.save(user);

        return new CheckInResult(true, user.getPoints(), "Daily check-in successful! +100 points.");
    }

    public record CheckInResult(boolean success, Long currentPoints, String message) {}
}
