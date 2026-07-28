#!/bin/bash

# Rename Project Script (Host/WSL side)
# This script handles renaming the template to your specific project name.

set -e

echo "=========================================="
echo "Renaming Filament Template Project"
echo "=========================================="

# Ask for project name
read -p "Enter your new project name (e.g. MyAwesomeApp): " PROJECT_NAME

if [ -z "$PROJECT_NAME" ]; then
    echo "❌ Project name cannot be empty!"
    exit 1
fi

PROJECT_NAME_LOWER=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')

echo ""
echo "📝 Setting project name to: $PROJECT_NAME"
echo "📝 Slugified name: $PROJECT_NAME_LOWER"
echo ""

# Update devcontainer.json
if [ -f ".devcontainer/devcontainer.json" ]; then
    sed -i "s/\"name\": \".*\"/\"name\": \"$PROJECT_NAME\"/" .devcontainer/devcontainer.json
    echo "✅ Updated .devcontainer/devcontainer.json"
fi

# Update docker-compose.yml
if [ -f ".devcontainer/docker-compose.yml" ]; then
    sed -i "s/^name: .*/name: $PROJECT_NAME/" .devcontainer/docker-compose.yml
    sed -i "s/image: .*/image: $PROJECT_NAME_LOWER:latest/" .devcontainer/docker-compose.yml
    echo "✅ Updated .devcontainer/docker-compose.yml (name and image)"
fi

# Set up .env
if [ ! -f ".env" ]; then
    echo "📝 Creating .env from .env.example..."
    cp .env.example .env
fi

# Update APP_NAME in .env
sed -i "s/^APP_NAME=.*/APP_NAME=\"$PROJECT_NAME\"/" .env
echo "✅ Updated APP_NAME in .env"

# Update composer.json name
if [ -f "composer.json" ]; then
    sed -i "0,/\"name\": \".*\"/s//\"name\": \"template\/$PROJECT_NAME_LOWER\"/" composer.json
    echo "✅ Updated composer.json name"
fi

echo ""
echo "=========================================="
echo "✨ Renaming completed!"
echo "=========================================="
echo "Next steps:"
echo "1. Re-open this folder in VS Code Dev Container."
echo "2. The container will automatically run the installation script."
echo "=========================================="
