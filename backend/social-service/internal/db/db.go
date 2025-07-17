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
var NutritionDB *gorm.DB
var UserDB *gorm.DB

func Connect() {
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using default environment variables")
	}

	dsn := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable search_path=%s",
		os.Getenv("DB_HOST"),
		os.Getenv("DB_PORT"),
		os.Getenv("DB_USER"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_NAME"),
		os.Getenv("DB_SCHEMA"),
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

	// Connect to nutrition schema
	nutritionDSN := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable search_path=nutrition",
		os.Getenv("DB_HOST"),
		os.Getenv("DB_PORT"),
		os.Getenv("DB_USER"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_NAME"),
	)
	for i := range 10 {
		NutritionDB, err = gorm.Open(postgres.Open(nutritionDSN), &gorm.Config{})
		if err == nil {
			break
		}
		log.Printf("Nutrition DB connection failed, retrying... (%d/10)", i+1)
		time.Sleep(2 * time.Second)
	}
	if err != nil {
		log.Fatalf("Failed to connect to nutrition database: %v", err)
	}

	// Connect to user schema
	userDSN := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable search_path=user",
		os.Getenv("DB_HOST"),
		os.Getenv("DB_PORT"),
		os.Getenv("DB_USER"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_NAME"),
	)
	for i := range 10 {
		UserDB, err = gorm.Open(postgres.Open(userDSN), &gorm.Config{})
		if err == nil {
			break
		}
		log.Printf("User DB connection failed, retrying... (%d/10)", i+1)
		time.Sleep(2 * time.Second)
	}
	if err != nil {
		log.Fatalf("Failed to connect to user database: %v", err)
	}

	sqlDB, err := DB.DB()
	if err != nil {
		log.Fatalf("Failed to get sql.DB: %v", err)
	}
	_, err = sqlDB.Exec(`CREATE EXTENSION IF NOT EXISTS "uuid-ossp";`)
	if err != nil {
		log.Printf("Failed to create uuid-ossp extension (might already exist): %v", err)
	}

	// Set search_path for the social schema
	_, err = sqlDB.Exec(fmt.Sprintf("SET search_path TO %s", os.Getenv("DB_SCHEMA")))
	if err != nil {
		log.Printf("Failed to set search_path: %v", err)
	}

	log.Println("Database connected successfully")

	// Auto-migrate models in the social schema
	if err := DB.AutoMigrate(&model.Message{}, &model.Conversation{}, &model.Friend{}); err != nil {
		log.Fatalf("Failed to migrate database: %v", err)
	}
	log.Println("Database migration completed")
}

// Message operations
func CreateMessage(message *model.Message) error {
	return DB.Create(message).Error
}

func GetMessagesByConversation(user1ID, user2ID uuid.UUID, limit, offset int) ([]model.Message, error) {
	var messages []model.Message
	query := DB.Where(
		"(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)",
		user1ID, user2ID, user2ID, user1ID,
	).Order("created_at DESC")

	if limit > 0 {
		query = query.Limit(limit)
	}
	if offset > 0 {
		query = query.Offset(offset)
	}

	err := query.Find(&messages).Error
	return messages, err
}

func GetMessageCountByConversation(user1ID, user2ID uuid.UUID) (int64, error) {
	var count int64
	err := DB.Model(&model.Message{}).Where(
		"(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)",
		user1ID, user2ID, user2ID, user1ID,
	).Count(&count).Error
	return count, err
}

func MarkMessagesAsRead(messageIDs []uuid.UUID, userID uuid.UUID) error {
	return DB.Model(&model.Message{}).
		Where("id IN ? AND receiver_id = ?", messageIDs, userID).
		Update("is_read", true).Error
}

// Conversation operations
func GetOrCreateConversation(user1ID, user2ID uuid.UUID) (*model.Conversation, error) {
	var conversation model.Conversation

	// Try to find existing conversation (either direction)
	err := DB.Where(
		"(user1_id = ? AND user2_id = ?) OR (user1_id = ? AND user2_id = ?)",
		user1ID, user2ID, user2ID, user1ID,
	).First(&conversation).Error

	if err == gorm.ErrRecordNotFound {
		// Create new conversation
		conversation = model.Conversation{
			User1ID:   user1ID,
			User2ID:   user2ID,
			CreatedAt: time.Now(),
			UpdatedAt: time.Now(),
		}
		err = DB.Create(&conversation).Error
	}

	return &conversation, err
}

func UpdateConversationLastMessage(conversationID, messageID uuid.UUID) error {
	return DB.Model(&model.Conversation{}).
		Where("id = ?", conversationID).
		Update("last_message_id", messageID).Error
}

