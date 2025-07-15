package handler

import (
	"net/http"
	"time"

	"github.com/ffabious/healthy-summer/nutrition-service/internal/auth"
	"github.com/ffabious/healthy-summer/nutrition-service/internal/db"
	"github.com/ffabious/healthy-summer/nutrition-service/internal/model"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// @Summary Post a new meal
// @Description Create a new meal entry for a user
// @Tags Nutrition
// @Accept json
// @Produce json
// @Param meal body model.PostMealRequest true "Meal data"
// @Success 201 {object} model.Meal
// @Router /api/meals [post]
// @Security BearerAuth
func PostMealHandler(c *gin.Context) {
	user_id, err := auth.ExtractUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized", "details": err.Error()})
		return
	}
	var req model.PostMealRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data", "details": err.Error()})
		return
	}

	meal := model.Meal{
		ID:            uuid.New(),
		UserID:        uuid.MustParse(user_id),
		Name:          req.Name,
		Calories:      req.Calories,
		Protein:       req.Protein,
		Carbohydrates: req.Carbohydrates,
		Fats:          req.Fats,
		Timestamp:     time.Now(),
	}

	if err := db.CreateMeal(&meal); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create meal", "details": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, meal)
}

// @Summary Get meals for a user
// @Description Retrieve all meals for a user
// @Tags Nutrition
// @Produce json
// @Success 200 {array} model.Meal
// @Router /api/meals [get]
// @Security BearerAuth
func GetMealsHandler(c *gin.Context) {
	user_id, err := auth.ExtractUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized", "details": err.Error()})
		return
	}

	meals, err := db.GetMealsByUserID(user_id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve meals", "details": err.Error()})
		return
	}

	c.JSON(http.StatusOK, meals)
}

// @Summary Post a new water entry
// @Description Create a new water entry for a user
// @Tags Nutrition
// @Accept json
// @Produce json
// @Param water body model.PostWaterRequest true "Water data"
// @Success 201 {object} model.Water
// @Router /api/water [post]
// @Security BearerAuth
func PostWaterHandler(c *gin.Context) {
	user_id, err := auth.ExtractUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized", "details": err.Error()})
		return
	}
	var req model.PostWaterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data", "details": err.Error()})
		return
	}

	water := model.Water{
		ID:        uuid.New(),
		UserID:    uuid.MustParse(user_id),
		VolumeMl:  req.VolumeMl,
		Timestamp: time.Now(),
	}

	if err := db.CreateWater(&water); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create water entry", "details": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, water)
}

// @Summary Get nutrition statistics for a user
// @Description Get nutrition statistics for today, week, month, and total
// @Tags Nutrition
// @Produce json
// @Success 200 {object} model.NutritionStats
// @Router /api/stats [get]
// @Security BearerAuth
func GetNutritionStatsHandler(c *gin.Context) {
	user_id, err := auth.ExtractUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized", "details": err.Error()})
		return
	}

	stats, err := db.GetNutritionStatsByUserID(user_id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve nutrition stats", "details": err.Error()})
		return
	}

	c.JSON(http.StatusOK, stats)
}

// @Summary Get water intake for a user
// @Description Retrieve all water intake entries for a user
// @Tags Nutrition
// @Produce json
// @Success 200 {array} model.Water
// @Router /api/water [get]
// @Security BearerAuth
func GetWaterIntakeHandler(c *gin.Context) {
	user_id, err := auth.ExtractUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized", "details": err.Error()})
		return
	}

	waterEntries, err := db.GetWaterIntakeByUserID(user_id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve water intake", "details": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"water_entries": waterEntries})
}

// @Summary Update a meal
// @Description Update an existing meal for a user
// @Tags Nutrition
// @Accept json
// @Produce json
// @Param id path string true "Meal ID"
// @Param meal body model.PostMealRequest true "Updated meal data"
// @Success 200 {object} model.Meal
// @Router /api/meals/{id} [put]
// @Security BearerAuth
func UpdateMealHandler(c *gin.Context) {
	user_id, err := auth.ExtractUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized", "details": err.Error()})
		return
	}

	mealID := c.Param("id")
	if mealID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Meal ID is required"})
		return
	}

	var req model.PostMealRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data", "details": err.Error()})
		return
	}

	meal, err := db.UpdateMeal(mealID, user_id, &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update meal", "details": err.Error()})
		return
	}

	c.JSON(http.StatusOK, meal)
}

// @Summary Delete a meal
// @Description Delete an existing meal for a user
// @Tags Nutrition
// @Param id path string true "Meal ID"
// @Success 204
// @Router /api/meals/{id} [delete]
// @Security BearerAuth
func DeleteMealHandler(c *gin.Context) {
	user_id, err := auth.ExtractUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized", "details": err.Error()})
		return
	}

	mealID := c.Param("id")
	if mealID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Meal ID is required"})
		return
	}

	if err := db.DeleteMeal(mealID, user_id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete meal", "details": err.Error()})
		return
	}

	c.Status(http.StatusNoContent)
}

// @Summary Update a water entry
// @Description Update an existing water entry for a user
// @Tags Nutrition
// @Accept json
// @Produce json
// @Param id path string true "Water Entry ID"
// @Param water body model.PostWaterRequest true "Updated water data"
// @Success 200 {object} model.Water
// @Router /api/water/{id} [put]
// @Security BearerAuth
func UpdateWaterEntryHandler(c *gin.Context) {
	user_id, err := auth.ExtractUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized", "details": err.Error()})
		return
	}

	waterID := c.Param("id")
	if waterID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Water entry ID is required"})
		return
	}

	var req model.PostWaterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data", "details": err.Error()})
		return
	}

	water, err := db.UpdateWaterEntry(waterID, user_id, &req)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update water entry", "details": err.Error()})
		return
	}

	c.JSON(http.StatusOK, water)
}

// @Summary Delete a water entry
// @Description Delete an existing water entry for a user
// @Tags Nutrition
// @Param id path string true "Water Entry ID"
// @Success 204
// @Router /api/water/{id} [delete]
// @Security BearerAuth
func DeleteWaterEntryHandler(c *gin.Context) {
	user_id, err := auth.ExtractUserID(c)
	if err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized", "details": err.Error()})
		return
	}

	waterID := c.Param("id")
	if waterID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Water entry ID is required"})
		return
	}

	if err := db.DeleteWaterEntry(waterID, user_id); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to delete water entry", "details": err.Error()})
		return
	}

	c.Status(http.StatusNoContent)
}
