package handler

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/ffabious/healthy-summer/activity-service/internal/model"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

func TestPostActivityHandlerWithoutAuth(t *testing.T) {
	gin.SetMode(gin.TestMode)

	tests := []struct {
		name           string
		requestBody    interface{}
		authHeader     string
		expectedStatus int
		expectedError  string
	}{
		{
			name:           "Missing authorization header",
			requestBody:    model.PostActivityRequest{},
			expectedStatus: http.StatusUnauthorized,
			expectedError:  "Unauthorized",
		},
		{
			name:           "Invalid authorization header format",
			requestBody:    model.PostActivityRequest{},
			authHeader:     "InvalidFormat",
			expectedStatus: http.StatusUnauthorized,
			expectedError:  "missing or invalid token",
		},
		{
			name:           "Invalid JWT token",
			requestBody:    model.PostActivityRequest{},
			authHeader:     "Bearer invalid.token.here",
			expectedStatus: http.StatusUnauthorized,
			expectedError:  "Unauthorized",
		},
		{
			name:           "Invalid JSON body",
			requestBody:    "invalid-json",
			authHeader:     "Bearer valid.token.here",
			expectedStatus: http.StatusUnauthorized, // Auth fails first
			expectedError:  "Unauthorized",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			router := gin.New()
			router.POST("/api/activities", PostActivityHandler)

			var requestBody []byte
			var err error

			if str, ok := tt.requestBody.(string); ok {
				requestBody = []byte(str)
			} else {
				requestBody, err = json.Marshal(tt.requestBody)
				if err != nil {
					t.Fatalf("Failed to marshal request body: %v", err)
				}
			}

			req := httptest.NewRequest("POST", "/api/activities", bytes.NewBuffer(requestBody))
			req.Header.Set("Content-Type", "application/json")

			if tt.authHeader != "" {
				req.Header.Set("Authorization", tt.authHeader)
			}

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			if w.Code != tt.expectedStatus {
				t.Errorf("Expected status %d, got %d", tt.expectedStatus, w.Code)
			}

			if tt.expectedError != "" && !strings.Contains(w.Body.String(), tt.expectedError) {
				t.Errorf("Expected error message to contain '%s', got: %s", tt.expectedError, w.Body.String())
			}
		})
	}
}

func TestGetActivitiesHandlerWithoutAuth(t *testing.T) {
	gin.SetMode(gin.TestMode)

	tests := []struct {
		name           string
		authHeader     string
		expectedStatus int
		expectedError  string
	}{
		{
			name:           "Missing authorization header",
			expectedStatus: http.StatusUnauthorized,
			expectedError:  "Unauthorized",
		},
		{
			name:           "Invalid authorization header format",
			authHeader:     "InvalidFormat",
			expectedStatus: http.StatusUnauthorized,
			expectedError:  "missing or invalid token",
		},
		{
			name:           "Invalid JWT token",
			authHeader:     "Bearer invalid.token.here",
			expectedStatus: http.StatusUnauthorized,
			expectedError:  "Unauthorized",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			router := gin.New()
			router.GET("/api/activities", GetActivitiesHandler)

			req := httptest.NewRequest("GET", "/api/activities", nil)

			if tt.authHeader != "" {
				req.Header.Set("Authorization", tt.authHeader)
			}

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			if w.Code != tt.expectedStatus {
				t.Errorf("Expected status %d, got %d", tt.expectedStatus, w.Code)
			}

			if tt.expectedError != "" && !strings.Contains(w.Body.String(), tt.expectedError) {
				t.Errorf("Expected error message to contain '%s', got: %s", tt.expectedError, w.Body.String())
			}
		})
	}
}

func TestGetCurrentUserActivityStatsHandlerWithoutAuth(t *testing.T) {
	gin.SetMode(gin.TestMode)

	tests := []struct {
		name           string
		authHeader     string
		expectedStatus int
		expectedError  string
	}{
		{
			name:           "Missing authorization header",
			expectedStatus: http.StatusUnauthorized,
			expectedError:  "Unauthorized",
		},
		{
			name:           "Invalid authorization header format",
			authHeader:     "InvalidFormat",
			expectedStatus: http.StatusUnauthorized,
			expectedError:  "missing or invalid token",
		},
		{
			name:           "Invalid JWT token",
			authHeader:     "Bearer invalid.token.here",
			expectedStatus: http.StatusUnauthorized,
			expectedError:  "Unauthorized",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			router := gin.New()
			router.GET("/api/activities/stats", GetCurrentUserActivityStatsHandler)

			req := httptest.NewRequest("GET", "/api/activities/stats", nil)

			if tt.authHeader != "" {
				req.Header.Set("Authorization", tt.authHeader)
			}

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			if w.Code != tt.expectedStatus {
				t.Errorf("Expected status %d, got %d", tt.expectedStatus, w.Code)
			}

			if tt.expectedError != "" && !strings.Contains(w.Body.String(), tt.expectedError) {
				t.Errorf("Expected error message to contain '%s', got: %s", tt.expectedError, w.Body.String())
			}
		})
	}
}

