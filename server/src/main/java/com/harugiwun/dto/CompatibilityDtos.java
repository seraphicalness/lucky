package com.harugiwun.dto;

public class CompatibilityDtos {

    public record AdWatchRequest(String feature) {}

    public record AdWatchResponse(boolean unlocked, String feature, long unlockedUntilEpochSecond) {}

    public record ScoreCompareResponse(
        int myTotalScore,
        int myMoneyScore,
        int myLoveScore,
        int myHealthScore,
        int myWorkScore,
        int mySocialScore,
        int friendTotalScore,
        int friendMoneyScore,
        int friendLoveScore,
        int friendHealthScore,
        int friendWorkScore,
        int friendSocialScore
    ) {}

    public record ElementCompatibilityResponse(
        int compatibilityScore,
        String summary,
        String myDominantElement,
        String friendDominantElement,
        String relationshipDescription
    ) {}
}
