package main

import (
	"log"
	"net/http"

	"github.com/ffabious/healthy-summer/nutrition-service/internal/handler"
)

func main() {
	http.HandleFunc("/api/nutrition", handler.NutritionHandler)

	log.Println("Starting server on :8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
