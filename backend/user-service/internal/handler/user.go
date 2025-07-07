package handler

import (
	"net/http"
	"time"

	"github.com/ffabious/healthy-summer/user-service/internal/model"
	"github.com/gin-gonic/gin"
)

// @Summary User Login
// @Description Authenticate user
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

	resp := model.LoginResponse{
		Token: "dummy-token",
		User: model.User{
			ID:        "12345",
			Email:     req.Email,
			FirstName: "John",
			LastName:  "Doe",
		},
		ExpiresAt: time.Now().Add(24 * time.Hour),
	}

	c.JSON(http.StatusOK, resp)
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
