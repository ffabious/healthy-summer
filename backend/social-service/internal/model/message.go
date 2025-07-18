package model

import (
	"time"

	"github.com/google/uuid"
)

type GetFeedResponse struct {
	Feeds []Feed `json:"feeds"`
}

type Feed struct {
	Items []FeedItem `json:"items"`
}

type FeedItem struct {
	ActivityID uuid.UUID `json:"activity_id"`
	FriendID   uuid.UUID `json:"friend_id"`
}

type Friend struct {
	ID        uuid.UUID `json:"id"`
	UserID    uuid.UUID `json:"user_id"`
	FriendID  uuid.UUID `json:"friend_id"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}