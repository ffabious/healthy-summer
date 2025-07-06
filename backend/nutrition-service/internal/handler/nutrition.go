package handler

import (
	"net/http"
)

func NutritionHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Nutrition handler"))
}
