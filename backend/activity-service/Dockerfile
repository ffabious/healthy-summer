FROM golang:1.24.4-alpine

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o activity-service ./cmd

EXPOSE 8081

CMD ["./activity-service"]
