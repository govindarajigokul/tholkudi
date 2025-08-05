# GitHub Secrets Setup for AWS S3 Deployment

## 🔐 Required GitHub Secrets

You need to add these secrets to your GitHub repository:

### 1. AWS_S3_BUCKET
- **Value**: `govindaraji`
- **Description**: Your S3 bucket name

### 2. AWS_ACCESS_KEY_ID
- **Value**: Your AWS Access Key ID
- **Description**: AWS credentials for deployment

### 3. AWS_SECRET_ACCESS_KEY
- **Value**: Your AWS Secret Access Key
- **Description**: AWS credentials for deployment

### 4. AWS_REGION
- **Value**: Your AWS region (e.g., `us-east-1`, `ap-south-1`, `eu-west-1`)
- **Description**: The AWS region where your S3 bucket is located

### 5. CLOUDFRONT_DISTRIBUTION_ID (Optional)
- **Value**: Your CloudFront distribution ID (if you have one)
- **Description**: For cache invalidation (optional)

## 📝 How to Add Secrets to GitHub

### Step 1: Go to Repository Settings
1. Open your GitHub repository
2. Click on **Settings** tab
3. In the left sidebar, click **Secrets and variables**
4. Click **Actions**

### Step 2: Add Each Secret
1. Click **New repository secret**
2. Enter the **Name** (e.g., `AWS_S3_BUCKET`)
3. Enter the **Value** (e.g., `govindaraji`)
4. Click **Add secret**
5. Repeat for all secrets

## 🌍 Finding Your AWS Region

Your AWS region depends on where you created your S3 bucket. Common regions:

- **US East (N. Virginia)**: `us-east-1`
- **US West (Oregon)**: `us-west-2`
- **Asia Pacific (Mumbai)**: `ap-south-1`
- **Europe (Ireland)**: `eu-west-1`
- **Asia Pacific (Singapore)**: `ap-southeast-1`

To find your region:
1. Go to AWS S3 Console
2. Click on your bucket "govindaraji"
3. Check the region in the bucket details

## 🔑 AWS Credentials Setup

### Option 1: Use Existing IAM User
If you already have AWS credentials, use those.

### Option 2: Create New IAM User (Recommended)
1. Go to AWS IAM Console
2. Click **Users** → **Add users**
3. Enter username: `github-actions-s3-deploy`
4. Select **Programmatic access**
5. Attach policy: `AmazonS3FullAccess`
6. Copy the **Access Key ID** and **Secret Access Key**

### Minimal IAM Policy (More Secure)
Instead of full S3 access, you can create a custom policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:ListBucket",
                "s3:PutBucketWebsite"
            ],
            "Resource": [
                "arn:aws:s3:::govindaraji",
                "arn:aws:s3:::govindaraji/*"
            ]
        }
    ]
}
```

## 🚀 Testing the Deployment

After adding all secrets:

1. **Create and switch to deployment branch**:
   ```bash
   git checkout -b deployment
   ```

2. **Commit and push** the workflow file:
   ```bash
   git add .github/workflows/deploy-s3.yml
   git commit -m "Add AWS S3 deployment workflow"
   git push origin deployment
   ```

3. **Check the Actions tab** in your GitHub repository to see the deployment progress

4. **Your website will be available at**:
   ```
   http://govindaraji.s3-website-[your-region].amazonaws.com
   ```

## 🔧 Troubleshooting

### Common Issues:

1. **Build fails**: Check if `npx ng build --configuration production` works locally
2. **AWS credentials error**: Verify your Access Key ID and Secret Access Key
3. **S3 bucket not found**: Make sure the bucket name is exactly `govindaraji`
4. **Region mismatch**: Ensure the AWS_REGION matches your bucket's region

### Debug Steps:
1. Check the **Actions** tab in GitHub for error logs
2. Verify all secrets are added correctly
3. Make sure your S3 bucket allows public read access for website hosting

## 📋 Checklist

- [ ] S3 bucket "govindaraji" created
- [ ] AWS credentials added to GitHub secrets
- [ ] All 4 required secrets configured
- [ ] Workflow file committed and pushed
- [ ] S3 bucket configured for static website hosting
- [ ] Bucket policy allows public read access

## 🎯 Next Steps

Once everything is set up:
1. Every push to `main` branch will trigger automatic deployment
2. Your DSpace Angular app will be built and deployed to S3
3. The website will be accessible via the S3 website URL

Need help with any step? Check the GitHub Actions logs for detailed error messages!
