package com.harugiwun.api;

import com.harugiwun.dto.FriendDtos;
import com.harugiwun.service.FriendService;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/friends")
public class FriendController {

    private final FriendService friendService;

    public FriendController(FriendService friendService) {
        this.friendService = friendService;
    }

    // 친구 신청
    @PostMapping("/request")
    public FriendDtos.FriendRequestResponse sendRequest(
        @AuthenticationPrincipal Long userId,
        @RequestBody FriendDtos.FriendRequestSendRequest body
    ) {
        return friendService.sendRequest(userId, body.toUserId());
    }

    // 친구 신청 수락/거절
    @PostMapping("/request/respond")
    public FriendDtos.FriendRequestResponse respond(
        @AuthenticationPrincipal Long userId,
        @RequestBody FriendDtos.FriendRequestActionRequest body
    ) {
        return friendService.respondToRequest(userId, body.requestId(), body.action());
    }

    // 내 친구 목록
    @GetMapping
    public FriendDtos.FriendListResponse getFriends(
        @AuthenticationPrincipal Long userId
    ) {
        return friendService.getFriends(userId);
    }

    // 받은 친구 신청 목록 (PENDING)
    @GetMapping("/requests/pending")
    public FriendDtos.PendingRequestListResponse getPendingRequests(
        @AuthenticationPrincipal Long userId
    ) {
        return friendService.getPendingRequests(userId);
    }
}
