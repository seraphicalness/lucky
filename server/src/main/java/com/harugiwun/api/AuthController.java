package com.harugiwun.api;

import com.harugiwun.dto.AuthDtos;
import com.harugiwun.service.AuthService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/social/login")
    public AuthDtos.SocialLoginResponse socialLogin(@RequestBody AuthDtos.SocialLoginRequest request) {
        return authService.appleLogin(request);
    }
}
