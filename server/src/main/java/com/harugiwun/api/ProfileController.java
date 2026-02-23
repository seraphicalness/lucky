package com.harugiwun.api;

import com.harugiwun.config.JwtUtil;
import com.harugiwun.dto.ProfileDtos;
import com.harugiwun.service.ProfileService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/profile")
public class ProfileController {

    private final ProfileService profileService;
    private final JwtUtil jwtUtil;

    public ProfileController(ProfileService profileService, JwtUtil jwtUtil) {
        this.profileService = profileService;
        this.jwtUtil = jwtUtil;
    }

    @GetMapping
    public ProfileDtos.ProfileResponse getProfile(@RequestHeader("Authorization") String authHeader) {
        Long userId = jwtUtil.resolveUserId(authHeader);
        return profileService.getProfile(userId);
    }

    @PutMapping
    public ProfileDtos.ProfileResponse updateProfile(
        @RequestHeader("Authorization") String authHeader,
        @RequestBody ProfileDtos.ProfileUpdateRequest request
    ) {
        Long userId = jwtUtil.resolveUserId(authHeader);
        return profileService.updateProfile(userId, request);
    }
}
