package com.harugiwun.dto;

import java.time.LocalDate;
import java.time.LocalTime;

public class ProfileDtos {

    public record ProfileResponse(
        Long userId,
        String nickname,
        LocalDate birthDate,
        LocalTime birthTime
    ) {}

    public record ProfileUpdateRequest(
        String nickname,
        LocalDate birthDate,
        LocalTime birthTime
    ) {}
}
