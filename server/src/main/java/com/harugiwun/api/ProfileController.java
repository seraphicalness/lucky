package com.harugiwun.api;

import com.harugiwun.domain.profile.AppUserProfile;
import com.harugiwun.dto.ProfileDtos;
import com.harugiwun.dto.SajuDtos;
import com.harugiwun.repository.AppUserProfileRepository;
import com.harugiwun.service.ProfileService;
import com.harugiwun.service.SajuInfoService;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/v1/profile")
public class ProfileController {

    private final ProfileService profileService;
    private final SajuInfoService sajuInfoService;
    private final AppUserProfileRepository profileRepository;

    public ProfileController(
        ProfileService profileService,
        SajuInfoService sajuInfoService,
        AppUserProfileRepository profileRepository
    ) {
        this.profileService = profileService;
        this.sajuInfoService = sajuInfoService;
        this.profileRepository = profileRepository;
    }

    @GetMapping
    public ProfileDtos.ProfileResponse getProfile(@AuthenticationPrincipal Long userId) {
        return profileService.getProfile(userId);
    }

    @PutMapping
    public ProfileDtos.ProfileResponse updateProfile(
        @AuthenticationPrincipal Long userId,
        @RequestBody ProfileDtos.ProfileUpdateRequest request
    ) {
        return profileService.updateProfile(userId, request);
    }

    @GetMapping("/saju")
    public SajuDtos.SajuResponse getSaju(@AuthenticationPrincipal Long userId) {
        AppUserProfile profile = profileRepository.findByUserId(userId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "프로필이 없습니다. 먼저 생년월일을 등록해주세요."));
        return sajuInfoService.getSaju(profile);
    }
}
