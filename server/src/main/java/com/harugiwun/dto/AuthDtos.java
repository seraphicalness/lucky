package com.harugiwun.dto;

import com.harugiwun.domain.profile.BirthCalendarType;
import com.harugiwun.domain.profile.Gender;
import java.time.LocalDate;
import java.time.LocalTime;

public class AuthDtos {

    public record SocialLoginRequest(
        String providerUserId,
        String nickname,
        LocalDate birthDate,
        LocalTime birthTime,
        BirthCalendarType birthCalendarType,
        Boolean birthIsLeapMonth,
        Gender gender
    ) {}

    public record SocialLoginResponse(
        Long userId,
        String token
    ) {}
}
