package model

import (
	"time"

	"github.com/google/uuid"
)

type User struct {
	ID       uuid.UUID `json:"id" gorm:"type:uuid;default:uuid_generate_v4();primaryKey"`
	Email    string    `json:"email" gorm:"type:varchar(100);uniqueIndex;not null"`
	Password string    `json:"-" gorm:"type:varchar(100);not null"`
	FirstName string   `json:"first_name" gorm:"type:varchar(50);not null"`
	LastName  string   `json:"last_name" gorm:"type:varchar(50);not null"`
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