func GetConversationsByUser(userID uuid.UUID) ([]model.ConversationWithUser, error) {
	var conversations []model.ConversationWithUser

	query := `
		SELECT 
			c.*,
			CASE 
				WHEN c.user1_id = $1 THEN u2.first_name || ' ' || u2.last_name
				ELSE u1.first_name || ' ' || u1.last_name
			END as friend_name,
			CASE 
				WHEN c.user1_id = $1 THEN u2.email
				ELSE u1.email
			END as friend_email
		FROM conversations c
		LEFT JOIN users u1 ON c.user1_id = u1.id
		LEFT JOIN users u2 ON c.user2_id = u2.id
		WHERE c.user1_id = $1 OR c.user2_id = $1
		ORDER BY c.updated_at DESC
	`

	rows, err := DB.Raw(query, userID).Rows()
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var conv model.ConversationWithUser
		err := rows.Scan(
			&conv.ID, &conv.User1ID, &conv.User2ID, &conv.LastMessageID,
			&conv.CreatedAt, &conv.UpdatedAt, &conv.FriendName, &conv.FriendEmail,
		)
		if err != nil {
			return nil, err
		}
		conversations = append(conversations, conv)
	}

	return conversations, nil
}

// Friend operations
func CreateFriendRequest(userID, friendID uuid.UUID) (*model.Friend, error) {
	// Check if friendship already exists (in either direction)
	var existingFriend model.Friend
	err := DB.Where(
		"(user_id = ? AND friend_id = ?) OR (user_id = ? AND friend_id = ?)",
		userID, friendID, friendID, userID,
	).First(&existingFriend).Error

	if err == nil {
		return nil, fmt.Errorf("friendship already exists")
	}

	if err != gorm.ErrRecordNotFound {
		return nil, err
	}

	friend := &model.Friend{
		UserID:    userID,
		FriendID:  friendID,
		Status:    "pending",
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	err = DB.Create(friend).Error
	return friend, err
}

func AcceptFriendRequest(friendID uuid.UUID, userID uuid.UUID) error {
	return DB.Model(&model.Friend{}).
		Where("id = ? AND friend_id = ?", friendID, userID).
		Update("status", "accepted").Error
}

func GetFriendsByUser(userID uuid.UUID) ([]model.FriendWithUser, error) {
	var friends []model.FriendWithUser

	query := `
		SELECT 
			f.*,
			CASE 
				WHEN f.user_id = $1 THEN u2.first_name || ' ' || u2.last_name
				ELSE u1.first_name || ' ' || u1.last_name
			END as friend_name,
			CASE 
				WHEN f.user_id = $1 THEN u2.email
				ELSE u1.email
			END as friend_email
		FROM friends f
		LEFT JOIN users u1 ON f.user_id = u1.id
		LEFT JOIN users u2 ON f.friend_id = u2.id
		WHERE (f.user_id = $1 OR f.friend_id = $1) AND f.status = 'accepted'
		ORDER BY f.created_at DESC
	`

	rows, err := DB.Raw(query, userID).Rows()
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	for rows.Next() {
		var friend model.FriendWithUser
		err := rows.Scan(
			&friend.ID, &friend.UserID, &friend.FriendID, &friend.Status,
			&friend.CreatedAt, &friend.UpdatedAt, &friend.FriendName, &friend.FriendEmail,
		)
		if err != nil {
			return nil, err
		}
		friends = append(friends, friend)
	}

	return friends, nil
}

func GetUserByEmail(email string) (*model.User, error) {
	var user model.User
	err := DB.Where("email = ?", email).First(&user).Error
	if err != nil {
		return nil, err
	}
	return &user, nil
}

// Feed operations
func GetFriendsActivityFeed(userID uuid.UUID) ([]model.FeedItem, error) {
	var feedItems []model.FeedItem

	// Get friends first from social schema
	friends, err := GetFriendsByUser(userID)
	if err != nil {
		return nil, err
	}

	// For each friend, check their activities for today
	today := time.Now().Truncate(24 * time.Hour)
	tomorrow := today.Add(24 * time.Hour)

	for _, friend := range friends {
		var friendUserID uuid.UUID
		// Determine the friend's actual user ID
		if friend.UserID == userID {
			friendUserID = friend.FriendID
		} else {
			friendUserID = friend.UserID
		}

		// Check water intake activity (currently the only implemented activity)
		waterFeedItem := checkWaterIntakeActivity(friendUserID, friend.FriendName, today, tomorrow)
		if waterFeedItem != nil {
			feedItems = append(feedItems, *waterFeedItem)
		}

		// Future: Add other activity checks here
		// exerciseFeedItem := checkExerciseActivity(friendUserID, friend.FriendName, today, tomorrow)
		// mealFeedItem := checkMealActivity(friendUserID, friend.FriendName, today, tomorrow)
	}

	return feedItems, nil
}

// checkWaterIntakeActivity checks if a friend achieved the water intake goal (2L)
func checkWaterIntakeActivity(userID uuid.UUID, userName string, today, tomorrow time.Time) *model.FeedItem {
	// Query nutrition database for water intake
	var totalWater float64
	err := NutritionDB.Table("waters").
		Select("COALESCE(SUM(volume_ml), 0)").
		Where("user_id = ? AND timestamp >= ? AND timestamp < ?", userID, today, tomorrow).
		Scan(&totalWater).Error

	if err != nil {
		log.Printf("Error querying water intake for user %s: %v", userID, err)
		return nil
	}

	// If friend drank 2L or more (2000ml), create feed item
	if totalWater >= 2000 {
		return &model.FeedItem{
			UserID:       userID,
			UserName:     userName,
			ActivityType: "water_intake",
			ActivityData: map[string]interface{}{
				"volume_ml": totalWater,
				"goal_met":  true,
			},
			CreatedAt: time.Now(),
		}
	}

	return nil
}
