package model

import (
	"encoding/json"
	"testing"
	"time"

	"github.com/google/uuid"
)

func TestIntensityIsValid(t *testing.T) {
	tests := []struct {
		name      string
		intensity Intensity
		expected  bool
	}{
		{
			name:      "Valid low intensity",
			intensity: IntensityLow,
			expected:  true,
		},
		{
			name:      "Valid medium intensity",
			intensity: IntensityMedium,
			expected:  true,
		},
		{
			name:      "Valid high intensity",
			intensity: IntensityHigh,
			expected:  true,
		},
		{
			name:      "Invalid intensity",
			intensity: Intensity("invalid"),
			expected:  false,
		},
		{
			name:      "Empty intensity",
			intensity: Intensity(""),
			expected:  false,
		},
		{
			name:      "Case sensitive - uppercase LOW",
			intensity: Intensity("LOW"),
			expected:  false,
		},
		{
			name:      "Case sensitive - uppercase MEDIUM",
			intensity: Intensity("MEDIUM"),
			expected:  false,
		},
		{
			name:      "Case sensitive - uppercase HIGH",
			intensity: Intensity("HIGH"),
			expected:  false,
		},
		{
			name:      "Mixed case",
			intensity: Intensity("Low"),
			expected:  false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := tt.intensity.IsValid()
			if result != tt.expected {
				t.Errorf("Expected %v, got %v for intensity %q", tt.expected, result, tt.intensity)
			}
		})
	}
}

func TestPostActivityRequestJSONSerialization(t *testing.T) {
	timestamp := time.Now()
	
	request := PostActivityRequest{
		Type:        "running",
		DurationMin: 30,
		Intensity:   IntensityMedium,
		Calories:    300,
		Location:    "Park",
		Timestamp:   timestamp,
	}

	// Test marshaling to JSON
	jsonData, err := json.Marshal(request)
	if err != nil {
		t.Fatalf("Failed to marshal PostActivityRequest: %v", err)
	}

	// Test unmarshaling from JSON
	var unmarshaled PostActivityRequest
	err = json.Unmarshal(jsonData, &unmarshaled)
	if err != nil {
		t.Fatalf("Failed to unmarshal PostActivityRequest: %v", err)
	}

	// Verify fields
	if unmarshaled.Type != request.Type {
		t.Errorf("Expected Type %q, got %q", request.Type, unmarshaled.Type)
	}
	if unmarshaled.DurationMin != request.DurationMin {
		t.Errorf("Expected DurationMin %d, got %d", request.DurationMin, unmarshaled.DurationMin)
	}
	if unmarshaled.Intensity != request.Intensity {
		t.Errorf("Expected Intensity %q, got %q", request.Intensity, unmarshaled.Intensity)
	}
	if unmarshaled.Calories != request.Calories {
		t.Errorf("Expected Calories %d, got %d", request.Calories, unmarshaled.Calories)
	}
	if unmarshaled.Location != request.Location {
		t.Errorf("Expected Location %q, got %q", request.Location, unmarshaled.Location)
	}
}

func TestUpdateActivityRequestJSONSerialization(t *testing.T) {
	request := UpdateActivityRequest{
		Type:        "cycling",
		DurationMin: 45,
		Intensity:   IntensityHigh,
		Calories:    400,
		Location:    "Road",
	}

	// Test marshaling to JSON
	jsonData, err := json.Marshal(request)
	if err != nil {
		t.Fatalf("Failed to marshal UpdateActivityRequest: %v", err)
	}

	// Test unmarshaling from JSON
	var unmarshaled UpdateActivityRequest
	err = json.Unmarshal(jsonData, &unmarshaled)
	if err != nil {
		t.Fatalf("Failed to unmarshal UpdateActivityRequest: %v", err)
	}

	// Verify fields
	if unmarshaled.Type != request.Type {
		t.Errorf("Expected Type %q, got %q", request.Type, unmarshaled.Type)
	}
	if unmarshaled.DurationMin != request.DurationMin {
		t.Errorf("Expected DurationMin %d, got %d", request.DurationMin, unmarshaled.DurationMin)
	}
	if unmarshaled.Intensity != request.Intensity {
		t.Errorf("Expected Intensity %q, got %q", request.Intensity, unmarshaled.Intensity)
	}
	if unmarshaled.Calories != request.Calories {
		t.Errorf("Expected Calories %d, got %d", request.Calories, unmarshaled.Calories)
	}
	if unmarshaled.Location != request.Location {
		t.Errorf("Expected Location %q, got %q", request.Location, unmarshaled.Location)
	}
}

