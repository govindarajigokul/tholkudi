@echo off
REM S3 Bucket Setup Script for DSpace Angular Deployment
REM This script configures your S3 bucket for static website hosting

echo.
echo 🚀 Setting up S3 bucket for DSpace Angular deployment
echo ==================================================

REM Configuration
set BUCKET_NAME=govindaraji
set REGION=us-east-1

REM Check if AWS CLI is installed
aws --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ AWS CLI is not installed. Please install it first.
    echo Visit: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
    pause
    exit /b 1
)
echo ✅ AWS CLI found

REM Check if AWS credentials are configured
aws sts get-caller-identity >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ AWS credentials not configured. Please run 'aws configure' first.
    pause
    exit /b 1
)
echo ✅ AWS credentials configured

REM Get current AWS region
for /f "tokens=*" %%i in ('aws configure get region 2^>nul') do set CURRENT_REGION=%%i
if not "%CURRENT_REGION%"=="" (
    set REGION=%CURRENT_REGION%
    echo ℹ️  Using AWS region: %REGION%
)

REM Check if bucket exists
aws s3api head-bucket --bucket %BUCKET_NAME% >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ S3 bucket '%BUCKET_NAME%' does not exist or you don't have access
    echo ℹ️  Please create the bucket first in AWS Console or run:
    echo aws s3 mb s3://%BUCKET_NAME% --region %REGION%
    pause
    exit /b 1
)
echo ✅ S3 bucket '%BUCKET_NAME%' exists

REM Configure bucket for static website hosting
echo ℹ️  Configuring bucket for static website hosting...
aws s3 website s3://%BUCKET_NAME% --index-document index.html --error-document index.html
if %errorlevel% equ 0 (
    echo ✅ Static website hosting configured
) else (
    echo ❌ Failed to configure static website hosting
    pause
    exit /b 1
)

REM Create bucket policy for public read access
echo ℹ️  Setting up bucket policy for public read access...

echo { > bucket-policy.json
echo     "Version": "2012-10-17", >> bucket-policy.json
echo     "Statement": [ >> bucket-policy.json
echo         { >> bucket-policy.json
echo             "Sid": "PublicReadGetObject", >> bucket-policy.json
echo             "Effect": "Allow", >> bucket-policy.json
echo             "Principal": "*", >> bucket-policy.json
echo             "Action": "s3:GetObject", >> bucket-policy.json
echo             "Resource": "arn:aws:s3:::%BUCKET_NAME%/*" >> bucket-policy.json
echo         } >> bucket-policy.json
echo     ] >> bucket-policy.json
echo } >> bucket-policy.json

aws s3api put-bucket-policy --bucket %BUCKET_NAME% --policy file://bucket-policy.json
if %errorlevel% equ 0 (
    echo ✅ Bucket policy applied successfully
    del bucket-policy.json
) else (
    echo ❌ Failed to apply bucket policy
    del bucket-policy.json
    pause
    exit /b 1
)

REM Disable block public access (required for website hosting)
echo ℹ️  Configuring public access settings...
aws s3api put-public-access-block --bucket %BUCKET_NAME% --public-access-block-configuration "BlockPublicAcls=false,IgnorePublicAcls=false,BlockPublicPolicy=false,RestrictPublicBuckets=false"
if %errorlevel% equ 0 (
    echo ✅ Public access settings configured
) else (
    echo ⚠️  Could not configure public access settings. You may need to do this manually in AWS Console.
)

REM Get the website URL
set WEBSITE_URL=http://%BUCKET_NAME%.s3-website-%REGION%.amazonaws.com

echo.
echo ✅ S3 bucket setup complete!
echo.
echo ℹ️  Your website will be available at:
echo %WEBSITE_URL%
echo.
echo ℹ️  GitHub Secrets to add:
echo AWS_S3_BUCKET: %BUCKET_NAME%
echo AWS_REGION: %REGION%
echo AWS_ACCESS_KEY_ID: [Your AWS Access Key]
echo AWS_SECRET_ACCESS_KEY: [Your AWS Secret Key]
echo.
echo ℹ️  Next steps:
echo 1. Add the GitHub secrets mentioned above
echo 2. Create and switch to 'deployment' branch
echo 3. Commit and push the workflow file to deployment branch
echo 4. Your app will auto-deploy on every push to deployment branch
echo.
echo ⚠️  Note: Make sure your AWS credentials have the necessary S3 permissions!
echo.

REM Test upload (optional)
set /p answer="Do you want to test upload a sample file? (y/n): "
if /i "%answer%"=="y" (
    echo ^<html^>^<body^>^<h1^>Test Page^</h1^>^<p^>S3 bucket is working!^</p^>^</body^>^</html^> > test.html
    aws s3 cp test.html s3://%BUCKET_NAME%/test.html
    del test.html
    echo ✅ Test file uploaded. Check: %WEBSITE_URL%/test.html
)

echo.
echo ✅ Setup complete! 🎉
pause
