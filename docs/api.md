# ?섎（湲곗슫 API ?뺤쓽

## ?몄쬆

### `POST /api/v1/auth/social/login`
- ?ㅻ챸: Apple 濡쒓렇??紐?API
- ?붿껌
```json
{
  "providerUserId": "apple-user-123",
  "nickname": "?섎（",
  "birthDate": "1995-05-12",
  "birthTime": "09:30:00"
}
```
- ?묐떟
```json
{
  "userId": 1,
  "token": "<jwt>"
}
```

## ?꾨줈??
### `GET /api/v1/profile`
- ?ㅻ뜑: `Authorization: Bearer <jwt>`
- ?묐떟: ?ъ슜???꾨줈???뺣낫

### `PUT /api/v1/profile`
- ?ㅻ뜑: `Authorization: Bearer <jwt>`
- ?붿껌
```json
{
  "nickname": "?덈땳?ㅼ엫",
  "birthDate": "1995-05-12",
  "birthTime": "09:30:00"
}
```

## ?댁꽭

### `GET /api/v1/fortune/today/widget`
- ?ㅻ뜑: `Authorization: Bearer <jwt>`
- ?ㅻ챸: ?꾩젽???붿빟 ?댁꽭

### `GET /api/v1/fortune/today`
- ?ㅻ뜑: `Authorization: Bearer <jwt>`
- ?ㅻ챸: ?곸꽭 ?댁꽭(珥앹젏 + 5媛?移댄뀒怨좊━ + ?띿뒪??
