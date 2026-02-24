package com.harugiwun.domain.fortune;

import java.time.LocalDate;

public class FortunePeriod {

    public enum PeriodType {
        DAEWOON,
        SEWOON
    }

    private final LocalDate startDate;
    private final LocalDate endDate;
    private final String stemBranch; // 간지 표현 (예: 甲子)
    private final String element;    // 오행 표현 (예: 木, 火, 土, 金, 水)
    private final PeriodType type;

    public FortunePeriod(LocalDate startDate, LocalDate endDate, String stemBranch, String element, PeriodType type) {
        this.startDate = startDate;
        this.endDate = endDate;
        this.stemBranch = stemBranch;
        this.element = element;
        this.type = type;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public LocalDate getEndDate() {
        return endDate;
    }

    public String getStemBranch() {
        return stemBranch;
    }

    public String getElement() {
        return element;
    }

    public PeriodType getType() {
        return type;
    }
}


