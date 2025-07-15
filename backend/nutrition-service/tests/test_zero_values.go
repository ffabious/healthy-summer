package main

import (
	"bytes"
	"fmt"
	"net/http"
	"net/http/httptest"

	"github.com/ffabious/healthy-summer/nutrition-service/internal/model"
	"github.com/gin-gonic/gin"
)

func testMealValidation(c *gin.Context) {
	var req model.PostMealRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data", "details": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "meal": req})
}

func testWaterValidation(c *gin.Context) {
	var req model.PostWaterRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request data", "details": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"success": true, "water": req})
}

func main() {
	gin.SetMode(gin.TestMode)

	// Test data with zero carbohydrates (like meat)
	testCases := []struct {
		name string
		json string
	}{
		{
			name: "Grilled Chicken Breast (0 carbs)",
			json: `{
				"name": "Grilled Chicken Breast",
				"calories": 165,
				"protein": 31.0,
				"carbohydrates": 0.0,
				"fats": 3.6
			}`,
		},
		{
			name: "White Rice (0 fats)",
			json: `{
				"name": "White Rice",
				"calories": 130,
				"protein": 2.7,
				"carbohydrates": 28.0,
				"fats": 0.0
			}`,
		},
		{
			name: "Olive Oil (0 protein, 0 carbs)",
			json: `{
				"name": "Olive Oil (1 tbsp)",
				"calories": 120,
				"protein": 0.0,
				"carbohydrates": 0.0,
				"fats": 14.0
			}`,
		},
	}

	fmt.Println("Testing meal validation with zero macronutrients...")

	router := gin.New()
	router.POST("/test-meal", testMealValidation)
	router.POST("/test-water", testWaterValidation)

	for _, tc := range testCases {
		fmt.Printf("\nTesting: %s\n", tc.name)

		req, _ := http.NewRequest("POST", "/test-meal", bytes.NewBufferString(tc.json))
		req.Header.Set("Content-Type", "application/json")

		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		if w.Code == http.StatusOK {
			fmt.Printf("✅ Validation passed - Status: %d\n", w.Code)
		} else {
			fmt.Printf("❌ Validation failed - Status: %d, Body: %s\n", w.Code, w.Body.String())
		}
	}

	// Test water intake
	fmt.Println("\n\nTesting water intake validation...")

	waterTests := []struct {
		name       string
		json       string
		shouldPass bool
	}{
		{
			name:       "Valid water intake",
			json:       `{"volume_ml": 250.0}`,
			shouldPass: true,
		},
		{
			name:       "Zero water intake (should fail)",
			json:       `{"volume_ml": 0.0}`,
			shouldPass: false,
		},
		{
			name:       "Negative water intake (should fail)",
			json:       `{"volume_ml": -100.0}`,
			shouldPass: false,
		},
	}

	for _, tc := range waterTests {
		fmt.Printf("\nTesting: %s\n", tc.name)

		req, _ := http.NewRequest("POST", "/test-water", bytes.NewBufferString(tc.json))
		req.Header.Set("Content-Type", "application/json")

		w := httptest.NewRecorder()
		router.ServeHTTP(w, req)

		passed := w.Code == http.StatusOK
		if passed == tc.shouldPass {
			if passed {
				fmt.Printf("✅ Correctly passed - Status: %d\n", w.Code)
			} else {
				fmt.Printf("✅ Correctly rejected - Status: %d\n", w.Code)
			}
		} else {
			if passed {
				fmt.Printf("❌ Should have failed but passed - Status: %d\n", w.Code)
			} else {
				fmt.Printf("❌ Should have passed but failed - Status: %d, Body: %s\n", w.Code, w.Body.String())
			}
		}
	}
}
