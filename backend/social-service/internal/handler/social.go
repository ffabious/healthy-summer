package handler

import (
	"net/http"
	"strconv"
	"time"

	"github.com/ffabious/healthy-summer/social-service/internal/auth"
	"github.com/ffabious/healthy-summer/social-service/internal/db"
	"github.com/ffabious/healthy-summer/social-service/internal/model"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// SendMessage handles HTTP POST requests to send a message
func SendMessage(c *gin.Context) {
	var req model.SendMessageRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data", "details": err.Error()})
		return
	}

	senderID, err := auth.GetUserIDFromContext(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid user context"})
		return
	}

	// Create message
	message := &model.Message{
		SenderID:    senderID,
		ReceiverID:  req.ReceiverID,
		Content:     req.Content,
		MessageType: req.MessageType,
		IsRead:      false,
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}

	if message.MessageType == "" {
		message.MessageType = "text"
	}

	// Save to database
	if err := db.CreateMessage(message); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save message", "details": err.Error()})
		return
	}

	// Update conversation
	conversation, err := db.GetOrCreateConversation(senderID, req.ReceiverID)
	if err == nil {
		db.UpdateConversationLastMessage(conversation.ID, message.ID)
	}

	c.JSON(http.StatusCreated, model.SendMessageResponse{Message: *message})
}

// GetMessages handles HTTP GET requests to retrieve messages
func GetMessages(c *gin.Context) {
	userID, err := auth.GetUserIDFromContext(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid user context"})
		return
	}

	friendIDStr := c.Param("friendId")
	friendID, err := uuid.Parse(friendIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid friend ID"})
		return
	}

	// Parse query parameters
	limitStr := c.DefaultQuery("limit", "50")
	offsetStr := c.DefaultQuery("offset", "0")

	limit, err := strconv.Atoi(limitStr)
	if err != nil {
		limit = 50
	}

	offset, err := strconv.Atoi(offsetStr)
	if err != nil {
		offset = 0
	}

	// Get messages
	messages, err := db.GetMessagesByConversation(userID, friendID, limit, offset)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve messages", "details": err.Error()})
		return
	}

	// Get total count
	total, err := db.GetMessageCountByConversation(userID, friendID)
	if err != nil {
		total = 0
	}

	c.JSON(http.StatusOK, model.GetMessagesResponse{
		Messages: messages,
		Total:    total,
	})
}

// GetConversations handles HTTP GET requests to retrieve user's conversations
func GetConversations(c *gin.Context) {
	userID, err := auth.GetUserIDFromContext(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid user context"})
		return
	}

	conversations, err := db.GetConversationsByUser(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve conversations", "details": err.Error()})
		return
	}

	c.JSON(http.StatusOK, model.GetConversationsResponse{Conversations: conversations})
}

// SendFriendRequest handles HTTP POST requests to send a friend request
func SendFriendRequest(c *gin.Context) {
	var req model.FriendRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data", "details": err.Error()})
		return
	}

	userID, err := auth.GetUserIDFromContext(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid user context"})
		return
	}

	// Find user by email
	friend, err := db.GetUserByEmail(req.FriendEmail)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "User not found"})
		return
	}

	// Create friend request
	friendRequest, err := db.CreateFriendRequest(userID, friend.ID)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Failed to send friend request", "details": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, model.FriendResponse{Friend: *friendRequest})
}

// AcceptFriendRequest handles HTTP PUT requests to accept a friend request
func AcceptFriendRequest(c *gin.Context) {
	userID, err := auth.GetUserIDFromContext(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid user context"})
		return
	}

	friendIDStr := c.Param("friendId")
	friendID, err := uuid.Parse(friendIDStr)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid friend ID"})
		return
	}

	if err := db.AcceptFriendRequest(friendID, userID); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Failed to accept friend request", "details": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Friend request accepted"})
}

// GetFriends handles HTTP GET requests to retrieve user's friends
func GetFriends(c *gin.Context) {
	userID, err := auth.GetUserIDFromContext(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid user context"})
		return
	}

	friends, err := db.GetFriendsByUser(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve friends", "details": err.Error()})
		return
	}

	c.JSON(http.StatusOK, model.GetFriendsResponse{Friends: friends})
}

// MarkAsRead handles HTTP PUT requests to mark messages as read
func MarkAsRead(c *gin.Context) {
	var req model.MarkAsReadRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data", "details": err.Error()})
		return
	}

	userID, err := auth.GetUserIDFromContext(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid user context"})
		return
	}

	if err := db.MarkMessagesAsRead(req.MessageIDs, userID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to mark messages as read", "details": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Messages marked as read"})
}

// @Summary GetFeed
// @Description Get user's activity feed
// @Tags Feed
// @Accept json
// @Produce json
// @Success 200 {object} model.GetFeedResponse
// @Router /api/feed [get]
// @Security BearerAuth
func GetFeed(c *gin.Context) {
	userID, err := auth.GetUserIDFromContext(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid user context"})
		return
	}

	feedItems, err := db.GetFriendsActivityFeed(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch feed", "details": err.Error()})
		return
	}

	response := model.GetFeedResponse{
		FeedItems: feedItems,
	}

	c.JSON(http.StatusOK, response)
}

// Legacy handlers for compatibility
func SocialsHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Social service is running"))
}

func SocialHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Social handler"))
}
