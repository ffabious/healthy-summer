package auth

import (
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt/v5"
)

func TestJWTMiddleware(t *testing.T) {
	// Set up test environment
	gin.SetMode(gin.TestMode)
	originalSecret := os.Getenv("JWT_SECRET")
	defer os.Setenv("JWT_SECRET", originalSecret)
	os.Setenv("JWT_SECRET", "test-secret")

	tests := []struct {
		name           string
		authHeader     string
		expectedStatus int
		shouldContain  string
	}{
		{
			name:           "Valid token",
			authHeader:     "Bearer " + generateValidToken("user123"),
			expectedStatus: http.StatusOK,
			shouldContain:  "user123",
		},
		{
			name:           "Missing authorization header",
			authHeader:     "",
			expectedStatus: http.StatusUnauthorized,
			shouldContain:  "Missing or invalid token",
		},
		{
			name:           "Invalid bearer format",
			authHeader:     "InvalidToken",
			expectedStatus: http.StatusUnauthorized,
			shouldContain:  "Missing or invalid token",
		},
		{
			name:           "Invalid token",
			authHeader:     "Bearer invalid.token.here",
			expectedStatus: http.StatusUnauthorized,
			shouldContain:  "Invalid token",
		},
		{
			name:           "Token without user_id claim",
			authHeader:     "Bearer " + generateTokenWithoutUserID(),
			expectedStatus: http.StatusUnauthorized,
			shouldContain:  "Invalid claims",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Create router and add middleware
			router := gin.New()
			router.Use(JWTMiddleware())
			router.GET("/test", func(c *gin.Context) {
				userID, exists := c.Get("user_id")
				if exists {
					c.JSON(http.StatusOK, gin.H{"user_id": userID})
				} else {
					c.JSON(http.StatusOK, gin.H{"message": "success"})
				}
			})

			// Create request
			req := httptest.NewRequest("GET", "/test", nil)
			if tt.authHeader != "" {
				req.Header.Set("Authorization", tt.authHeader)
			}

			// Record response
			w := httptest.NewRecorder()
			router.ServeHTTP(w, req)

			// Assert status
			if w.Code != tt.expectedStatus {
				t.Errorf("Expected status %d, got %d", tt.expectedStatus, w.Code)
			}

			// Assert response contains expected content
			if !strings.Contains(w.Body.String(), tt.shouldContain) {
				t.Errorf("Expected response to contain '%s', got: %s", tt.shouldContain, w.Body.String())
			}
		})
	}
}

func TestExtractUserID(t *testing.T) {
	gin.SetMode(gin.TestMode)

	tests := []struct {
		name          string
		authorization string
		expectedID    string
		expectError   bool
		errorContains string
	}{
		{
			name:          "Valid token with user ID",
			authorization: "Bearer " + generateUnverifiedToken("user123"),
			expectedID:    "user123",
			expectError:   false,
		},
		{
			name:          "Missing authorization header",
			authorization: "",
			expectedID:    "",
			expectError:   true,
			errorContains: "missing or invalid token",
		},
		{
			name:          "Invalid bearer format",
			authorization: "InvalidFormat",
			expectedID:    "",
			expectError:   true,
			errorContains: "missing or invalid token",
		},
		{
			name:          "Invalid token format",
			authorization: "Bearer invalid.token",
			expectedID:    "",
			expectError:   true,
			errorContains: "failed to parse token",
		},
		{
			name:          "Token without user_id claim",
			authorization: "Bearer " + generateUnverifiedTokenWithoutUserID(),
			expectedID:    "",
			expectError:   true,
			errorContains: "invalid or missing user ID in claims",
		},
		{
			name:          "Token with empty user_id",
			authorization: "Bearer " + generateUnverifiedTokenWithEmptyUserID(),
			expectedID:    "",
			expectError:   true,
			errorContains: "invalid or missing user ID in claims",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// Create gin context
			w := httptest.NewRecorder()
			c, _ := gin.CreateTestContext(w)
			req := httptest.NewRequest("GET", "/test", nil)
			if tt.authorization != "" {
				req.Header.Set("Authorization", tt.authorization)
			}
			c.Request = req

			// Call function
			userID, err := ExtractUserID(c)

			// Assert results
			if tt.expectError {
				if err == nil {
					t.Errorf("Expected error but got none")
				} else if !strings.Contains(err.Error(), tt.errorContains) {
					t.Errorf("Expected error to contain '%s', got: %s", tt.errorContains, err.Error())
				}
				if userID != "" {
					t.Errorf("Expected empty userID on error, got: %s", userID)
				}
			} else {
				if err != nil {
					t.Errorf("Expected no error but got: %v", err)
				}
				if userID != tt.expectedID {
					t.Errorf("Expected userID '%s', got '%s'", tt.expectedID, userID)
				}
			}
		})
	}
}

// Helper functions for generating test tokens

func generateValidToken(userID string) string {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": userID,
		"exp":     time.Now().Add(time.Hour).Unix(),
	})
	tokenString, _ := token.SignedString([]byte("test-secret"))
	return tokenString
}

func generateTokenWithoutUserID() string {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"exp": time.Now().Add(time.Hour).Unix(),
	})
	tokenString, _ := token.SignedString([]byte("test-secret"))
	return tokenString
}

func generateUnverifiedToken(userID string) string {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": userID,
		"exp":     time.Now().Add(time.Hour).Unix(),
	})
	tokenString, _ := token.SignedString([]byte("any-secret"))
	return tokenString
}

func generateUnverifiedTokenWithoutUserID() string {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"exp": time.Now().Add(time.Hour).Unix(),
	})
	tokenString, _ := token.SignedString([]byte("any-secret"))
	return tokenString
}

func generateUnverifiedTokenWithEmptyUserID() string {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"user_id": "",
		"exp":     time.Now().Add(time.Hour).Unix(),
	})
	tokenString, _ := token.SignedString([]byte("any-secret"))
	return tokenString
}
