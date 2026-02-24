package com.harugiwun.service.fortune;

import com.harugiwun.domain.profile.AppUserProfile;
import com.harugiwun.domain.profile.BirthCalendarType;
import com.harugiwun.domain.profile.Gender;
import com.nlf.calendar.EightChar;
import com.nlf.calendar.Lunar;
import com.nlf.calendar.Solar;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.EnumMap;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Component;

@Component
public class SajuFortuneCalculator {

    public record Result(
        int totalScore,
        int moneyScore,
        int loveScore,
        int healthScore,
        int workScore,
        int socialScore,
        String luckyColor,
        int luckyNumber
    ) {}

    private enum Element {
        WOOD, FIRE, EARTH, METAL, WATER
    }

    private static final Map<Element, List<String>> ELEMENT_COLORS = Map.of(
        Element.WOOD, List.of("Green", "Teal"),
        Element.FIRE, List.of("Red", "Orange"),
        Element.EARTH, List.of("Yellow", "Brown"),
        Element.METAL, List.of("White", "Gray"),
        Element.WATER, List.of("Blue", "Black")
    );

    private static final Map<Element, Element> GENERATES = Map.of(
        Element.WOOD, Element.FIRE,
        Element.FIRE, Element.EARTH,
        Element.EARTH, Element.METAL,
        Element.METAL, Element.WATER,
        Element.WATER, Element.WOOD
    );

    private static final Map<Element, Element> CONTROLS = Map.of(
        Element.WOOD, Element.EARTH,
        Element.EARTH, Element.WATER,
        Element.WATER, Element.FIRE,
        Element.FIRE, Element.METAL,
        Element.METAL, Element.WOOD
    );

    public Result calculate(Long userId, AppUserProfile profile, LocalDate fortuneDate) {
        if (userId == null) {
            throw new IllegalArgumentException("userId is required");
        }
        if (profile == null || profile.getBirthDate() == null) {
            throw new IllegalArgumentException("birthDate is required");
        }

        LocalTime birthTime = profile.getBirthTime() == null ? LocalTime.NOON : profile.getBirthTime();
        BirthCalendarType calendarType = profile.getBirthCalendarType() == null ? BirthCalendarType.SOLAR : profile.getBirthCalendarType();
        boolean isLeapMonth = Boolean.TRUE.equals(profile.getBirthIsLeapMonth());
        Gender gender = profile.getGender() == null ? Gender.UNKNOWN : profile.getGender();

        Lunar birthLunar = toLunar(calendarType, profile.getBirthDate(), birthTime, isLeapMonth);
        EightChar natal = birthLunar.getEightChar();

        EightChar today = Solar
            .fromYmdHms(fortuneDate.getYear(), fortuneDate.getMonthValue(), fortuneDate.getDayOfMonth(), 12, 0, 0)
            .getLunar()
            .getEightChar();

        Element dayMaster = elementOfStem(stemOf(natal.getDay()));
        EnumMap<Element, Integer> natalCounts = countElements(natal);
        DailyElements daily = dailyElements(today);

        Element wealth = CONTROLS.get(dayMaster);
        Element officer = controlledBy(dayMaster);
        Element resource = generatedBy(dayMaster);
        Element output = GENERATES.get(dayMaster);
        Element peer = dayMaster;

        int money = clamp(scoreBase(natalCounts)
            + daily.count(wealth) * 9
            + daily.count(resource) * 2
            - daily.count(officer) * 6);

        Element spouseStar = spouseStar(gender, wealth, officer);
        int love = clamp(scoreBase(natalCounts)
            + daily.count(spouseStar) * 10
            + daily.count(resource) * 2
            - daily.count(output) * 2);

        int work = clamp(scoreBase(natalCounts)
            + daily.count(officer) * 9
            + daily.count(resource) * 3
            - daily.count(wealth) * 2);

        int social = clamp(scoreBase(natalCounts)
            + daily.count(peer) * 6
            + daily.count(output) * 4
            - daily.count(officer) * 2);

        int health = clamp(scoreBase(natalCounts)
            + balanceBonus(natalCounts)
            + daily.count(mostNeeded(natalCounts)) * 8
            - daily.count(mostExcess(natalCounts)) * 4);

        int total = clamp((money + love + work + social + health) / 5);

        Element luckyElement = mostNeeded(natalCounts);
        String luckyColor = pickLuckyColor(userId, fortuneDate, luckyElement);
        int luckyNumber = 1 + boundedHash(userId, fortuneDate, "luckyNumber", 45);

        return new Result(total, money, love, health, work, social, luckyColor, luckyNumber);
    }

    private Lunar toLunar(BirthCalendarType type, LocalDate date, LocalTime time, boolean isLeapMonth) {
        int hour = time.getHour();
        int minute = time.getMinute();
        int second = time.getSecond();

        if (type == BirthCalendarType.LUNAR) {
            int lunarMonth = date.getMonthValue();
            if (isLeapMonth) {
                lunarMonth = -lunarMonth;
            }
            return Lunar.fromYmdHms(date.getYear(), lunarMonth, date.getDayOfMonth(), hour, minute, second);
        }

        return Solar
            .fromYmdHms(date.getYear(), date.getMonthValue(), date.getDayOfMonth(), hour, minute, second)
            .getLunar();
    }

