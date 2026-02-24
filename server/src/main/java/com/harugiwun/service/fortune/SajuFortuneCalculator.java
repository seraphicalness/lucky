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

    private enum DayMasterStrength {
        WEAK, BALANCED, STRONG
    }

    private final FortuneScoringWeights weights;

    public SajuFortuneCalculator(FortuneScoringWeights weights) {
        this.weights = weights;
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

        DayMasterStrength strength = evaluateDayMasterStrength(natal, dayMaster, natalCounts);
        int strengthBias = strengthBias(strength);

        int baseScore = scoreBase(natalCounts) + strengthBias;

        FortuneScoringWeights.CategoryWeights moneyWeights = weights.getCategoryWeights(FortuneCategory.MONEY);
        int moneyBase = 
            baseScore
                + daily.count(wealth) * moneyWeights.wealthWeight()
                + daily.count(resource) * moneyWeights.resourceWeight()
                + daily.count(officer) * moneyWeights.officerWeight()
                + daily.count(output) * moneyWeights.outputWeight()
                + daily.count(peer) * moneyWeights.peerWeight();
        int money = clamp(
            applyBranchRelationAdjustments(moneyBase, FortuneCategory.MONEY, wealth, natal, today)
        );

        Element spouseStar = spouseStar(gender, wealth, officer);
        FortuneScoringWeights.CategoryWeights loveWeights = weights.getCategoryWeights(FortuneCategory.LOVE);
        int loveBase =
            baseScore
                + daily.count(spouseStar) * Math.max(loveWeights.wealthWeight(), loveWeights.officerWeight())
                + daily.count(resource) * loveWeights.resourceWeight()
                + daily.count(output) * loveWeights.outputWeight();
        int love = clamp(
            applyBranchRelationAdjustments(loveBase, FortuneCategory.LOVE, elementOfBranch(branchOf(today.getDay())), natal, today)
        );

        FortuneScoringWeights.CategoryWeights workWeights = weights.getCategoryWeights(FortuneCategory.WORK);
        int workBase =
            baseScore
                + daily.count(wealth) * workWeights.wealthWeight()
                + daily.count(resource) * workWeights.resourceWeight()
                + daily.count(officer) * workWeights.officerWeight();
        int work = clamp(
            applyBranchRelationAdjustments(workBase, FortuneCategory.WORK, officer, natal, today)
        );

        FortuneScoringWeights.CategoryWeights socialWeights = weights.getCategoryWeights(FortuneCategory.SOCIAL);
        int socialBase =
            baseScore
                + daily.count(wealth) * socialWeights.wealthWeight()
                + daily.count(resource) * socialWeights.resourceWeight()
                + daily.count(officer) * socialWeights.officerWeight()
                + daily.count(output) * socialWeights.outputWeight()
                + daily.count(peer) * socialWeights.peerWeight();
        int social = clamp(
            applyBranchRelationAdjustments(socialBase, FortuneCategory.SOCIAL, peer, natal, today)
        );

        int healthBase =
            baseScore
                + balanceBonus(natalCounts)
                + daily.count(mostNeeded(natalCounts)) * 8
                - daily.count(mostExcess(natalCounts)) * 4;
        int health = clamp(
            applyBranchRelationAdjustments(healthBase, FortuneCategory.HEALTH, dayMaster, natal, today)
        );

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
        return weights.baseScore() + bonus;
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

    private DayMasterStrength evaluateDayMasterStrength(EightChar natal, Element dayMaster, EnumMap<Element, Integer> natalCounts) {
        // 월지 오행
        Element monthBranchElement = elementOfBranch(branchOf(natal.getMonth()));

        int score = 0;
        // 월령 가중치: 같은 오행이거나 생조 관계면 가산, 극을 당하면 감점
        score += monthBranchWeight(dayMaster, monthBranchElement);

        Element resource = generatedBy(dayMaster);
        Element peer = dayMaster;
        Element wealth = CONTROLS.get(dayMaster);
        Element officer = controlledBy(dayMaster);

        int peerCount = natalCounts.getOrDefault(peer, 0);
        int resourceCount = natalCounts.getOrDefault(resource, 0);
        int wealthCount = natalCounts.getOrDefault(wealth, 0);
        int officerCount = natalCounts.getOrDefault(officer, 0);

        // 비겁/인성(동류/생조)이 많으면 신강 쪽으로
        score += peerCount * 2;
        score += resourceCount;
        // 재·관이 많으면 신약 쪽으로
        score -= wealthCount;
        score -= officerCount * 2;

        if (score >= 6) {
            return DayMasterStrength.STRONG;
        }
        if (score <= 1) {
            return DayMasterStrength.WEAK;
        }
        return DayMasterStrength.BALANCED;
    }

    private int monthBranchWeight(Element dayMaster, Element monthBranchElement) {
        if (monthBranchElement == dayMaster) {
            return 4;
        }
        // 월지가 일간을 생조하면 +3
        if (GENERATES.get(monthBranchElement) == dayMaster) {
            return 3;
        }
        // 일간이 월지를 생하면 +1
        if (GENERATES.get(dayMaster) == monthBranchElement) {
            return 1;
        }
        // 월지가 일간을 극하면 -3
        if (CONTROLS.get(monthBranchElement) == dayMaster) {
            return -3;
        }
        // 일간이 월지를 극하면 -1
        if (CONTROLS.get(dayMaster) == monthBranchElement) {
            return -1;
        }
        return 0;
    }

    private int strengthBias(DayMasterStrength strength) {
        return switch (strength) {
            case STRONG -> 3;
            case WEAK -> -3;
            case BALANCED -> 0;
        };
    }

    private int applyBranchRelationAdjustments(
        int score,
        FortuneCategory category,
        Element relatedElement,
        EightChar natal,
        EightChar today
    ) {
        String natalYearBranch = branchOf(natal.getYear());
        String natalMonthBranch = branchOf(natal.getMonth());
        String natalDayBranch = branchOf(natal.getDay());
        String natalTimeBranch = branchOf(natal.getTime());
        String todayDayBranch = branchOf(today.getDay());

        // 관련된 오행을 가진 원국 지지가 오늘 일지와 충이면 패널티
        String[] natalBranches = {natalYearBranch, natalMonthBranch, natalDayBranch, natalTimeBranch};
        for (String b : natalBranches) {
            if (b == null) continue;
            if (elementOfBranch(b) == relatedElement && BranchRelationUtils.isClash(b, todayDayBranch)) {
                score -= weights.clashPenalty();
            }
        }

        // 오늘 일지를 포함한 전체 지지에서 삼합이 형성되고,
        // 그 삼합국의 중심이 되는 오늘 일지의 오행이 관련 오행과 같으면 보너스
        List<String> allBranches = List.of(
            natalYearBranch,
            natalMonthBranch,
            natalDayBranch,
            natalTimeBranch,
            todayDayBranch
        );
        if (BranchRelationUtils.isThreeHarmony(allBranches)) {
            Element todayElement = elementOfBranch(todayDayBranch);
            if (todayElement == relatedElement) {
                score += weights.harmonyBonus();
            }
        }

        return score;
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

