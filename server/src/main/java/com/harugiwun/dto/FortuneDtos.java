package com.harugiwun.dto;

import java.time.LocalDate;

public class FortuneDtos {

    public record FortuneWidgetResponse(
        LocalDate date,
        boolean pending,
        String pendingMessage,
        Integer totalScore,
        String luckyColor,
        Integer luckyNumber,
        String summary
    ) {
        public static FortuneWidgetResponse pending(LocalDate date) {
            return new FortuneWidgetResponse(date, true, "탭하여 오늘 운세를 확인해주세요", null, null, null, null);
        }

        public static FortuneWidgetResponse of(LocalDate date, int totalScore, String luckyColor, int luckyNumber, String summary) {
            return new FortuneWidgetResponse(date, false, null, totalScore, luckyColor, luckyNumber, summary);
        }
    }

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
