package com.harugiwun.service.fortune;

import com.harugiwun.domain.fortune.FortunePeriod;
import com.harugiwun.domain.profile.AppUserProfile;
import com.harugiwun.domain.profile.BirthCalendarType;
import com.harugiwun.domain.profile.Gender;
import com.nlf.calendar.Lunar;
import com.nlf.calendar.Solar;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.stereotype.Service;

@Service
public class UnseTimelineService {

    // 60갑자 순서 (甲子=0 기준, 1984년이 甲子년)
    private static final List<String> SEXAGENARY_CYCLE = List.of(
        "甲子", "乙丑", "丙寅", "丁卯", "戊辰", "己巳", "庚午", "辛未", "壬申", "癸酉",
        "甲戌", "乙亥", "丙子", "丁丑", "戊寅", "己卯", "庚辰", "辛巳", "壬午", "癸未",
        "甲申", "乙酉", "丙戌", "丁亥", "戊子", "己丑", "庚寅", "辛卯", "壬辰", "癸巳",
        "甲午", "乙未", "丙申", "丁酉", "戊戌", "己亥", "庚子", "辛丑", "壬寅", "癸卯",
        "甲辰", "乙巳", "丙午", "丁未", "戊申", "己酉", "庚戌", "辛亥", "壬子", "癸丑",
        "甲寅", "乙卯", "丙辰", "丁巳", "戊午", "己未", "庚申", "辛酉", "壬戌", "癸亥"
    );

    // 양간(陽干): 甲丙戊庚壬
    private static final Set<String> YANG_STEMS = Set.of("甲", "丙", "戊", "庚", "壬");

    // 대운 순/역행 기준이 되는 12절(節) — 중기(中氣)는 포함하지 않음
    private static final Set<String> JIE_TERMS = Set.of(
        "小寒", "立春", "驚蟄", "清明", "立夏", "芒種",
        "小暑", "立秋", "白露", "寒露", "立冬", "大雪"
    );

    private static final Map<String, String> STEM_ELEMENT_CHINESE = Map.of(
        "甲", "木", "乙", "木", "丙", "火", "丁", "火", "戊", "土",
        "己", "土", "庚", "金", "辛", "金", "壬", "水", "癸", "水"
    );

    private static final int DAEWOON_COUNT = 8;
    private static final int DAEWOON_YEARS = 10;

    /**
     * 대운(大運) 계산
     *
     * <p>양남음녀(陽男陰女)는 순행, 음남양녀(陰男陽女)는 역행으로 월주에서 한 간지씩 이동한다.
     * 대운 시작 나이는 출생일에서 가장 가까운 절(節)까지의 날수를 3으로 나눠(반올림) 구한다.
     */
    public List<FortunePeriod> calculateDaewoon(AppUserProfile profile) {
        if (profile == null || profile.getBirthDate() == null) {
            return List.of();
        }

        LocalDate birthDate = profile.getBirthDate();
        LocalTime birthTime = profile.getBirthTime() != null ? profile.getBirthTime() : LocalTime.NOON;
        BirthCalendarType calendarType = profile.getBirthCalendarType() != null
            ? profile.getBirthCalendarType() : BirthCalendarType.SOLAR;
        boolean isLeapMonth = Boolean.TRUE.equals(profile.getBirthIsLeapMonth());
        Gender gender = profile.getGender() != null ? profile.getGender() : Gender.UNKNOWN;

        Lunar birthLunar = toLunar(calendarType, birthDate, birthTime, isLeapMonth);
        String yearStem = birthLunar.getEightChar().getYear().substring(0, 1);
        String monthPillar = birthLunar.getEightChar().getMonth();

        // 양남음녀 순행, 음남양녀 역행
        boolean isYangYear = YANG_STEMS.contains(yearStem);
        boolean forward = (gender == Gender.FEMALE) ? !isYangYear : isYangYear;

        int startAge = calculateStartAge(birthDate, forward);

        int monthIndex = SEXAGENARY_CYCLE.indexOf(monthPillar);
        if (monthIndex < 0) monthIndex = 0;

        List<FortunePeriod> result = new ArrayList<>();
        for (int i = 1; i <= DAEWOON_COUNT; i++) {
            int idx = forward
                ? (monthIndex + i) % 60
                : ((monthIndex - i) % 60 + 60) % 60;

            String pillar = SEXAGENARY_CYCLE.get(idx);
            String element = STEM_ELEMENT_CHINESE.getOrDefault(pillar.substring(0, 1), "木");

            int ageStart = startAge + (i - 1) * DAEWOON_YEARS;
            LocalDate start = birthDate.plusYears(ageStart);
            LocalDate end = birthDate.plusYears(ageStart + DAEWOON_YEARS).minusDays(1);

            result.add(new FortunePeriod(start, end, pillar, element, FortunePeriod.PeriodType.DAEWOON));
        }

        return result;
    }

