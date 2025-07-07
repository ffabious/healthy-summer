package handler

import (
	"net/http"
)

func NutritionHandler(w http.ResponseWriter, r *http.Request) {
	println("Nutrition handler called with method:", r.Method)
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Nutrition handler"))
}
