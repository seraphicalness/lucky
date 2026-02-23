package com.harugiwun.repository;

import com.harugiwun.domain.fortune.FortuneDaily;
import java.time.LocalDate;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FortuneDailyRepository extends JpaRepository<FortuneDaily, Long> {
    Optional<FortuneDaily> findByUserIdAndFortuneDate(Long userId, LocalDate fortuneDate);
}
