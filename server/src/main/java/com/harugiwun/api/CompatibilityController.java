package com.harugiwun.api;

import com.harugiwun.domain.ad.AdFeature;
import com.harugiwun.dto.CompatibilityDtos;
import com.harugiwun.service.CompatibilityService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/compatibility")
public class CompatibilityController {

    private final CompatibilityService compatibilityService;

    public CompatibilityController(CompatibilityService compatibilityService) {
        this.compatibilityService = compatibilityService;
    }

    /**
     * 광고 시청 완료 기록
     * 클라이언트가 광고 SDK에서 시청 완료 콜백을 받은 후 이 API를 호출한다.
     * feature: COMPATIBILITY_SCORE_COMPARE | COMPATIBILITY_ELEMENT_MATCH
     */
    @PostMapping("/ad-watch")
    public CompatibilityDtos.AdWatchResponse recordAdWatch(
        @AuthenticationPrincipal Long userId,
        @RequestParam String feature
    ) {
        AdFeature adFeature = AdFeature.valueOf(feature.toUpperCase());
        return compatibilityService.recordAdWatch(userId, adFeature);
    }

    /**
     * 오늘 운세 점수 비교 (광고 시청 후 24시간 이내 이용 가능)
     */
    @GetMapping("/score/{friendUserId}")
    public CompatibilityDtos.ScoreCompareResponse compareScores(
        @AuthenticationPrincipal Long myUserId,
        @PathVariable Long friendUserId
    ) {
        return compatibilityService.compareScores(myUserId, friendUserId);
    }

    /**
     * 사주 오행 궁합 점수 (광고 시청 후 24시간 이내 이용 가능)
     */
    @GetMapping("/element/{friendUserId}")
    public CompatibilityDtos.ElementCompatibilityResponse elementCompatibility(
        @AuthenticationPrincipal Long myUserId,
        @PathVariable Long friendUserId
    ) {
        return compatibilityService.elementCompatibility(myUserId, friendUserId);
    }
}
