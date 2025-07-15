package model

import (
	"time"

	"github.com/google/uuid"
)

type User struct {
	ID        uuid.UUID `json:"id" gorm:"type:uuid;default:uuid_generate_v4();primaryKey"`
	Email     string    `json:"email" gorm:"type:varchar(100);uniqueIndex;not null"`
	Password  string    `json:"-" gorm:"type:varchar(100);not null"`
	FirstName string    `json:"first_name" gorm:"type:varchar(50);not null"`
	LastName  string    `json:"last_name" gorm:"type:varchar(50);not null"`
	CreatedAt time.Time `json:"created_at" gorm:"not null"`
	UpdatedAt time.Time `json:"updated_at" gorm:"not null"`
}

type LoginRequest struct {
	Email    string `json:"email" binding:"required,email" example:"string@mail.com"`
	Password string `json:"password" binding:"required"`
}

type LoginResponse struct {
	User      User      `json:"user"`
	Token     string    `json:"token"`
	TokenType string    `json:"token_type" example:"Bearer"`
	ExpiresAt time.Time `json:"expires_at"`
}

type RegisterRequest struct {
	Email     string `json:"email" binding:"required,email" example:"string@mail.com"`
	Password  string `json:"password" binding:"required"`
	FirstName string `json:"first_name" binding:"required"`
	LastName  string `json:"last_name" binding:"required"`
}

type RegisterResponse struct {
	User      User      `json:"user"`
	Token     string    `json:"token"`
	TokenType string    `json:"token_type" example:"Bearer"`
	ExpiresAt time.Time `json:"expires_at"`
}

type UpdateProfileRequest struct {
	FirstName string `json:"first_name" binding:"required"`
	LastName  string `json:"last_name" binding:"required"`
}

type Friend struct {
	ID        uuid.UUID `json:"id" gorm:"type:uuid;default:uuid_generate_v4();primaryKey"`
	UserID    uuid.UUID `json:"user_id" gorm:"type:uuid;not null"`
	FriendID  uuid.UUID `json:"friend_id" gorm:"type:uuid;not null"`
	CreatedAt time.Time `json:"created_at" gorm:"not null"`
	UpdatedAt time.Time `json:"updated_at" gorm:"not null"`
}

type FriendRequest struct {
	ID         uuid.UUID `json:"id" gorm:"type:uuid;default:uuid_generate_v4();primaryKey"`
	SenderID   uuid.UUID `json:"sender_id" gorm:"type:uuid;not null"`
	ReceiverID uuid.UUID `json:"receiver_id" gorm:"type:uuid;not null"`
	Status     string    `json:"status" gorm:"type:varchar(20);not null;default:'pending'" example:"pending"`
	CreatedAt  time.Time `json:"created_at" gorm:"not null"`
	UpdatedAt  time.Time `json:"updated_at" gorm:"not null"`
}

type Achievement struct {
	ID        uuid.UUID `json:"id" gorm:"type:uuid;default:uuid_generate_v4();primaryKey"`
	UserID    uuid.UUID `json:"user_id" gorm:"type:uuid;not null"`
	Name      string    `json:"name" gorm:"type:varchar(100);not null"`
	Details   string    `json:"details" gorm:"type:varchar(255);not null"`
	CreatedAt time.Time `json:"created_at" gorm:"not null"`
	UpdatedAt time.Time `json:"updated_at" gorm:"not null"`
}

type AchievementRequest struct {
	UserID  uuid.UUID `json:"user_id" binding:"required"`
	Name    string    `json:"name" binding:"required"`
	Details string    `json:"details" binding:"required"`
}

type SendFriendRequestBody struct {
	ReceiverID uuid.UUID `json:"receiver_id" binding:"required"`
}

type FriendRequestResponse struct {
	ID         uuid.UUID `json:"id"`
	SenderID   uuid.UUID `json:"sender_id"`
	ReceiverID uuid.UUID `json:"receiver_id"`
	Status     string    `json:"status"`
	SenderName string    `json:"sender_name,omitempty"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}

type AcceptRejectRequestBody struct {
	RequestID uuid.UUID `json:"request_id" binding:"required"`
	Action    string    `json:"action" binding:"required,oneof=accept reject"`
}

type SearchUsersResponse struct {
	ID        uuid.UUID `json:"id"`
	Email     string    `json:"email"`
	FirstName string    `json:"first_name"`
	LastName  string    `json:"last_name"`
}

type FriendWithDetails struct {
	ID        uuid.UUID `json:"id"`
	UserID    uuid.UUID `json:"user_id"`
	FriendID  uuid.UUID `json:"friend_id"`
	FirstName string    `json:"first_name"`
	LastName  string    `json:"last_name"`
	Email     string    `json:"email"`
	CreatedAt time.Time `json:"created_at"`
}
