package handler

import (
	"net/http"
)

func ActivityHandler(w http.ResponseWriter, r *http.Request) {
	println("Activity handler called with method:", r.Method)
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Activity handler"))
}
