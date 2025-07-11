package handler

import (
	"net/http"
	"time"

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
func PostActivityHandler(c *gin.Context) {
	var req model.PostActivityRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data"})
		return
	}

	if !req.Intensity.IsValid() {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid intensity value"})
		return
	}

	activity := model.Activity{
		ID:          uuid.New(),
		UserID:      req.UserID,
		Type:        req.Type,
		DurationMin: req.DurationMin,
		Intensity:   req.Intensity,
		Calories:    req.Calories,
		Location:    req.Location,
		Timestamp:   time.Now(),
	}

	if err := db.CreateActivity(&activity); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create activity"})
		return
	}

	c.JSON(http.StatusCreated, activity)
}

// @Summary Get Activities
// @Description Get all activities for a user
// @Tags activities
// @Produce json
// @Param user_id path string true "User ID"
// @Success 200 {array} model.Activity
// @Router /api/activities/{user_id} [get]
func GetActivitiesHandler(c *gin.Context) {
	user_id := c.Param("user_id")
	activity, err := db.GetActivitiesByUserID(user_id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Activity not found"})
		return
	}

	if len(*activity) == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "No activities found for this user"})
		return
	}

	c.JSON(http.StatusOK, activity)
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
func PostStepEntryHandler(c *gin.Context) {
	var req model.PostStepEntryRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data"})
		return
	}

	stepEntry := model.StepEntry{
		ID:     uuid.New(),
		UserID: req.UserID,
		Date:   req.Date,
		Steps:  req.Steps,
	}

	if err := db.CreateStepEntry(&stepEntry); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create step entry"})
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
