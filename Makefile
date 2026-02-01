# Makefile for eval-hub.github.io documentation

.PHONY: help install serve build deploy clean

# Default target
help:
	@echo "Available targets:"
	@echo "  install    - Install documentation dependencies"
	@echo "  serve      - Start local development server"
	@echo "  build      - Build documentation site"
	@echo "  deploy     - Deploy to GitHub Pages"
	@echo "  clean      - Remove built documentation"

# Install dependencies
install:
	@echo "📦 Installing documentation dependencies..."
	pip install -r requirements.txt

# Serve documentation locally
serve:
	@echo "🚀 Starting documentation server..."
	@echo "📖 Documentation will be available at http://0.0.0.0:8000"
	mkdocs serve --dev-addr 0.0.0.0:8000

# Build documentation
build:
	@echo "🔨 Building documentation..."
	mkdocs build

# Deploy to GitHub Pages
deploy:
	@echo "🚀 Deploying to GitHub Pages..."
	mkdocs gh-deploy --force

# Clean built documentation
clean:
	@echo "🧹 Cleaning built documentation..."
	rm -rf site/

# Build and serve
preview: build serve
