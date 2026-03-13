package com.harugiwun.service.fortune;

import org.springframework.stereotype.Component;
import java.util.Map;
import java.util.Set;

@Component
public class TenGodCalculator {

    private static final Map<String, String> STEM_ELEMENT = Map.of(
        "甲", "목", "乙", "목", "丙", "화", "丁", "화", "戊", "토",
        "己", "토", "庚", "금", "辛", "금", "壬", "수", "癸", "수"
    );

    private static final Set<String> YANG_STEMS = Set.of("甲", "丙", "戊", "庚", "壬");

    public String calculate(String dayMasterStem, String targetStem) {
        if (dayMasterStem == null || targetStem == null) return "";

        String dmEl = STEM_ELEMENT.get(dayMasterStem);
        String tgEl = STEM_ELEMENT.get(targetStem);
        boolean sameYinYang = YANG_STEMS.contains(dayMasterStem) == YANG_STEMS.contains(targetStem);

        if (dmEl.equals(tgEl)) {
            return sameYinYang ? "비견" : "겁재";
        }

        if (isGenerating(dmEl, tgEl)) {
            return sameYinYang ? "식신" : "상관";
        }

        if (isControlling(dmEl, tgEl)) {
            return sameYinYang ? "편재" : "정재";
        }

        if (isControlling(tgEl, dmEl)) {
            return sameYinYang ? "편관" : "정관";
        }

        if (isGenerating(tgEl, dmEl)) {
            return sameYinYang ? "편인" : "정인";
        }

        return "";
    }

    private boolean isGenerating(String from, String to) {
        return switch (from) {
            case "목" -> "화".equals(to);
            case "화" -> "토".equals(to);
            case "토" -> "금".equals(to);
            case "금" -> "수".equals(to);
            case "수" -> "목".equals(to);
            default -> false;
        };
    }

    private boolean isControlling(String from, String to) {
        return switch (from) {
            case "목" -> "토".equals(to);
            case "화" -> "금".equals(to);
            case "토" -> "수".equals(to);
            case "금" -> "목".equals(to);
            case "수" -> "화".equals(to);
            default -> false;
        };
    }
}
