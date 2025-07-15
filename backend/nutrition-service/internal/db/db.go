package db

import (
	"fmt"
	"log"
	"os"

	"time"

	"github.com/ffabious/healthy-summer/nutrition-service/internal/model"
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

	if err := DB.AutoMigrate(&model.Meal{}, &model.Water{}); err != nil {
		log.Fatalf("Failed to migrate database models: %v", err)
	}

	log.Println("Database models migrated successfully")
	log.Println("Database connection and migration completed successfully")
	log.Println("Database connection string:", dsn)
}

func CreateMeal(meal *model.Meal) error {
	if err := DB.Create(meal).Error; err != nil {
		return fmt.Errorf("failed to create meal: %w", err)
	}
	return nil
}

func GetMealsByUserID(userID string) ([]model.Meal, error) {
	var meals []model.Meal
	if err := DB.Where("user_id = ?", userID).Find(&meals).Error; err != nil {
		return nil, fmt.Errorf("failed to get meals for user %s: %w", userID, err)
	}
	return meals, nil
}

func CreateWater(water *model.Water) error {
	if err := DB.Create(water).Error; err != nil {
		return fmt.Errorf("failed to create water entry: %w", err)
	}
	return nil
}

func GetWaterIntakeByUserID(userID string) ([]model.Water, error) {
	var waterEntries []model.Water
	if err := DB.Where("user_id = ?", userID).Order("timestamp DESC").Find(&waterEntries).Error; err != nil {
		return nil, fmt.Errorf("failed to get water intake for user %s: %w", userID, err)
	}
	return waterEntries, nil
}

func GetNutritionStatsByUserID(userID string) (*model.NutritionStats, error) {
	now := time.Now()
	today := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())
	weekStart := today.AddDate(0, 0, -int(today.Weekday()))
	monthStart := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, now.Location())

	stats := &model.NutritionStats{}

	// Calculate today's stats
	todayStats, err := calculatePeriodStats(userID, today, today.AddDate(0, 0, 1))
	if err != nil {
		return nil, fmt.Errorf("failed to calculate today's stats: %w", err)
	}
	stats.Today = *todayStats

	// Calculate week's stats
	weekStats, err := calculatePeriodStats(userID, weekStart, weekStart.AddDate(0, 0, 7))
	if err != nil {
		return nil, fmt.Errorf("failed to calculate week's stats: %w", err)
	}
	stats.Week = *weekStats

	// Calculate month's stats
	monthStats, err := calculatePeriodStats(userID, monthStart, monthStart.AddDate(0, 1, 0))
	if err != nil {
		return nil, fmt.Errorf("failed to calculate month's stats: %w", err)
	}
	stats.Month = *monthStats

	// Calculate total stats
	totalStats, err := calculatePeriodStats(userID, time.Time{}, time.Now().AddDate(1, 0, 0))
	if err != nil {
		return nil, fmt.Errorf("failed to calculate total stats: %w", err)
	}
	stats.Total = *totalStats

	return stats, nil
}

func calculatePeriodStats(userID string, startTime, endTime time.Time) (*model.NutritionPeriod, error) {
	var meals []model.Meal
	var waterEntries []model.Water

	// Get meals for the period
	query := DB.Where("user_id = ?", userID)
	if !startTime.IsZero() {
		query = query.Where("timestamp >= ?", startTime)
	}
	query = query.Where("timestamp < ?", endTime)

	if err := query.Find(&meals).Error; err != nil {
		return nil, fmt.Errorf("failed to get meals: %w", err)
	}

	// Get water entries for the period
	waterQuery := DB.Where("user_id = ?", userID)
	if !startTime.IsZero() {
		waterQuery = waterQuery.Where("timestamp >= ?", startTime)
	}
	waterQuery = waterQuery.Where("timestamp < ?", endTime)

	if err := waterQuery.Find(&waterEntries).Error; err != nil {
		return nil, fmt.Errorf("failed to get water entries: %w", err)
	}

	// Calculate totals
	stats := &model.NutritionPeriod{
		MealCount: len(meals),
	}

	for _, meal := range meals {
		stats.TotalCalories += meal.Calories
		stats.TotalProtein += meal.Protein
		stats.TotalCarbs += meal.Carbohydrates
		stats.TotalFats += meal.Fats
	}

	for _, water := range waterEntries {
		stats.TotalWaterMl += water.VolumeMl
	}

	return stats, nil
}

func SearchFood(query string) ([]model.FoodItem, error) {
	var foods []model.FoodItem
	if err := DB.Where("name ILIKE ?", "%"+query+"%").Find(&foods).Error; err != nil {
		return nil, fmt.Errorf("failed to search food items: %w", err)
	}
	return foods, nil
}

func UpdateMeal(mealID, userID string, req *model.PostMealRequest) (*model.Meal, error) {
	var meal model.Meal

	// First, check if the meal exists and belongs to the user
	if err := DB.Where("id = ? AND user_id = ?", mealID, userID).First(&meal).Error; err != nil {
		return nil, fmt.Errorf("meal not found or access denied: %w", err)
	}

	// Update the meal fields
	meal.Name = req.Name
	meal.Calories = req.Calories
	meal.Protein = req.Protein
	meal.Carbohydrates = req.Carbohydrates
	meal.Fats = req.Fats

	if err := DB.Save(&meal).Error; err != nil {
		return nil, fmt.Errorf("failed to update meal: %w", err)
	}

	return &meal, nil
}

func DeleteMeal(mealID, userID string) error {
	result := DB.Where("id = ? AND user_id = ?", mealID, userID).Delete(&model.Meal{})
	if result.Error != nil {
		return fmt.Errorf("failed to delete meal: %w", result.Error)
	}
	if result.RowsAffected == 0 {
		return fmt.Errorf("meal not found or access denied")
	}
	return nil
}

func UpdateWaterEntry(waterID, userID string, req *model.PostWaterRequest) (*model.Water, error) {
	var water model.Water

	// First, check if the water entry exists and belongs to the user
	if err := DB.Where("id = ? AND user_id = ?", waterID, userID).First(&water).Error; err != nil {
		return nil, fmt.Errorf("water entry not found or access denied: %w", err)
	}

	// Update the water entry fields
	water.VolumeMl = req.VolumeMl

	if err := DB.Save(&water).Error; err != nil {
		return nil, fmt.Errorf("failed to update water entry: %w", err)
	}

	return &water, nil
}

func DeleteWaterEntry(waterID, userID string) error {
	result := DB.Where("id = ? AND user_id = ?", waterID, userID).Delete(&model.Water{})
	if result.Error != nil {
		return fmt.Errorf("failed to delete water entry: %w", result.Error)
	}
	if result.RowsAffected == 0 {
		return fmt.Errorf("water entry not found or access denied")
	}
	return nil
}
