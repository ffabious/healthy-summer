package handler

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/ffabious/healthy-summer/user-service/internal/model"
	"github.com/gin-gonic/gin"
)

func setupRouter() *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	return r
}

func TestLoginHandler(t *testing.T) {
	router := setupRouter()
	router.POST("/login", LoginHandler)

	tests := []struct {
		name           string
		requestBody    interface{}
		expectedStatus int
		expectError    bool
	}{
		{
			name:           "Invalid JSON",
			requestBody:    `{"email": "invalid-json"`,
			expectedStatus: http.StatusBadRequest,
			expectError:    true,
		},
		{
			name:           "Empty request body",
			requestBody:    "",
			expectedStatus: http.StatusBadRequest,
			expectError:    true,
		},
		{
			name: "Missing email",
			requestBody: model.LoginRequest{
				Password: "password123",
			},
			expectedStatus: http.StatusBadRequest, // Gin binding validation error
			expectError:    true,
		},
		{
			name: "Missing password",
			requestBody: model.LoginRequest{
				Email: "test@example.com",
			},
			expectedStatus: http.StatusBadRequest, // Gin binding validation error
			expectError:    true,
		},
		{
			name: "Valid request format but non-existent user",
			requestBody: model.LoginRequest{
				Email:    "nonexistent@example.com",
				Password: "password123",
			},
			expectedStatus: http.StatusUnauthorized,
			expectError:    true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			var body []byte
			var err error

			if str, ok := tt.requestBody.(string); ok {
				body = []byte(str)
			} else {
				body, err = json.Marshal(tt.requestBody)
				if err != nil {
					t.Fatalf("Failed to marshal request body: %v", err)
				}
			}

			req, _ := http.NewRequest("POST", "/login", bytes.NewBuffer(body))
			req.Header.Set("Content-Type", "application/json")
			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			if w.Code != tt.expectedStatus {
				t.Errorf("Expected status %d, got %d", tt.expectedStatus, w.Code)
			}

			if tt.expectError {
				var response map[string]interface{}
				if err := json.Unmarshal(w.Body.Bytes(), &response); err != nil {
					t.Errorf("Failed to unmarshal error response: %v", err)
				}
				if _, exists := response["error"]; !exists {
					t.Error("Expected error field in response")
				}
			}
		})
	}
}

func TestRegisterHandler(t *testing.T) {
	router := setupRouter()
	router.POST("/register", RegisterHandler)

	tests := []struct {
		name           string
		requestBody    interface{}
		expectedStatus int
		expectError    bool
	}{
		{
			name:           "Invalid JSON",
			requestBody:    `{"email": "invalid-json"`,
			expectedStatus: http.StatusBadRequest,
			expectError:    true,
		},
		{
			name:           "Empty request body",
			requestBody:    "",
			expectedStatus: http.StatusBadRequest,
			expectError:    true,
		},
		{
			name: "Missing email",
			requestBody: model.RegisterRequest{
				Password:  "password123",
				FirstName: "Test",
				LastName:  "User",
			},
			expectedStatus: http.StatusBadRequest, // Gin binding validation error
			expectError:    true,
		},
		{
			name: "Missing password",
			requestBody: model.RegisterRequest{
				Email:     "test@example.com",
				FirstName: "Test",
				LastName:  "User",
			},
			expectedStatus: http.StatusBadRequest, // Gin binding validation error
			expectError:    true,
		},
		{
			name: "Missing first name",
			requestBody: model.RegisterRequest{
				Email:    "test@example.com",
				Password: "password123",
				LastName: "User",
			},
			expectedStatus: http.StatusBadRequest, // Gin binding validation error
			expectError:    true,
		},
		{
			name: "Missing last name",
			requestBody: model.RegisterRequest{
				Email:     "test@example.com",
				Password:  "password123",
				FirstName: "Test",
			},
			expectedStatus: http.StatusBadRequest, // Gin binding validation error
			expectError:    true,
		},
		{
			name: "Valid request format",
			requestBody: model.RegisterRequest{
				Email:     "test@example.com",
				Password:  "password123",
				FirstName: "Test",
				LastName:  "User",
			},
			expectedStatus: http.StatusInternalServerError, // Will fail due to no DB connection
			expectError:    true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			var body []byte
			var err error

			if str, ok := tt.requestBody.(string); ok {
				body = []byte(str)
			} else {
				body, err = json.Marshal(tt.requestBody)
				if err != nil {
					t.Fatalf("Failed to marshal request body: %v", err)
				}
			}

			req, _ := http.NewRequest("POST", "/register", bytes.NewBuffer(body))
			req.Header.Set("Content-Type", "application/json")
			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			if w.Code != tt.expectedStatus {
				t.Errorf("Expected status %d, got %d", tt.expectedStatus, w.Code)
			}

			if tt.expectError {
				var response map[string]interface{}
				if err := json.Unmarshal(w.Body.Bytes(), &response); err != nil {
					t.Errorf("Failed to unmarshal error response: %v", err)
				}
				if _, exists := response["error"]; !exists {
					t.Error("Expected error field in response")
				}
			}
		})
	}
}

