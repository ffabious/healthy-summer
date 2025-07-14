package db

import (
	"fmt"
	"log"
	"os"

	"time"

	"github.com/ffabious/healthy-summer/user-service/internal/model"
	"github.com/google/uuid"
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

	if err := DB.AutoMigrate(&model.User{}); err != nil {
		log.Fatalf("Failed to migrate database models: %v", err)
	}

	log.Println("Database models migrated successfully")
	log.Println("Database connection and migration completed successfully")
	log.Println("Database connection string:", dsn)
}

func PostLogin(request model.LoginRequest) (*model.User, error) {
	var user model.User
	if err := DB.Where("email = ? AND password = ?", request.Email, request.Password).First(&user).Error; err != nil {
		return nil, err
	}
	return &user, nil
}

func PostRegister(request model.RegisterRequest) (*model.User, error) {
	user := model.User{
		ID:        uuid.New(),
		Email:     request.Email,
		Password:  request.Password,
		FirstName: request.FirstName,
		LastName:  request.LastName,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	if err := DB.Create(&user).Error; err != nil {
		return nil, err
	}
	return &user, nil
}

func GetUserByID(userID uuid.UUID) (*model.User, error) {
	var user model.User
	if err := DB.First(&user, "id = ?", userID).Error; err != nil {
		return nil, err
	}
	return &user, nil
}

func GetUserByEmail(email string) (*model.User, error) {
	var user model.User
	if err := DB.First(&user, "email = ?", email).Error; err != nil {
		return nil, err
	}
	return &user, nil
}