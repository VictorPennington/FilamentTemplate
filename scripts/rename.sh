#!/bin/bash

# Rename Project Script (Host/WSL side)
# This script handles renaming the template to your specific project name,
# building a local Docker image, and configuring the environment.

set -e

echo "=========================================="
echo "🚀 Renaming Filament Template Project"
echo "=========================================="

# ---------------------------------------------------------
# 1. Project Information Gathering
# ---------------------------------------------------------

# Ask for project name
read -p "Enter your new project name (e.g. MyAwesomeApp): " PROJECT_NAME

if [ -z "$PROJECT_NAME" ]; then
    echo "❌ Project name cannot be empty!"
    exit 1
fi

# Ask for database port
read -p "Enter database host port (default: 3312): " DB_PORT
DB_PORT=${DB_PORT:-3312}

# Ask for phpMyAdmin port
read -p "Enter phpMyAdmin host port (default: 8092): " PMA_PORT
PMA_PORT=${PMA_PORT:-8092}

PROJECT_NAME_LOWER=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')
IMAGE_TAG="filament-app:$PROJECT_NAME_LOWER"

echo ""
echo "📝 Project name: $PROJECT_NAME"
echo "📝 Slugified name: $PROJECT_NAME_LOWER"
echo "📝 Docker Image Tag: $IMAGE_TAG"
echo "📝 Database port: $DB_PORT"
echo "📝 phpMyAdmin port: $PMA_PORT"
echo ""

# ---------------------------------------------------------
# 2. Docker Image Building
# ---------------------------------------------------------

echo "🏗️  Building local Docker image..."
if command -v docker >/dev/null 2>&1; then
    docker build -t "$IMAGE_TAG" -f .devcontainer/Dockerfile .
    echo "✅ Docker image built: $IMAGE_TAG"
else
    echo "⚠️  Docker command not found. Skipping build. You may need to build it manually."
fi

# ---------------------------------------------------------
# 3. Configuration Updates
# ---------------------------------------------------------

echo "⚙️  Updating configurations..."

# Update devcontainer.json
if [ -f ".devcontainer/devcontainer.json" ]; then
    sed -i "s/\"name\": \".*\"/\"name\": \"$PROJECT_NAME\"/" .devcontainer/devcontainer.json
    echo "✅ Updated .devcontainer/devcontainer.json"
fi

