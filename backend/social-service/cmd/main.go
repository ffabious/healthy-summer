package main

import (
	"log"
	"net/http"
	"os"

	"github.com/ffabious/healthy-summer/social-service/internal/handler"
)

func main() {
	http.HandleFunc("/api/socials", handler.SocialsHandler)
	http.HandleFunc("/api/socials/", handler.SocialHandler)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8083"
	}

	log.Printf("Starting server on :%s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}
}
