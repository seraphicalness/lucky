package com.harugiwun.repository;

import com.harugiwun.domain.ad.AdFeature;
import com.harugiwun.domain.ad.AdView;
import java.time.LocalDateTime;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AdViewRepository extends JpaRepository<AdView, Long> {

    Optional<AdView> findTopByUserIdAndFeatureAndViewedAtAfterOrderByViewedAtDesc(
        Long userId, AdFeature feature, LocalDateTime after
    );
}
