package main

import (
	"log"
	"os"

	_ "github.com/ffabious/healthy-summer/activity-service/docs"
	"github.com/ffabious/healthy-summer/activity-service/internal/auth"
	"github.com/ffabious/healthy-summer/activity-service/internal/db"
	"github.com/ffabious/healthy-summer/activity-service/internal/handler"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

func main() {
	if err := godotenv.Load("/etc/healthy-summer/secrets/activity-service.env"); err != nil {
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

	protected := r.Group("/api/activities")
	protected.Use(auth.JWTMiddleware())

	protected.POST("", handler.PostActivityHandler)
	protected.GET("", handler.GetActivitiesHandler)
	protected.GET("/stats/:user_id", handler.GetActivityStatsHandler)
	protected.POST("/steps", handler.PostStepEntryHandler)
	protected.GET("/analytics/:user_id", handler.GetActivityAnalyticsHandler)

	cert_file := os.Getenv("TLS_CERT_PATH")
	key_file := os.Getenv("TLS_KEY_PATH")

	if cert_file != "" && key_file != "" {
		runTLS(r, cert_file, key_file, port)
	} else {
		runRegular(r, port)
	}
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

func runTLS(r *gin.Engine, certFile, keyFile string, port string) {
	log.Printf("Starting user service on :%s with TLS", port)
	if err := r.RunTLS("0.0.0.0:"+port, certFile, keyFile); err != nil {
		log.Fatalf("Failed to start user service with TLS: %v", err)
	}
	log.Println("User service started successfully with TLS")
	log.Println("Swagger documentation available at /api/docs/index.html")
}