    /**
     * 세운(歲運) 계산
     *
     * <p>기준 연도부터 10년치 태세(太歲) 간지와 오행을 반환한다.
     * 경계는 편의상 양력 1월 1일 ~ 12월 31일을 사용한다.
     */
    public List<FortunePeriod> calculateSewoon(LocalDate baseDate) {
        if (baseDate == null) {
            baseDate = LocalDate.now();
        }

        List<FortunePeriod> result = new ArrayList<>();
        int startYear = baseDate.getYear();

        for (int year = startYear; year < startYear + 10; year++) {
            // 1984년(甲子=index 0) 기준으로 간지 인덱스 계산
            int index = ((year - 4) % 60 + 60) % 60;
            String pillar = SEXAGENARY_CYCLE.get(index);
            String element = STEM_ELEMENT_CHINESE.getOrDefault(pillar.substring(0, 1), "木");

            LocalDate start = LocalDate.of(year, 1, 1);
            LocalDate end = LocalDate.of(year, 12, 31);

            result.add(new FortunePeriod(start, end, pillar, element, FortunePeriod.PeriodType.SEWOON));
        }

        return result;
    }

    /**
     * 월운(月運) 계산: 오호둔년법(五虎遁年法) 적용
     */
    public List<FortunePeriod> calculateWolwoon(int year) {
        // 해당 연도의 천간 인덱스 (0=甲, 1=乙, ...)
        int yearStemIdx = ((year - 4) % 10 + 10) % 10;
        
        // 오호둔년법: 1월(寅월)의 천간 결정
        // 甲己년 -> 丙寅(2), 乙庚 -> 戊寅(4), 丙辛 -> 庚寅(6), 丁壬 -> 壬寅(8), 戊癸 -> 甲寅(0)
        int startStemIdx = switch (yearStemIdx % 5) {
            case 0 -> 2; // 甲, 己
            case 1 -> 4; // 乙, 庚
            case 2 -> 6; // 丙, 辛
            case 3 -> 8; // 丁, 壬
            case 4 -> 0; // 戊, 癸
            default -> 0;
        };

        // 1월(寅월)의 60갑자 인덱스 (寅=index 2)
        int startIndex = (startStemIdx * 6 + 2 * 5) % 60; 
        // 위 수식 대신 직접 60갑자에서 찾기 (천간 index, 지지 index=2(寅))
        for (int i = 0; i < 60; i++) {
            String p = SEXAGENARY_CYCLE.get(i);
            if (p.startsWith(List.of("甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸").get(startStemIdx)) 
                && p.endsWith("寅")) {
                startIndex = i;
                break;
            }
        }

        List<FortunePeriod> result = new ArrayList<>();
        for (int month = 1; month <= 12; month++) {
            int idx = (startIndex + (month - 1)) % 60;
            String pillar = SEXAGENARY_CYCLE.get(idx);
            String element = STEM_ELEMENT_CHINESE.getOrDefault(pillar.substring(0, 1), "木");

            LocalDate start = LocalDate.of(year, month, 1);
            LocalDate end = start.withDayOfMonth(start.lengthOfMonth());

            result.add(new FortunePeriod(start, end, pillar, element, FortunePeriod.PeriodType.WOLWOON));
        }
        return result;
    }

    /**
     * 대운 시작 나이 = 출생일에서 가장 가까운 절(節)까지의 날수 ÷ 3 (반올림, 최소 1)
     *
     * <p>순행이면 미래 방향, 역행이면 과거 방향으로 탐색한다.
     */
    private int calculateStartAge(LocalDate birthDate, boolean forward) {
        Solar birthSolar = Solar.fromYmdHms(
            birthDate.getYear(), birthDate.getMonthValue(), birthDate.getDayOfMonth(), 0, 0, 0
        );
        int direction = forward ? 1 : -1;
        Solar current = birthSolar;

        // 절기 간격은 최대 ~32일이므로 45일 범위면 충분
        for (int days = 1; days <= 45; days++) {
            current = current.next(direction);
            String jieQi = current.getLunar().getJieQi();
            if (jieQi != null && !jieQi.isEmpty() && JIE_TERMS.contains(jieQi)) {
                return Math.max(1, (int) Math.round(days / 3.0));
            }
        }
        return 3; // 절기를 찾지 못한 경우 기본값
    }

    private Lunar toLunar(BirthCalendarType type, LocalDate date, LocalTime time, boolean isLeapMonth) {
        int h = time.getHour(), m = time.getMinute(), s = time.getSecond();
        if (type == BirthCalendarType.LUNAR) {
            int month = isLeapMonth ? -date.getMonthValue() : date.getMonthValue();
            return Lunar.fromYmdHms(date.getYear(), month, date.getDayOfMonth(), h, m, s);
        }
        return Solar.fromYmdHms(date.getYear(), date.getMonthValue(), date.getDayOfMonth(), h, m, s).getLunar();
    }
}
