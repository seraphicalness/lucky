package com.harugiwun.common;

import org.springframework.stereotype.Component;

@Component
public class TemplateTextGenerator {

    public String widgetSummary(int totalScore) {
        if (totalScore >= 80) {
            return "?ㅻ뒛? ?먮쫫??留ㅼ슦 醫뗭븘?? 以묒슂??寃곗젙???쒕룄?대낫?몄슂.";
        }
        if (totalScore >= 60) {
            return "臾대궃?섍퀬 ?덉젙?곸씤 ?섎（?덉슂. ?묒? 湲고쉶瑜?梨숆꺼蹂댁꽭??";
        }
        if (totalScore >= 40) {
            return "??臾대━ ?놁씠 泥쒖쿇??媛硫?醫뗭? ?섎（?덉슂.";
        }
        return "?댁떇怨??뺣━媛 ?꾩슂???좎씠?먯슂. ?섏씠??議곗젅??醫뗭븘??";
    }

    public String detailText(int money, int love, int health, int work, int social) {
        return "湲덉쟾 " + tone(money)
            + " / ?곗븷 " + tone(love)
            + " / 嫄닿컯 " + tone(health)
            + " / ??" + tone(work)
            + " / ?멸컙愿怨?" + tone(social)
            + " ?ㅻ뒛? 洹좏삎媛??덇쾶 ?吏곸씠硫?醫뗭? 寃곌낵媛 ?섏???";
    }

    private String tone(int score) {
        if (score >= 80) {
            return "?곸듅??;
        }
        if (score >= 60) {
            return "?덉젙沅?;
        }
        if (score >= 40) {
            return "蹂댄넻";
        }
        return "二쇱쓽";
    }
}
