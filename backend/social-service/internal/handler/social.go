package handler

import (
	"net/http"
)

func SocialsHandler(w http.ResponseWriter, r *http.Request) {
	println("Socials handler called with method:", r.Method)
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Socials handler"))
}

func SocialHandler(w http.ResponseWriter, r *http.Request) {
	println("Social handler called with method:", r.Method)
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Social handler"))
}
