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
	var period model.ActivityPeriod

	// Query activity stats
	if err := DB.Model(&model.Activity{}).
		Select("COUNT(*) AS activity_count, COALESCE(SUM(duration_min),0) AS duration_min, COALESCE(SUM(calories),0) AS calories").
		Where("user_id = ? AND DATE(timestamp) = CURRENT_DATE", userID).
		Scan(&period).Error; err != nil {
		return nil, err
	}

	// Query steps
	var stepSum struct{ Steps int }
	if err := DB.Model(&model.StepEntry{}).
		Select("COALESCE(SUM(steps),0) AS steps").
		Where("user_id = ? AND date = CURRENT_DATE", userID).
		Scan(&stepSum).Error; err != nil {
		return nil, err
	}
	period.Steps = stepSum.Steps

	stats.Today = period

	// Query weekly stats
	var weekPeriod model.ActivityPeriod

	// Query weekly activity stats (last 7 days including today)
	if err := DB.Model(&model.Activity{}).
		Select("COUNT(*) AS activity_count, COALESCE(SUM(duration_min),0) AS duration_min, COALESCE(SUM(calories),0) AS calories").
		Where("user_id = ? AND DATE(timestamp) >= CURRENT_DATE - INTERVAL '6 days'", userID).
		Scan(&weekPeriod).Error; err != nil {
		return nil, err
	}

	// Query weekly steps
	var weekStepSum struct{ Steps int }
	if err := DB.Model(&model.StepEntry{}).
		Select("COALESCE(SUM(steps),0) AS steps").
		Where("user_id = ? AND date >= CURRENT_DATE - INTERVAL '6 days'", userID).
		Scan(&weekStepSum).Error; err != nil {
		return nil, err
	}
	weekPeriod.Steps = weekStepSum.Steps

	stats.Week = weekPeriod

	var monthPeriod model.ActivityPeriod

	// Query monthly activity stats (last 30 days including today)
	if err := DB.Model(&model.Activity{}).
		Select("COUNT(*) AS activity_count, COALESCE(SUM(duration_min),0) AS duration_min, COALESCE(SUM(calories),0) AS calories").
		Where("user_id = ? AND DATE(timestamp) >= CURRENT_DATE - INTERVAL '29 days'", userID).
		Scan(&monthPeriod).Error; err != nil {
		return nil, err
	}

	// Query monthly steps
	var monthStepSum struct{ Steps int }
	if err := DB.Model(&model.StepEntry{}).
		Select("COALESCE(SUM(steps),0) AS steps").
		Where("user_id = ? AND date >= CURRENT_DATE - INTERVAL '29 days'", userID).
		Scan(&monthStepSum).Error; err != nil {
		return nil, err
	}
	monthPeriod.Steps = monthStepSum.Steps

	stats.Month = monthPeriod

	// Query total activity stats
	var totalPeriod model.ActivityPeriod

	// Query total activity stats (all time)
	if err := DB.Model(&model.Activity{}).
		Select("COUNT(*) AS activity_count, COALESCE(SUM(duration_min),0) AS duration_min, COALESCE(SUM(calories),0) AS calories").
		Where("user_id = ?", userID).
		Scan(&totalPeriod).Error; err != nil {
		return nil, err
	}

	// Query total steps (all time)
	var totalStepSum struct{ Steps int }
	if err := DB.Model(&model.StepEntry{}).
		Select("COALESCE(SUM(steps),0) AS steps").
		Where("user_id = ?", userID).
		Scan(&totalStepSum).Error; err != nil {
		return nil, err
	}
	totalPeriod.Steps = totalStepSum.Steps

	stats.Total = totalPeriod

	return &stats, nil
}

func CreateStepEntry(stepEntry *model.StepEntry) error {
	if err := DB.Create(stepEntry).Error; err != nil {
		return fmt.Errorf("failed to create step entry: %w", err)
	}
	return nil
}

func GetStepEntriesByUserID(userID string, days int) ([]model.StepEntry, error) {
	var stepEntries []model.StepEntry
	query := fmt.Sprintf("user_id = ? AND date >= CURRENT_DATE - INTERVAL '%d days'", days-1)
	if err := DB.Where(query, userID).
		Order("date DESC").
		Find(&stepEntries).Error; err != nil {
		return nil, fmt.Errorf("failed to get step entries for user %s: %w", userID, err)
	}
	return stepEntries, nil
}

func GetActivityAnalyticsByUserID(userID string) (*model.GetActivityAnalyticsResponse, error) {
	var analytics model.GetActivityAnalyticsResponse

	// Query activities by type and add to ActivityBreakdown list
	if err := DB.Model(&model.Activity{}).
		Select("type, COUNT(*) AS activity_count, COALESCE(SUM(duration_min),0) AS total_duration_min, COALESCE(SUM(calories),0) AS total_calories").
		Where("user_id = ?", userID).
		Group("type").
		Scan(&analytics.ActivityBreakdown).Error; err != nil {
		return nil, fmt.Errorf("failed to get running activities for user %s: %w", userID, err)
	}

	// Calculate top activity type based on total_calories / total_duration_min
	var topActivity model.ActivityAnalyticsByType
	if err := DB.Model(&model.Activity{}).
		Select("type, COUNT(*) AS activity_count, COALESCE(SUM(duration_min),0) AS total_duration_min, COALESCE(SUM(calories),0) AS total_calories").
		Where("user_id = ?", userID).
		Group("type").
		Order("COALESCE(SUM(calories),0) / NULLIF(COALESCE(SUM(duration_min),0), 0) DESC").
		Limit(1).
		Scan(&topActivity).Error; err != nil {
		return nil, fmt.Errorf("failed to get top activity for user %s: %w", userID, err)
	}

	analytics.TopActivity = topActivity

	// Query most calories burned day
	var mostCaloriesBurnedDay model.MostCaloriesBurnedDay
	if err := DB.Model(&model.Activity{}).
		Select("DATE(timestamp) AS date, COALESCE(SUM(calories),0) AS calories").
		Where("user_id = ?", userID).
		Group("DATE(timestamp)").
		Order("calories DESC").
		Limit(1).
		Scan(&mostCaloriesBurnedDay).Error; err != nil {
		return nil, fmt.Errorf("failed to get most calories burned day for user %s: %w", userID, err)
	}
	analytics.MostCaloriesBurnedDay = mostCaloriesBurnedDay

	return &analytics, nil
}

func GetActivityByID(activityID string) (*model.Activity, error) {
	var activity model.Activity
	if err := DB.Where("id = ?", activityID).First(&activity).Error; err != nil {
		return nil, fmt.Errorf("failed to get activity %s: %w", activityID, err)
	}
	return &activity, nil
}

func UpdateActivity(activity *model.Activity) error {
	if err := DB.Save(activity).Error; err != nil {
		return fmt.Errorf("failed to update activity: %w", err)
	}
	return nil
}

func DeleteActivity(activityID string) error {
	if err := DB.Where("id = ?", activityID).Delete(&model.Activity{}).Error; err != nil {
		return fmt.Errorf("failed to delete activity %s: %w", activityID, err)
	}
	return nil
}
