package com.harugiwun.api;

import com.harugiwun.dto.FortuneDtos;
import com.harugiwun.dto.TarotDtos; // New import
import com.harugiwun.service.FortuneService;
import com.harugiwun.service.fortune.TarotCardService; // New import
import org.springframework.http.ResponseEntity; // New import for ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/fortune/today")
public class FortuneController {

    private final FortuneService fortuneService;
    private final TarotCardService tarotCardService; // New field

    public FortuneController(FortuneService fortuneService, TarotCardService tarotCardService) { // Modified constructor
        this.fortuneService = fortuneService;
        this.tarotCardService = tarotCardService;
    }

    @GetMapping("/widget")
    public FortuneDtos.FortuneWidgetResponse todayWidget(@AuthenticationPrincipal Long userId) {
        return fortuneService.getTodayWidget(userId);
    }

    @GetMapping
    public FortuneDtos.FortuneDetailResponse today(@AuthenticationPrincipal Long userId) {
        return fortuneService.getTodayDetail(userId);
    }

    @GetMapping("/friend/{friendUserId}")
    public FortuneDtos.FortuneDetailResponse friendToday(
        @AuthenticationPrincipal Long userId,
        @PathVariable Long friendUserId
    ) {
        return fortuneService.getFriendTodayFortune(userId, friendUserId);
    }

    @GetMapping("/tarot")
    public ResponseEntity<TarotDtos.DailyTarotCardResponse> getDailyTarotCard(@AuthenticationPrincipal Long userId) {
        return ResponseEntity.ok(tarotCardService.getDailyTarotCard(userId));
    }

    @PostMapping("/tarot/pick")
    public ResponseEntity<TarotDtos.DailyTarotCardResponse> pickDailyTarotCard(@AuthenticationPrincipal Long userId) {
        return ResponseEntity.ok(tarotCardService.pickDailyTarotCard(userId));
    }
}
