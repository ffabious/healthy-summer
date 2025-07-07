FROM golang:1.24.4-alpine

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o nutrition-service ./cmd

EXPOSE 8082

CMD ["./nutrition-service"]
