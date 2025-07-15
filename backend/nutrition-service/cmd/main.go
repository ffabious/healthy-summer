package main

import (
	"log"
	"os"

	_ "github.com/ffabious/healthy-summer/nutrition-service/docs"
	"github.com/ffabious/healthy-summer/nutrition-service/internal/auth"
	"github.com/ffabious/healthy-summer/nutrition-service/internal/db"
	"github.com/ffabious/healthy-summer/nutrition-service/internal/handler"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

func main() {
	if err := godotenv.Load("/etc/healthy-summer/secrets/nutrition-service.env"); err != nil {
		log.Println("Error:", err.Error())
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
	protected := r.Group("/api")
	protected.Use(auth.JWTMiddleware())

	protected.POST("/meals", handler.PostMealHandler)
	protected.GET("/meals", handler.GetMealsHandler)
	protected.POST("/water", handler.PostWaterHandler)
	protected.GET("/water", handler.GetWaterIntakeHandler)
	protected.GET("/stats", handler.GetNutritionStatsHandler)

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
