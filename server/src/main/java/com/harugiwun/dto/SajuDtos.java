package com.harugiwun.dto;

import java.util.Map;

public class SajuDtos {

    public record SajuResponse(
        PillarInfo yearPillar,
        PillarInfo monthPillar,
        PillarInfo dayPillar,
        PillarInfo timePillar,
        String dayMasterKorean,
        String dayMasterElement,
        String dayPillarName,
        String dayMasterStrength,
        Map<String, Integer> elementDistribution,
        String yongsin
    ) {}

    public record PillarInfo(
        String characters,
        String stemKorean,
        String branchKorean,
        String stemElement,
        String branchElement
    ) {}
}
