package handler

import (
	"net/http"

	"github.com/ffabious/healthy-summer/social-service/internal/auth"
	"github.com/ffabious/healthy-summer/social-service/internal/db"
	"github.com/ffabious/healthy-summer/social-service/internal/model"
	"github.com/gin-gonic/gin"
)

// @Summary GetFeed
// @Description Get the activity feed for the current user
// @Tags Feed
// @Security BearerAuth
// @Produce json
// @Success 200 {object} model.Feed
// @Router /api/feed [get]
func GetFeed(c *gin.Context) {
	userID, err := auth.ExtractUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Fetch list of friends
	var friends []model.Friend
	friends, err = db.GetFriends(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch friends"})
		return
	}

	// Fetch activities from friends
	var feed model.Feed
	feed, err = db.GetFeedByFriends(userID, friends)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch feed"})
		return
	}

	c.JSON(http.StatusOK, feed)
}
