package handler

import (
	"net/http"
)

func ActivityHandler(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	w.Write([]byte("Activity handler"))
}
