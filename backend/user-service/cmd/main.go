package main

import (
	"log"
	"net/http"
	"os"

	_ "github.com/ffabious/healthy-summer/user-service/docs"
	"github.com/ffabious/healthy-summer/user-service/internal/handler"
	httpSwagger "github.com/swaggo/http-swagger"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	http.HandleFunc("/api/users/login", handler.LoginHandler)
	http.HandleFunc("/api/users/register", handler.RegisterHandler)
	http.HandleFunc("/api/docs/", httpSwagger.WrapHandler)

	log.Printf("Starting server on :%s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
