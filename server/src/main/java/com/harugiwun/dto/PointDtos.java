package com.harugiwun.dto;

import java.time.LocalDateTime;

public class PointDtos {

    public record AdRewardRequest(String adUnitId) {}

    public record PointBalanceResponse(Long currentPoints, Integer dailyAdCount, String message) {}

    public record PurchaseRequest(
        String productId,
        Long amount,
        String receiptData
    ) {}
}
