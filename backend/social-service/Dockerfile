FROM golang:1.24.4-alpine

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN go build -o social-service ./cmd

EXPOSE 8083

CMD ["./social-service"]
