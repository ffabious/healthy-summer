package main

import (
	"log"
	"net/http"
	"os"

	"github.com/ffabious/healthy-summer/user-service/internal/handler"
)

func main() {
	http.HandleFunc("/api/users", handler.UsersHandler)
	http.HandleFunc("/api/users/", handler.UserHandler)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Starting server on :%s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
