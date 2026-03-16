package com.harugiwun.api;

import com.harugiwun.dto.PointDtos;
import com.harugiwun.service.PointService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/points")
public class PointController {

    private final PointService pointService;

    public PointController(PointService pointService) {
        this.pointService = pointService;
    }

    @GetMapping("/balance")
    public PointDtos.PointBalanceResponse getBalance(@AuthenticationPrincipal Long userId) {
        return pointService.getBalance(userId);
    }

    @PostMapping("/ad-reward")
    public PointDtos.PointBalanceResponse claimAdReward(
        @AuthenticationPrincipal Long userId,
        @RequestBody PointDtos.AdRewardRequest request
    ) {
        return pointService.addAdReward(userId);
    }

    @PostMapping("/purchase")
    public PointDtos.PointBalanceResponse purchasePoints(
        @AuthenticationPrincipal Long userId,
        @RequestBody PointDtos.PurchaseRequest request
    ) {
        return pointService.purchasePoints(userId, request);
    }
}
