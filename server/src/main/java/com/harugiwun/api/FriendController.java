package com.harugiwun.api;

import com.harugiwun.config.JwtUtil;
import com.harugiwun.dto.FriendDtos;
import com.harugiwun.service.FriendService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/friends")
public class FriendController {

    private final FriendService friendService;
    private final JwtUtil jwtUtil;

    public FriendController(FriendService friendService, JwtUtil jwtUtil) {
        this.friendService = friendService;
        this.jwtUtil = jwtUtil;
    }

    // 친구 신청
    @PostMapping("/request")
    public FriendDtos.FriendRequestResponse sendRequest(
        @RequestHeader("Authorization") String authHeader,
        @RequestBody FriendDtos.FriendRequestSendRequest body
    ) {
        Long userId = jwtUtil.resolveUserId(authHeader);
        return friendService.sendRequest(userId, body.toUserId());
    }

    // 친구 신청 수락/거절
    @PostMapping("/request/respond")
    public FriendDtos.FriendRequestResponse respond(
        @RequestHeader("Authorization") String authHeader,
        @RequestBody FriendDtos.FriendRequestActionRequest body
    ) {
        Long userId = jwtUtil.resolveUserId(authHeader);
        return friendService.respondToRequest(userId, body.requestId(), body.action());
    }

    // 내 친구 목록
    @GetMapping
    public FriendDtos.FriendListResponse getFriends(
        @RequestHeader("Authorization") String authHeader
    ) {
        Long userId = jwtUtil.resolveUserId(authHeader);
        return friendService.getFriends(userId);
    }

    // 받은 친구 신청 목록 (PENDING)
    @GetMapping("/requests/pending")
    public FriendDtos.PendingRequestListResponse getPendingRequests(
        @RequestHeader("Authorization") String authHeader
    ) {
        Long userId = jwtUtil.resolveUserId(authHeader);
        return friendService.getPendingRequests(userId);
    }
}
