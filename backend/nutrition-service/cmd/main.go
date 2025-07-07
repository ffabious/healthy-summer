package main

import (
	"log"
	"net/http"
	"os"

	"github.com/ffabious/healthy-summer/nutrition-service/internal/handler"
)

func main() {
	http.HandleFunc("/api/nutrition", handler.NutritionHandler)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8082"
	}

	log.Printf("Starting server on :%s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
