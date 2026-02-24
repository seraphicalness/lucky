package com.harugiwun.service.fortune;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

public final class BranchRelationUtils {

    private BranchRelationUtils() {
    }

    private static final Set<String> CLASH_PAIRS = Set.of(
        "子午", "午子",
        "卯酉", "酉卯",
        "寅申", "申寅",
        "丑未", "未丑",
        "辰戌", "戌辰",
        "巳亥", "亥巳"
    );

    public static boolean isClash(String branchA, String branchB) {
        if (branchA == null || branchB == null) {
            return false;
        }
        if (branchA.equals(branchB)) {
            return false;
        }
        String pair = branchA + branchB;
        return CLASH_PAIRS.contains(pair);
    }

    /**
     * 전달된 지지 목록 안에 어떤 삼합 조합이라도 포함되어 있는지 여부.
     * (예: 申子辰, 亥卯未, 寅午戌, 巳酉丑)
     */
    public static boolean isThreeHarmony(List<String> branches) {
        if (branches == null || branches.size() < 3) {
            return false;
        }
        Set<String> set = new HashSet<>(branches);
        // 수국: 申子辰
        if (set.contains("申") && set.contains("子") && set.contains("辰")) {
            return true;
        }
        // 목국: 亥卯未
        if (set.contains("亥") && set.contains("卯") && set.contains("未")) {
            return true;
        }
        // 화국: 寅午戌
        if (set.contains("寅") && set.contains("午") && set.contains("戌")) {
            return true;
        }
        // 금국: 巳酉丑
        if (set.contains("巳") && set.contains("酉") && set.contains("丑")) {
            return true;
        }
        return false;
    }
}


