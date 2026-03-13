package com.harugiwun.service;

import com.harugiwun.domain.friend.Friend;
import com.harugiwun.domain.friend.FriendRequest;
import com.harugiwun.domain.friend.FriendRequestStatus;
import com.harugiwun.domain.user.AppUser;
import com.harugiwun.dto.FriendDtos;
import com.harugiwun.repository.AppUserRepository;
import com.harugiwun.repository.FriendRepository;
import com.harugiwun.repository.FriendRequestRepository;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class FriendService {

    private final FriendRequestRepository friendRequestRepository;
    private final FriendRepository friendRepository;
    private final AppUserRepository appUserRepository;

    public FriendService(
        FriendRequestRepository friendRequestRepository,
        FriendRepository friendRepository,
        AppUserRepository appUserRepository
    ) {
        this.friendRequestRepository = friendRequestRepository;
        this.friendRepository = friendRepository;
        this.appUserRepository = appUserRepository;
    }

    @Transactional
    public FriendDtos.FriendRequestResponse sendRequest(Long fromUserId, Long toUserId) {
        if (fromUserId.equals(toUserId)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "자기 자신에게 친구 신청을 할 수 없습니다");
        }

        AppUser fromUser = findUser(fromUserId);
        AppUser toUser = findUser(toUserId);

        if (friendRepository.existsByUserIdAndFriendUserId(fromUserId, toUserId)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "이미 친구 관계입니다");
        }

        if (friendRequestRepository.existsByFromUserIdAndToUserIdAndStatus(fromUserId, toUserId, FriendRequestStatus.PENDING)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "이미 친구 신청을 보냈습니다");
        }

        if (friendRequestRepository.existsByFromUserIdAndToUserIdAndStatus(toUserId, fromUserId, FriendRequestStatus.PENDING)) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "상대방이 이미 친구 신청을 보냈습니다. 받은 요청을 확인해주세요.");
        }

        FriendRequest request = new FriendRequest();
        request.setFromUser(fromUser);
        request.setToUser(toUser);
        FriendRequest saved = friendRequestRepository.save(request);

        return toRequestResponse(saved);
    }

    @Transactional
    @SuppressWarnings("null")
    public FriendDtos.FriendRequestResponse respondToRequest(Long userId, Long requestId, FriendRequestStatus action) {
        if (action != FriendRequestStatus.ACCEPTED && action != FriendRequestStatus.REJECTED) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "action은 ACCEPTED 또는 REJECTED만 가능합니다");
        }

        FriendRequest request = friendRequestRepository.findById(requestId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "친구 신청을 찾을 수 없습니다"));

        @SuppressWarnings("null")
        Long toUserId = request.getToUser().getId();
        if (!toUserId.equals(userId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "해당 친구 신청에 대한 권한이 없습니다");
        }

        if (request.getStatus() != FriendRequestStatus.PENDING) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "이미 처리된 친구 신청입니다");
        }

        request.setStatus(action);

        if (action == FriendRequestStatus.ACCEPTED) {
            saveFriendPair(request.getFromUser(), request.getToUser());
        }

        return toRequestResponse(request);
    }

    @Transactional(readOnly = true)
    public FriendDtos.FriendListResponse getFriends(Long userId) {
        List<FriendDtos.FriendResponse> list = friendRepository.findByUserId(userId).stream()
            .map(f -> new FriendDtos.FriendResponse(
                f.getFriendUser().getId(),
                f.getFriendUser().getNickname(),
                f.getCreatedAt(),
                f.getFriendUser().getLastActiveAt()
            ))
            .toList();
        return new FriendDtos.FriendListResponse(list);
    }

    @Transactional
    public FriendDtos.NudgeResponse nudgeFriend(Long fromUserId, Long toUserId) {
        if (!areFriends(fromUserId, toUserId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "친구가 아닙니다");
        }
        
        AppUser fromUser = findUser(fromUserId);
        AppUser toUser = findUser(toUserId);
        
        // TODO: 실제 Push 알림 발송 로직 (FCM/APNs)
        System.out.println("Nudge from " + fromUser.getNickname() + " to " + toUser.getNickname());
        
        return new FriendDtos.NudgeResponse(true, toUser.getNickname() + "님을 콕 찔렀습니다!");
    }

    @Transactional(readOnly = true)
    public FriendDtos.PendingRequestListResponse getPendingRequests(Long userId) {
        List<FriendDtos.FriendRequestResponse> list =
            friendRequestRepository.findByToUserIdAndStatus(userId, FriendRequestStatus.PENDING).stream()
                .map(this::toRequestResponse)
                .toList();
        return new FriendDtos.PendingRequestListResponse(list);
    }

    public boolean areFriends(Long userId, Long targetUserId) {
        return friendRepository.existsByUserIdAndFriendUserId(userId, targetUserId);
    }

    private void saveFriendPair(AppUser a, AppUser b) {
        Friend ab = new Friend();
        ab.setUser(a);
        ab.setFriendUser(b);
        friendRepository.save(ab);

        Friend ba = new Friend();
        ba.setUser(b);
        ba.setFriendUser(a);
        friendRepository.save(ba);
    }

    @SuppressWarnings("null")
    private AppUser findUser(Long userId) {
        return appUserRepository.findById(userId)
            .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "유저를 찾을 수 없습니다: " + userId));
    }

    @SuppressWarnings("null")
    private FriendDtos.FriendRequestResponse toRequestResponse(FriendRequest r) {
        return new FriendDtos.FriendRequestResponse(
            r.getId(),
            r.getFromUser().getId(),
            r.getFromUser().getNickname(),
            r.getToUser().getId(),
            r.getToUser().getNickname(),
            r.getStatus(),
            r.getCreatedAt()
        );
    }
}
