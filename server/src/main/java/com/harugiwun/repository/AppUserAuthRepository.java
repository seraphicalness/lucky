package com.harugiwun.repository;

import com.harugiwun.domain.user.AppUserAuth;
import com.harugiwun.domain.user.AuthProvider;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AppUserAuthRepository extends JpaRepository<AppUserAuth, Long> {
    Optional<AppUserAuth> findByProviderAndProviderUserId(AuthProvider provider, String providerUserId);
}
