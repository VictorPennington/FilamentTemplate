#!/bin/bash

# Install Script (Container side)
# This script handles the installation of dependencies and database setup.

set -e

# Fix "dubious ownership" in Git for the workspace directory
# This is required because the directory is mounted from the host and owned by a different user.
git config --system --add safe.directory /var/www/html

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

# Wait 5 seconds
sleep 5

# Run migrations
echo "🚀 Running database migrations..."
php artisan migrate --force



echo ""
echo "=========================================="
echo "✨ Installation completed successfully!"
echo "=========================================="
echo "Your app is ready at http://localhost:8080 (or your configured port)"
