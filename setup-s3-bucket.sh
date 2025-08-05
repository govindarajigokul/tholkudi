#!/bin/bash

# S3 Bucket Setup Script for DSpace Angular Deployment
# This script configures your S3 bucket for static website hosting

set -e

# Configuration
BUCKET_NAME="govindaraji"
REGION="us-east-1"  # Change this to your AWS region

echo "🚀 Setting up S3 bucket for DSpace Angular deployment"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    print_error "AWS CLI is not installed. Please install it first."
    echo "Visit: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

print_status "AWS CLI found"

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS credentials not configured. Please run 'aws configure' first."
    exit 1
fi

print_status "AWS credentials configured"

# Get current AWS region
CURRENT_REGION=$(aws configure get region)
if [ -n "$CURRENT_REGION" ]; then
    REGION=$CURRENT_REGION
    print_info "Using AWS region: $REGION"
fi

# Check if bucket exists
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    print_status "S3 bucket '$BUCKET_NAME' exists"
else
    print_error "S3 bucket '$BUCKET_NAME' does not exist or you don't have access"
    print_info "Please create the bucket first in AWS Console or run:"
    echo "aws s3 mb s3://$BUCKET_NAME --region $REGION"
    exit 1
fi

# Configure bucket for static website hosting
print_info "Configuring bucket for static website hosting..."
aws s3 website s3://$BUCKET_NAME --index-document index.html --error-document index.html

if [ $? -eq 0 ]; then
    print_status "Static website hosting configured"
else
    print_error "Failed to configure static website hosting"
    exit 1
fi

# Create bucket policy for public read access
print_info "Setting up bucket policy for public read access..."

BUCKET_POLICY='{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::'$BUCKET_NAME'/*"
        }
    ]
}'

echo "$BUCKET_POLICY" > /tmp/bucket-policy.json

aws s3api put-bucket-policy --bucket "$BUCKET_NAME" --policy file:///tmp/bucket-policy.json

if [ $? -eq 0 ]; then
    print_status "Bucket policy applied successfully"
    rm /tmp/bucket-policy.json
else
    print_error "Failed to apply bucket policy"
    rm /tmp/bucket-policy.json
    exit 1
fi

# Disable block public access (required for website hosting)
print_info "Configuring public access settings..."
aws s3api put-public-access-block --bucket "$BUCKET_NAME" --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"

if [ $? -eq 0 ]; then
    print_status "Public access settings configured"
else
    print_warning "Could not configure public access settings. You may need to do this manually in AWS Console."
fi

# Get the website URL
WEBSITE_URL="http://$BUCKET_NAME.s3-website-$REGION.amazonaws.com"

print_status "S3 bucket setup complete!"
echo ""
print_info "Your website will be available at:"
echo "$WEBSITE_URL"
echo ""
print_info "GitHub Secrets to add:"
echo "AWS_S3_BUCKET: $BUCKET_NAME"
echo "AWS_REGION: $REGION"
echo "AWS_ACCESS_KEY_ID: [Your AWS Access Key]"
echo "AWS_SECRET_ACCESS_KEY: [Your AWS Secret Key]"
echo ""
print_info "Next steps:"
echo "1. Add the GitHub secrets mentioned above"
echo "2. Create and switch to 'deployment' branch"
echo "3. Commit and push the workflow file to deployment branch"
echo "4. Your app will auto-deploy on every push to deployment branch"
echo ""
print_warning "Note: Make sure your AWS credentials have the necessary S3 permissions!"

# Test upload (optional)
read -p "Do you want to test upload a sample file? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "<html><body><h1>Test Page</h1><p>S3 bucket is working!</p></body></html>" > /tmp/test.html
    aws s3 cp /tmp/test.html s3://$BUCKET_NAME/test.html
    rm /tmp/test.html
    print_status "Test file uploaded. Check: $WEBSITE_URL/test.html"
fi

print_status "Setup complete! 🎉"
