package model

import (
	"time"

	"github.com/google/uuid"
)

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

type StepEntry struct {
	ID     uuid.UUID `json:"id" gorm:"type:uuid;default:uuid_generate_v4();primaryKey"`
	UserID uuid.UUID `json:"user_id" gorm:"type:uuid;not null"`
	Date   time.Time `json:"date" gorm:"not null"`
	Steps  int       `json:"steps" gorm:"not null"`
}

type ActivityStats struct {
	TotalDurationMin int `json:"total_duration_min"`
	TotalCalories    int `json:"total_calories"`
	Activities       int `json:"activities"`
}

type ActivityAnalytics struct {
	ByType map[string]int `json:"by_type"` // "Running": 120 mins
	ByDay  map[string]int `json:"by_day"`  // "Mon": 300 kcal
}
