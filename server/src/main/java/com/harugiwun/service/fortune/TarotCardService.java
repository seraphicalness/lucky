package com.harugiwun.service.fortune;

import com.harugiwun.domain.fortune.TarotDaily;
import com.harugiwun.domain.user.AppUser;
import com.harugiwun.dto.TarotDtos;
import com.harugiwun.repository.AppUserRepository;
import com.harugiwun.repository.TarotDailyRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDate;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class TarotCardService {

    private final RestTemplate restTemplate;
    private final TarotDailyRepository tarotDailyRepository;
    private final AppUserRepository appUserRepository;

    private static final String TAROT_API_URL = "https://tarotapi.dev/api/v1/cards/random?n=1";

    @Transactional(readOnly = true)
    public TarotDtos.DailyTarotCardResponse getDailyTarotCard(Long userId) {
        AppUser user = appUserRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));
        
        LocalDate today = LocalDate.now();
        Optional<TarotDaily> existing = tarotDailyRepository.findByUserAndFortuneDate(user, today);

        if (existing.isPresent()) {
            return TarotDtos.DailyTarotCardResponse.from(existing.get());
        } else {
            return TarotDtos.DailyTarotCardResponse.notPicked();
        }
    }

    @Transactional
    public TarotDtos.DailyTarotCardResponse pickDailyTarotCard(Long userId) {
        AppUser user = appUserRepository.findById(userId)
            .orElseThrow(() -> new IllegalArgumentException("User not found"));
        
        LocalDate today = LocalDate.now();
        Optional<TarotDaily> existing = tarotDailyRepository.findByUserAndFortuneDate(user, today);

        if (existing.isPresent()) {
            return TarotDtos.DailyTarotCardResponse.from(existing.get());
        }

        try {
            ResponseEntity<TarotDtos.TarotApiWrapperResponse> responseEntity = restTemplate.exchange(
                TAROT_API_URL,
                HttpMethod.GET,
                null,
                TarotDtos.TarotApiWrapperResponse.class
            );

            TarotDtos.TarotApiWrapperResponse response = responseEntity.getBody();

            if (response != null && response.cards() != null && !response.cards().isEmpty()) {
                TarotDtos.TarotApiResponse apiCard = response.cards().get(0);
                
                TarotDaily entity = new TarotDaily();
                entity.setUser(user);
                entity.setFortuneDate(today);
                entity.setName(apiCard.name());
                entity.setMeaning(apiCard.meaningUp());
                entity.setDescription(apiCard.desc());
                entity.setImageUrl("/images/tarot/" + apiCard.nameShort() + ".png");
                
                tarotDailyRepository.save(entity);
                
                return TarotDtos.DailyTarotCardResponse.from(entity);
            } else {
                return TarotDtos.DailyTarotCardResponse.fallback();
            }
        } catch (Exception e) {
            System.err.println("Error calling Tarot API: " + e.getMessage());
            return TarotDtos.DailyTarotCardResponse.fallback();
        }
    }
}
