#!/bin/bash
set -e

echo "Building TimeLeft Backend..."

# Build development image
docker build -t timeleft-backend:dev .

# Build production image
docker build -t timeleft-backend:prod --target base .

echo "Build completed successfully!"