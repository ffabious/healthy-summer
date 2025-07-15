package model

import (
	"time"

	"github.com/google/uuid"
)

type Meal struct {
	ID            uuid.UUID `json:"id" gorm:"type:uuid;default:uuid_generate_v4();primaryKey"`
	UserID        uuid.UUID `json:"user_id" gorm:"type:uuid;not null"`
	Name          string    `json:"name" gorm:"type:varchar(100);not null"`
	Calories      int       `json:"calories" gorm:"not null"`
	Protein       float64   `json:"protein" gorm:"not null"`
	Carbohydrates float64   `json:"carbohydrates" gorm:"not null"`
	Fats          float64   `json:"fats" gorm:"not null"`
	Timestamp     time.Time `json:"timestamp" gorm:"not null"`
}

type Water struct {
	ID        uuid.UUID `json:"id" gorm:"type:uuid;default:uuid_generate_v4();primaryKey"`
	UserID    uuid.UUID `json:"user_id" gorm:"type:uuid;not null"`
	VolumeMl  float64   `json:"volume_ml" gorm:"not null"`
	Timestamp time.Time `json:"timestamp" gorm:"not null"`
}

type NutritionStats struct {
	Today NutritionPeriod `json:"today"`
	Week  NutritionPeriod `json:"week"`
	Month NutritionPeriod `json:"month"`
	Total NutritionPeriod `json:"total"`
}

type NutritionPeriod struct {
	MealCount     int     `json:"meal_count"`
	TotalCalories int     `json:"total_calories"`
	TotalProtein  float64 `json:"total_protein"`
	TotalCarbs    float64 `json:"total_carbohydrates"`
	TotalFats     float64 `json:"total_fats"`
	TotalWaterMl  float64 `json:"total_water_ml"`
}

type SearchFoodRequest struct {
	Query string `json:"query" binding:"required"`
}

type SearchFoodResponse struct {
	Foods []FoodItem `json:"foods"`
}

type FoodItem struct {
	Name          string  `json:"name"`
	Calories      int     `json:"calories"`
	Protein       float64 `json:"protein"`
	Carbohydrates float64 `json:"carbohydrates"`
	Fats          float64 `json:"fats"`
}

type PostMealRequest struct {
	Name          string  `json:"name" binding:"required"`
	Calories      int     `json:"calories" binding:"required,min=0"`
	Protein       float64 `json:"protein" binding:"min=0"`
	Carbohydrates float64 `json:"carbohydrates" binding:"min=0"`
	Fats          float64 `json:"fats" binding:"min=0"`
}

type PostWaterRequest struct {
	VolumeMl float64 `json:"volume_ml" binding:"required,gt=0"`
}
