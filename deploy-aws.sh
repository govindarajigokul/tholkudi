#!/bin/bash

# DSpace Angular AWS Deployment Script
# This script helps automate the deployment process to AWS

set -e

echo "🚀 DSpace Angular AWS Deployment Script"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Check if required tools are installed
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        print_error "Node.js is not installed"
        exit 1
    fi
    print_status "Node.js found: $(node --version)"
    
    # Check npm
    if ! command -v npm &> /dev/null; then
        print_error "npm is not installed"
        exit 1
    fi
    print_status "npm found: $(npm --version)"
    
    # Check if Angular CLI is available
    if ! command -v npx &> /dev/null; then
        print_error "npx is not available"
        exit 1
    fi
    print_status "npx found"
    
    # Check AWS CLI (optional)
    if command -v aws &> /dev/null; then
        print_status "AWS CLI found: $(aws --version)"
    else
        print_warning "AWS CLI not found - you'll need it for some deployment options"
    fi
    
    # Check Docker (optional)
    if command -v docker &> /dev/null; then
        print_status "Docker found: $(docker --version)"
    else
        print_warning "Docker not found - needed for ECS deployment"
    fi
}

# Build the application
build_application() {
    print_info "Building DSpace Angular for production..."
    
    if npx ng build --configuration production; then
        print_status "Build completed successfully!"
        print_info "Build artifacts are in the 'dist' directory"
    else
        print_error "Build failed!"
        exit 1
    fi
}

# Create deployment package for Elastic Beanstalk
create_eb_package() {
    print_info "Creating Elastic Beanstalk deployment package..."
    
    # Create deployment directory
    rm -rf dspace-aws-deploy
    mkdir -p dspace-aws-deploy
    cd dspace-aws-deploy
    
    # Copy necessary files
    cp -r ../dist ./
    cp -r ../config ./
    cp ../package.json ./
    
    # Copy yarn.lock if it exists, otherwise package-lock.json
    if [ -f ../yarn.lock ]; then
        cp ../yarn.lock ./
    elif [ -f ../package-lock.json ]; then
        cp ../package-lock.json ./
    fi
    
    # Create Procfile
    echo "web: npm run serve:ssr" > Procfile
    
    # Create .ebextensions directory and configuration
    mkdir -p .ebextensions
    cat > .ebextensions/nodejs.config << EOF
option_settings:
  aws:elasticbeanstalk:container:nodejs:
    NodeCommand: "npm run serve:ssr"
    NodeVersion: 18.19.1
  aws:elasticbeanstalk:application:environment:
    NODE_ENV: production
    DSPACE_UI_SSL: false
    DSPACE_UI_HOST: 0.0.0.0
    DSPACE_UI_PORT: 8080
    # UPDATE THESE VALUES FOR YOUR DSPACE BACKEND:
    DSPACE_REST_SSL: true
    DSPACE_REST_HOST: demo.dspace.org
    DSPACE_REST_PORT: 443
    DSPACE_REST_NAMESPACE: /server
EOF
    
    # Create deployment zip
    zip -r ../dspace-angular-eb.zip . -x "*.git*" "node_modules/*"
    cd ..
    
    print_status "Elastic Beanstalk package created: dspace-angular-eb.zip"
    print_warning "Remember to update the DSPACE_REST_* variables in .ebextensions/nodejs.config"
}

# Build Docker image
build_docker_image() {
    print_info "Building Docker image..."
    
    if docker build -f Dockerfile.dist -t dspace-angular:latest .; then
        print_status "Docker image built successfully!"
        print_info "Image tagged as: dspace-angular:latest"
    else
        print_error "Docker build failed!"
        exit 1
    fi
}

# Create production config file
create_prod_config() {
    print_info "Creating production configuration file..."
    
    cat > config/config.prod.yml << EOF
# Production configuration for DSpace Angular
ui:
  ssl: false
  host: 0.0.0.0
  port: 4000
  nameSpace: /

rest:
  ssl: true
  host: demo.dspace.org  # UPDATE THIS TO YOUR DSPACE BACKEND
  port: 443
  nameSpace: /server

# Cache settings for production
cache:
  # NOTE: server-side caching is disabled by default in production
  # Enable it by setting serverSide to true and configuring the settings below
  serverSide: false

# Enable production optimizations
production: true
EOF
    
    print_status "Production config created: config/config.prod.yml"
    print_warning "Remember to update the 'rest.host' value to your actual DSpace backend URL"
}

# Main menu
show_menu() {
    echo ""
    echo "Select deployment option:"
    echo "1) Build application only"
    echo "2) Create Elastic Beanstalk package"
    echo "3) Build Docker image"
    echo "4) Create production config"
    echo "5) Full preparation (build + EB package + config)"
    echo "6) Exit"
    echo ""
    read -p "Enter your choice (1-6): " choice
}

# Main execution
main() {
    check_prerequisites
    
    while true; do
        show_menu
        case $choice in
            1)
                build_application
                ;;
            2)
                if [ ! -d "dist" ]; then
                    print_warning "No dist directory found. Building application first..."
                    build_application
                fi
                create_eb_package
                ;;
            3)
                if [ ! -d "dist" ]; then
                    print_warning "No dist directory found. Building application first..."
                    build_application
                fi
                build_docker_image
                ;;
            4)
                create_prod_config
                ;;
            5)
                build_application
                create_prod_config
                create_eb_package
                print_status "Full preparation completed!"
                print_info "Next steps:"
                print_info "1. Update config/config.prod.yml with your backend URL"
                print_info "2. Update .ebextensions/nodejs.config in dspace-aws-deploy/"
                print_info "3. Deploy using: eb init && eb create && eb deploy"
                ;;
            6)
                print_info "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid option. Please try again."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Run the script
main
