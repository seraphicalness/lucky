package com.harugiwun.service.fortune;

import java.util.EnumMap;
import org.springframework.stereotype.Component;

@Component
public class FortuneScoringWeights {

    public static class CategoryWeights {
        private final int wealthWeight;
        private final int resourceWeight;
        private final int officerWeight;
        private final int outputWeight;
        private final int peerWeight;

        public CategoryWeights(int wealthWeight, int resourceWeight, int officerWeight, int outputWeight, int peerWeight) {
            this.wealthWeight = wealthWeight;
            this.resourceWeight = resourceWeight;
            this.officerWeight = officerWeight;
            this.outputWeight = outputWeight;
            this.peerWeight = peerWeight;
        }

        public int wealthWeight() {
            return wealthWeight;
        }

        public int resourceWeight() {
            return resourceWeight;
        }

        public int officerWeight() {
            return officerWeight;
        }

        public int outputWeight() {
            return outputWeight;
        }

        public int peerWeight() {
            return peerWeight;
        }
    }

    private final EnumMap<FortuneCategory, CategoryWeights> categoryWeights = new EnumMap<>(FortuneCategory.class);

    // 월령·합충 보정 등에 공통으로 사용할 수 있는 기본값
    private final int baseScore = 55;
    private final int clashPenalty = 5;
    private final int harmonyBonus = 5;

    public FortuneScoringWeights() {
        // 기존 감각값을 기본값으로 옮김
        categoryWeights.put(
            FortuneCategory.MONEY,
            new CategoryWeights(
                9,  // wealth
                2,  // resource
                -6, // officer (패널티)
                0,
                0
            )
        );
        categoryWeights.put(
            FortuneCategory.LOVE,
            new CategoryWeights(
                5,  // wealth는 성별에 따라 spouseStar가 되므로 여기서는 0
                2,  // resource
                5,  // officer는 spouseStar 쪽에서 처리
                -2, // output 패널티
                0
            )
        );
        categoryWeights.put(
            FortuneCategory.WORK,
            new CategoryWeights(
                -2, // wealth 패널티
                3,  // resource
                9,  // officer
                0,
                0
            )
        );
        categoryWeights.put(
            FortuneCategory.SOCIAL,
            new CategoryWeights(
                0,
                0,
                -2, // officer 패널티
                4,  // output
                6   // peer
            )
        );
        categoryWeights.put(
            FortuneCategory.HEALTH,
            new CategoryWeights(
                0,
                0,
                0,
                0,
                0
            )
        );
    }

    public CategoryWeights getCategoryWeights(FortuneCategory category) {
        return categoryWeights.get(category);
    }

    public int baseScore() {
        return baseScore;
    }

    public int clashPenalty() {
        return clashPenalty;
    }

    public int harmonyBonus() {
        return harmonyBonus;
    }
}


