package com.harugiwun.service;

import com.harugiwun.common.TemplateTextGenerator;
import com.harugiwun.domain.fortune.FortuneDaily;
import com.harugiwun.domain.profile.AppUserProfile;
import com.harugiwun.domain.user.AppUser;
import com.harugiwun.dto.FortuneDtos;
import com.harugiwun.repository.AppUserProfileRepository;
import com.harugiwun.repository.AppUserRepository;
import com.harugiwun.repository.FortuneDailyRepository;
import com.harugiwun.service.fortune.SajuFortuneCalculator;
import java.time.LocalDate;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class FortuneService {

    private final FortuneDailyRepository fortuneDailyRepository;
    private final AppUserRepository appUserRepository;
    private final AppUserProfileRepository appUserProfileRepository;
    private final TemplateTextGenerator templateTextGenerator;
    private final SajuFortuneCalculator sajuFortuneCalculator;

    public FortuneService(
        FortuneDailyRepository fortuneDailyRepository,
        AppUserRepository appUserRepository,
        AppUserProfileRepository appUserProfileRepository,
        TemplateTextGenerator templateTextGenerator,
        SajuFortuneCalculator sajuFortuneCalculator
    ) {
        this.fortuneDailyRepository = fortuneDailyRepository;
        this.appUserRepository = appUserRepository;
        this.appUserProfileRepository = appUserProfileRepository;
        this.templateTextGenerator = templateTextGenerator;
        this.sajuFortuneCalculator = sajuFortuneCalculator;
    }

    @Transactional
    public FortuneDaily generateDailyFortune(Long userId, LocalDate date) {
        return fortuneDailyRepository.findByUserIdAndFortuneDate(userId, date)
            .orElseGet(() -> {
                try {
                    return createAndSaveFortune(userId, date);
                } catch (DataIntegrityViolationException e) {
                    // 동시 요청으로 다른 트랜잭션이 먼저 INSERT한 경우 재조회
                    return fortuneDailyRepository.findByUserIdAndFortuneDate(userId, date)
                        .orElseThrow(() -> new ResponseStatusException(HttpStatus.INTERNAL_SERVER_ERROR, "Fortune generation failed"));
                }
            });
    }

    @Scheduled(cron = "0 0 0 * * *")
    @SuppressWarnings("null")
    public void preGenerateAllFortunes() {
        LocalDate tomorrow = LocalDate.now().plusDays(1);
        appUserRepository.findAll().forEach(user -> {
            if (user.getId() == null) return;
            try {
                generateDailyFortune(user.getId(), tomorrow);
            } catch (Exception ignored) {
                // 개별 유저 실패가 전체 배치를 중단시키지 않도록
            }
        });
    }

    @Transactional
    public FortuneDtos.FortuneWidgetResponse getTodayWidget(Long userId) {
        FortuneDaily fortune = generateDailyFortune(userId, LocalDate.now());
        return new FortuneDtos.FortuneWidgetResponse(
            fortune.getFortuneDate(),
            fortune.getTotalScore(),
            fortune.getLuckyColor(),
            fortune.getLuckyNumber(),
            fortune.getWidgetSummary()
        );
    }

    @Transactional
    public FortuneDtos.FortuneDetailResponse getTodayDetail(Long userId) {
        FortuneDaily fortune = generateDailyFortune(userId, LocalDate.now());
        return new FortuneDtos.FortuneDetailResponse(
            fortune.getFortuneDate(),
            fortune.getTotalScore(),
            fortune.getMoneyScore(),
            fortune.getLoveScore(),
            fortune.getHealthScore(),
            fortune.getWorkScore(),
            fortune.getSocialScore(),
            fortune.getLuckyColor(),
            fortune.getLuckyNumber(),
            fortune.getWidgetSummary(),
            fortune.getDetailText()
        );
    }

    private FortuneDaily createAndSaveFortune(Long userId, LocalDate date) {
        AppUser user = appUserRepository
            .findById(userId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));

        AppUserProfile profile = appUserProfileRepository.findByUserId(userId).orElse(null);
        if (profile == null || profile.getBirthDate() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Profile birthDate is required");
        }

        SajuFortuneCalculator.Result r = sajuFortuneCalculator.calculate(userId, profile, date);
        int money = r.moneyScore();
        int love = r.loveScore();
        int health = r.healthScore();
        int work = r.workScore();
        int social = r.socialScore();
        int total = r.totalScore();
        String luckyColor = r.luckyColor();
        int luckyNumber = r.luckyNumber();

        FortuneDaily fortune = new FortuneDaily();
        fortune.setUser(user);
        fortune.setFortuneDate(date);
        fortune.setMoneyScore(money);
        fortune.setLoveScore(love);
        fortune.setHealthScore(health);
        fortune.setWorkScore(work);
        fortune.setSocialScore(social);
        fortune.setTotalScore(total);
        fortune.setLuckyColor(luckyColor);
        fortune.setLuckyNumber(luckyNumber);
        fortune.setWidgetSummary(templateTextGenerator.widgetSummary(total, userId, date));
        fortune.setDetailText(templateTextGenerator.detailText(
            r.dominantTodayElement(), r.highestCategory(), r.lowestCategory(), r.hasClash()
        ));

        return fortuneDailyRepository.save(fortune);
    }
}
