#!/bin/bash

# Install Script (Container side)
# This script handles the installation of dependencies and database setup.

set -e

echo "=========================================="
echo "Starting Application Installation"
echo "=========================================="

# Install dependencies
echo "📦 Installing Composer dependencies..."
composer install --no-interaction --prefer-dist --optimize-autoloader

echo "📦 Installing Node dependencies..."
npm install

# Generate key if not set
if ! grep -q "APP_KEY=base64:" .env; then
    echo "🔑 Generating application key..."
    php artisan key:generate
fi

# Run migrations
echo "🚀 Running database migrations..."
php artisan migrate --force

# Build assets
echo "🏗️  Building assets..."
npm run build

echo ""
echo "=========================================="
echo "✨ Installation completed successfully!"
echo "=========================================="
echo "Your app is ready at http://localhost:8080 (or your configured port)"
