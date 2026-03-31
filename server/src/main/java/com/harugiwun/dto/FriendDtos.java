package com.harugiwun.dto;

import com.harugiwun.domain.friend.FriendRequestStatus;
import java.time.LocalDateTime;
import java.util.List;

public class FriendDtos {

    public record FriendRequestSendRequest(Long toUserId) {}

    public record FriendRequestActionRequest(Long requestId, FriendRequestStatus action) {}

    public record FriendRequestResponse(
        Long requestId,
        Long fromUserId,
        String fromUserNickname,
        Long toUserId,
        String toUserNickname,
        FriendRequestStatus status,
        LocalDateTime createdAt
    ) {}

    public record FriendResponse(
        Long friendUserId,
        String nickname,
        LocalDateTime friendSince,
        LocalDateTime lastActiveAt
    ) {}

    public record FriendListResponse(List<FriendResponse> friends) {}

    public record PendingRequestListResponse(List<FriendRequestResponse> requests) {}

    public record NudgeRequest(Long toUserId) {}

    public record NudgeResponse(boolean success, String message) {}
}
