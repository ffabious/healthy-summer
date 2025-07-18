package main

import (
	"log"
	"os"

	"github.com/ffabious/healthy-summer/social-service/internal/db"
	"github.com/ffabious/healthy-summer/social-service/internal/auth"
	"github.com/ffabious/healthy-summer/social-service/internal/handler"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"

	_ "github.com/ffabious/healthy-summer/social-service/docs"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

func main() {
	// Connect to database
	db.Connect()

	// Start HTTP server
	startHTTPServer()
}

func startHTTPServer() {
	r := gin.Default()

	// CORS middleware
	config := cors.DefaultConfig()
	config.AllowAllOrigins = true
	config.AllowMethods = []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"}
	config.AllowHeaders = []string{"*"}
	r.Use(cors.New(config))

	// Swagger documentation
	r.GET("/api/docs/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	// Protected routes
	api := r.Group("/api", auth.JWTMiddleware())
	{
		// Feed routes
		api.GET("/feed", handler.GetFeed)
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8083"
	}

	log.Printf("Starting HTTP server on :%s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatalf("Failed to start HTTP server: %v", err)
	}
}
