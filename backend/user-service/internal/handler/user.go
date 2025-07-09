package handler

import (
	"net/http"
	"time"

	"github.com/ffabious/healthy-summer/user-service/internal/auth"
	"github.com/ffabious/healthy-summer/user-service/internal/model"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// @Summary User Login
// @Description Login a user and return a JWT token
// @Tags auth
// @Accept json
// @Produce json
// @Param loginRequest body model.LoginRequest true "Login Request"
// @Success 200 {object} model.LoginResponse
// @Router /api/users/login [post]
func LoginHandler(c *gin.Context) {
	var req model.LoginRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Simulate user authentication
	if req.Email != "" && req.Password != "" {
		// Generate a dummy JWT token for the user
		token, err := auth.GenerateJWT(uuid.UUID{}) // Replace with actual user ID from database
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token"})
			return
		}

		resp := model.LoginResponse{
			Token:     token,
			TokenType: "Bearer",
			ExpiresAt: time.Now().Add(24 * time.Hour),
			User: model.User{
				ID:        "12345",
				Email:     req.Email,
				FirstName: "John",
				LastName:  "Doe",
			},
		}

		c.JSON(http.StatusOK, resp)
	} else {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid email or password"})
	}
}

// @Summary User Registration
// @Description Register a new user
// @Tags auth
// @Accept json
// @Produce json
// @Param registerRequest body model.RegisterRequest true "Register Request"
// @Success 201 {object} model.RegisterResponse
// @Router /api/users/register [post]
func RegisterHandler(c *gin.Context) {
	var req model.RegisterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	resp := model.RegisterResponse{
		Token: "dummy-token",
		User: model.User{
			ID:        "12345",
			Email:     req.Email,
			FirstName: req.FirstName,
			LastName:  req.LastName,
		},
		ExpiresAt: time.Now().Add(24 * time.Hour),
	}

	c.JSON(http.StatusCreated, resp)
}
