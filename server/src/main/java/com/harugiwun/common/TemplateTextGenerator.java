package com.harugiwun.common;

import com.harugiwun.service.fortune.Element;
import com.harugiwun.service.fortune.FortuneCategory;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.LocalDate;
import java.util.List;
import org.springframework.stereotype.Component;

@Component
public class TemplateTextGenerator {

    private static final List<String> HIGH_SCORE_SUMMARIES = List.of(
        "오늘은 흐름이 매우 좋아요. 중요한 결정을 시도해보세요.",
        "최고의 하루가 예상됩니다. 자신감을 갖고 나아가세요.",
        "행운이 당신과 함께하는 날! 모든 일이 순조롭게 풀릴 거예요.",
        "무엇을 하든 좋은 결과가 따르는, 최고의 컨디션입니다."
    );
    private static final List<String> MID_SCORE_SUMMARIES = List.of(
        "무난하고 안정적인 하루예요. 작은 기회를 챙겨보세요.",
        "평온한 하루입니다. 일상 속에서 작은 행복을 찾아보세요.",
        "차분하게 하루를 보내기 좋은 날입니다. 순리대로 행동하세요."
    );
    private static final List<String> LOW_SCORE_SUMMARIES = List.of(
        "큰 무리 없이 천천히 가면 좋은 하루예요.",
        "조급해하지 말고, 한 템포 쉬어가는 지혜가 필요합니다.",
        "현상 유지에 집중하며, 다음 기회를 준비하는 날입니다."
    );
    private static final List<String> VERY_LOW_SCORE_SUMMARIES = List.of(
        "휴식과 정리가 필요한 날이에요. 페이스 조절이 중요해요.",
        "에너지를 충전하며 내실을 다지는 데 집중하면 좋은 하루입니다.",
        "오늘은 묵묵히 자신의 자리를 지키는 것이 최선입니다."
    );


    public String widgetSummary(int totalScore, Long userId, LocalDate date) {
        if (totalScore >= 80) {
            int idx = boundedHash(userId, date, "widgetSummary", HIGH_SCORE_SUMMARIES.size());
            return HIGH_SCORE_SUMMARIES.get(idx);
        }
        if (totalScore >= 60) {
            int idx = boundedHash(userId, date, "widgetSummary", MID_SCORE_SUMMARIES.size());
            return MID_SCORE_SUMMARIES.get(idx);
        }
        if (totalScore >= 40) {
            int idx = boundedHash(userId, date, "widgetSummary", LOW_SCORE_SUMMARIES.size());
            return LOW_SCORE_SUMMARIES.get(idx);
        }
        int idx = boundedHash(userId, date, "widgetSummary", VERY_LOW_SCORE_SUMMARIES.size());
        return VERY_LOW_SCORE_SUMMARIES.get(idx);
    }

    public String detailText(
        Element dominantTodayElement,
        FortuneCategory highestCategory,
        FortuneCategory lowestCategory,
        boolean hasClash
    ) {
        StringBuilder sb = new StringBuilder();

        sb.append(dominantElementText(dominantTodayElement));
        sb.append(getPositiveAdvice(highestCategory));
        sb.append(getNegativeAdvice(lowestCategory));

        if (hasClash) {
            sb.append("오늘은 예상치 못한 변수나 다툼이 발생할 수 있으니, 평소보다 한 발짝 물러서서 상황을 관망하는 지혜가 필요합니다. ");
        }

        if (highestCategory == lowestCategory) {
            sb.append("전반적으로 모든 운세가 균형을 이루는 무난한 하루입니다. ");
        }

        sb.append("자신의 페이스를 유지하면서 기회를 포착해 보세요.");
        return sb.toString();
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

    private String dominantElementText(Element element) {
        return switch (element) {
            case WOOD -> "오늘은 나무(木)의 기운처럼 성장과 새로운 시작의 에너지가 강한 날입니다. ";
            case FIRE -> "불(火)의 기운이 가득해 열정과 표현력이 돋보이는 하루가 될 수 있습니다. ";
            case EARTH -> "흙(土)의 기운이 안정감을 주어 신중하고 꾸준한 태도가 빛을 발하는 날입니다. ";
            case METAL -> "쇠(金)의 기운이 맺고 끊음을 명확하게 만들어 주어, 결단력과 분별력이 필요한 날입니다. ";
            case WATER -> "물(水)의 기운이 지혜와 유연함을 더해주어, 소통과 흐름에 맡기는 자세가 유리합니다. ";
        };
    }

    private String getPositiveAdvice(FortuneCategory category) {
        return switch (category) {
            case MONEY -> "재물운이 가장 좋은 날입니다. 작은 투자나 금전 거래에서 의외의 행운이 따를 수 있습니다. ";
            case LOVE -> "애정운이 돋보이는 하루입니다. 새로운 인연을 만나거나 기존 관계가 더욱 깊어질 수 있습니다. ";
            case HEALTH -> "건강운이 좋으니, 활기차게 하루를 시작해 보세요. 미뤄뒀던 운동을 시작하기에도 좋은 날입니다. ";
            case WORK -> "직업운이 상승세입니다. 집중력과 성과가 따라주니, 중요한 업무를 처리하기에 좋은 시기입니다. ";
            case SOCIAL -> "인간관계운이 좋아 주변에 사람들이 모이는 날입니다. 새로운 만남이나 모임에 적극적으로 참여해보세요. ";
        };
    }

    private String getNegativeAdvice(FortuneCategory category) {
        return switch (category) {
            case MONEY -> "금전적인 지출에 주의가 필요한 날입니다. 충동적인 구매나 불필요한 거래는 피하는 것이 좋습니다. ";
            case LOVE -> "연인이나 친구와 사소한 오해가 생기기 쉬운 날입니다. 말 한마디를 건넬 때 신중함이 필요합니다. ";
            case HEALTH -> "컨디션이 저하될 수 있으니 무리한 활동은 피하고, 충분한 휴식을 취하는 것이 중요합니다. ";
            case WORK -> "업무에서 작은 실수가 발생할 수 있습니다. 평소보다 꼼꼼하게 확인하는 습관이 필요합니다. ";
            case SOCIAL -> "주변 사람들과의 관계에서 작은 마찰이 예상됩니다. 오늘은 혼자만의 시간을 갖는 것도 좋은 방법입니다. ";
        };
    }
}
