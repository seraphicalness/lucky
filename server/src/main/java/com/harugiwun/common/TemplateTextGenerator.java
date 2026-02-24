package com.harugiwun.common;

import org.springframework.stereotype.Component;

@Component
public class TemplateTextGenerator {

    public String widgetSummary(int totalScore) {
        if (totalScore >= 80) {
            return "오늘은 흐름이 매우 좋아요. 중요한 결정을 시도해보세요.";
        }
        if (totalScore >= 60) {
            return "무난하고 안정적인 하루예요. 작은 기회를 챙겨보세요.";
        }
        if (totalScore >= 40) {
            return "큰 무리 없이 천천히 가면 좋은 하루예요.";
        }
        return "휴식과 정리가 필요한 날이에요. 페이스 조절이 좋아요.";
    }

    public String detailText(int money, int love, int health, int work, int social) {
        return "금전 " + tone(money)
            + " / 연애 " + tone(love)
            + " / 건강 " + tone(health)
            + " / 일 " + tone(work)
            + " / 인간관계 " + tone(social)
            + " 오늘은 균형감 있게 움직이면 좋은 결과가 나와요.";
    }

    private String tone(int score) {
        if (score >= 80) {
            return "상승세";
        }
        if (score >= 60) {
            return "안정권";
        }
        if (score >= 40) {
            return "보통";
        }
        return "주의";
    }

    public String narrativeText(
        String dominantElement,
        String dayMasterStrength,
        boolean strongWealth,
        boolean strongOfficer,
        boolean hasWealthClashToday
    ) {
        StringBuilder sb = new StringBuilder();

        if (dominantElement != null) {
            sb.append("오늘은 ").append(dominantElement).append(" 기운이 두드러지는 날이에요. ");
        }

        if ("STRONG".equals(dayMasterStrength)) {
            sb.append("전체적으로 자신감과 추진력이 강한 흐름입니다. ");
        } else if ("WEAK".equals(dayMasterStrength)) {
            sb.append("체력과 마음이 쉽게 지칠 수 있어 무리하지 않는 편이 좋아요. ");
        }

        if (strongWealth) {
            sb.append("재성의 기운이 강하게 작용해 금전적인 기회가 눈에 띌 수 있어요. ");
        }

        if (strongOfficer) {
            sb.append("관성의 기운이 살아 있어 책임과 평가가 부각되는 하루입니다. ");
        }

        if (hasWealthClashToday) {
            sb.append("다만 재성에 충이 들어와 투자나 큰 지출은 한 번 더 점검하는 것이 좋아요. ");
        }

        if (sb.length() == 0) {
            sb.append("오늘은 전반적으로 큰 굴곡 없이 흘러가는 에너지입니다. ");
        }

        sb.append("자신의 페이스를 유지하면서 기회를 포착해 보세요.");
        return sb.toString();
    }
}
