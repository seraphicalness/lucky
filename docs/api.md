# 하루기운 API 정의

## 인증

### `POST /api/v1/auth/social/login`
- 설명: Apple 로그인 및 회원가입
- 요청
```json
{
  "providerUserId": "apple-user-123",
  "nickname": "하루",
  "birthDate": "1995-05-12",
  "birthTime": "09:30:00",
  "gender": "MALE",
  "birthCalendarType": "SOLAR",
  "birthIsLeapMonth": false
}
```
- 응답
```json
{
  "userId": 1,
  "token": "<jwt>"
}
```

## 프로필
### `GET /api/v1/profile`
- 헤더: `Authorization: Bearer <jwt>`
- 응답: 사용자 프로필 정보

### `PUT /api/v1/profile`
- 헤더: `Authorization: Bearer <jwt>`
- 요청
```json
{
  "nickname": "닉네임",
  "birthDate": "1995-05-12",
  "birthTime": "09:30:00"
}
```

## 운세

### `GET /api/v1/fortune/today/widget`
- 헤더: `Authorization: Bearer <jwt>`
- 설명: 위젯용 요약 운세

### `GET /api/v1/fortune/today`
- 헤더: `Authorization: Bearer <jwt>`
- 설명: 상세 운세(총점 + 5개 카테고리 + 텍스트)

## 친구
### `POST /api/v1/friends/request`
- 요청: `{"toUserId": 123}`

### `POST /api/v1/friends/request/respond`
- 요청: `{"requestId": 1, "action": "ACCEPTED"}`
