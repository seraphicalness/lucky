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
}
