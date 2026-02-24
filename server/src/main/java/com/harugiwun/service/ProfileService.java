package com.harugiwun.service;

import com.harugiwun.domain.profile.AppUserProfile;
import com.harugiwun.domain.profile.BirthCalendarType;
import com.harugiwun.domain.profile.Gender;
import com.harugiwun.domain.user.AppUser;
import com.harugiwun.dto.ProfileDtos;
import com.harugiwun.repository.AppUserProfileRepository;
import com.harugiwun.repository.AppUserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class ProfileService {

    private final AppUserRepository appUserRepository;
    private final AppUserProfileRepository appUserProfileRepository;

    public ProfileService(AppUserRepository appUserRepository, AppUserProfileRepository appUserProfileRepository) {
        this.appUserRepository = appUserRepository;
        this.appUserProfileRepository = appUserProfileRepository;
    }

    @Transactional(readOnly = true)
    public ProfileDtos.ProfileResponse getProfile(Long userId) {
        AppUser user = getUser(userId);
        AppUserProfile profile = appUserProfileRepository.findByUserId(userId).orElse(null);
        return new ProfileDtos.ProfileResponse(
            user.getId(),
            user.getNickname(),
            profile == null ? null : profile.getBirthDate(),
            profile == null ? null : profile.getBirthTime(),
            profile == null ? null : profile.getBirthCalendarType(),
            profile == null ? null : profile.getBirthIsLeapMonth(),
            profile == null ? null : profile.getGender()
        );
    }

    @Transactional
    public ProfileDtos.ProfileResponse updateProfile(Long userId, ProfileDtos.ProfileUpdateRequest request) {
        AppUser user = getUser(userId);
        if (request.nickname() != null && !request.nickname().isBlank()) {
            user.setNickname(request.nickname());
        }

        AppUserProfile profile = appUserProfileRepository.findByUserId(userId).orElseGet(() -> {
            AppUserProfile p = new AppUserProfile();
            p.setUser(user);
            return p;
        });

        if (request.birthDate() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "birthDate is required");
        }

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

        return new ProfileDtos.ProfileResponse(
            user.getId(),
            user.getNickname(),
            profile.getBirthDate(),
            profile.getBirthTime(),
            profile.getBirthCalendarType(),
            profile.getBirthIsLeapMonth(),
            profile.getGender()
        );
    }

    private AppUser getUser(Long userId) {
        return appUserRepository
            .findById(userId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found"));
    }
}
