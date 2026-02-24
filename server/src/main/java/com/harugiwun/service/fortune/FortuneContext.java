package com.harugiwun.service.fortune;

import com.harugiwun.service.fortune.SajuFortuneCalculator.Result;

public class FortuneContext {

    private final Result result;
    private final String dominantElement;
    private final String dayMasterStrength;
    private final boolean strongWealth;
    private final boolean strongOfficer;
    private final boolean hasWealthClashToday;

    public FortuneContext(
        Result result,
        String dominantElement,
        String dayMasterStrength,
        boolean strongWealth,
        boolean strongOfficer,
        boolean hasWealthClashToday
    ) {
        this.result = result;
        this.dominantElement = dominantElement;
        this.dayMasterStrength = dayMasterStrength;
        this.strongWealth = strongWealth;
        this.strongOfficer = strongOfficer;
        this.hasWealthClashToday = hasWealthClashToday;
    }

    public Result result() {
        return result;
    }

    public String dominantElement() {
        return dominantElement;
    }

    public String dayMasterStrength() {
        return dayMasterStrength;
    }

    public boolean strongWealth() {
        return strongWealth;
    }

    public boolean strongOfficer() {
        return strongOfficer;
    }

    public boolean hasWealthClashToday() {
        return hasWealthClashToday;
    }
}