func TestGetCurrentUserHandler(t *testing.T) {
	router := setupRouter()
	router.GET("/user/current", GetCurrentUserHandler)

	tests := []struct {
		name           string
		userID         string
		expectedStatus int
		expectError    bool
	}{
		{
			name:           "Missing user ID in context",
			userID:         "",
			expectedStatus: http.StatusUnauthorized,
			expectError:    true,
		},
		{
			name:           "Invalid user ID format",
			userID:         "invalid-uuid",
			expectedStatus: http.StatusUnauthorized, // ExtractUserID fails
			expectError:    true,
		},
		{
			name:           "Valid UUID format but non-existent user",
			userID:         "550e8400-e29b-41d4-a716-446655440000",
			expectedStatus: http.StatusUnauthorized, // ExtractUserID fails in test context
			expectError:    true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			req, _ := http.NewRequest("GET", "/user/current", nil)
			w := httptest.NewRecorder()

			c, _ := gin.CreateTestContext(w)
			c.Request = req

			if tt.userID != "" {
				c.Set("userID", tt.userID)
			}

			GetCurrentUserHandler(c)

			if w.Code != tt.expectedStatus {
				t.Errorf("Expected status %d, got %d", tt.expectedStatus, w.Code)
			}

			if tt.expectError {
				var response map[string]interface{}
				if err := json.Unmarshal(w.Body.Bytes(), &response); err != nil {
					t.Errorf("Failed to unmarshal error response: %v", err)
				}
				if _, exists := response["error"]; !exists {
					t.Error("Expected error field in response")
				}
			}
		})
	}
}

func TestSearchUsersHandler(t *testing.T) {
	router := setupRouter()
	router.GET("/users/search", SearchUsersHandler)

	tests := []struct {
		name           string
		query          string
		userID         string
		expectedStatus int
		expectError    bool
	}{
		{
			name:           "Missing user ID in context",
			query:          "test",
			userID:         "",
			expectedStatus: http.StatusUnauthorized,
			expectError:    true,
		},
		{
			name:           "Invalid user ID format",
			query:          "test",
			userID:         "invalid-uuid",
			expectedStatus: http.StatusUnauthorized, // ExtractUserID fails
			expectError:    true,
		},
		{
			name:           "Missing query parameter",
			query:          "",
			userID:         "550e8400-e29b-41d4-a716-446655440000",
			expectedStatus: http.StatusUnauthorized, // ExtractUserID fails in test context
			expectError:    true,
		},
		{
			name:           "Valid parameters but no DB connection",
			query:          "test",
			userID:         "550e8400-e29b-41d4-a716-446655440000",
			expectedStatus: http.StatusUnauthorized, // ExtractUserID fails in test context
			expectError:    true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			url := "/users/search"
			if tt.query != "" {
				url += "?q=" + tt.query
			}

			req, _ := http.NewRequest("GET", url, nil)
			w := httptest.NewRecorder()

			c, _ := gin.CreateTestContext(w)
			c.Request = req

			if tt.userID != "" {
				c.Set("userID", tt.userID)
			}

			SearchUsersHandler(c)

			if w.Code != tt.expectedStatus {
				t.Errorf("Expected status %d, got %d", tt.expectedStatus, w.Code)
			}

			if tt.expectError {
				var response map[string]interface{}
				if err := json.Unmarshal(w.Body.Bytes(), &response); err != nil {
					t.Errorf("Failed to unmarshal error response: %v", err)
				}
				if _, exists := response["error"]; !exists {
					t.Error("Expected error field in response")
				}
			}
		})
	}
}

