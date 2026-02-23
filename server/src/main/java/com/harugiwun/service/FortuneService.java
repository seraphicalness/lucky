package com.harugiwun.service;

import com.harugiwun.common.TemplateTextGenerator;
import com.harugiwun.domain.fortune.FortuneDaily;
import com.harugiwun.domain.profile.AppUserProfile;
import com.harugiwun.domain.user.AppUser;
import com.harugiwun.dto.FortuneDtos;
import com.harugiwun.repository.AppUserProfileRepository;
import com.harugiwun.repository.AppUserRepository;
import com.harugiwun.repository.FortuneDailyRepository;
import java.time.LocalDate;
import java.util.List;
import java.util.Random;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class FortuneService {

    private static final List<String> COLORS = List.of("Red", "Blue", "Green", "Yellow", "Purple", "Orange", "White", "Black");

    private final FortuneDailyRepository fortuneDailyRepository;
    private final AppUserRepository appUserRepository;
    private final AppUserProfileRepository appUserProfileRepository;
    private final TemplateTextGenerator templateTextGenerator;

    public FortuneService(
        FortuneDailyRepository fortuneDailyRepository,
        AppUserRepository appUserRepository,
        AppUserProfileRepository appUserProfileRepository,
        TemplateTextGenerator templateTextGenerator
    ) {
        this.fortuneDailyRepository = fortuneDailyRepository;
        this.appUserRepository = appUserRepository;
        this.appUserProfileRepository = appUserProfileRepository;
        this.templateTextGenerator = templateTextGenerator;
    }

    @Transactional
    public FortuneDaily generateDailyFortune(Long userId, LocalDate date) {
        return fortuneDailyRepository.findByUserIdAndFortuneDate(userId, date)
            .orElseGet(() -> createAndSaveFortune(userId, date));
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

        LocalDate birthDate = appUserProfileRepository.findByUserId(userId)
            .map(AppUserProfile::getBirthDate)
            .orElse(LocalDate.of(2000, 1, 1));

        long seed = birthDate.toEpochDay() * 37L + date.toEpochDay() * 17L + userId;
        Random random = new Random(seed);

        int money = score(random);
        int love = score(random);
        int health = score(random);
        int work = score(random);
        int social = score(random);
        int total = clamp((money + love + health + work + social) / 5 + random.nextInt(11) - 5);
        String luckyColor = COLORS.get(random.nextInt(COLORS.size()));
        int luckyNumber = random.nextInt(45) + 1;

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
        fortune.setWidgetSummary(templateTextGenerator.widgetSummary(total));
        fortune.setDetailText(templateTextGenerator.detailText(money, love, health, work, social));

        return fortuneDailyRepository.save(fortune);
    }

    private int score(Random random) {
        return 35 + random.nextInt(66);
    }

    private int clamp(int score) {
        return Math.max(0, Math.min(100, score));
    }
}
