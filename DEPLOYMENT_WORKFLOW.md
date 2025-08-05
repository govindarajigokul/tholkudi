# Deployment Branch Workflow

## 🌿 Branch Strategy

Your auto-deployment is configured to trigger **ONLY** on the `deployment` branch, not on `main` or other branches.

## 🚀 How to Deploy

### Step 1: Work on Your Main Branch
```bash
# Work on main branch as usual
git checkout main
# Make your changes...
git add .
git commit -m "Add new features"
git push origin main
```

### Step 2: Deploy When Ready
```bash
# Switch to deployment branch
git checkout deployment

# Merge latest changes from main
git merge main

# Push to trigger deployment
git push origin deployment
```

## 🔄 Alternative: Direct Push to Deployment

If you want to deploy directly:

```bash
# Switch to deployment branch
git checkout deployment

# Make changes directly
# ... edit files ...

# Commit and push (triggers deployment)
git add .
git commit -m "Deploy: updated homepage"
git push origin deployment
```

## 🎯 Deployment Triggers

✅ **Will Deploy:**
- `git push origin deployment`
- Any push to the `deployment` branch
- Merging PRs into `deployment` branch

❌ **Will NOT Deploy:**
- `git push origin main`
- `git push origin feature-branch`
- Any push to branches other than `deployment`

## 📋 Complete Setup Checklist

### 1. Configure S3 Bucket
```bash
# Run the setup script
setup-s3-bucket.bat
```

### 2. Add GitHub Secrets
Go to GitHub → Settings → Secrets and variables → Actions

Add these secrets:
- `AWS_S3_BUCKET`: `govindaraji`
- `AWS_ACCESS_KEY_ID`: Your AWS access key
- `AWS_SECRET_ACCESS_KEY`: Your AWS secret key
- `AWS_REGION`: Your AWS region (e.g., `us-east-1`)

### 3. Create Deployment Branch
```bash
# Create deployment branch from main
git checkout main
git checkout -b deployment

# Add the workflow file
git add .github/workflows/deploy-s3.yml
git commit -m "Add AWS S3 deployment workflow"
git push origin deployment
```

### 4. Test Deployment
```bash
# Make a test change
echo "<!-- Deployment test -->" >> src/index.html

# Commit and push to deployment branch
git add .
git commit -m "Test: deployment workflow"
git push origin deployment
```

## 📊 Monitoring Deployments

1. **GitHub Actions**: Go to your repo → Actions tab
2. **Build Status**: Check if the workflow runs successfully
3. **Website**: Visit `http://govindaraji.s3-website-[region].amazonaws.com`

## 🔧 Typical Development Workflow

```bash
# 1. Develop on main branch
git checkout main
git pull origin main
# ... make changes ...
git add .
git commit -m "Feature: add new component"
git push origin main

# 2. When ready to deploy
git checkout deployment
git pull origin deployment
git merge main
git push origin deployment  # 🚀 This triggers deployment!

# 3. Back to development
git checkout main
```

## 🛠️ Advanced: Automatic Deployment from Main

If you want to automatically deploy when main is updated, you can create a separate workflow:

```yaml
# .github/workflows/auto-deploy-from-main.yml
name: Auto Deploy from Main
on:
  push:
    branches: [ main ]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Merge to deployment
      run: |
        git config user.name github-actions
        git config user.email github-actions@github.com
        git checkout deployment
        git merge main
        git push origin deployment
```

## 🎯 Benefits of This Approach

✅ **Controlled Deployments**: Only deploy when you're ready
✅ **Safe Development**: Work on main without accidental deployments
✅ **Easy Rollback**: Keep deployment branch stable
✅ **Clear History**: See exactly what was deployed and when

## 🆘 Troubleshooting

### Deployment Not Triggering?
- Check you're pushing to `deployment` branch, not `main`
- Verify GitHub secrets are set correctly
- Check Actions tab for error messages

### Build Failing?
- Ensure `npx ng build --configuration production` works locally
- Check if all dependencies are in package.json
- Verify Node.js version compatibility

### S3 Upload Failing?
- Check AWS credentials and permissions
- Verify S3 bucket exists and is accessible
- Ensure bucket policy allows uploads

## 📝 Quick Commands Reference

```bash
# Create deployment branch
git checkout -b deployment

# Deploy current changes
git checkout deployment && git merge main && git push origin deployment

# Check deployment status
# Go to GitHub → Actions tab

# View deployed site
# http://govindaraji.s3-website-[your-region].amazonaws.com
```

Happy deploying! 🚀
