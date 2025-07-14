package handler

import (
	"net/http"
	"time"

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
	var req model.PostMealRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data", "details": err.Error()})
		return
	}

	meal := model.Meal{
		ID:            uuid.New(),
		UserID:        req.UserID,
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
// @Description Retrieve all meals for a specific user
// @Tags Nutrition
// @Produce json
// @Param user_id path string true "User ID"
// @Success 200 {array} model.Meal
// @Router /api/meals/{user_id} [get]
// @Security BearerAuth
func GetMealsHandler(c *gin.Context) {
	userID := c.Param("user_id")
	if userID == "" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "User ID is required"})
		return
	}

	meals, err := db.GetMealsByUserID(userID)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to retrieve meals"})
		return
	}

	c.JSON(http.StatusOK, meals)
}

// @Summary Post a new water entry
// @Description Create a new water entry for a user
// @Tags Nutrition
// @Accept json
// @Produce json
// @Param water body model.Water true "Water entry data"
// @Success 201 {object} model.Water
// @Router /api/water [post]
// @Security BearerAuth
func PostWaterHandler(c *gin.Context) {
	var req model.Water
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data"})
		return
	}

	req.ID = uuid.New()
	req.Timestamp = time.Now()

	if err := db.CreateWater(&req); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create water entry"})
		return
	}

	c.JSON(http.StatusCreated, req)
}
