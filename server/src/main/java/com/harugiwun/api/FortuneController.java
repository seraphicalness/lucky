package com.harugiwun.api;

import com.harugiwun.config.JwtUtil;
import com.harugiwun.dto.FortuneDtos;
import com.harugiwun.service.FortuneService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/fortune/today")
public class FortuneController {

    private final FortuneService fortuneService;
    private final JwtUtil jwtUtil;

    public FortuneController(FortuneService fortuneService, JwtUtil jwtUtil) {
        this.fortuneService = fortuneService;
        this.jwtUtil = jwtUtil;
    }

    @GetMapping("/widget")
    public FortuneDtos.FortuneWidgetResponse todayWidget(@RequestHeader("Authorization") String authHeader) {
        Long userId = jwtUtil.resolveUserId(authHeader);
        return fortuneService.getTodayWidget(userId);
    }

    @GetMapping
    public FortuneDtos.FortuneDetailResponse today(@RequestHeader("Authorization") String authHeader) {
        Long userId = jwtUtil.resolveUserId(authHeader);
        return fortuneService.getTodayDetail(userId);
    }
}
