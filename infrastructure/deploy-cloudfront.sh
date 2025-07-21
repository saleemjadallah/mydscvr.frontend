#!/bin/bash

# CloudFront deployment script for mydscvr event images
# This script deploys the CloudFormation stack for CloudFront CDN

set -e

# Configuration
STACK_NAME="mydscvr-event-images-cdn"
TEMPLATE_FILE="cloudfront-s3-cdn.yaml"
REGION="us-east-1"  # CloudFront stacks must be created in us-east-1
S3_BUCKET_NAME="mydscvr-event-images"
S3_BUCKET_REGION="me-central-1"

# Optional: Set these if you have a custom domain
CUSTOM_DOMAIN=""  # e.g., "cdn.mydscvr.ai"
ACM_CERTIFICATE_ARN=""  # Required if using custom domain

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting CloudFront deployment for mydscvr event images...${NC}"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}Error: AWS CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}Error: AWS credentials not configured. Please run 'aws configure'.${NC}"
    exit 1
fi

# Validate CloudFormation template
echo -e "${YELLOW}Validating CloudFormation template...${NC}"
aws cloudformation validate-template \
    --template-body file://$TEMPLATE_FILE \
    --region $REGION

# Prepare parameters
PARAMETERS="ParameterKey=S3BucketName,ParameterValue=$S3_BUCKET_NAME ParameterKey=S3BucketRegion,ParameterValue=$S3_BUCKET_REGION"

if [ ! -z "$CUSTOM_DOMAIN" ]; then
    PARAMETERS="$PARAMETERS ParameterKey=AlternateDomainName,ParameterValue=$CUSTOM_DOMAIN"
fi

if [ ! -z "$ACM_CERTIFICATE_ARN" ]; then
    PARAMETERS="$PARAMETERS ParameterKey=ACMCertificateArn,ParameterValue=$ACM_CERTIFICATE_ARN"
fi

# Check if stack exists
if aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION &> /dev/null; then
    echo -e "${YELLOW}Stack exists. Updating...${NC}"
    aws cloudformation update-stack \
        --stack-name $STACK_NAME \
        --template-body file://$TEMPLATE_FILE \
        --parameters $PARAMETERS \
        --capabilities CAPABILITY_IAM \
        --region $REGION
    
    echo -e "${YELLOW}Waiting for stack update to complete...${NC}"
    aws cloudformation wait stack-update-complete \
        --stack-name $STACK_NAME \
        --region $REGION
else
    echo -e "${YELLOW}Creating new stack...${NC}"
    aws cloudformation create-stack \
        --stack-name $STACK_NAME \
        --template-body file://$TEMPLATE_FILE \
        --parameters $PARAMETERS \
        --capabilities CAPABILITY_IAM \
        --region $REGION
    
    echo -e "${YELLOW}Waiting for stack creation to complete...${NC}"
    aws cloudformation wait stack-create-complete \
        --stack-name $STACK_NAME \
        --region $REGION
fi

# Get stack outputs
echo -e "${GREEN}Stack deployment completed successfully!${NC}"
echo -e "${YELLOW}Getting CloudFront distribution details...${NC}"

CLOUDFRONT_DOMAIN=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $REGION \
    --query "Stacks[0].Outputs[?OutputKey=='CloudFrontDomainName'].OutputValue" \
    --output text)

CLOUDFRONT_ID=$(aws cloudformation describe-stacks \
    --stack-name $STACK_NAME \
    --region $REGION \
    --query "Stacks[0].Outputs[?OutputKey=='CloudFrontDistributionId'].OutputValue" \
    --output text)

echo -e "${GREEN}CloudFront Distribution Created Successfully!${NC}"
echo -e "Domain: ${GREEN}$CLOUDFRONT_DOMAIN${NC}"
echo -e "Distribution ID: ${GREEN}$CLOUDFRONT_ID${NC}"
echo -e "Full URL: ${GREEN}https://$CLOUDFRONT_DOMAIN${NC}"

echo -e "\n${YELLOW}Next Steps:${NC}"
echo "1. Update your application to use the CloudFront URL: https://$CLOUDFRONT_DOMAIN"
echo "2. Test image loading through CloudFront"
echo "3. If using a custom domain, update your DNS records"
echo "4. Monitor CloudFront metrics in AWS Console"

# Create environment file for application
echo -e "\n${YELLOW}Creating environment configuration file...${NC}"
cat > cloudfront-config.env << EOF
# CloudFront Configuration for mydscvr
CLOUDFRONT_DOMAIN=$CLOUDFRONT_DOMAIN
CLOUDFRONT_DISTRIBUTION_ID=$CLOUDFRONT_ID
CLOUDFRONT_URL=https://$CLOUDFRONT_DOMAIN
S3_BUCKET_NAME=$S3_BUCKET_NAME
S3_BUCKET_REGION=$S3_BUCKET_REGION
EOF

echo -e "${GREEN}Configuration saved to cloudfront-config.env${NC}"