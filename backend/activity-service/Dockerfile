# Builder
FROM golang:1.24.4-alpine AS builder

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go install github.com/swaggo/swag/cmd/swag@latest
RUN rm -rf ./docs && swag init --parseDependency --parseInternal -g cmd/main.go --output ./docs
RUN go build -o activity-service ./cmd

# Runtime
FROM alpine:3.20

RUN apk add --no-cache openssl

WORKDIR /app
COPY --from=builder /app/activity-service .
COPY --from=builder /app/docs ./docs

COPY ./entrypoint.sh .
RUN chmod +x entrypoint.sh

EXPOSE 8081
CMD ["./entrypoint.sh"]