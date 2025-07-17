package main

import (
	"log"
	"net"
	"net/http"
	"os"

	"github.com/ffabious/healthy-summer/social-service/internal/auth"
	"github.com/ffabious/healthy-summer/social-service/internal/db"

	grpcServer "github.com/ffabious/healthy-summer/social-service/internal/grpc"
	"github.com/ffabious/healthy-summer/social-service/internal/handler"
	pb "github.com/ffabious/healthy-summer/social-service/proto"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"google.golang.org/grpc"

	_ "github.com/ffabious/healthy-summer/social-service/docs"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

func main() {
	// Connect to database
	db.Connect()

	// // Start gRPC server in a goroutine
	// go startGRPCServer()

	// Start HTTP server
	startHTTPServer()
}

func startGRPCServer() {
	grpcPort := os.Getenv("GRPC_PORT")
	if grpcPort == "" {
		grpcPort = "9083"
	}

	lis, err := net.Listen("tcp", ":"+grpcPort)
	if err != nil {
		log.Fatalf("Failed to listen on gRPC port %s: %v", grpcPort, err)
	}

	s := grpc.NewServer()
	messagingServer := grpcServer.NewMessagingServer()
	pb.RegisterMessagingServiceServer(s, messagingServer)

	log.Printf("Starting gRPC server on :%s", grpcPort)
	if err := s.Serve(lis); err != nil {
		log.Fatalf("Failed to start gRPC server: %v", err)
	}
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

	// Public routes
	r.GET("/health", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "healthy"})
	})

	// Legacy routes for compatibility
	r.GET("/api/socials", gin.WrapF(handler.SocialsHandler))
	r.Any("/api/socials/*path", gin.WrapF(handler.SocialHandler))

	// Protected routes
	api := r.Group("/api", auth.JWTMiddleware())
	{
		// Message routes
		api.POST("/messages", handler.SendMessage)
		api.GET("/messages/:friendId", handler.GetMessages)
		api.PUT("/messages/read", handler.MarkAsRead)

		// Conversation routes
		api.GET("/conversations", handler.GetConversations)

		// Friend routes
		api.POST("/friends", handler.SendFriendRequest)
		api.PUT("/friends/:friendId/accept", handler.AcceptFriendRequest)
		api.GET("/friends", handler.GetFriends)

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
