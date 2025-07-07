package main

import (
	"log"
	"net/http"
	"os"

	"github.com/ffabious/healthy-summer/activity-service/internal/handler"
)

func main() {
	http.HandleFunc("/api/activity", handler.ActivityHandler)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8081"
	}

	log.Printf("Starting server on :%s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
