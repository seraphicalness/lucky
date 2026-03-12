package com.harugiwun.api;

import com.harugiwun.dto.FortuneDtos;
import com.harugiwun.service.FortuneService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/fortune/today")
public class FortuneController {

    private final FortuneService fortuneService;

    public FortuneController(FortuneService fortuneService) {
        this.fortuneService = fortuneService;
    }

    @GetMapping("/widget")
    public FortuneDtos.FortuneWidgetResponse todayWidget(@AuthenticationPrincipal Long userId) {
        return fortuneService.getTodayWidget(userId);
    }

    @GetMapping
    public FortuneDtos.FortuneDetailResponse today(@AuthenticationPrincipal Long userId) {
        return fortuneService.getTodayDetail(userId);
    }
}
