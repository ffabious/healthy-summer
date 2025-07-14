package handler

import (
	"net/http"
	"time"

	"github.com/ffabious/healthy-summer/user-service/internal/auth"
	"github.com/ffabious/healthy-summer/user-service/internal/db"
	"github.com/ffabious/healthy-summer/user-service/internal/model"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
)

func HashPassword(password string) (string, error) {
	hashed, err := bcrypt.GenerateFromPassword([]byte(password), bcrypt.DefaultCost)
	return string(hashed), err
}

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
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data", "details": err.Error()})
		return
	}

	user, err := db.GetUserByEmail(req.Email)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid email or password", "details": err.Error()})
		return
	}
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid email or password", "details": err.Error()})
		return
	}
	token, err := auth.GenerateJWT(user.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token", "details": err.Error()})
		return
	}
	resp := model.LoginResponse{
		User:      *user,
		Token:     token,
		TokenType: "Bearer",
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
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data", "details": err.Error()})
		return
	}
	hashedPassword, err := HashPassword(req.Password)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to hash password", "details": err.Error()})
		return
	}

	user, err := db.PostRegister(model.RegisterRequest{
		Email:     req.Email,
		Password:  hashedPassword,
		FirstName: req.FirstName,
		LastName:  req.LastName,
	})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to register user", "details": err.Error()})
		return
	}
	token, err := auth.GenerateJWT(user.ID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate token", "details": err.Error()})
		return
	}
	resp := model.RegisterResponse{
		User:      *user,
		Token:     token,
		TokenType: "Bearer",
		ExpiresAt: time.Now().Add(24 * time.Hour),
	}
	c.JSON(http.StatusCreated, resp)
}

// @Summary Get Current User
// @Description Get the currently authenticated user
// @Tags user
// @Produce json
// @Success 200 {object} model.User
// @Security BearerAuth
// @Router /api/users/me [get]
func GetCurrentUserHandler(c *gin.Context) {
	userID, err := auth.ExtractUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized", "details": err.Error()})
		return
	}

	user, err := db.GetUserByID(uuid.MustParse(userID))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found", "details": err.Error()})
		return
	}
	c.JSON(http.StatusOK, user)
}
