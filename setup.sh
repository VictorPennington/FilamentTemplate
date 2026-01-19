#!/bin/bash

# Laravel Project Setup Script
# This script automates the initial setup of a Laravel project

set -e  # Exit on any error

echo "=========================================="
echo "Starting Laravel Project Setup"
echo "=========================================="
echo ""

# Check if .env already exists
if [ -f ".env" ]; then
    echo "⚠️  .env file already exists. Skipping creation."
else
    echo "📝 Creating .env file from .env.example..."
    cp .env.example .env
    echo "✅ .env file created"
fi
echo ""

# Install Composer dependencies
echo "📦 Installing Composer dependencies..."
composer install
echo "✅ Composer dependencies installed"
echo ""

# Install Node dependencies
echo "📦 Installing Node dependencies..."
npm install
echo "✅ Node dependencies installed"
echo ""

# Create SQLite database file
echo "🗄️  Creating SQLite database file..."
mkdir -p database
touch database/database.sqlite
chmod 664 database/database.sqlite
echo "✅ SQLite database file created"
echo ""

# Generate application key
echo "🔑 Generating application key..."
php artisan key:generate
echo "✅ Application key generated"
echo ""

# Run database migrations
echo "🚀 Running database migrations..."
php artisan migrate
echo "✅ Database migrations completed"
echo ""

# Clear and cache configuration
echo "🧹 Clearing and caching configuration..."
php artisan config:cache
php artisan route:cache
php artisan view:cache
echo "✅ Configuration cached"
echo ""

echo "=========================================="
echo "✨ Setup completed successfully!"
echo "=========================================="
echo ""
echo "You can now run 'php artisan serve' to start the development server"
echo ""
