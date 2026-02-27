package com.harugiwun.service;

import com.harugiwun.domain.ad.AdFeature;
import com.harugiwun.domain.ad.AdView;
import com.harugiwun.domain.fortune.FortuneDaily;
import com.harugiwun.domain.profile.AppUserProfile;
import com.harugiwun.domain.user.AppUser;
import com.harugiwun.dto.CompatibilityDtos;
import com.harugiwun.repository.AdViewRepository;
import com.harugiwun.repository.AppUserProfileRepository;
import com.harugiwun.repository.AppUserRepository;
import com.harugiwun.service.fortune.Element;
import com.harugiwun.service.fortune.SajuFortuneCalculator;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.EnumMap;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class CompatibilityService {

    // 광고 1회 시청으로 잠금 해제되는 시간 (시간 단위)
    private static final int AD_UNLOCK_HOURS = 24;

    private static final Map<Element, Map<Element, Integer>> ELEMENT_COMPAT_TABLE;

    static {
        // 오행 간 궁합 점수 (0~100). 생(生)관계 > 비화(比和) > 극(剋)관계 순
        ELEMENT_COMPAT_TABLE = new EnumMap<>(Element.class);
        ELEMENT_COMPAT_TABLE.put(Element.WOOD, Map.of(
            Element.WOOD, 70,
            Element.FIRE, 85,   // 목생화
            Element.EARTH, 50,  // 목극토
            Element.METAL, 40,  // 금극목
            Element.WATER, 80   // 수생목
        ));
        ELEMENT_COMPAT_TABLE.put(Element.FIRE, Map.of(
            Element.WOOD, 85,   // 목생화
            Element.FIRE, 70,
            Element.EARTH, 80,  // 화생토
            Element.METAL, 45,  // 화극금
            Element.WATER, 40   // 수극화
        ));
        ELEMENT_COMPAT_TABLE.put(Element.EARTH, Map.of(
            Element.WOOD, 50,   // 목극토
            Element.FIRE, 80,   // 화생토
            Element.EARTH, 70,
            Element.METAL, 85,  // 토생금
            Element.WATER, 45   // 토극수
        ));
        ELEMENT_COMPAT_TABLE.put(Element.METAL, Map.of(
            Element.WOOD, 40,   // 금극목
            Element.FIRE, 45,   // 화극금
            Element.EARTH, 85,  // 토생금
            Element.METAL, 70,
            Element.WATER, 80   // 금생수
        ));
        ELEMENT_COMPAT_TABLE.put(Element.WATER, Map.of(
            Element.WOOD, 80,   // 수생목
            Element.FIRE, 40,   // 수극화
            Element.EARTH, 45,  // 토극수
            Element.METAL, 80,  // 금생수
            Element.WATER, 70
        ));
    }

    private final AdViewRepository adViewRepository;
    private final AppUserRepository appUserRepository;
    private final AppUserProfileRepository appUserProfileRepository;
    private final FriendService friendService;
    private final FortuneService fortuneService;
    private final SajuFortuneCalculator sajuFortuneCalculator;

    public CompatibilityService(
        AdViewRepository adViewRepository,
        AppUserRepository appUserRepository,
        AppUserProfileRepository appUserProfileRepository,
        FriendService friendService,
        FortuneService fortuneService,
        SajuFortuneCalculator sajuFortuneCalculator
    ) {
        this.adViewRepository = adViewRepository;
        this.appUserRepository = appUserRepository;
        this.appUserProfileRepository = appUserProfileRepository;
        this.friendService = friendService;
        this.fortuneService = fortuneService;
        this.sajuFortuneCalculator = sajuFortuneCalculator;
    }

    /**
     * 광고 시청 완료를 서버에 기록하고 잠금 해제 시각을 반환한다.
     */
    @Transactional
    @SuppressWarnings("null")
    public CompatibilityDtos.AdWatchResponse recordAdWatch(Long userId, AdFeature feature) {
        AppUser user = appUserRepository.findById(userId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "유저를 찾을 수 없습니다"));

        AdView adView = new AdView();
        adView.setUser(user);
        adView.setFeature(feature);
        adViewRepository.save(adView);

        LocalDateTime unlockedUntil = LocalDateTime.now().plusHours(AD_UNLOCK_HOURS);
        return new CompatibilityDtos.AdWatchResponse(
            true,
            feature.name(),
            unlockedUntil.toEpochSecond(ZoneOffset.UTC)
        );
    }

    /**
     * 오늘 운세 점수 비교 (광고 시청 필요)
     */
    @Transactional(readOnly = true)
    public CompatibilityDtos.ScoreCompareResponse compareScores(Long myUserId, Long friendUserId) {
        checkAdUnlock(myUserId, AdFeature.COMPATIBILITY_SCORE_COMPARE);
        checkFriendship(myUserId, friendUserId);

        FortuneDaily myFortune = fortuneService.generateDailyFortune(myUserId, LocalDate.now());
        FortuneDaily friendFortune = fortuneService.generateDailyFortune(friendUserId, LocalDate.now());

        return new CompatibilityDtos.ScoreCompareResponse(
            myFortune.getTotalScore(),
            myFortune.getMoneyScore(),
            myFortune.getLoveScore(),
            myFortune.getHealthScore(),
            myFortune.getWorkScore(),
            myFortune.getSocialScore(),
            friendFortune.getTotalScore(),
            friendFortune.getMoneyScore(),
            friendFortune.getLoveScore(),
            friendFortune.getHealthScore(),
            friendFortune.getWorkScore(),
            friendFortune.getSocialScore()
        );
    }

    /**
     * 사주 오행 궁합 점수 (광고 시청 필요)
     */
    @Transactional(readOnly = true)
    public CompatibilityDtos.ElementCompatibilityResponse elementCompatibility(Long myUserId, Long friendUserId) {
        checkAdUnlock(myUserId, AdFeature.COMPATIBILITY_ELEMENT_MATCH);
        checkFriendship(myUserId, friendUserId);

        AppUserProfile myProfile = getProfile(myUserId);
        AppUserProfile friendProfile = getProfile(friendUserId);

        Element myDominant = dominantElement(myProfile);
        Element friendDominant = dominantElement(friendProfile);

        int score = ELEMENT_COMPAT_TABLE.get(myDominant).get(friendDominant);
        String relation = describeRelation(myDominant, friendDominant);
        String summary = buildCompatSummary(score);

        return new CompatibilityDtos.ElementCompatibilityResponse(
            score,
            summary,
            myDominant.name(),
            friendDominant.name(),
            relation
        );
    }

    private void checkAdUnlock(Long userId, AdFeature feature) {
        LocalDateTime threshold = LocalDateTime.now().minusHours(AD_UNLOCK_HOURS);
        boolean unlocked = adViewRepository
            .findTopByUserIdAndFeatureAndViewedAtAfterOrderByViewedAtDesc(userId, feature, threshold)
            .isPresent();
        if (!unlocked) {
            throw new ResponseStatusException(HttpStatus.PAYMENT_REQUIRED, "광고를 시청한 후 이용할 수 있습니다");
        }
    }

    private void checkFriendship(Long myUserId, Long friendUserId) {
        if (!friendService.areFriends(myUserId, friendUserId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "친구 관계인 유저와만 비교할 수 있습니다");
        }
    }

    private AppUserProfile getProfile(Long userId) {
        return appUserProfileRepository.findByUserId(userId)
            .filter(p -> p.getBirthDate() != null)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.BAD_REQUEST, "사주 정보가 없는 유저입니다: " + userId));
    }

    @SuppressWarnings("null")
    private Element dominantElement(AppUserProfile profile) {
        // 사주 원국에서 가장 많이 나타나는 오행을 대표 오행으로 사용
        SajuFortuneCalculator.Result r = sajuFortuneCalculator.calculate(
            profile.getUser().getId(), profile, LocalDate.now()
        );
        return r.dominantTodayElement();
    }

    private String describeRelation(Element a, Element b) {
        // 생(生) 관계
        if (generates(a, b)) return a.name() + "이(가) " + b.name() + "을(를) 생하는 상생 관계입니다.";
        if (generates(b, a)) return b.name() + "이(가) " + a.name() + "을(를) 생하는 상생 관계입니다.";
        // 극(剋) 관계
        if (controls(a, b)) return a.name() + "이(가) " + b.name() + "을(를) 극하는 상극 관계입니다.";
        if (controls(b, a)) return b.name() + "이(가) " + a.name() + "을(를) 극하는 상극 관계입니다.";
        // 비화(比和)
        return "두 사람의 오행이 같아 비화(比和) 관계입니다.";
    }

    private boolean generates(Element from, Element to) {
        return switch (from) {
            case WOOD -> to == Element.FIRE;
            case FIRE -> to == Element.EARTH;
            case EARTH -> to == Element.METAL;
            case METAL -> to == Element.WATER;
            case WATER -> to == Element.WOOD;
        };
    }

    private boolean controls(Element from, Element to) {
        return switch (from) {
            case WOOD -> to == Element.EARTH;
            case EARTH -> to == Element.WATER;
            case WATER -> to == Element.FIRE;
            case FIRE -> to == Element.METAL;
            case METAL -> to == Element.WOOD;
        };
    }

    private String buildCompatSummary(int score) {
        if (score >= 80) return "매우 좋은 궁합입니다. 서로 에너지를 북돋아 주는 관계예요.";
        if (score >= 65) return "좋은 궁합입니다. 서로 잘 어울리는 편이에요.";
        if (score >= 55) return "무난한 궁합입니다. 서로 이해하려는 노력이 필요해요.";
        return "상극 관계이지만, 서로의 차이를 인정하면 오히려 성장할 수 있어요.";
    }
}
