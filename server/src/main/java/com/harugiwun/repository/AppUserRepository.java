package com.harugiwun.repository;

import com.harugiwun.domain.user.AppUser;
import java.time.LocalDateTime;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AppUserRepository extends JpaRepository<AppUser, Long> {

    List<AppUser> findAllByLastActiveAtAfter(LocalDateTime since);
}
