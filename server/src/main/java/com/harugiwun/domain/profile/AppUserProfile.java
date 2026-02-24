package com.harugiwun.domain.profile;

import com.harugiwun.domain.user.AppUser;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.PreUpdate;
import jakarta.persistence.Table;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Entity
@Table(name = "app_user_profile")
public class AppUserProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", unique = true)
    private AppUser user;

    @Column(nullable = false)
    private LocalDate birthDate;

    @Column
    private LocalTime birthTime;

    @Enumerated(EnumType.STRING)
    @Column
    private BirthCalendarType birthCalendarType;

    @Column
    private Boolean birthIsLeapMonth;

    @Enumerated(EnumType.STRING)
    @Column
    private Gender gender;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    @PreUpdate
    public void touch() {
        this.updatedAt = LocalDateTime.now();
        if (this.birthCalendarType == null) {
            this.birthCalendarType = BirthCalendarType.SOLAR;
        }
        if (this.birthIsLeapMonth == null) {
            this.birthIsLeapMonth = Boolean.FALSE;
        }
        if (this.gender == null) {
            this.gender = Gender.UNKNOWN;
        }
    }

    public Long getId() { return id; }
    public AppUser getUser() { return user; }
    public void setUser(AppUser user) { this.user = user; }
    public LocalDate getBirthDate() { return birthDate; }
    public void setBirthDate(LocalDate birthDate) { this.birthDate = birthDate; }
    public LocalTime getBirthTime() { return birthTime; }
    public void setBirthTime(LocalTime birthTime) { this.birthTime = birthTime; }
    public BirthCalendarType getBirthCalendarType() { return birthCalendarType; }
    public void setBirthCalendarType(BirthCalendarType birthCalendarType) { this.birthCalendarType = birthCalendarType; }
    public Boolean getBirthIsLeapMonth() { return birthIsLeapMonth; }
    public void setBirthIsLeapMonth(Boolean birthIsLeapMonth) { this.birthIsLeapMonth = birthIsLeapMonth; }
    public Gender getGender() { return gender; }
    public void setGender(Gender gender) { this.gender = gender; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
}
