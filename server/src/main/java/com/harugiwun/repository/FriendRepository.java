package com.harugiwun.repository;

import com.harugiwun.domain.friend.Friend;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface FriendRepository extends JpaRepository<Friend, Long> {

    List<Friend> findByUserId(Long userId);

    boolean existsByUserIdAndFriendUserId(Long userId, Long friendUserId);

    void deleteByUserIdAndFriendUserId(Long userId, Long friendUserId);
}
