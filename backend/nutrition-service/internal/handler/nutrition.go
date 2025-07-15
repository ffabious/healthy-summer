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
