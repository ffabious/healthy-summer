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

	if err := DB.AutoMigrate(&model.User{}, &model.Friend{}, &model.FriendRequest{}, &model.Achievement{}); err != nil {
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

func UpdateUserProfile(userID uuid.UUID, request model.UpdateProfileRequest) (*model.User, error) {
	user := model.User{
		ID:        userID,
		FirstName: request.FirstName,
		LastName:  request.LastName,
		UpdatedAt: time.Now(),
	}

	if err := DB.Model(&user).Where("id = ?", userID).Updates(user).Error; err != nil {
		return nil, err
	}
	return &user, nil
}

func GetFriendsByUserID(userID uuid.UUID) ([]model.FriendWithDetails, error) {
	var friends []model.FriendWithDetails
	if err := DB.Table("friends").
		Select("friends.id, friends.user_id, friends.friend_id, users.first_name, users.last_name, users.email, friends.created_at").
		Joins("JOIN users ON friends.friend_id = users.id").
		Where("friends.user_id = ?", userID).
		Scan(&friends).Error; err != nil {
		return nil, err
	}
	return friends, nil
}

func SendFriendRequest(senderID, receiverID uuid.UUID) (*model.FriendRequest, error) {
	// Check if users are the same
	if senderID == receiverID {
		return nil, fmt.Errorf("cannot send friend request to yourself")
	}

	// Check if receiver exists
	var receiver model.User
	if err := DB.First(&receiver, "id = ?", receiverID).Error; err != nil {
		return nil, fmt.Errorf("user not found")
	}

	// Check if already friends
	alreadyFriends, err := CheckExistingFriendship(senderID, receiverID)
	if err != nil {
		return nil, err
	}
	if alreadyFriends {
		return nil, fmt.Errorf("users are already friends")
	}

	// Check if friend request already exists
	existingRequest, err := CheckExistingFriendRequest(senderID, receiverID)
	if err != nil {
		return nil, err
	}
	if existingRequest {
		return nil, fmt.Errorf("friend request already exists")
	}

	friendRequest := model.FriendRequest{
		ID:         uuid.New(),
		SenderID:   senderID,
		ReceiverID: receiverID,
		Status:     "pending",
		CreatedAt:  time.Now(),
		UpdatedAt:  time.Now(),
	}

	if err := DB.Create(&friendRequest).Error; err != nil {
		return nil, err
	}
	return &friendRequest, nil
}

func AddAchievement(userID uuid.UUID, achievement model.Achievement) (*model.Achievement, error) {
	achievement.ID = uuid.New()
	achievement.UserID = userID
	achievement.CreatedAt = time.Now()
	achievement.UpdatedAt = time.Now()

	if err := DB.Create(&achievement).Error; err != nil {
		return nil, err
	}
	return &achievement, nil
}

// GetPendingFriendRequests retrieves all pending friend requests received by a user
func GetPendingFriendRequests(userID uuid.UUID) ([]model.FriendRequestResponse, error) {
	var requests []model.FriendRequestResponse
	if err := DB.Table("friend_requests").
		Select("friend_requests.id, friend_requests.sender_id, friend_requests.receiver_id, friend_requests.status, CONCAT(users.first_name, ' ', users.last_name) as sender_name, friend_requests.created_at, friend_requests.updated_at").
		Joins("JOIN users ON friend_requests.sender_id = users.id").
		Where("friend_requests.receiver_id = ? AND friend_requests.status = ?", userID, "pending").
		Scan(&requests).Error; err != nil {
		return nil, err
	}
	return requests, nil
}

// GetSentFriendRequests retrieves all friend requests sent by a user
func GetSentFriendRequests(userID uuid.UUID) ([]model.FriendRequest, error) {
	var requests []model.FriendRequest
	if err := DB.Where("sender_id = ?", userID).Find(&requests).Error; err != nil {
		return nil, err
	}
	return requests, nil
}

// AcceptFriendRequest accepts a friend request and creates a friendship
func AcceptFriendRequest(requestID uuid.UUID, userID uuid.UUID) (*model.FriendRequest, error) {
	var request model.FriendRequest
	if err := DB.First(&request, "id = ? AND receiver_id = ?", requestID, userID).Error; err != nil {
		return nil, err
	}

	if request.Status != "pending" {
		return nil, fmt.Errorf("friend request is not pending")
	}

	// Start transaction
	tx := DB.Begin()

	// Update request status
	request.Status = "accepted"
	request.UpdatedAt = time.Now()
	if err := tx.Save(&request).Error; err != nil {
		tx.Rollback()
		return nil, err
	}

	// Create friendship both ways
	friend1 := model.Friend{
		ID:        uuid.New(),
		UserID:    request.SenderID,
		FriendID:  request.ReceiverID,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	friend2 := model.Friend{
		ID:        uuid.New(),
		UserID:    request.ReceiverID,
		FriendID:  request.SenderID,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	if err := tx.Create(&friend1).Error; err != nil {
		tx.Rollback()
		return nil, err
	}

	if err := tx.Create(&friend2).Error; err != nil {
		tx.Rollback()
		return nil, err
	}

	tx.Commit()
	return &request, nil
}

// RejectFriendRequest rejects a friend request
func RejectFriendRequest(requestID uuid.UUID, userID uuid.UUID) (*model.FriendRequest, error) {
	var request model.FriendRequest
	if err := DB.First(&request, "id = ? AND receiver_id = ?", requestID, userID).Error; err != nil {
		return nil, err
	}

	if request.Status != "pending" {
		return nil, fmt.Errorf("friend request is not pending")
	}

	request.Status = "rejected"
	request.UpdatedAt = time.Now()
	if err := DB.Save(&request).Error; err != nil {
		return nil, err
	}

	return &request, nil
}

// SearchUsers searches for users by email or name
func SearchUsers(query string, excludeUserID uuid.UUID) ([]model.User, error) {
	var users []model.User
	searchPattern := "%" + query + "%"
	if err := DB.Where(
		"(email ILIKE ? OR CONCAT(first_name, ' ', last_name) ILIKE ?) AND id != ?",
		searchPattern, searchPattern, excludeUserID,
	).Find(&users).Error; err != nil {
		return nil, err
	}
	return users, nil
}

// CheckExistingFriendRequest checks if a friend request already exists between two users
func CheckExistingFriendRequest(senderID, receiverID uuid.UUID) (bool, error) {
	var count int64
	if err := DB.Model(&model.FriendRequest{}).Where(
		"((sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)) AND status = ?",
		senderID, receiverID, receiverID, senderID, "pending",
	).Count(&count).Error; err != nil {
		return false, err
	}
	return count > 0, nil
}

// CheckExistingFriendship checks if users are already friends
func CheckExistingFriendship(userID1, userID2 uuid.UUID) (bool, error) {
	var count int64
	if err := DB.Model(&model.Friend{}).Where(
		"(user_id = ? AND friend_id = ?) OR (user_id = ? AND friend_id = ?)",
		userID1, userID2, userID2, userID1,
	).Count(&count).Error; err != nil {
		return false, err
	}
	return count > 0, nil
}
