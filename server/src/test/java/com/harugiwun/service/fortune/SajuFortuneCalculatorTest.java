package com.harugiwun.service.fortune;

import com.harugiwun.domain.profile.AppUserProfile;
import com.harugiwun.domain.profile.BirthCalendarType;
import com.harugiwun.domain.profile.Gender;
import java.time.LocalDate;
import java.time.LocalTime;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class SajuFortuneCalculatorTest {

    private final SajuFortuneCalculator calculator = new SajuFortuneCalculator();

    @Test
    void deterministicForSameInputs() {
        AppUserProfile p = new AppUserProfile();
        p.setBirthDate(LocalDate.of(1995, 3, 10));
        p.setBirthTime(LocalTime.of(8, 30));
        p.setBirthCalendarType(BirthCalendarType.SOLAR);
        p.setBirthIsLeapMonth(false);
        p.setGender(Gender.MALE);

        LocalDate d = LocalDate.of(2026, 2, 24);
        var r1 = calculator.calculate(1L, p, d);
        var r2 = calculator.calculate(1L, p, d);

        assertEquals(r1, r2);
    }

    @Test
    void changesByDate() {
        AppUserProfile p = new AppUserProfile();
        p.setBirthDate(LocalDate.of(1995, 3, 10));
        p.setBirthTime(LocalTime.of(8, 30));
        p.setBirthCalendarType(BirthCalendarType.SOLAR);
        p.setBirthIsLeapMonth(false);
        p.setGender(Gender.MALE);

        var r1 = calculator.calculate(1L, p, LocalDate.of(2026, 2, 24));
        var r2 = calculator.calculate(1L, p, LocalDate.of(2026, 2, 25));

        assertNotEquals(r1, r2);
    }

    @Test
    void genderAffectsLoveScoreWhenPossible() {
        AppUserProfile base = new AppUserProfile();
        base.setBirthDate(LocalDate.of(1991, 7, 12));
        base.setBirthTime(LocalTime.of(12, 0));
        base.setBirthCalendarType(BirthCalendarType.SOLAR);
        base.setBirthIsLeapMonth(false);

        AppUserProfile male = new AppUserProfile();
        male.setBirthDate(base.getBirthDate());
        male.setBirthTime(base.getBirthTime());
        male.setBirthCalendarType(base.getBirthCalendarType());
        male.setBirthIsLeapMonth(base.getBirthIsLeapMonth());
        male.setGender(Gender.MALE);

        AppUserProfile female = new AppUserProfile();
        female.setBirthDate(base.getBirthDate());
        female.setBirthTime(base.getBirthTime());
        female.setBirthCalendarType(base.getBirthCalendarType());
        female.setBirthIsLeapMonth(base.getBirthIsLeapMonth());
        female.setGender(Gender.FEMALE);

        boolean found = false;
        LocalDate start = LocalDate.of(2026, 1, 1);
        for (int i = 0; i < 90; i++) {
            LocalDate d = start.plusDays(i);
            int maleLove = calculator.calculate(1L, male, d).loveScore();
            int femaleLove = calculator.calculate(1L, female, d).loveScore();
            if (maleLove != femaleLove) {
                found = true;
                break;
            }
        }

        assertTrue(found, "expected at least one day where gender affects loveScore");
    }

    @Test
    void lunarInputDoesNotThrow() {
        AppUserProfile p = new AppUserProfile();
        // 테스트 목적: 음력 입력 경로가 최소한 예외 없이 처리되는지
        p.setBirthDate(LocalDate.of(1995, 1, 1));
        p.setBirthTime(LocalTime.of(0, 0));
        p.setBirthCalendarType(BirthCalendarType.LUNAR);
        p.setBirthIsLeapMonth(false);
        p.setGender(Gender.UNKNOWN);

        assertDoesNotThrow(() -> calculator.calculate(123L, p, LocalDate.of(2026, 2, 24)));
    }
}