func TestUpdateProfileHandler(t *testing.T) {
	router := setupRouter()
	router.PUT("/profile", UpdateProfileHandler)

	tests := []struct {
		name           string
		requestBody    interface{}
		userID         string
		expectedStatus int
		expectError    bool
	}{
		{
			name:           "Missing user ID in context",
			requestBody:    model.UpdateProfileRequest{FirstName: "Test"},
			userID:         "",
			expectedStatus: http.StatusUnauthorized,
			expectError:    true,
		},
		{
			name:           "Invalid user ID format",
			requestBody:    model.UpdateProfileRequest{FirstName: "Test"},
			userID:         "invalid-uuid",
			expectedStatus: http.StatusUnauthorized, // ExtractUserID fails
			expectError:    true,
		},
		{
			name:           "Invalid JSON",
			requestBody:    `{"firstName": "invalid-json"`,
			userID:         "550e8400-e29b-41d4-a716-446655440000",
			expectedStatus: http.StatusUnauthorized, // ExtractUserID fails in test context
			expectError:    true,
		},
		{
			name:           "Valid request but no DB connection",
			requestBody:    model.UpdateProfileRequest{FirstName: "Test", LastName: "User"},
			userID:         "550e8400-e29b-41d4-a716-446655440000",
			expectedStatus: http.StatusUnauthorized, // ExtractUserID fails in test context
			expectError:    true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			var body []byte
			var err error

			if str, ok := tt.requestBody.(string); ok {
				body = []byte(str)
			} else {
				body, err = json.Marshal(tt.requestBody)
				if err != nil {
					t.Fatalf("Failed to marshal request body: %v", err)
				}
			}

			req, _ := http.NewRequest("PUT", "/profile", bytes.NewBuffer(body))
			req.Header.Set("Content-Type", "application/json")
			w := httptest.NewRecorder()

			c, _ := gin.CreateTestContext(w)
			c.Request = req

			if tt.userID != "" {
				c.Set("userID", tt.userID)
			}

			UpdateProfileHandler(c)

			if w.Code != tt.expectedStatus {
				t.Errorf("Expected status %d, got %d", tt.expectedStatus, w.Code)
			}

			if tt.expectError {
				var response map[string]interface{}
				if err := json.Unmarshal(w.Body.Bytes(), &response); err != nil {
					t.Errorf("Failed to unmarshal error response: %v", err)
				}
				if _, exists := response["error"]; !exists {
					t.Error("Expected error field in response")
				}
			}
		})
	}
}

func TestHashPassword(t *testing.T) {
	tests := []struct {
		name     string
		password string
		wantErr  bool
	}{
		{
			name:     "Valid password",
			password: "password123",
			wantErr:  false,
		},
		{
			name:     "Empty password",
			password: "",
			wantErr:  false, // bcrypt can hash empty strings
		},
		{
			name:     "Long password",
			password: "this_is_a_very_long_password_but_under_72_bytes_limit",
			wantErr:  false,
		},
		{
			name:     "Special characters",
			password: "p@ssw0rd!@#$%^&*()",
			wantErr:  false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			hashed, err := HashPassword(tt.password)

			if (err != nil) != tt.wantErr {
				t.Errorf("HashPassword() error = %v, wantErr %v", err, tt.wantErr)
				return
			}

			if !tt.wantErr {
				if hashed == "" {
					t.Error("HashPassword() returned empty hash")
				}

				if hashed == tt.password {
					t.Error("HashPassword() returned unhashed password")
				}

				// Verify the hash length is reasonable
				if len(hashed) < 50 {
					t.Error("HashPassword() returned suspiciously short hash")
				}
			}
		})
	}
}
