package com.harugiwun.repository;

import com.harugiwun.domain.fortune.TarotDaily;
import com.harugiwun.domain.user.AppUser;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.Optional;

public interface TarotDailyRepository extends JpaRepository<TarotDaily, Long> {
    Optional<TarotDaily> findByUserAndFortuneDate(AppUser user, LocalDate fortuneDate);
}
