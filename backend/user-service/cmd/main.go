package main

import (
	"log"
	"os"

	_ "github.com/ffabious/healthy-summer/user-service/docs"
	"github.com/ffabious/healthy-summer/user-service/internal/handler"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

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

	log.Printf("Starting user service on :%s", port)
	if err := r.Run("0.0.0.0:" + port); err != nil {
		log.Fatalf("Failed to start user service: %v", err)
	}
	log.Println("User service started successfully")
	log.Println("Swagger documentation available at /api/docs/index.html")
}
