package com.harugiwun.dto;

import java.time.LocalDate;
import java.time.LocalTime;

public class AuthDtos {

    public record SocialLoginRequest(
        String providerUserId,
        String nickname,
        LocalDate birthDate,
        LocalTime birthTime
    ) {}

    public record SocialLoginResponse(
        Long userId,
        String token
    ) {}
}
