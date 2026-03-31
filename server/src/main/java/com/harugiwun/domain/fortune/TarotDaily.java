package com.harugiwun.domain.fortune;

import com.harugiwun.domain.user.AppUser;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "tarot_daily", uniqueConstraints = {
    @UniqueConstraint(name = "uk_tarot_user_date", columnNames = {"user_id", "fortuneDate"})
})
@Getter
@Setter
@NoArgsConstructor
public class TarotDaily {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id")
    private AppUser user;

    @Column(nullable = false)
    private LocalDate fortuneDate;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false, length = 1000)
    private String meaning;

    @Column(nullable = false, length = 2000)
    private String description;

    @Column(nullable = false)
    private String imageUrl;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        this.createdAt = LocalDateTime.now();
    }
}
