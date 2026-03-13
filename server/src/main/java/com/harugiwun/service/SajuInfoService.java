package com.harugiwun.service;

import com.harugiwun.domain.profile.AppUserProfile;
import com.harugiwun.domain.profile.BirthCalendarType;
import com.harugiwun.dto.SajuDtos;
import com.nlf.calendar.EightChar;
import com.nlf.calendar.Lunar;
import com.nlf.calendar.Solar;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.LinkedHashMap;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class SajuInfoService {

    private static final Map<String, String> STEM_KOREAN = Map.of(
        "甲", "갑", "乙", "을", "丙", "병", "丁", "정", "戊", "무",
        "己", "기", "庚", "경", "辛", "신", "壬", "임", "癸", "계"
    );

    private static final Map<String, String> BRANCH_KOREAN = Map.ofEntries(
        Map.entry("子", "자"), Map.entry("丑", "축"), Map.entry("寅", "인"),
        Map.entry("卯", "묘"), Map.entry("辰", "진"), Map.entry("巳", "사"),
        Map.entry("午", "오"), Map.entry("未", "미"), Map.entry("申", "신"),
        Map.entry("酉", "유"), Map.entry("戌", "술"), Map.entry("亥", "해")
    );

    private static final Map<String, String> STEM_ELEMENT = Map.of(
        "甲", "목", "乙", "목", "丙", "화", "丁", "화", "戊", "토",
        "己", "토", "庚", "금", "辛", "금", "壬", "수", "癸", "수"
    );

    private static final Map<String, String> BRANCH_ELEMENT = Map.ofEntries(
        Map.entry("子", "수"), Map.entry("丑", "토"), Map.entry("寅", "목"),
        Map.entry("卯", "목"), Map.entry("辰", "토"), Map.entry("巳", "화"),
        Map.entry("午", "화"), Map.entry("未", "토"), Map.entry("申", "금"),
        Map.entry("酉", "금"), Map.entry("戌", "토"), Map.entry("亥", "수")
    );

    public SajuDtos.SajuResponse getSaju(AppUserProfile profile) {
        if (profile == null || profile.getBirthDate() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "생년월일을 먼저 등록해주세요.");
        }

        LocalTime birthTime = profile.getBirthTime() != null ? profile.getBirthTime() : LocalTime.NOON;
        boolean hasExactTime = profile.getBirthTime() != null;
        BirthCalendarType calendarType = profile.getBirthCalendarType() != null
            ? profile.getBirthCalendarType() : BirthCalendarType.SOLAR;
        boolean isLeapMonth = Boolean.TRUE.equals(profile.getBirthIsLeapMonth());

        Lunar birthLunar = toLunar(calendarType, profile.getBirthDate(), birthTime, isLeapMonth);
        EightChar natal = birthLunar.getEightChar();

        String dayStem   = natal.getDay().substring(0, 1);
        String dayBranch = natal.getDay().substring(1, 2);

        SajuDtos.PillarInfo yearPillar  = toPillarInfo(natal.getYear(), dayStem);
        SajuDtos.PillarInfo monthPillar = toPillarInfo(natal.getMonth(), dayStem);
        SajuDtos.PillarInfo dayPillar   = toPillarInfo(natal.getDay(), dayStem);
        SajuDtos.PillarInfo timePillar  = hasExactTime ? toPillarInfo(natal.getTime(), dayStem) : null;

        String dayMasterKorean  = STEM_KOREAN.getOrDefault(dayStem, dayStem);
        String dayMasterElement = STEM_ELEMENT.getOrDefault(dayStem, "목");
        String dayPillarName    = dayMasterKorean + BRANCH_KOREAN.getOrDefault(dayBranch, dayBranch) + "일주";

        Map<String, Integer> elementDistribution = countElements(natal, hasExactTime);
        String yongsin   = findYongsin(elementDistribution);
        String strength  = evaluateStrength(natal, elementDistribution, dayStem);

        return new SajuDtos.SajuResponse(
            yearPillar, monthPillar, dayPillar, timePillar,
            dayMasterKorean, dayMasterElement, dayPillarName,
            strength, elementDistribution, yongsin
        );
    }

    private Lunar toLunar(BirthCalendarType type, LocalDate date, LocalTime time, boolean isLeapMonth) {
        int h = time.getHour(), m = time.getMinute(), s = time.getSecond();
        if (type == BirthCalendarType.LUNAR) {
            int month = isLeapMonth ? -date.getMonthValue() : date.getMonthValue();
            return Lunar.fromYmdHms(date.getYear(), month, date.getDayOfMonth(), h, m, s);
        }
        return Solar.fromYmdHms(date.getYear(), date.getMonthValue(), date.getDayOfMonth(), h, m, s).getLunar();
    }

    private SajuDtos.PillarInfo toPillarInfo(String pillar, String dayMasterStem) {
        if (pillar == null || pillar.length() < 2) return null;
        String stem   = pillar.substring(0, 1);
        String branch = pillar.substring(1, 2);
        return new SajuDtos.PillarInfo(
            pillar,
            STEM_KOREAN.getOrDefault(stem, stem),
            BRANCH_KOREAN.getOrDefault(branch, branch),
            STEM_ELEMENT.getOrDefault(stem, "목"),
            BRANCH_ELEMENT.getOrDefault(branch, "토"),
            tenGodCalculator.calculate(dayMasterStem, stem)
        );
    }

    private Map<String, Integer> countElements(EightChar natal, boolean hasTime) {
        Map<String, Integer> counts = new LinkedHashMap<>();
        for (String el : new String[]{"목", "화", "토", "금", "수"}) counts.put(el, 0);
        addPillar(counts, natal.getYear());
        addPillar(counts, natal.getMonth());
        addPillar(counts, natal.getDay());
        if (hasTime) addPillar(counts, natal.getTime());
        return counts;
    }

    private void addPillar(Map<String, Integer> counts, String pillar) {
        if (pillar == null || pillar.length() < 2) return;
        counts.merge(STEM_ELEMENT.getOrDefault(pillar.substring(0, 1), "목"), 1, (a, b) -> a + b);
        counts.merge(BRANCH_ELEMENT.getOrDefault(pillar.substring(1, 2), "토"), 1, (a, b) -> a + b);
    }

    private String findYongsin(Map<String, Integer> dist) {
        return dist.entrySet().stream()
            .min(Map.Entry.comparingByValue())
            .map(Map.Entry::getKey)
            .orElse("목");
    }

    private String evaluateStrength(EightChar natal, Map<String, Integer> dist, String dayStem) {
        String dm        = STEM_ELEMENT.getOrDefault(dayStem, "목");
        String resource  = generatedBy(dm);   // 인성
        String officer   = controlledBy(dm);  // 관성 (일간 극하는 오행)
        String wealth    = controls(dm);      // 재성 (일간이 극하는 오행)

        int supportScore  = dist.getOrDefault(dm, 0) * 2 + dist.getOrDefault(resource, 0);
        int pressureScore = dist.getOrDefault(officer, 0) * 2 + dist.getOrDefault(wealth, 0);

        // 월지 가중치
        String monthBranch = natal.getMonth().length() >= 2 ? natal.getMonth().substring(1, 2) : "";
        String monthEl     = BRANCH_ELEMENT.getOrDefault(monthBranch, "토");
        if (monthEl.equals(dm) || monthEl.equals(resource)) {
            supportScore += 2;
        } else if (monthEl.equals(officer)) {
            pressureScore += 2;
        }

        if (supportScore - pressureScore >= 4) return "신강";
        if (pressureScore - supportScore >= 4) return "신약";
        return "중화";
    }

    private String generatedBy(String el) {
        return switch (el) {
            case "목" -> "수"; case "화" -> "목"; case "토" -> "화";
            case "금" -> "토"; case "수" -> "금"; default -> "수";
        };
    }

    private String controlledBy(String el) {
        return switch (el) {
            case "목" -> "금"; case "화" -> "수"; case "토" -> "목";
            case "금" -> "화"; case "수" -> "토"; default -> "금";
        };
    }

    private String controls(String el) {
        return switch (el) {
            case "목" -> "토"; case "화" -> "금"; case "토" -> "수";
            case "금" -> "목"; case "수" -> "화"; default -> "토";
        };
    }
}
