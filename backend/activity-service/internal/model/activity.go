package model

import (
	"time"

	"github.com/google/uuid"
)

// @name Intensity
type Intensity string

const (
	IntensityLow    Intensity = "low"
	IntensityMedium Intensity = "medium"
	IntensityHigh   Intensity = "high"
)

func (i Intensity) IsValid() bool {
	switch i {
	case IntensityLow, IntensityMedium, IntensityHigh:
		return true
	}
	return false
}

// @name Activity
type Activity struct {
	ID          uuid.UUID `json:"id" gorm:"type:uuid;default:uuid_generate_v4();primaryKey"`
	UserID      uuid.UUID `json:"user_id" gorm:"type:uuid;not null"`
	Type        string    `json:"type" gorm:"type:varchar(50);not null"`
	DurationMin int       `json:"duration_min" gorm:"not null"`
	Intensity   Intensity `json:"intensity" gorm:"type:intensity_enum;not null"`
	Calories    int       `json:"calories" gorm:"not null"`
	Location    string    `json:"location" gorm:"type:varchar(100)"`
	Timestamp   time.Time `json:"timestamp" gorm:"not null"`
}

// @name StepEntry
type StepEntry struct {
	ID     uuid.UUID `json:"id" gorm:"type:uuid;default:uuid_generate_v4();primaryKey"`
	UserID uuid.UUID `json:"user_id" gorm:"type:uuid;not null"`
	Date   time.Time `json:"date" gorm:"not null"`
	Steps  int       `json:"steps" gorm:"not null"`
}

// @name ActivityStats
type ActivityStats struct {
	Today ActivityPeriod `json:"today"`
	Week  ActivityPeriod `json:"week"`
	Month ActivityPeriod `json:"month"`
	Total ActivityPeriod `json:"total"`
}

type ActivityPeriod struct {
	ActivityCount int `json:"activity_count"`
	DurationMin   int `json:"duration_min"`
	Calories      int `json:"calories"`
	Steps         int `json:"steps"`
}

type ActivityAnalyticsByType struct {
	Type             string `json:"type"`
	ActivityCount    int    `json:"activity_count"`
	TotalDurationMin int    `json:"total_duration_min"`
	TotalCalories    int    `json:"total_calories"`
}

// @name PostActivityRequest
type PostActivityRequest struct {
	Type        string    `json:"type" binding:"required"`
	DurationMin int       `json:"duration_min" binding:"required,gt=0"`
	Intensity   Intensity `json:"intensity" binding:"required"`
	Calories    int       `json:"calories" binding:"min=0"`
	Location    string    `json:"location"`
	Timestamp   time.Time `json:"timestamp" binding:"required"`
}

// @name UpdateActivityRequest
type UpdateActivityRequest struct {
	Type        string    `json:"type" binding:"required"`
	DurationMin int       `json:"duration_min" binding:"required,gt=0"`
	Intensity   Intensity `json:"intensity" binding:"required"`
	Calories    int       `json:"calories" binding:"min=0"`
	Location    string    `json:"location"`
}

// @name PostActivityResponse
type PostActivityResponse struct {
	ID          uuid.UUID `json:"id"`
	UserID      uuid.UUID `json:"user_id"`
	Type        string    `json:"type"`
	DurationMin int       `json:"duration_min"`
	Intensity   Intensity `json:"intensity"`
	Calories    int       `json:"calories"`
	Location    string    `json:"location"`
	Timestamp   time.Time `json:"timestamp"`
}

// @name GetActivitiesByUserIDRequest
type GetActivitiesByUserIDRequest struct {
	UserID uuid.UUID `json:"user_id" binding:"required"`
}

// @name GetActivitiesByUserIDResponse
type GetActivitiesByUserIDResponse struct {
	Activities []Activity `json:"activities"`
}

// @name GetActivityStatsRequest
type GetActivityStatsRequest struct {
	UserID uuid.UUID `json:"user_id" binding:"required"`
}

// @name GetActivityStatsResponse
type GetActivityAnalyticsRequest struct {
	UserID uuid.UUID `json:"user_id" binding:"required"`
}

type MostCaloriesBurnedDay struct {
	Date     time.Time `json:"date"`
	Calories int       `json:"calories"`
}

// @name GetActivityAnalyticsResponse
type GetActivityAnalyticsResponse struct {
	ActivityBreakdown     []ActivityAnalyticsByType `json:"activity_breakdown"`
	TopActivity           ActivityAnalyticsByType   `json:"top_activity"`
	MostCaloriesBurnedDay MostCaloriesBurnedDay     `json:"most_calories_burned_day"`
}

// @name PostStepEntryRequest
type PostStepEntryRequest struct {
	Date  time.Time `json:"date" binding:"required"`
	Steps int       `json:"steps" binding:"min=0"`
}

// @name PostStepEntryResponse
type PostStepEntryResponse struct {
	ID     uuid.UUID `json:"id"`
	UserID uuid.UUID `json:"user_id"`
	Date   time.Time `json:"date"`
	Steps  int       `json:"steps"`
}

// @name GetStepsByUserIdRequest
type GetStepsByUserIdRequest struct {
	UserID uuid.UUID `json:"user_id" binding:"required"`
}

// @name GetStepsByUserIdResponse
type GetStepsByUserIdResponse struct {
	Steps []StepEntry `json:"steps"`
}