    private record DailyElements(EnumMap<Element, Integer> counts) {
        int count(Element e) {
            return counts.getOrDefault(e, 0);
        }
    }

    private DailyElements dailyElements(EightChar today) {
        EnumMap<Element, Integer> counts = new EnumMap<>(Element.class);
        inc(counts, elementOfStem(stemOf(today.getDay())));
        inc(counts, elementOfBranch(branchOf(today.getDay())));
        inc(counts, elementOfStem(stemOf(today.getMonth())));
        inc(counts, elementOfBranch(branchOf(today.getMonth())));
        return new DailyElements(counts);
    }

    private EnumMap<Element, Integer> countElements(EightChar natal) {
        EnumMap<Element, Integer> counts = new EnumMap<>(Element.class);

        addPillar(counts, natal.getYear());
        addPillar(counts, natal.getMonth());
        addPillar(counts, natal.getDay());
        addPillar(counts, natal.getTime());

        return counts;
    }

    private void addPillar(EnumMap<Element, Integer> counts, String pillar) {
        inc(counts, elementOfStem(stemOf(pillar)));
        inc(counts, elementOfBranch(branchOf(pillar)));
    }

    private void inc(EnumMap<Element, Integer> counts, Element e) {
        counts.put(e, counts.getOrDefault(e, 0) + 1);
    }

    private int scoreBase(EnumMap<Element, Integer> natalCounts) {
        int bonus = balanceBonus(natalCounts);
        return 55 + bonus;
    }

    private int balanceBonus(EnumMap<Element, Integer> natalCounts) {
        int min = Integer.MAX_VALUE;
        int max = Integer.MIN_VALUE;
        for (Element e : Element.values()) {
            int c = natalCounts.getOrDefault(e, 0);
            min = Math.min(min, c);
            max = Math.max(max, c);
        }
        int spread = max - min;
        if (spread <= 1) return 10;
        if (spread == 2) return 6;
        if (spread == 3) return 2;
        return -2;
    }

    private Element mostNeeded(EnumMap<Element, Integer> natalCounts) {
        Element best = Element.WOOD;
        int min = Integer.MAX_VALUE;
        for (Element e : Element.values()) {
            int c = natalCounts.getOrDefault(e, 0);
            if (c < min) {
                min = c;
                best = e;
            }
        }
        return best;
    }

    private Element mostExcess(EnumMap<Element, Integer> natalCounts) {
        Element best = Element.WOOD;
        int max = Integer.MIN_VALUE;
        for (Element e : Element.values()) {
            int c = natalCounts.getOrDefault(e, 0);
            if (c > max) {
                max = c;
                best = e;
            }
        }
        return best;
    }

    private String pickLuckyColor(Long userId, LocalDate date, Element luckyElement) {
        List<String> colors = ELEMENT_COLORS.getOrDefault(luckyElement, List.of("Blue"));
        int idx = boundedHash(userId, date, "luckyColor", colors.size());
        return colors.get(idx);
    }

    private int boundedHash(Long userId, LocalDate date, String purpose, int boundExclusive) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] bytes = (userId + ":" + date + ":" + purpose).getBytes(StandardCharsets.UTF_8);
            byte[] digest = md.digest(bytes);
            int v = ByteBuffer.wrap(digest, 0, 4).getInt() & Integer.MAX_VALUE;
            return v % boundExclusive;
        } catch (Exception e) {
            int v = (userId + ":" + date + ":" + purpose).hashCode() & Integer.MAX_VALUE;
            return v % boundExclusive;
        }
    }

    private Element spouseStar(Gender gender, Element wealth, Element officer) {
        if (gender == Gender.MALE) return wealth;
        if (gender == Gender.FEMALE) return officer;
        return wealth;
    }

    private Element generatedBy(Element dm) {
        for (Map.Entry<Element, Element> e : GENERATES.entrySet()) {
            if (e.getValue() == dm) return e.getKey();
        }
        return Element.WATER;
    }

    private Element controlledBy(Element dm) {
        for (Map.Entry<Element, Element> e : CONTROLS.entrySet()) {
            if (e.getValue() == dm) return e.getKey();
        }
        return Element.METAL;
    }

    private String stemOf(String pillar) {
        if (pillar == null || pillar.length() < 2) {
            throw new IllegalArgumentException("invalid pillar: " + pillar);
        }
        return pillar.substring(0, 1);
    }

    private String branchOf(String pillar) {
        if (pillar == null || pillar.length() < 2) {
            throw new IllegalArgumentException("invalid pillar: " + pillar);
        }
        return pillar.substring(1, 2);
    }

    private Element elementOfStem(String stem) {
        return switch (stem) {
            case "甲", "乙" -> Element.WOOD;
            case "丙", "丁" -> Element.FIRE;
            case "戊", "己" -> Element.EARTH;
            case "庚", "辛" -> Element.METAL;
            case "壬", "癸" -> Element.WATER;
            default -> Element.WATER;
        };
    }

    private Element elementOfBranch(String branch) {
        return switch (branch) {
            case "寅", "卯" -> Element.WOOD;
            case "巳", "午" -> Element.FIRE;
            case "申", "酉" -> Element.METAL;
            case "亥", "子" -> Element.WATER;
            case "丑", "辰", "未", "戌" -> Element.EARTH;
            default -> Element.EARTH;
        };
    }

    private int clamp(int score) {
        return Math.max(0, Math.min(100, score));
    }
}

