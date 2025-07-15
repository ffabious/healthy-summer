package handler

import (
	"net/http"
	"time"

	"github.com/ffabious/healthy-summer/activity-service/internal/auth"
	"github.com/ffabious/healthy-summer/activity-service/internal/db"
	"github.com/ffabious/healthy-summer/activity-service/internal/model"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// @Summary Post Activity
// @Description Create a new activity entry
// @Tags activities
// @Accept json
// @Produce json
// @Param activity body model.PostActivityRequest true "Activity data"
// @Success 201 {object} model.Activity
// @Router /api/activities [post]
// @Security BearerAuth
func PostActivityHandler(c *gin.Context) {
	user_id, err := auth.ExtractUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized", "details": err.Error()})
		return
	}
	var req model.PostActivityRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data", "details": err.Error()})
		return
	}
	activity := model.Activity{
		ID:          uuid.New(),
		UserID:      uuid.MustParse(user_id),
		Type:        req.Type,
		DurationMin: req.DurationMin,
		Intensity:   req.Intensity,
		Calories:    req.Calories,
		Location:    req.Location,
		Timestamp:   time.Now(),
	}

	if err := db.CreateActivity(&activity); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create activity", "details": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, activity)
}

// @Summary Get Activities
// @Description Get all activities for a user
// @Tags activities
// @Produce json
// @Success 200 {array} model.Activity
// @Router /api/activities [get]
// @Security BearerAuth
func GetActivitiesHandler(c *gin.Context) {
	user_id, err := auth.ExtractUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized", "details": err.Error()})
		return
	}

	activities, err := db.GetActivitiesByUserID(user_id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Activities not found", "details": err.Error()})
		return
	}

	c.JSON(http.StatusOK, activities)
}

// @Summary Get Activity Stats
// @Description Get activity stats for a user
// @Tags activities
// @Produce json
// @Param user_id path string true "User ID"
// @Success 200 {object} model.ActivityStats
// @Router /api/activities/stats/{user_id} [get]
func GetActivityStatsHandler(c *gin.Context) {
	user_id := c.Param("user_id")
	stats, err := db.GetActivityStatsByUserID(user_id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Activity stats not found"})
		return
	}

	c.JSON(http.StatusOK, stats)
}

// @Summary Post Step Entry
// @Description Create a new step entry
// @Tags activities
// @Accept json
// @Produce json
// @Param step_entry body model.PostStepEntryRequest true "Step entry data"
// @Success 201 {object} model.StepEntry
// @Router /api/activities/steps [post]
// @Security BearerAuth
func PostStepEntryHandler(c *gin.Context) {
	user_id, err := auth.ExtractUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized", "details": err.Error()})
		return
	}
	var req model.PostStepEntryRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data", "details": err.Error()})
		return
	}
	stepEntry := model.StepEntry{
		ID:     uuid.New(),
		UserID: uuid.MustParse(user_id),
		Date:   req.Date,
		Steps:  req.Steps,
	}

	if err := db.CreateStepEntry(&stepEntry); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create step entry", "details": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, stepEntry)
}

// @Summary Get Activity Analytics
// @Description Get activity analytics for a user
// @Tags activities
// @Produce json
// @Param user_id path string true "User ID"
// @Success 200 {object} model.GetActivityAnalyticsResponse
// @Router /api/activities/analytics/{user_id} [get]
// GetActivityAnalyticsHandler retrieves activity analytics for a user
func GetActivityAnalyticsHandler(c *gin.Context) {
	user_id := c.Param("user_id")
	analytics, err := db.GetActivityAnalyticsByUserID(user_id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Activity analytics not found"})
		return
	}

	c.JSON(http.StatusOK, analytics)
}

// @Summary Update Activity
// @Description Update an existing activity entry
// @Tags activities
// @Accept json
// @Produce json
// @Param id path string true "Activity ID"
// @Param activity body model.UpdateActivityRequest true "Updated activity data"
// @Success 200 {object} model.Activity
// @Router /api/activities/{id} [put]
// @Security BearerAuth
func UpdateActivityHandler(c *gin.Context) {
	user_id, err := auth.ExtractUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized", "details": err.Error()})
		return
	}

	activityID := c.Param("id")
	if activityID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Activity ID is required"})
		return
	}

	var req model.UpdateActivityRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data", "details": err.Error()})
		return
	}

	// Verify the activity belongs to the authenticated user
	existingActivity, err := db.GetActivityByID(activityID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Activity not found", "details": err.Error()})
		return
	}

	if existingActivity.UserID.String() != user_id {
		c.JSON(http.StatusForbidden, gin.H{"error": "You can only update your own activities"})
		return
	}

	// Update the activity
	activity := model.Activity{
		ID:          existingActivity.ID,
		UserID:      existingActivity.UserID,
		Type:        req.Type,
		DurationMin: req.DurationMin,
		Intensity:   req.Intensity,
		Calories:    req.Calories,
		Location:    req.Location,
		Timestamp:   existingActivity.Timestamp, // Keep original timestamp
	}

	if err := db.UpdateActivity(&activity); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update activity", "details": err.Error()})
		return
	}

	c.JSON(http.StatusOK, activity)
}

// @Summary Delete Activity
// @Description Delete an existing activity entry
// @Tags activities
// @Param id path string true "Activity ID"
// @Success 204
// @Router /api/activities/{id} [delete]
// @Security BearerAuth
func DeleteActivityHandler(c *gin.Context) {
	user_id, err := auth.ExtractUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized", "details": err.Error()})
		return
	}

	activityID := c.Param("id")
	if activityID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Activity ID is required"})
		return
	}

	// Verify the activity belongs to the authenticated user
	existingActivity, err := db.GetActivityByID(activityID)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Activity not found", "details": err.Error()})
		return
	}

	if existingActivity.UserID.String() != user_id {
		c.JSON(http.StatusForbidden, gin.H{"error": "You can only delete your own activities"})
		return
	}

	if err := db.DeleteActivity(activityID); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete activity", "details": err.Error()})
		return
	}

	c.JSON(http.StatusNoContent, nil)
}
