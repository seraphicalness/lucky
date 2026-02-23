# 아키텍처 개요

## 모노레포 구조
- `server`: Spring Boot 3 + Java 17 + Gradle + PostgreSQL
- `ios`: SwiftUI + WidgetKit
- `docs`: API/DB/구조 문서

## 서버 설계
- `api`: REST 엔드포인트
- `service`: 인증, 프로필, 운세 비즈니스 로직
- `repository`: JPA Repository
- `domain`: 사용자/프로필/운세/친구 엔티티
- `config`: JWT 유틸
- `common`: 템플릿 텍스트 생성기

## 운세 생성 방식 (현재)
- 사용자 생년월일 + 날짜 기반 시드 랜덤
- 일 단위 캐시(`fortune_daily`) 재사용
- 템플릿 문구 생성(LLM 미연동)

## 향후 확장
- Gemini 기반 문구 생성으로 전환
- 친구 비교 API 확장(총점 외 세부 카테고리 옵션)
- Auth filter/security 고도화
