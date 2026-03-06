package com.harugiwun.service;

import com.harugiwun.config.JwtUtil;
import com.harugiwun.domain.profile.AppUserProfile;
import com.harugiwun.domain.profile.BirthCalendarType;
import com.harugiwun.domain.profile.Gender;
import com.harugiwun.domain.user.AppUser;
import com.harugiwun.domain.user.AppUserAuth;
import com.harugiwun.domain.user.AuthProvider;
import com.harugiwun.dto.AuthDtos;
import com.harugiwun.repository.AppUserAuthRepository;
import com.harugiwun.repository.AppUserProfileRepository;
import com.harugiwun.repository.AppUserRepository;
import java.time.LocalDateTime;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private final AppUserRepository appUserRepository;
    private final AppUserAuthRepository appUserAuthRepository;
    private final AppUserProfileRepository appUserProfileRepository;
    private final JwtUtil jwtUtil;

    public AuthService(
        AppUserRepository appUserRepository,
        AppUserAuthRepository appUserAuthRepository,
        AppUserProfileRepository appUserProfileRepository,
        JwtUtil jwtUtil
    ) {
        this.appUserRepository = appUserRepository;
        this.appUserAuthRepository = appUserAuthRepository;
        this.appUserProfileRepository = appUserProfileRepository;
        this.jwtUtil = jwtUtil;
    }

    @Transactional
    public AuthDtos.SocialLoginResponse mockAppleLogin(AuthDtos.SocialLoginRequest request) {
        if (request.providerUserId() == null || request.providerUserId().isBlank()) {
            throw new IllegalArgumentException("providerUserId is required");
        }

        AppUser user = appUserAuthRepository
            .findByProviderAndProviderUserId(AuthProvider.APPLE, request.providerUserId())
            .map(AppUserAuth::getUser)
            .orElseGet(() -> createUserWithAuth(request));

        if (request.birthDate() != null) {
            AppUserProfile profile = appUserProfileRepository.findByUserId(user.getId()).orElseGet(() -> {
                AppUserProfile p = new AppUserProfile();
                p.setUser(user);
                return p;
            });
            profile.setBirthDate(request.birthDate());
            profile.setBirthTime(request.birthTime());
            if (request.birthCalendarType() != null) {
                profile.setBirthCalendarType(request.birthCalendarType());
            } else if (profile.getBirthCalendarType() == null) {
                profile.setBirthCalendarType(BirthCalendarType.SOLAR);
            }
            if (request.birthIsLeapMonth() != null) {
                profile.setBirthIsLeapMonth(request.birthIsLeapMonth());
            } else if (profile.getBirthIsLeapMonth() == null) {
                profile.setBirthIsLeapMonth(Boolean.FALSE);
            }
            if (request.gender() != null) {
                profile.setGender(request.gender());
            } else if (profile.getGender() == null) {
                profile.setGender(Gender.UNKNOWN);
            }
            appUserProfileRepository.save(profile);
        }

        user.setLastActiveAt(LocalDateTime.now());
        appUserRepository.save(user);

        String token = jwtUtil.createToken(user.getId());
        return new AuthDtos.SocialLoginResponse(user.getId(), token);
    }

    private AppUser createUserWithAuth(AuthDtos.SocialLoginRequest request) {
        AppUser user = new AppUser();
        user.setNickname(request.nickname() == null || request.nickname().isBlank() ? "?섎（湲곗슫?좎?" : request.nickname());
        AppUser savedUser = appUserRepository.save(user);

        AppUserAuth auth = new AppUserAuth();
        auth.setUser(savedUser);
        auth.setProvider(AuthProvider.APPLE);
        auth.setProviderUserId(request.providerUserId());
        appUserAuthRepository.save(auth);

        return savedUser;
    }
}
