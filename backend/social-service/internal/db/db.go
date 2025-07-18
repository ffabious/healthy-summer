package db

import (
	"fmt"
	"log"
	"os"
	"time"

	"github.com/ffabious/healthy-summer/social-service/internal/model"
	"github.com/google/uuid"
	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var DB *gorm.DB
var UserDB *gorm.DB

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

	// Connect to social schema
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
		log.Printf("Failed to create uuid-ossp extension (might already exist): %v", err)
	}

	log.Println("Database connected successfully")

}

func GetFriends(userID string) ([]model.Friend, error) {
	var friends []model.Friend
	err := DB.Table("friends").
		Where("user_id = ?", userID).
		Find(&friends).Error
	return friends, err
}

func GetFeedByFriends(userID string, friends []model.Friend) (model.Feed, error) {
	var feed model.Feed
	var friendIDs []string
	for _, friend := range friends {
		friendIDs = append(friendIDs, friend.FriendID.String())
	}

	type WaterResult struct {
		UserID string
		Total  float64
	}

	var results []WaterResult
	err := DB.Table("waters").
		Select("user_id, SUM(amount) as total").
		Where("user_id IN ?", friendIDs).
		Group("user_id").
		Having("SUM(amount) >= ?", 2000).
		Scan(&results).Error
	if err != nil {
		return feed, err
	}

	for _, result := range results {
		feed.Items = append(feed.Items, model.FeedItem{
			ActivityID: uuid.New(),
			FriendID:   uuid.MustParse(result.UserID),
		})
	}

	return feed, nil
}
