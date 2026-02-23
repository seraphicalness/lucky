# DB ?ㅽ궎留??붿빟

## `app_user`
- id (PK)
- nickname
- created_at

## `app_user_auth`
- id (PK)
- user_id (FK -> app_user)
- provider (APPLE)
- provider_user_id
- created_at

## `app_user_profile`
- id (PK)
- user_id (FK, UNIQUE)
- birth_date
- birth_time (nullable)
- updated_at

## `fortune_daily`
- id (PK)
- user_id (FK)
- fortune_date
- total_score
- money_score
- love_score
- health_score
- work_score
- social_score
- lucky_color
- lucky_number
- widget_summary
- detail_text
- created_at
- UNIQUE(user_id, fortune_date)

## `friend`
- id (PK)
- user_id (FK)
- friend_user_id (FK)
- created_at
- UNIQUE(user_id, friend_user_id)

## `friend_request`
- id (PK)
- from_user_id (FK)
- to_user_id (FK)
- status (PENDING/ACCEPTED/REJECTED)
- created_at