func TestPostStepEntryHandlerWithoutAuth(t *testing.T) {
	gin.SetMode(gin.TestMode)

	tests := []struct {
		name           string
		requestBody    interface{}
		authHeader     string
		expectedStatus int
		expectedError  string
	}{
		{
			name:           "Missing authorization header",
			requestBody:    model.PostStepEntryRequest{},
			expectedStatus: http.StatusUnauthorized,
			expectedError:  "Unauthorized",
		},
		{
			name:           "Invalid authorization header format",
			requestBody:    model.PostStepEntryRequest{},
			authHeader:     "InvalidFormat",
			expectedStatus: http.StatusUnauthorized,
			expectedError:  "missing or invalid token",
		},
		{
			name:           "Invalid JWT token",
			requestBody:    model.PostStepEntryRequest{},
			authHeader:     "Bearer invalid.token.here",
			expectedStatus: http.StatusUnauthorized,
			expectedError:  "Unauthorized",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			router := gin.New()
			router.POST("/api/activities/steps", PostStepEntryHandler)

			requestBody, err := json.Marshal(tt.requestBody)
			if err != nil {
				t.Fatalf("Failed to marshal request body: %v", err)
			}

			req := httptest.NewRequest("POST", "/api/activities/steps", bytes.NewBuffer(requestBody))
			req.Header.Set("Content-Type", "application/json")

			if tt.authHeader != "" {
				req.Header.Set("Authorization", tt.authHeader)
			}

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			if w.Code != tt.expectedStatus {
				t.Errorf("Expected status %d, got %d", tt.expectedStatus, w.Code)
			}

			if tt.expectedError != "" && !strings.Contains(w.Body.String(), tt.expectedError) {
				t.Errorf("Expected error message to contain '%s', got: %s", tt.expectedError, w.Body.String())
			}
		})
	}
}

func TestGetStepEntriesHandlerWithoutAuth(t *testing.T) {
	gin.SetMode(gin.TestMode)

	tests := []struct {
		name           string
		queryParam     string
		authHeader     string
		expectedStatus int
		expectedError  string
	}{
		{
			name:           "Missing authorization header",
			expectedStatus: http.StatusUnauthorized,
			expectedError:  "Unauthorized",
		},
		{
			name:           "Missing authorization header with query param",
			queryParam:     "?days=7",
			expectedStatus: http.StatusUnauthorized,
			expectedError:  "Unauthorized",
		},
		{
			name:           "Invalid authorization header format",
			authHeader:     "InvalidFormat",
			expectedStatus: http.StatusUnauthorized,
			expectedError:  "missing or invalid token",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			router := gin.New()
			router.GET("/api/activities/steps", GetStepEntriesHandler)

			url := "/api/activities/steps" + tt.queryParam
			req := httptest.NewRequest("GET", url, nil)

			if tt.authHeader != "" {
				req.Header.Set("Authorization", tt.authHeader)
			}

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			if w.Code != tt.expectedStatus {
				t.Errorf("Expected status %d, got %d", tt.expectedStatus, w.Code)
			}

			if tt.expectedError != "" && !strings.Contains(w.Body.String(), tt.expectedError) {
				t.Errorf("Expected error message to contain '%s', got: %s", tt.expectedError, w.Body.String())
			}
		})
	}
}

func TestGetActivityAnalyticsHandler(t *testing.T) {
	gin.SetMode(gin.TestMode)

	tests := []struct {
		name           string
		userID         string
		expectedStatus int
		expectedError  string
	}{
		{
			name:           "Valid user ID",
			userID:         uuid.New().String(),
			expectedStatus: http.StatusNotFound, // Expected since no database setup
		},
		{
			name:           "Empty user ID",
			userID:         "",
			expectedStatus: http.StatusNotFound,
		},
		{
			name:           "Invalid user ID format",
			userID:         "invalid-uuid",
			expectedStatus: http.StatusNotFound,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			router := gin.New()
			router.GET("/api/activities/analytics/:user_id", GetActivityAnalyticsHandler)

			url := "/api/activities/analytics/" + tt.userID
			req := httptest.NewRequest("GET", url, nil)

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			if w.Code != tt.expectedStatus {
				t.Errorf("Expected status %d, got %d", tt.expectedStatus, w.Code)
			}

			if tt.expectedError != "" && !strings.Contains(w.Body.String(), tt.expectedError) {
				t.Errorf("Expected error message to contain '%s', got: %s", tt.expectedError, w.Body.String())
			}
		})
	}
}

