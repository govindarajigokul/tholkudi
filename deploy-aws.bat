@echo off
REM DSpace Angular AWS Deployment Script for Windows
REM This script helps automate the deployment process to AWS

echo.
echo 🚀 DSpace Angular AWS Deployment Script (Windows)
echo ========================================

:check_prerequisites
echo.
echo ℹ️  Checking prerequisites...

REM Check Node.js
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js is not installed
    pause
    exit /b 1
)
echo ✅ Node.js found

REM Check npm
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ npm is not installed
    pause
    exit /b 1
)
echo ✅ npm found

REM Check npx
npx --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ npx is not available
    pause
    exit /b 1
)
echo ✅ npx found

REM Check AWS CLI (optional)
aws --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ AWS CLI found
) else (
    echo ⚠️  AWS CLI not found - you'll need it for some deployment options
)

REM Check Docker (optional)
docker --version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Docker found
) else (
    echo ⚠️  Docker not found - needed for ECS deployment
)

:menu
echo.
echo Select deployment option:
echo 1) Build application only
echo 2) Create Elastic Beanstalk package
echo 3) Build Docker image
echo 4) Create production config
echo 5) Full preparation (build + EB package + config)
echo 6) Exit
echo.
set /p choice="Enter your choice (1-6): "

if "%choice%"=="1" goto build_app
if "%choice%"=="2" goto create_eb
if "%choice%"=="3" goto build_docker
if "%choice%"=="4" goto create_config
if "%choice%"=="5" goto full_prep
if "%choice%"=="6" goto exit
echo ❌ Invalid option. Please try again.
goto menu

:build_app
echo.
echo ℹ️  Building DSpace Angular for production...
npx ng build --configuration production
if %errorlevel% neq 0 (
    echo ❌ Build failed!
    pause
    exit /b 1
)
echo ✅ Build completed successfully!
echo ℹ️  Build artifacts are in the 'dist' directory
goto continue

:create_eb
echo.
if not exist "dist" (
    echo ⚠️  No dist directory found. Building application first...
    call :build_app
)
echo ℹ️  Creating Elastic Beanstalk deployment package...

REM Create deployment directory
if exist "dspace-aws-deploy" rmdir /s /q dspace-aws-deploy
mkdir dspace-aws-deploy
cd dspace-aws-deploy

REM Copy necessary files
xcopy ..\dist dist\ /e /i /q
xcopy ..\config config\ /e /i /q
copy ..\package.json . >nul

REM Copy yarn.lock if it exists, otherwise package-lock.json
if exist ..\yarn.lock (
    copy ..\yarn.lock . >nul
) else if exist ..\package-lock.json (
    copy ..\package-lock.json . >nul
)

REM Create Procfile
echo web: npm run serve:ssr > Procfile

REM Create .ebextensions directory and configuration
mkdir .ebextensions
(
echo option_settings:
echo   aws:elasticbeanstalk:container:nodejs:
echo     NodeCommand: "npm run serve:ssr"
echo     NodeVersion: 18.19.1
echo   aws:elasticbeanstalk:application:environment:
echo     NODE_ENV: production
echo     DSPACE_UI_SSL: false
echo     DSPACE_UI_HOST: 0.0.0.0
echo     DSPACE_UI_PORT: 8080
echo     # UPDATE THESE VALUES FOR YOUR DSPACE BACKEND:
echo     DSPACE_REST_SSL: true
echo     DSPACE_REST_HOST: demo.dspace.org
echo     DSPACE_REST_PORT: 443
echo     DSPACE_REST_NAMESPACE: /server
) > .ebextensions\nodejs.config

cd ..
echo ✅ Elastic Beanstalk package directory created: dspace-aws-deploy\
echo ⚠️  Remember to update the DSPACE_REST_* variables in .ebextensions\nodejs.config
goto continue

:build_docker
echo.
if not exist "dist" (
    echo ⚠️  No dist directory found. Building application first...
    call :build_app
)
echo ℹ️  Building Docker image...
docker build -f Dockerfile.dist -t dspace-angular:latest .
if %errorlevel% neq 0 (
    echo ❌ Docker build failed!
    pause
    exit /b 1
)
echo ✅ Docker image built successfully!
echo ℹ️  Image tagged as: dspace-angular:latest
goto continue

:create_config
echo.
echo ℹ️  Creating production configuration file...
if not exist "config" mkdir config
(
echo # Production configuration for DSpace Angular
echo ui:
echo   ssl: false
echo   host: 0.0.0.0
echo   port: 4000
echo   nameSpace: /
echo.
echo rest:
echo   ssl: true
echo   host: demo.dspace.org  # UPDATE THIS TO YOUR DSPACE BACKEND
echo   port: 443
echo   nameSpace: /server
echo.
echo # Cache settings for production
echo cache:
echo   # NOTE: server-side caching is disabled by default in production
echo   # Enable it by setting serverSide to true and configuring the settings below
echo   serverSide: false
echo.
echo # Enable production optimizations
echo production: true
) > config\config.prod.yml

echo ✅ Production config created: config\config.prod.yml
echo ⚠️  Remember to update the 'rest.host' value to your actual DSpace backend URL
goto continue

:full_prep
echo.
call :build_app
call :create_config
call :create_eb
echo ✅ Full preparation completed!
echo ℹ️  Next steps:
echo ℹ️  1. Update config\config.prod.yml with your backend URL
echo ℹ️  2. Update .ebextensions\nodejs.config in dspace-aws-deploy\
echo ℹ️  3. Deploy using: eb init && eb create && eb deploy
goto continue

:continue
echo.
pause
goto menu

:exit
echo ℹ️  Goodbye!
pause
exit /b 0
