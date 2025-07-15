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

// @Summary Get User Profile
// @Description Get the profile of the currently authenticated user
// @Tags user
// @Produce json
// @Success 200 {object} model.User
// @Security BearerAuth
// @Router /api/users/profile [get]
func GetProfileHandler(c *gin.Context) {
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

// @Summary Update User Profile
// @Description Update the profile of the currently authenticated user
// @Tags user
// @Accept json
// @Produce json
// @Param updateProfileRequest body model.UpdateProfileRequest true "Update Profile Request"
// @Success 200 {object} model.User
// @Security BearerAuth
// @Router /api/users/profile [put]
func UpdateProfileHandler(c *gin.Context) {
	userID, err := auth.ExtractUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized", "details": err.Error()})
		return
	}

	var req model.UpdateProfileRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data", "details": err.Error()})
		return
	}

	user, err := db.UpdateUserProfile(uuid.MustParse(userID), req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update profile", "details": err.Error()})
		return
	}
	c.JSON(http.StatusOK, user)
}

// @Summary Get Friends
// @Description Get the friends of the currently authenticated user
// @Tags friends
// @Produce json
// @Success 200 {array} model.Friend
// @Security BearerAuth
// @Router /api/users/friends [get]
func GetFriendsHandler(c *gin.Context) {
	userID, err := auth.ExtractUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized", "details": err.Error()})
		return
	}

	friends, err := db.GetFriendsByUserID(uuid.MustParse(userID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve friends", "details": err.Error()})
		return
	}
	c.JSON(http.StatusOK, friends)
}

// @Summary Send Friend Request
// @Description Send a friend request to another user
// @Tags friends
// @Accept json
// @Produce json
// @Param friendRequest body model.SendFriendRequestBody true "Friend Request"
// @Success 201 {object} model.FriendRequest
// @Security BearerAuth
// @Router /api/users/friends/request [post]
func SendFriendRequestHandler(c *gin.Context) {
	userID, err := auth.ExtractUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized", "details": err.Error()})
		return
	}

	var req model.SendFriendRequestBody
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data", "details": err.Error()})
		return
	}

	friendRequest, err := db.SendFriendRequest(uuid.MustParse(userID), req.ReceiverID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to send friend request", "details": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, friendRequest)
}

// @Summary Add Achievement
// @Description Add an achievement for the currently authenticated user
// @Tags achievements
// @Accept json
// @Produce json
// @Param achievementRequest body model.AchievementRequest true "Achievement Request"
// @Success 201 {object} model.Achievement
// @Security BearerAuth
// @Router /api/users/achievements [post]
func AddAchievementHandler(c *gin.Context) {
	userID, err := auth.ExtractUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized", "details": err.Error()})
		return
	}

	var req model.AchievementRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data", "details": err.Error()})
		return
	}

	if req.Name == "" || req.Details == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Achievement name and details are required"})
		return
	}

	achievement := model.Achievement{
		UserID:    uuid.MustParse(userID),
		Name:      req.Name,
		Details:   req.Details,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}
	achieved, err := db.AddAchievement(uuid.MustParse(userID), achievement)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to add achievement", "details": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, achieved)
}

// @Summary Get Pending Friend Requests
// @Description Get all pending friend requests received by the authenticated user
// @Tags friends
// @Produce json
// @Success 200 {array} model.FriendRequestResponse
// @Security BearerAuth
// @Router /api/users/friends/requests [get]
func GetPendingFriendRequestsHandler(c *gin.Context) {
	userID, err := auth.ExtractUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized", "details": err.Error()})
		return
	}

	requests, err := db.GetPendingFriendRequests(uuid.MustParse(userID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve friend requests", "details": err.Error()})
		return
	}
	c.JSON(http.StatusOK, requests)
}

// @Summary Accept or Reject Friend Request
// @Description Accept or reject a friend request
// @Tags friends
// @Accept json
// @Produce json
// @Param request body model.AcceptRejectRequestBody true "Accept/Reject Request"
// @Success 200 {object} model.FriendRequest
// @Security BearerAuth
// @Router /api/users/friends/respond [post]
func RespondToFriendRequestHandler(c *gin.Context) {
	userID, err := auth.ExtractUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized", "details": err.Error()})
		return
	}

	var req model.AcceptRejectRequestBody
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data", "details": err.Error()})
		return
	}

	var request *model.FriendRequest
	if req.Action == "accept" {
		request, err = db.AcceptFriendRequest(req.RequestID, uuid.MustParse(userID))
	} else {
		request, err = db.RejectFriendRequest(req.RequestID, uuid.MustParse(userID))
	}

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to respond to friend request", "details": err.Error()})
		return
	}
	c.JSON(http.StatusOK, request)
}

// @Summary Search Users
// @Description Search for users by email or name
// @Tags users
// @Produce json
// @Param q query string true "Search query"
// @Success 200 {array} model.SearchUsersResponse
// @Security BearerAuth
// @Router /api/users/search [get]
func SearchUsersHandler(c *gin.Context) {
	userID, err := auth.ExtractUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized", "details": err.Error()})
		return
	}

	query := c.Query("q")
	if query == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Search query is required"})
		return
	}

	users, err := db.SearchUsers(query, uuid.MustParse(userID))
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to search users", "details": err.Error()})
		return
	}

	// Convert to response format
	var response []model.SearchUsersResponse
	for _, user := range users {
		response = append(response, model.SearchUsersResponse{
			ID:        user.ID,
			Email:     user.Email,
			FirstName: user.FirstName,
			LastName:  user.LastName,
		})
	}

	c.JSON(http.StatusOK, response)
}
