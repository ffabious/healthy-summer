package handler

import (
	"net/http"
)

func UserHandler(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement user-specific logic here
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("User handler"))
}

func UsersHandler(w http.ResponseWriter, r *http.Request) {
	// TODO: Implement logic for handling multiple users
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Users handler"))
}