# Update docker-compose.yml
if [ -f ".devcontainer/docker-compose.yml" ]; then
    sed -i "s/^name: .*/name: $PROJECT_NAME/" .devcontainer/docker-compose.yml
    sed -i "s/image: filament-app:template/image: $IMAGE_TAG/" .devcontainer/docker-compose.yml
    
    # Rename MySQL service variables
    sed -i "s/container_name: filament-db/container_name: ${PROJECT_NAME_LOWER}-db/" .devcontainer/docker-compose.yml
    sed -i "s/container_name: filament-phpmyadmin/container_name: ${PROJECT_NAME_LOWER}-phpmyadmin/" .devcontainer/docker-compose.yml
    sed -i "s/MYSQL_DATABASE: .*/MYSQL_DATABASE: ${PROJECT_NAME_LOWER}_db/" .devcontainer/docker-compose.yml
    sed -i "s/GRANT ALL PRIVILEGES ON filament.* TO 'filament_user'@'%'; GRANT ALL PRIVILEGES ON test_db.* TO 'filament_user'@'%'; CREATE DATABASE IF NOT EXISTS filament; CREATE DATABASE IF NOT EXISTS test_db; GRANT ALL PRIVILEGES ON filament.* TO 'filament_user'@'%'; GRANT ALL PRIVILEGES ON test_db.* TO 'filament_user'@'%';/GRANT ALL PRIVILEGES ON ${PROJECT_NAME_LOWER}_db.* TO '${PROJECT_NAME_LOWER}_user'@'%'; GRANT ALL PRIVILEGES ON ${PROJECT_NAME_LOWER}_test_db.* TO '${PROJECT_NAME_LOWER}_user'@'%'; CREATE DATABASE IF NOT EXISTS ${PROJECT_NAME_LOWER}_db; CREATE DATABASE IF NOT EXISTS ${PROJECT_NAME_LOWER}_test_db; GRANT ALL PRIVILEGES ON ${PROJECT_NAME_LOWER}_db.* TO '${PROJECT_NAME_LOWER}_user'@'%'; GRANT ALL PRIVILEGES ON ${PROJECT_NAME_LOWER}_test_db.* TO '${PROJECT_NAME_LOWER}_user'@'%';/" .devcontainer/docker-compose.yml
    sed -i "s/DB_DATABASE: \"filament\"/DB_DATABASE: \"${PROJECT_NAME_LOWER}_db\"/" .devcontainer/docker-compose.yml
    sed -i "s/MYSQL_USER: .*/MYSQL_USER: ${PROJECT_NAME_LOWER}_user/" .devcontainer/docker-compose.yml
    sed -i "s/MYSQL_PASSWORD: .*/MYSQL_PASSWORD: filament_password/" .devcontainer/docker-compose.yml
    
    # Update PHPUnit test database
    if [ -f "phpunit.xml" ]; then
        sed -i "s/<env name=\"DB_DATABASE\" value=\"test_db\"\/>/<env name=\"DB_DATABASE\" value=\"${PROJECT_NAME_LOWER}_test_db\"\/>/g" phpunit.xml
    fi
    sed -i "s/MYSQL_ROOT_PASSWORD: .*/MYSQL_ROOT_PASSWORD: filament_password/" .devcontainer/docker-compose.yml
    sed -i "s/PMA_PASSWORD: .*/PMA_PASSWORD: filament_password/" .devcontainer/docker-compose.yml
    
    # Update Ports
    sed -i "s/\"3312:3306\"/\"$DB_PORT:3306\"/" .devcontainer/docker-compose.yml
    sed -i "s/\"8092:80\"/\"$PMA_PORT:80\"/" .devcontainer/docker-compose.yml

    echo "✅ Updated .devcontainer/docker-compose.yml (services, image, and ports)"
fi

# ---------------------------------------------------------
# 4. Environment (.env) Setup
# ---------------------------------------------------------

if [ ! -f ".env" ]; then
    echo "📝 Creating .env from .env.example..."
    if [ -f ".env.example" ]; then
        cp .env.example .env
    else
        touch .env
    fi
fi

# Update APP_NAME in .env
sed -i "s/^APP_NAME=.*/APP_NAME=\"$PROJECT_NAME\"/" .env

# Update DB configuration in .env
sed -i "s/^DB_CONNECTION=.*/DB_CONNECTION=mysql/" .env
sed -i "s/^# DB_HOST=.*/DB_HOST=db/" .env
sed -i "s/^# DB_PORT=.*/DB_PORT=3306/" .env
sed -i "s/^# DB_DATABASE=.*/DB_DATABASE=${PROJECT_NAME_LOWER}_db/" .env
sed -i "s/^# DB_USERNAME=.*/DB_USERNAME=root/" .env
sed -i "s/^# DB_PASSWORD=.*/DB_PASSWORD=filament_password/" .env

# Handle already uncommented DB variables if any
sed -i "s/^DB_HOST=.*/DB_HOST=db/" .env
sed -i "s/^DB_PORT=.*/DB_PORT=3306/" .env
sed -i "s/^DB_DATABASE=.*/DB_DATABASE=${PROJECT_NAME_LOWER}_db/" .env
sed -i "s/^DB_USERNAME=.*/DB_USERNAME=root/" .env
sed -i "s/^DB_PASSWORD=.*/DB_PASSWORD=filament_password/" .env

echo "✅ Updated .env configuration"

# ---------------------------------------------------------
# 5. Composer & Finalization
# ---------------------------------------------------------

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
echo "2. The container will use the pre-built '$IMAGE_TAG' image."
echo "=========================================="
