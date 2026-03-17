package com.harugiwun.repository;

import com.harugiwun.domain.ad.AdFeature;
import com.harugiwun.domain.ad.AdView;
import java.time.LocalDateTime;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface AdViewRepository extends JpaRepository<AdView, Long> {
    long countByUserIdAndFeatureAndViewedAtBetween(Long userId, AdFeature feature, LocalDateTime start, LocalDateTime end);

    java.util.Optional<AdView> findTopByUserIdAndFeatureAndViewedAtAfterOrderByViewedAtDesc(Long userId, AdFeature feature, LocalDateTime threshold);
}
