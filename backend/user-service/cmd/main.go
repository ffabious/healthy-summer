package main

import (
	"log"
	"net/http"

	"github.com/ffabious/healthy-summer/user-service/internal/handler"
)

func main() {
	http.HandleFunc("/api/users", handler.UsersHandler)
	http.HandleFunc("/api/users/", handler.UserHandler)

	log.Println("Starting server on :8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}