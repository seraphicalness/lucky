package com.harugiwun.dto;

import java.time.LocalDate;

public class FortuneDtos {

    public record FortuneWidgetResponse(
        LocalDate date,
        int totalScore,
        String luckyColor,
        int luckyNumber,
        String summary
    ) {}

    public record FortuneDetailResponse(
        LocalDate date,
        int totalScore,
        int moneyScore,
        int loveScore,
        int healthScore,
        int workScore,
        int socialScore,
        String luckyColor,
        int luckyNumber,
        String summary,
        String detailText
    ) {}
}
