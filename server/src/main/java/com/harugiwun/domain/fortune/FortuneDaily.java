package com.harugiwun.domain.fortune;

import com.harugiwun.domain.user.AppUser;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "fortune_daily", uniqueConstraints = {
    @UniqueConstraint(name = "uk_fortune_user_date", columnNames = {"user_id", "fortuneDate"})
})
public class FortuneDaily {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id")
    private AppUser user;

    @Column(nullable = false)
    private LocalDate fortuneDate;

    @Column(nullable = false)
    private int totalScore;

    @Column(nullable = false)
    private int moneyScore;

    @Column(nullable = false)
    private int loveScore;

    @Column(nullable = false)
    private int healthScore;

    @Column(nullable = false)
    private int workScore;

    @Column(nullable = false)
    private int socialScore;

    @Column(nullable = false)
    private String luckyColor;

    @Column(nullable = false)
    private int luckyNumber;

    @Column(nullable = false, length = 200)
    private String widgetSummary;

    @Column(nullable = false, length = 500)
    private String detailText;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @PrePersist
    public void prePersist() {
        this.createdAt = LocalDateTime.now();
    }

    public Long getId() { return id; }
    public AppUser getUser() { return user; }
    public void setUser(AppUser user) { this.user = user; }
    public LocalDate getFortuneDate() { return fortuneDate; }
    public void setFortuneDate(LocalDate fortuneDate) { this.fortuneDate = fortuneDate; }
    public int getTotalScore() { return totalScore; }
    public void setTotalScore(int totalScore) { this.totalScore = totalScore; }
    public int getMoneyScore() { return moneyScore; }
    public void setMoneyScore(int moneyScore) { this.moneyScore = moneyScore; }
    public int getLoveScore() { return loveScore; }
    public void setLoveScore(int loveScore) { this.loveScore = loveScore; }
    public int getHealthScore() { return healthScore; }
    public void setHealthScore(int healthScore) { this.healthScore = healthScore; }
    public int getWorkScore() { return workScore; }
    public void setWorkScore(int workScore) { this.workScore = workScore; }
    public int getSocialScore() { return socialScore; }
    public void setSocialScore(int socialScore) { this.socialScore = socialScore; }
    public String getLuckyColor() { return luckyColor; }
    public void setLuckyColor(String luckyColor) { this.luckyColor = luckyColor; }
    public int getLuckyNumber() { return luckyNumber; }
    public void setLuckyNumber(int luckyNumber) { this.luckyNumber = luckyNumber; }
    public String getWidgetSummary() { return widgetSummary; }
    public void setWidgetSummary(String widgetSummary) { this.widgetSummary = widgetSummary; }
    public String getDetailText() { return detailText; }
    public void setDetailText(String detailText) { this.detailText = detailText; }
    public LocalDateTime getCreatedAt() { return createdAt; }
}
