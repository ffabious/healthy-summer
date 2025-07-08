package db

import (
	"fmt"
	"log"
	"os"

	"time"

	"github.com/ffabious/healthy-summer/activity-service/internal/model"
	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB

func Connect() {
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using default environment variables")
	}

	dsn := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		os.Getenv("DB_HOST"),
		os.Getenv("DB_PORT"),
		os.Getenv("DB_USER"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_NAME"),
	)

	var err error
	for i := range 10 {
		DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
		if err == nil {
			break
		}
		log.Printf("DB connection failed, retrying... (%d/10)", i+1)
		time.Sleep(2 * time.Second)
	}
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	sqlDB, err := DB.DB()
	if err != nil {
		log.Fatalf("Failed to get sql.DB: %v", err)
	}
	_, err = sqlDB.Exec(`CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`)
	if err != nil {
		log.Fatalf("Failed to create extension uuid-ossp: %v", err)
	}
	_, err = sqlDB.Exec(`
		DO $$
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'intensity_enum') THEN
				CREATE TYPE intensity_enum AS ENUM ('low', 'medium', 'high');
			END IF;
		END$$;
	`)
	if err != nil {
		log.Fatalf("Failed to create enum type intensity_enum: %v", err)
	}
	log.Println("Database connection established successfully")
	if err := DB.AutoMigrate(&model.Activity{}, &model.StepEntry{}); err != nil {
		log.Fatalf("Failed to auto-migrate models: %v", err)
	}
	log.Println("Database models migrated successfully")
	log.Println("Database connection and migration completed successfully")
	log.Println("Database connection string:", dsn)
}

func CreateActivity(activity *model.Activity) error {
	if err := DB.Create(activity).Error; err != nil {
		return fmt.Errorf("failed to create activity: %w", err)
	}
	return nil
}

func GetActivitiesByUserID(userID string) (*[]model.Activity, error) {
	var activities []model.Activity
	if err := DB.Where("user_id = ?", userID).Find(&activities).Error; err != nil {
		return nil, fmt.Errorf("failed to get activities for user %s: %w", userID, err)
	}
	return &activities, nil
}

func GetActivityStatsByUserID(userID string) (*model.ActivityStats, error) {
	var stats model.ActivityStats
	if err := DB.Model(&model.Activity{}).
		Select("SUM(duration_min) AS total_duration_min, SUM(calories) AS total_calories, COUNT(*) AS activities").
		Where("user_id = ?", userID).
		Scan(&stats).Error; err != nil {
		return nil, fmt.Errorf("failed to get activity stats for user %s: %w", userID, err)
	}
	if stats.Activities == 0 {
		return nil, nil // No activities found
	}
	return &stats, nil
}