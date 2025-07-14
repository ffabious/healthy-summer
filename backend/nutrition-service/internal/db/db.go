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

func GetNutritionStatsByUserID(userID string) (*model.NutritionStats, error) {
	var stats model.NutritionStats
	if err := DB.Where("user_id = ?", userID).First(&stats).Error; err != nil {
		return nil, fmt.Errorf("failed to get nutrition stats for user %s: %w", userID, err)
	}
	return &stats, nil
}

func SearchFood(query string) ([]model.FoodItem, error) {
	var foods []model.FoodItem
	if err := DB.Where("name ILIKE ?", "%"+query+"%").Find(&foods).Error; err != nil {
		return nil, fmt.Errorf("failed to search food items: %w", err)
	}
	return foods, nil
}
