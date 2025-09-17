#!/bin/bash
set -e

echo "Starting development environment..."

# Ensure environment file exists
if [ ! -f .env.development ]; then
    echo "Error: .env.development not found!"
    echo "Copy .env.example to .env.development and configure it."
    exit 1
fi

# Start development environment
docker-compose up --build

echo "Development environment started!"