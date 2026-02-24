package com.harugiwun.service.fortune;

import com.harugiwun.domain.fortune.FortunePeriod;
import com.harugiwun.domain.profile.AppUserProfile;
import java.time.LocalDate;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class UnseTimelineService {

    /**
     * TODO: 대운 계산 로직
     * - 출생 일시 및 성별, 월령 등을 기반으로 대운 시작 시점과 각 10년 운의 간지/오행을 계산한다.
     */
    public List<FortunePeriod> calculateDaewoon(AppUserProfile profile) {
        // 향후 구현을 위해 시그니처만 정의해 둔다.
        return List.of();
    }

    /**
     * TODO: 세운(연운/세운) 계산 로직
     * - 기준 연도를 받아 해당 연/혹은 몇 년치의 세운 간지/오행을 계산한다.
     */
    public List<FortunePeriod> calculateSewoon(LocalDate baseDate) {
        // 향후 구현을 위해 시그니처만 정의해 둔다.
        return List.of();
    }
}


