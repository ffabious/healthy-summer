FROM golang:1.24.4-alpine

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go install github.com/swaggo/swag/cmd/swag@latest

RUN swag init --parseDependency --parseInternal -g cmd/main.go --output ./docs

RUN go build -o activity-service ./cmd

EXPOSE 8081

CMD ["./activity-service"]
