package com.harugiwun.service.fortune;

import com.harugiwun.dto.TarotDtos;
import java.util.Arrays;
import java.util.List;
import lombok.RequiredArgsConstructor;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;

@Service
@RequiredArgsConstructor
public class TarotCardService {

    private final RestTemplate restTemplate;

    private static final String TAROT_API_URL = "https://tarotapi.dev/api/v1/cards/random?n=1"; // Request 1 random card

    public TarotDtos.DailyTarotCardResponse getDailyTarotCard() {
        try {
            // tarotapi.dev returns an array of cards, even for n=1
            ResponseEntity<List<TarotDtos.TarotApiResponse>> responseEntity = restTemplate.exchange(
                TAROT_API_URL,
                HttpMethod.GET,
                null,
                new ParameterizedTypeReference<List<TarotDtos.TarotApiResponse>>() {}
            );

            List<TarotDtos.TarotApiResponse> cards = responseEntity.getBody();

            if (cards != null && !cards.isEmpty()) {
                return TarotDtos.DailyTarotCardResponse.from(cards.get(0));
            } else {
                // If API returns empty list, treat as an error and use fallback
                return TarotDtos.DailyTarotCardResponse.fallback();
            }
        } catch (RestClientException e) {
            // Log the exception for debugging
            System.err.println("Error calling Tarot API: " + e.getMessage());
            return TarotDtos.DailyTarotCardResponse.fallback();
        }
    }
}
