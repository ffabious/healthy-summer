#!/bin/sh

# Create certs if they don't exist
if [ ! -f /app/server.key ]; then
  echo "Generating self-signed TLS certificate..."
  openssl req -x509 -newkey rsa:2048 -nodes \
    -keyout /app/key.pem -out /app/cert.pem -days 365 \
    -subj "/CN=localhost"
fi

# Start the app with TLS
./user-service