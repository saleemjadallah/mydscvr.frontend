#!/bin/bash

# CloudFront deployment script for mydscvr event images (Local version)
# Run this from your local machine where AWS CLI is configured

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

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Check if we're in the right directory
if [ ! -f "$SCRIPT_DIR/$TEMPLATE_FILE" ]; then
    echo -e "${RED}Error: CloudFormation template not found at $SCRIPT_DIR/$TEMPLATE_FILE${NC}"
    echo "Please run this script from the infrastructure directory"
    exit 1
fi

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}Error: AWS CLI is not installed. Please install it first.${NC}"
    echo "Visit: https://aws.amazon.com/cli/"
    exit 1
fi

# Check AWS credentials
echo -e "${YELLOW}Checking AWS credentials...${NC}"
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}Error: AWS credentials not configured.${NC}"
    echo "Please configure AWS credentials using one of these methods:"
    echo "1. Run 'aws configure' and enter your credentials"
    echo "2. Set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables"
    echo "3. Use AWS SSO: 'aws sso login'"
    exit 1
fi

# Display AWS identity
IDENTITY=$(aws sts get-caller-identity --output json)
echo -e "${GREEN}AWS Identity:${NC}"
echo "$IDENTITY" | jq '.'

# Validate CloudFormation template
echo -e "${YELLOW}Validating CloudFormation template...${NC}"
aws cloudformation validate-template \
    --template-body file://$SCRIPT_DIR/$TEMPLATE_FILE \
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
echo -e "${YELLOW}Checking if stack exists...${NC}"
if aws cloudformation describe-stacks --stack-name $STACK_NAME --region $REGION &> /dev/null; then
    echo -e "${YELLOW}Stack exists. Updating...${NC}"
    aws cloudformation update-stack \
        --stack-name $STACK_NAME \
        --template-body file://$SCRIPT_DIR/$TEMPLATE_FILE \
        --parameters $PARAMETERS \
        --capabilities CAPABILITY_IAM \
        --region $REGION
    
    echo -e "${YELLOW}Waiting for stack update to complete...${NC}"
    echo "This may take 15-20 minutes for CloudFront distribution..."
    aws cloudformation wait stack-update-complete \
        --stack-name $STACK_NAME \
        --region $REGION
else
    echo -e "${YELLOW}Creating new stack...${NC}"
    aws cloudformation create-stack \
        --stack-name $STACK_NAME \
        --template-body file://$SCRIPT_DIR/$TEMPLATE_FILE \
        --parameters $PARAMETERS \
        --capabilities CAPABILITY_IAM \
        --region $REGION
    
    echo -e "${YELLOW}Waiting for stack creation to complete...${NC}"
    echo "This may take 15-20 minutes for CloudFront distribution..."
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
echo "2. Set CDN_URL environment variable when building Flutter app:"
echo "   flutter build web --dart-define=CDN_URL=https://$CLOUDFRONT_DOMAIN"
echo "3. Test image loading through CloudFront using test-cloudfront.html"
echo "4. Monitor CloudFront metrics in AWS Console"

# Create environment file for application
echo -e "\n${YELLOW}Creating environment configuration file...${NC}"
cat > $SCRIPT_DIR/cloudfront-config.env << EOF
# CloudFront Configuration for mydscvr
# Source this file or copy values to your build process
export CLOUDFRONT_DOMAIN=$CLOUDFRONT_DOMAIN
export CLOUDFRONT_DISTRIBUTION_ID=$CLOUDFRONT_ID
export CLOUDFRONT_URL=https://$CLOUDFRONT_DOMAIN
export CDN_URL=https://$CLOUDFRONT_DOMAIN
export S3_BUCKET_NAME=$S3_BUCKET_NAME
export S3_BUCKET_REGION=$S3_BUCKET_REGION

# Flutter build command with CDN
# flutter build web --dart-define=CDN_URL=https://$CLOUDFRONT_DOMAIN
EOF

echo -e "${GREEN}Configuration saved to cloudfront-config.env${NC}"

# Open test page
echo -e "\n${YELLOW}Opening test page...${NC}"
if command -v open &> /dev/null; then
    open "$SCRIPT_DIR/test-cloudfront.html?cloudfront=$CLOUDFRONT_DOMAIN"
elif command -v xdg-open &> /dev/null; then
    xdg-open "$SCRIPT_DIR/test-cloudfront.html?cloudfront=$CLOUDFRONT_DOMAIN"
else
    echo "Test your CloudFront setup by opening: $SCRIPT_DIR/test-cloudfront.html?cloudfront=$CLOUDFRONT_DOMAIN"
fi