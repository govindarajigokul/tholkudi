# DSpace Angular AWS Deployment Guide

## Overview
This guide explains how to deploy your DSpace Angular application to AWS using various deployment options.

## Prerequisites
✅ **Completed**: Angular CLI is working with `npx ng build --configuration production`
✅ **Completed**: Production build is successful (dist/browser folder created)
✅ **Build Output Location**: `dist/browser/` (contains your static files)

## Deployment Options

### Option 1: AWS Elastic Beanstalk (Recommended for beginners)

#### Step 1: Prepare the Application
1. **Create a deployment package**:
   ```bash
   # Create a deployment directory
   mkdir dspace-aws-deploy
   cd dspace-aws-deploy
   
   # Copy the built application
   cp -r ../dist ./
   cp -r ../config ./
   cp ../package.json ./
   cp ../yarn.lock ./
   ```

2. **Create a Procfile** for Elastic Beanstalk:
   ```bash
   echo "web: npm run serve:ssr" > Procfile
   ```

3. **Create .ebextensions/nodejs.config**:
   ```yaml
   option_settings:
     aws:elasticbeanstalk:container:nodejs:
       NodeCommand: "npm run serve:ssr"
       NodeVersion: 18.19.1
     aws:elasticbeanstalk:application:environment:
       NODE_ENV: production
       DSPACE_UI_SSL: false
       DSPACE_UI_HOST: 0.0.0.0
       DSPACE_UI_PORT: 8080
       DSPACE_REST_SSL: true
       DSPACE_REST_HOST: your-dspace-backend.com
       DSPACE_REST_PORT: 443
       DSPACE_REST_NAMESPACE: /server
   ```

#### Step 2: Deploy to Elastic Beanstalk
1. Install EB CLI: `pip install awsebcli`
2. Initialize: `eb init`
3. Create environment: `eb create dspace-angular-prod`
4. Deploy: `eb deploy`

### Option 2: AWS ECS with Docker (Production-ready)

#### Step 1: Use the provided Dockerfile.dist
The project already includes `Dockerfile.dist` optimized for production:

```dockerfile
# Build stage
FROM docker.io/node:18-alpine AS build
RUN apk add --update python3 make g++ && rm -rf /var/cache/apk/*
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --network-timeout 300000
ADD . /app/
RUN yarn build:prod

# Runtime stage
FROM node:18-alpine
RUN npm install --global pm2
COPY --chown=node:node --from=build /app/dist /app/dist
COPY --chown=node:node config /app/config
COPY --chown=node:node docker/dspace-ui.json /app/dspace-ui.json
WORKDIR /app
USER node
ENV NODE_ENV=production
EXPOSE 4000
CMD pm2-runtime start dspace-ui.json --json
```

#### Step 2: Build and Push to ECR
```bash
# Build the Docker image
docker build -f Dockerfile.dist -t dspace-angular:latest .

# Create ECR repository
aws ecr create-repository --repository-name dspace-angular

# Get login token
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

# Tag and push
docker tag dspace-angular:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/dspace-angular:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/dspace-angular:latest
```

#### Step 3: Create ECS Task Definition
```json
{
  "family": "dspace-angular",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::<account-id>:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "dspace-angular",
      "image": "<account-id>.dkr.ecr.us-east-1.amazonaws.com/dspace-angular:latest",
      "portMappings": [
        {
          "containerPort": 4000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {"name": "NODE_ENV", "value": "production"},
        {"name": "DSPACE_UI_SSL", "value": "false"},
        {"name": "DSPACE_UI_HOST", "value": "0.0.0.0"},
        {"name": "DSPACE_UI_PORT", "value": "4000"},
        {"name": "DSPACE_REST_SSL", "value": "true"},
        {"name": "DSPACE_REST_HOST", "value": "your-dspace-backend.com"},
        {"name": "DSPACE_REST_PORT", "value": "443"},
        {"name": "DSPACE_REST_NAMESPACE", "value": "/server"}
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/dspace-angular",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

### Option 3: AWS S3 + CloudFront (Static hosting - requires backend changes)

⚠️ **Note**: This option requires disabling SSR and configuring the app for static hosting.

#### Step 1: Build for static hosting
```bash
# Modify angular.json to disable SSR for static build
npx ng build --configuration production --output-hashing=all
```

#### Step 2: Upload to S3
```bash
aws s3 sync dist/browser/ s3://your-dspace-bucket --delete
aws s3 website s3://your-dspace-bucket --index-document index.html --error-document index.html
```

## Environment Configuration

### Required Environment Variables
```bash
# UI Configuration
DSPACE_UI_SSL=false
DSPACE_UI_HOST=0.0.0.0
DSPACE_UI_PORT=4000
DSPACE_UI_NAMESPACE=/

# Backend Configuration (CRITICAL - Update these!)
DSPACE_REST_SSL=true
DSPACE_REST_HOST=your-dspace-backend.com
DSPACE_REST_PORT=443
DSPACE_REST_NAMESPACE=/server
```

### Configuration Files
Create `config/config.prod.yml`:
```yaml
ui:
  ssl: false
  host: 0.0.0.0
  port: 4000
  nameSpace: /

rest:
  ssl: true
  host: your-dspace-backend.com
  port: 443
  nameSpace: /server
```

## Load Balancer & SSL Setup

### Application Load Balancer
1. Create ALB in AWS Console
2. Configure target group pointing to port 4000
3. Add SSL certificate from ACM
4. Configure health check: `/health` endpoint

### Security Groups
```
Inbound Rules:
- HTTP (80) from ALB
- HTTPS (443) from ALB
- Custom TCP (4000) from ALB Security Group

Outbound Rules:
- All traffic to 0.0.0.0/0
```

## Monitoring & Logging

### CloudWatch Logs
- Configure log groups: `/aws/ecs/dspace-angular`
- Set retention period: 30 days

### Health Checks
The application provides health endpoints:
- `/health` - Basic health check
- `/` - Application root

## Troubleshooting

### Common Issues
1. **CORS errors**: Ensure backend allows your domain
2. **SSR errors**: Check that DSPACE_REST_* variables point to public URLs
3. **Memory issues**: Increase ECS task memory allocation
4. **Build failures**: Ensure Node.js 18+ is used

### Logs Access
```bash
# ECS logs
aws logs tail /ecs/dspace-angular --follow

# Elastic Beanstalk logs
eb logs
```

## Next Steps
1. ✅ Build completed successfully
2. 🔄 Choose deployment option (Elastic Beanstalk recommended for first deployment)
3. 🔄 Configure environment variables for your DSpace backend
4. 🔄 Set up domain and SSL certificate
5. 🔄 Configure monitoring and backups

## Quick Start Commands
```bash
# For immediate testing with Elastic Beanstalk:
eb init
eb create dspace-angular-prod
eb deploy

# For Docker/ECS deployment:
docker build -f Dockerfile.dist -t dspace-angular .
# Then follow ECS steps above
```
