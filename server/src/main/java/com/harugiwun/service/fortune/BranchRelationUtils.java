package com.harugiwun.service.fortune;

import java.util.*;

public final class BranchRelationUtils {
    private static final Set<String> CLASH_PAIRS = Set.of(
        "子午", "午子", "卯酉", "酉卯", "寅申", "申寅", "丑未", "未丑", "辰戌", "戌辰", "巳亥", "亥巳");

    private static final Set<String> SIX_HARMONY_PAIRS = Set.of(
        "子丑", "丑子", "寅亥", "亥寅", "卯戌", "戌卯", "辰酉", "酉辰", "巳申", "申巳", "午未", "未午");

    private static final Set<String> HARM_PAIRS = Set.of(
        "子未", "未子", "丑午", "午丑", "寅巳", "巳寅", "卯辰", "辰卯", "申亥", "亥申", "酉戌", "戌酉");

    private static final Set<String> BREAK_PAIRS = Set.of(
        "子酉", "酉子", "午卯", "卯午", "寅亥", "亥寅", "申巳", "巳申", "丑辰", "辰丑", "戌未", "未戌");

    private static final List<String> STEMS = List.of("甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸");
    private static final List<String> BRANCHES = List.of("子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥");

    public static List<String> getVoidBranches(String dayPillar) {
        if (dayPillar == null || dayPillar.length() < 2) return List.of();
        var stemIdx = STEMS.indexOf(dayPillar.substring(0, 1));
        var branchIdx = BRANCHES.indexOf(dayPillar.substring(1, 2));
        if (stemIdx == -1 || branchIdx == -1) return List.of();

        var diff = (branchIdx - stemIdx + 12) % 12;
        return List.of(
            BRANCHES.get((diff - 2 + 12) % 12),
            BRANCHES.get((diff - 1 + 12) % 12)
        );
    }

    public static boolean isVoid(String dayPillar, String branch) {
        return getVoidBranches(dayPillar).contains(branch);
    }

    public static boolean isClash(String a, String b) {
        if (a == null || b == null || a.equals(b)) return false;
        return CLASH_PAIRS.contains(a + b);
    }

    public static boolean isThreeHarmony(List<String> branches) {
        if (branches == null || branches.size() < 3) return false;
        var s = new HashSet<>(branches);
        return (s.contains("申") && s.contains("子") && s.contains("辰"))
            || (s.contains("亥") && s.contains("卯") && s.contains("未"))
            || (s.contains("寅") && s.contains("午") && s.contains("戌"))
            || (s.contains("巳") && s.contains("酉") && s.contains("丑"));
    }

    public static boolean isSixHarmony(String a, String b) {
        if (a == null || b == null || a.equals(b)) return false;
        return SIX_HARMONY_PAIRS.contains(a + b);
    }

    public static boolean isDirectionalHarmony(List<String> branches) {
        return getDirectionalHarmonyElement(branches).isPresent();
    }

    public static Optional<Element> getDirectionalHarmonyElement(List<String> branches) {
        if (branches == null || branches.size() < 3) return Optional.empty();
        var s = new HashSet<>(branches);
        if (s.contains("寅") && s.contains("卯") && s.contains("辰")) return Optional.of(Element.WOOD);
        if (s.contains("巳") && s.contains("午") && s.contains("未")) return Optional.of(Element.FIRE);
        if (s.contains("申") && s.contains("酉") && s.contains("戌")) return Optional.of(Element.METAL);
        if (s.contains("亥") && s.contains("子") && s.contains("丑")) return Optional.of(Element.WATER);
        return Optional.empty();
    }

    public static boolean isPunishment(List<String> branches) {
        if (branches == null || branches.isEmpty()) return false;
        var s = new HashSet<>(branches);
        
        if (s.contains("寅") && s.contains("巳") && s.contains("申")) return true;
        if (s.contains("丑") && s.contains("戌") && s.contains("未")) return true;
        if (s.contains("子") && s.contains("卯")) return true;
        if (s.contains("辰") && Collections.frequency(branches, "辰") >= 2) return true;
        if (s.contains("午") && Collections.frequency(branches, "午") >= 2) return true;
        if (s.contains("酉") && Collections.frequency(branches, "酉") >= 2) return true;
        if (s.contains("亥") && Collections.frequency(branches, "亥") >= 2) return true;
        
        return false;
    }

    public static boolean isHarm(String a, String b) {
        if (a == null || b == null || a.equals(b)) return false;
        return HARM_PAIRS.contains(a + b);
    }

    public static boolean isBreak(String a, String b) {
        if (a == null || b == null || a.equals(b)) return false;
        return BREAK_PAIRS.contains(a + b);
    }
}