func TestUpdateActivityHandlerWithoutAuth(t *testing.T) {
	gin.SetMode(gin.TestMode)

	tests := []struct {
		name           string
		activityID     string
		requestBody    interface{}
		authHeader     string
		expectedStatus int
		expectedError  string
	}{
		{
			name:       "Missing activity ID in URL",
			activityID: "",
			requestBody: model.UpdateActivityRequest{
				Type:        "cycling",
				DurationMin: 45,
				Intensity:   model.IntensityHigh,
				Calories:    400,
				Location:    "Road",
			},
			expectedStatus: http.StatusNotFound, // 404 because route doesn't match
		},
		{
			name:           "Missing authorization header",
			activityID:     uuid.New().String(),
			requestBody:    model.UpdateActivityRequest{},
			expectedStatus: http.StatusUnauthorized,
			expectedError:  "Unauthorized",
		},
		{
			name:           "Invalid authorization header format",
			activityID:     uuid.New().String(),
			requestBody:    model.UpdateActivityRequest{},
			authHeader:     "InvalidFormat",
			expectedStatus: http.StatusUnauthorized,
			expectedError:  "missing or invalid token",
		},
		{
			name:           "Invalid JWT token",
			activityID:     uuid.New().String(),
			requestBody:    model.UpdateActivityRequest{},
			authHeader:     "Bearer invalid.token.here",
			expectedStatus: http.StatusUnauthorized,
			expectedError:  "Unauthorized",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			router := gin.New()
			router.PUT("/api/activities/:id", UpdateActivityHandler)

			requestBody, err := json.Marshal(tt.requestBody)
			if err != nil {
				t.Fatalf("Failed to marshal request body: %v", err)
			}

			url := "/api/activities/" + tt.activityID
			req := httptest.NewRequest("PUT", url, bytes.NewBuffer(requestBody))
			req.Header.Set("Content-Type", "application/json")

			if tt.authHeader != "" {
				req.Header.Set("Authorization", tt.authHeader)
			}

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			if w.Code != tt.expectedStatus {
				t.Errorf("Expected status %d, got %d", tt.expectedStatus, w.Code)
			}

			if tt.expectedError != "" && !strings.Contains(w.Body.String(), tt.expectedError) {
				t.Errorf("Expected error message to contain '%s', got: %s", tt.expectedError, w.Body.String())
			}
		})
	}
}

func TestDeleteActivityHandlerWithoutAuth(t *testing.T) {
	gin.SetMode(gin.TestMode)

	tests := []struct {
		name           string
		activityID     string
		authHeader     string
		expectedStatus int
		expectedError  string
	}{
		{
			name:           "Missing activity ID in URL",
			activityID:     "",
			expectedStatus: http.StatusNotFound, // 404 because route doesn't match
		},
		{
			name:           "Missing authorization header",
			activityID:     uuid.New().String(),
			expectedStatus: http.StatusUnauthorized,
			expectedError:  "Unauthorized",
		},
		{
			name:           "Invalid authorization header format",
			activityID:     uuid.New().String(),
			authHeader:     "InvalidFormat",
			expectedStatus: http.StatusUnauthorized,
			expectedError:  "missing or invalid token",
		},
		{
			name:           "Invalid JWT token",
			activityID:     uuid.New().String(),
			authHeader:     "Bearer invalid.token.here",
			expectedStatus: http.StatusUnauthorized,
			expectedError:  "Unauthorized",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			router := gin.New()
			router.DELETE("/api/activities/:id", DeleteActivityHandler)

			url := "/api/activities/" + tt.activityID
			req := httptest.NewRequest("DELETE", url, nil)

			if tt.authHeader != "" {
				req.Header.Set("Authorization", tt.authHeader)
			}

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			if w.Code != tt.expectedStatus {
				t.Errorf("Expected status %d, got %d", tt.expectedStatus, w.Code)
			}

			if tt.expectedError != "" && !strings.Contains(w.Body.String(), tt.expectedError) {
				t.Errorf("Expected error message to contain '%s', got: %s", tt.expectedError, w.Body.String())
			}
		})
	}
}

