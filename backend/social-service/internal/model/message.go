package model

import (
	"time"

	"github.com/google/uuid"
)

// User model for external references (this should ideally come from user-service)
type User struct {
	ID        uuid.UUID `json:"id" gorm:"type:uuid;default:uuid_generate_v4();primaryKey"`
	Email     string    `json:"email" gorm:"type:varchar(100);uniqueIndex;not null"`
	FirstName string    `json:"first_name" gorm:"type:varchar(50);not null"`
	LastName  string    `json:"last_name" gorm:"type:varchar(50);not null"`
	CreatedAt time.Time `json:"created_at" gorm:"not null"`
	UpdatedAt time.Time `json:"updated_at" gorm:"not null"`
}

type Message struct {
	ID          uuid.UUID `json:"id" gorm:"type:uuid;default:uuid_generate_v4();primaryKey"`
	SenderID    uuid.UUID `json:"sender_id" gorm:"type:uuid;not null;index"`
	ReceiverID  uuid.UUID `json:"receiver_id" gorm:"type:uuid;not null;index"`
	Content     string    `json:"content" gorm:"type:text;not null"`
	MessageType string    `json:"message_type" gorm:"type:varchar(20);default:'text';not null"` // text, image, etc.
	IsRead      bool      `json:"is_read" gorm:"default:false;not null"`
	CreatedAt   time.Time `json:"created_at" gorm:"not null"`
	UpdatedAt   time.Time `json:"updated_at" gorm:"not null"`
}

type Conversation struct {
	ID           uuid.UUID `json:"id" gorm:"type:uuid;default:uuid_generate_v4();primaryKey"`
	User1ID      uuid.UUID `json:"user1_id" gorm:"type:uuid;not null;index"`
	User2ID      uuid.UUID `json:"user2_id" gorm:"type:uuid;not null;index"`
	LastMessage  *Message  `json:"last_message,omitempty" gorm:"foreignKey:ID;references:LastMessageID"`
	LastMessageID *uuid.UUID `json:"last_message_id" gorm:"type:uuid"`
	CreatedAt    time.Time `json:"created_at" gorm:"not null"`
	UpdatedAt    time.Time `json:"updated_at" gorm:"not null"`
}

type Friend struct {
	ID         uuid.UUID `json:"id" gorm:"type:uuid;default:uuid_generate_v4();primaryKey"`
	UserID     uuid.UUID `json:"user_id" gorm:"type:uuid;not null;index"`
	FriendID   uuid.UUID `json:"friend_id" gorm:"type:uuid;not null;index"`
	Status     string    `json:"status" gorm:"type:varchar(20);default:'pending';not null"` // pending, accepted, blocked
	CreatedAt  time.Time `json:"created_at" gorm:"not null"`
	UpdatedAt  time.Time `json:"updated_at" gorm:"not null"`
}

// Request/Response models
type SendMessageRequest struct {
	ReceiverID  uuid.UUID `json:"receiver_id" binding:"required"`
	Content     string    `json:"content" binding:"required"`
	MessageType string    `json:"message_type,omitempty"`
}

type SendMessageResponse struct {
	Message Message `json:"message"`
}

type GetMessagesRequest struct {
	FriendID uuid.UUID `json:"friend_id" binding:"required"`
	Limit    int       `json:"limit,omitempty"`
	Offset   int       `json:"offset,omitempty"`
}

type GetMessagesResponse struct {
	Messages []Message `json:"messages"`
	Total    int64     `json:"total"`
}

type GetConversationsResponse struct {
	Conversations []ConversationWithUser `json:"conversations"`
}

type ConversationWithUser struct {
	Conversation
	FriendName  string `json:"friend_name"`
	FriendEmail string `json:"friend_email"`
}

type FriendRequest struct {
	FriendEmail string `json:"friend_email" binding:"required,email"`
}

type FriendResponse struct {
	Friend Friend `json:"friend"`
}

type GetFriendsResponse struct {
	Friends []FriendWithUser `json:"friends"`
}

type FriendWithUser struct {
	Friend
	FriendName  string `json:"friend_name"`
	FriendEmail string `json:"friend_email"`
}

type MarkAsReadRequest struct {
	MessageIDs []uuid.UUID `json:"message_ids" binding:"required"`
}
