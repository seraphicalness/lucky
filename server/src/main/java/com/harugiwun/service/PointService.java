package com.harugiwun.service;

import com.harugiwun.domain.ad.AdFeature;
import com.harugiwun.domain.ad.AdView;
import com.harugiwun.domain.user.AppUser;
import com.harugiwun.dto.PointDtos;
import com.harugiwun.repository.AdViewRepository;
import com.harugiwun.repository.AppUserRepository;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class PointService {

    private final AppUserRepository userRepository;
    private final AdViewRepository adViewRepository;

    public PointService(AppUserRepository userRepository, AdViewRepository adViewRepository) {
        this.userRepository = userRepository;
        this.adViewRepository = adViewRepository;
    }

    @Transactional(readOnly = true)
    public PointDtos.PointBalanceResponse getBalance(Long userId) {
        AppUser user = userRepository.findById(userId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
        
        int dailyAdCount = countDailyAds(userId);
        return new PointDtos.PointBalanceResponse(user.getPoints(), dailyAdCount, "조회 성공");
    }

    @Transactional
    public PointDtos.PointBalanceResponse addAdReward(Long userId) {
        AppUser user = userRepository.findById(userId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        int dailyAdCount = countDailyAds(userId);
        if (dailyAdCount >= 5) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "일일 광고 시청 횟수(5회)를 초과했습니다.");
        }

        // 포인트 지급
        user.setPoints(user.getPoints() + 100);
        userRepository.save(user);

        // 광고 시청 기록 저장
        AdView adView = new AdView();
        adView.setUser(user);
        adView.setFeature(AdFeature.POINT_REWARD);
        adViewRepository.save(adView);

        return new PointDtos.PointBalanceResponse(user.getPoints(), dailyAdCount + 1, "100P가 지급되었습니다!");
    }

    @Transactional
    public PointDtos.PointBalanceResponse purchasePoints(Long userId, PointDtos.PurchaseRequest request) {
        AppUser user = userRepository.findById(userId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        // TODO: 실제 App Store 영수증 검증 로직 추가 (여기서는 요청된 amount만큼 지급)
        user.setPoints(user.getPoints() + request.amount());
        userRepository.save(user);

        return new PointDtos.PointBalanceResponse(user.getPoints(), countDailyAds(userId), request.amount() + "P 충전이 완료되었습니다.");
    }

    private int countDailyAds(Long userId) {
        LocalDateTime startOfDay = LocalDateTime.of(LocalDate.now(), LocalTime.MIN);
        LocalDateTime endOfDay = LocalDateTime.of(LocalDate.now(), LocalTime.MAX);
        return (int) adViewRepository.countByUserIdAndFeatureAndViewedAtBetween(
            userId, AdFeature.POINT_REWARD, startOfDay, endOfDay
        );
    }
}
