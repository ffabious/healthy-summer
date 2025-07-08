package main

import (
	"log"
	"os"

	// "github.com/ffabious/healthy-summer/activity-service/internal/handler"
	// _ "github.com/ffabious/healthy-summer/activity-service/docs"
	"github.com/ffabious/healthy-summer/activity-service/internal/db"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	// swaggerFiles "github.com/swaggo/files"
	// ginSwagger "github.com/swaggo/gin-swagger"
)

func main() {
	if err := godotenv.Load(); err != nil {
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

	// r.GET("/api/docs/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
	// r.GET("/api/activities", handler.GetActivitiesHandler)

	log.Printf("Starting activity service on :%s", port)
	if err := r.Run("0.0.0.0:" + port); err != nil {
		log.Fatalf("Failed to start activity service: %v", err)
	}
	log.Println("Activity service started successfully")
	// log.Println("Swagger documentation available at /api/docs/index.html")
}
