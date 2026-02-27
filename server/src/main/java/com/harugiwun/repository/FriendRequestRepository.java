package com.harugiwun.repository;

import com.harugiwun.domain.friend.FriendRequest;
import com.harugiwun.domain.friend.FriendRequestStatus;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FriendRequestRepository extends JpaRepository<FriendRequest, Long> {

    Optional<FriendRequest> findByFromUserIdAndToUserId(Long fromUserId, Long toUserId);

    boolean existsByFromUserIdAndToUserIdAndStatus(Long fromUserId, Long toUserId, FriendRequestStatus status);

    List<FriendRequest> findByToUserIdAndStatus(Long toUserId, FriendRequestStatus status);

    List<FriendRequest> findByFromUserIdAndStatus(Long fromUserId, FriendRequestStatus status);
}