func TestPostStepEntryRequestJSONSerialization(t *testing.T) {
	timestamp := time.Now()
	
	request := PostStepEntryRequest{
		Date:  timestamp,
		Steps: 10000,
	}

	// Test marshaling to JSON
	jsonData, err := json.Marshal(request)
	if err != nil {
		t.Fatalf("Failed to marshal PostStepEntryRequest: %v", err)
	}

	// Test unmarshaling from JSON
	var unmarshaled PostStepEntryRequest
	err = json.Unmarshal(jsonData, &unmarshaled)
	if err != nil {
		t.Fatalf("Failed to unmarshal PostStepEntryRequest: %v", err)
	}

	// Verify fields
	if !unmarshaled.Date.Equal(request.Date) {
		t.Errorf("Expected Date %v, got %v", request.Date, unmarshaled.Date)
	}
	if unmarshaled.Steps != request.Steps {
		t.Errorf("Expected Steps %d, got %d", request.Steps, unmarshaled.Steps)
	}
}

func TestActivityJSONSerialization(t *testing.T) {
	id := uuid.New()
	userID := uuid.New()
	timestamp := time.Now()
	
	activity := Activity{
		ID:          id,
		UserID:      userID,
		Type:        "swimming",
		DurationMin: 60,
		Intensity:   IntensityLow,
		Calories:    250,
		Location:    "Pool",
		Timestamp:   timestamp,
	}

	// Test marshaling to JSON
	jsonData, err := json.Marshal(activity)
	if err != nil {
		t.Fatalf("Failed to marshal Activity: %v", err)
	}

	// Test unmarshaling from JSON
	var unmarshaled Activity
	err = json.Unmarshal(jsonData, &unmarshaled)
	if err != nil {
		t.Fatalf("Failed to unmarshal Activity: %v", err)
	}

	// Verify fields
	if unmarshaled.ID != activity.ID {
		t.Errorf("Expected ID %v, got %v", activity.ID, unmarshaled.ID)
	}
	if unmarshaled.UserID != activity.UserID {
		t.Errorf("Expected UserID %v, got %v", activity.UserID, unmarshaled.UserID)
	}
	if unmarshaled.Type != activity.Type {
		t.Errorf("Expected Type %q, got %q", activity.Type, unmarshaled.Type)
	}
	if unmarshaled.DurationMin != activity.DurationMin {
		t.Errorf("Expected DurationMin %d, got %d", activity.DurationMin, unmarshaled.DurationMin)
	}
	if unmarshaled.Intensity != activity.Intensity {
		t.Errorf("Expected Intensity %q, got %q", activity.Intensity, unmarshaled.Intensity)
	}
	if unmarshaled.Calories != activity.Calories {
		t.Errorf("Expected Calories %d, got %d", activity.Calories, unmarshaled.Calories)
	}
	if unmarshaled.Location != activity.Location {
		t.Errorf("Expected Location %q, got %q", activity.Location, unmarshaled.Location)
	}
}

func TestStepEntryJSONSerialization(t *testing.T) {
	id := uuid.New()
	userID := uuid.New()
	date := time.Now()
	
	stepEntry := StepEntry{
		ID:     id,
		UserID: userID,
		Date:   date,
		Steps:  8500,
	}

	// Test marshaling to JSON
	jsonData, err := json.Marshal(stepEntry)
	if err != nil {
		t.Fatalf("Failed to marshal StepEntry: %v", err)
	}

	// Test unmarshaling from JSON
	var unmarshaled StepEntry
	err = json.Unmarshal(jsonData, &unmarshaled)
	if err != nil {
		t.Fatalf("Failed to unmarshal StepEntry: %v", err)
	}

	// Verify fields
	if unmarshaled.ID != stepEntry.ID {
		t.Errorf("Expected ID %v, got %v", stepEntry.ID, unmarshaled.ID)
	}
	if unmarshaled.UserID != stepEntry.UserID {
		t.Errorf("Expected UserID %v, got %v", stepEntry.UserID, unmarshaled.UserID)
	}
	if !unmarshaled.Date.Equal(stepEntry.Date) {
		t.Errorf("Expected Date %v, got %v", stepEntry.Date, unmarshaled.Date)
	}
	if unmarshaled.Steps != stepEntry.Steps {
		t.Errorf("Expected Steps %d, got %d", stepEntry.Steps, unmarshaled.Steps)
	}
}

func TestIntensityConstants(t *testing.T) {
	// Test that intensity constants are what we expect
	if IntensityLow != "low" {
		t.Errorf("Expected IntensityLow to be 'low', got %q", IntensityLow)
	}
	if IntensityMedium != "medium" {
		t.Errorf("Expected IntensityMedium to be 'medium', got %q", IntensityMedium)
	}
	if IntensityHigh != "high" {
		t.Errorf("Expected IntensityHigh to be 'high', got %q", IntensityHigh)
	}
}
