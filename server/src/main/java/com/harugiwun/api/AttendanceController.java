package com.harugiwun.api;

import com.harugiwun.service.AttendanceService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/attendance")
public class AttendanceController {

    private final AttendanceService attendanceService;

    public AttendanceController(AttendanceService attendanceService) {
        this.attendanceService = attendanceService;
    }

    @PostMapping("/check-in")
    public AttendanceService.CheckInResult checkIn(@AuthenticationPrincipal Object principal) {
        // Principal is set as Long userId in JwtAuthenticationFilter
        Long userId = (Long) principal;
        return attendanceService.checkIn(userId);
    }
}
