package com.harugiwun.repository;

import com.harugiwun.domain.profile.AppUserProfile;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AppUserProfileRepository extends JpaRepository<AppUserProfile, Long> {
    Optional<AppUserProfile> findByUserId(Long userId);
}