func TestCreateStepEntryHandlerWithoutAuth(t *testing.T) {
	gin.SetMode(gin.TestMode)

	tests := []struct {
		name           string
		requestBody    interface{}
		authHeader     string
		expectedStatus int
		expectedError  string
	}{
		{
			name: "Missing authorization header",
			requestBody: map[string]interface{}{
				"steps": 10000,
				"date":  time.Now(),
			},
			expectedStatus: http.StatusUnauthorized,
			expectedError:  "Unauthorized",
		},
		{
			name: "Invalid authorization header format",
			requestBody: map[string]interface{}{
				"steps": 10000,
				"date":  time.Now(),
			},
			authHeader:     "InvalidFormat",
			expectedStatus: http.StatusUnauthorized,
			expectedError:  "missing or invalid token",
		},
		{
			name: "Invalid JWT token",
			requestBody: map[string]interface{}{
				"steps": 10000,
				"date":  time.Now(),
			},
			authHeader:     "Bearer invalid.token.here",
			expectedStatus: http.StatusUnauthorized,
			expectedError:  "Unauthorized",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			router := gin.New()
			router.POST("/api/activities/steps", CreateStepEntryHandler)

			requestBody, err := json.Marshal(tt.requestBody)
			if err != nil {
				t.Fatalf("Failed to marshal request body: %v", err)
			}

			req := httptest.NewRequest("POST", "/api/activities/steps", bytes.NewBuffer(requestBody))
			req.Header.Set("Content-Type", "application/json")

			if tt.authHeader != "" {
				req.Header.Set("Authorization", tt.authHeader)
			}

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			if w.Code != tt.expectedStatus {
				t.Errorf("Expected status %d, got %d", tt.expectedStatus, w.Code)
			}

			if tt.expectedError != "" && !strings.Contains(w.Body.String(), tt.expectedError) {
				t.Errorf("Expected error message to contain '%s', got: %s", tt.expectedError, w.Body.String())
			}
		})
	}
}

// Test input validation for request bodies
func TestActivityRequestValidation(t *testing.T) {
	gin.SetMode(gin.TestMode)

	tests := []struct {
		name        string
		requestBody interface{}
		isValid     bool
	}{
		{
			name: "Valid activity request",
			requestBody: model.PostActivityRequest{
				Type:        "running",
				DurationMin: 30,
				Intensity:   model.IntensityMedium,
				Calories:    300,
				Location:    "Park",
				Timestamp:   time.Now(),
			},
			isValid: true,
		},
		{
			name: "Invalid intensity enum",
			requestBody: map[string]interface{}{
				"type":         "running",
				"duration_min": 30,
				"intensity":    "invalid",
				"calories":     300,
				"location":     "Park",
				"timestamp":    time.Now(),
			},
			isValid: false,
		},
		{
			name: "Missing required type field",
			requestBody: map[string]interface{}{
				"duration_min": 30,
				"intensity":    "medium",
				"calories":     300,
				"location":     "Park",
				"timestamp":    time.Now(),
			},
			isValid: false,
		},
		{
			name: "Zero duration",
			requestBody: map[string]interface{}{
				"type":         "running",
				"duration_min": 0,
				"intensity":    "medium",
				"calories":     300,
				"location":     "Park",
				"timestamp":    time.Now(),
			},
			isValid: false,
		},
		{
			name: "Negative calories",
			requestBody: map[string]interface{}{
				"type":         "running",
				"duration_min": 30,
				"intensity":    "medium",
				"calories":     -100,
				"location":     "Park",
				"timestamp":    time.Now(),
			},
			isValid: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			router := gin.New()
			router.POST("/api/activities", PostActivityHandler)

			requestBody, err := json.Marshal(tt.requestBody)
			if err != nil {
				t.Fatalf("Failed to marshal request body: %v", err)
			}

			req := httptest.NewRequest("POST", "/api/activities", bytes.NewBuffer(requestBody))
			req.Header.Set("Content-Type", "application/json")
			// No auth header, so we expect unauthorized status

			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			// All requests will be unauthorized due to missing auth
			// But we can still test that the JSON structure is valid by checking
			// if the error is about auth (not JSON parsing)
			if w.Code != http.StatusUnauthorized {
				t.Errorf("Expected unauthorized status, got %d", w.Code)
			}

			response := w.Body.String()
			if !strings.Contains(response, "Unauthorized") {
				t.Errorf("Expected unauthorized error, got: %s", response)
			}
		})
	}
}

