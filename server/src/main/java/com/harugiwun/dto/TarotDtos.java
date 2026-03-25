package com.harugiwun.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

public class TarotDtos {

    public record TarotApiResponse(
        String name,
        @JsonProperty("name_short") String nameShort,
        String value,
        @JsonProperty("value_int") int valueInt,
        String type,
        @JsonProperty("meaning_up") String meaningUp,
        @JsonProperty("meaning_rev") String meaningRev,
        String desc
    ) {}

    public record DailyTarotCardResponse(
        String name,
        String meaning, // meaning_up을 사용
        String description,
        String imageUrl // 이미지 URL은 프론트엔드에서 카드 이름 기반으로 매핑하거나, 기본 이미지 사용
    ) {
        public static DailyTarotCardResponse from(TarotApiResponse apiResponse) {
            // tarotapi.dev는 이미지 URL을 직접 제공하지 않으므로, 프론트엔드에서 카드 이름 기반으로 매핑해야 합니다.
            // 여기서는 임시로 플레이스홀더 URL을 사용하거나, 프론트엔드에서 처리하도록 비워둡니다.
            String imageUrl = "/images/tarot/" + apiResponse.nameShort() + ".png"; // 예시 URL
            return new DailyTarotCardResponse(
                apiResponse.name(),
                apiResponse.meaningUp(), // 오늘의 카드이므로 정방향 의미 사용
                apiResponse.desc(),
                imageUrl
            );
        }

        public static DailyTarotCardResponse fallback() {
            return new DailyTarotCardResponse(
                "The Fool (Fallback)",
                "새로운 시작, 순수함, 자유로운 영혼 (Fallback)",
                "API 호출에 실패하여 기본 카드를 제공합니다. The Fool 카드는 새로운 여정의 시작을 의미합니다.",
                "/images/tarot/major-00.png" // 기본 이미지
            );
        }
    }
}
