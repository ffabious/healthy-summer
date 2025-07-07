package handler

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/ffabious/healthy-summer/user-service/internal/model"
)

// @Summary User Login
// @Description Authenticate user
// @Tags auth
// @Accept json
// @Produce json
// @Param loginRequest body model.LoginRequest true "Login Request"
// @Success 200 {object} model.LoginResponse
// @Router /api/users/login [post]
func LoginHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req model.LoginRequest
	decoder := json.NewDecoder(r.Body)
	if err := decoder.Decode(&req); err != nil {
		http.Error(w, "Invalid request payload", http.StatusBadRequest)
		return
	}
	defer r.Body.Close()

	w.WriteHeader(http.StatusOK)
	response := model.LoginResponse{
		Token: "dummy-token",
		User: model.User{
			ID:        "12345",
			Email:     "string",
			FirstName: "John",
			LastName:  "Doe",
		},
		ExpiresAt: time.Now().Add(24 * time.Hour),
	}
	if err := json.NewEncoder(w).Encode(response); err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		return
	}
}

func RegisterHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req model.RegisterRequest
	decoder := json.NewDecoder(r.Body)
	if err := decoder.Decode(&req); err != nil {
		http.Error(w, "Invalid request payload", http.StatusBadRequest)
		return
	}
	defer r.Body.Close()

	w.WriteHeader(http.StatusCreated)
	response := model.RegisterResponse{
		Token: "dummy-token",
		User: model.User{
			ID:        "12345",
			Email:     req.Email,
			FirstName: req.FirstName,
			LastName:  req.LastName,
		},
		ExpiresAt: time.Now().Add(24 * time.Hour),
	}
	if err := json.NewEncoder(w).Encode(response); err != nil {
		http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		return
	}
}
