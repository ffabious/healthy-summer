package main

import (
	"log"
	"os"

	_ "github.com/ffabious/healthy-summer/user-service/docs"
	"github.com/ffabious/healthy-summer/user-service/internal/auth"
	"github.com/ffabious/healthy-summer/user-service/internal/db"
	"github.com/ffabious/healthy-summer/user-service/internal/handler"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

func main() {
	if err := godotenv.Load("/etc/healthy-summer/secrets/user-service.env"); err != nil {
		log.Println("No .env file found, using default environment variables")
	}
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	db.Connect()

	r := gin.Default()

	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"},
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Accept"},
		AllowCredentials: true,
	}))

	r.GET("/api/docs/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
	r.POST("/api/users/login", handler.LoginHandler)
	r.POST("/api/users/register", handler.RegisterHandler)

	protected := r.Group("/api/users")
	protected.Use(auth.JWTMiddleware())

	protected.GET("/me", handler.GetCurrentUserHandler)
	protected.GET("/profile", handler.GetProfileHandler)
	protected.PUT("/profile", handler.UpdateProfileHandler)
	protected.GET("/friends", handler.GetFriendsHandler)
	protected.POST("/friends/request", handler.SendFriendRequestHandler)
	protected.GET("/friends/requests", handler.GetPendingFriendRequestsHandler)
	protected.POST("/friends/respond", handler.RespondToFriendRequestHandler)
	protected.GET("/search", handler.SearchUsersHandler)
	protected.POST("/achievements", handler.AddAchievementHandler)

	runRegular(r, port)
}

func runRegular(r *gin.Engine, port string) {
	log.Printf("Starting user service on :%s", port)
	if err := r.Run("0.0.0.0:" + port); err != nil {
		log.Fatalf("Failed to start user service: %v", err)
	}
	log.Println("User service started successfully")
	log.Println("Swagger documentation available at /api/docs/index.html")
	log.Println("User service is running without TLS")
}
