package com.harugiwun.dto;

import com.harugiwun.domain.profile.BirthCalendarType;
import com.harugiwun.domain.profile.Gender;
import java.time.LocalDate;
import java.time.LocalTime;

public class ProfileDtos {

    public record ProfileResponse(
        Long userId,
        String nickname,
        LocalDate birthDate,
        LocalTime birthTime,
        BirthCalendarType birthCalendarType,
        Boolean birthIsLeapMonth,
        Gender gender
    ) {}

    public record ProfileUpdateRequest(
        String nickname,
        LocalDate birthDate,
        LocalTime birthTime,
        BirthCalendarType birthCalendarType,
        Boolean birthIsLeapMonth,
        Gender gender
    ) {}
}
