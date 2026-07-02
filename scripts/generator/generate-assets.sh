#!/bin/bash

set -e

echo "========================================="
echo "Platform Agent - Generate DevOps Assets"
echo "========================================="

##############################################
# Validate Inputs
##############################################

for VAR in APP_HOME APP_PATH DOCKER_TEMPLATE TERRAFORM_TEMPLATE CICD_TEMPLATE
do
    if [ -z "${!VAR}" ]; then
        echo "ERROR: $VAR is not set."
        exit 1
    fi
done

TARGET_DIR="$APP_HOME/$REPO_ROOT"

echo "Application Home : $APP_HOME"
echo "Application Path : $APP_PATH"
echo "Target Directory : $TARGET_DIR"

echo ""
echo "Docker Template     : $DOCKER_TEMPLATE"
echo "Terraform Template  : $TERRAFORM_TEMPLATE"
echo "CI/CD Template      : $CICD_TEMPLATE"

##############################################
# Validate Template Directories
##############################################

[ -d "$DOCKER_TEMPLATE" ] || {
    echo "Docker template missing."
    exit 1
}

[ -d "$TERRAFORM_TEMPLATE" ] || {
    echo "Terraform template missing."
    exit 1
}

[ -d "$CICD_TEMPLATE" ] || {
    echo "CI/CD template missing."
    exit 1
}

##############################################
# Docker
##############################################

if [ "$HAS_DOCKERFILE" != "true" ]; then

    echo ""
    echo "Generating Docker assets..."

    ##########################################################
    # Generate Dockerfile
    ##########################################################

    cp "$DOCKER_TEMPLATE/Dockerfile" \
       "$TARGET_DIR/Dockerfile"

    ##########################################################
    # Generate .dockerignore
    ##########################################################

    cp "$DOCKER_TEMPLATE/.dockerignore" \
       "$TARGET_DIR/.dockerignore"

    ##########################################################
    # Replace Dockerfile Placeholders
    ##########################################################

    echo ""
    echo "Customizing Dockerfile..."

    sed -i \
        "s|<APPLICATION_DLL>|$APPLICATION_DLL|g" \
        "$TARGET_DIR/Dockerfile"

    echo "Dockerfile customized successfully."

    ##########################################################
    # Preview Generated Dockerfile
    ##########################################################

    echo ""
    echo "===== Dockerfile Preview ====="

    grep "ENTRYPOINT" "$TARGET_DIR/Dockerfile"

else

    echo "Dockerfile already exists."

fi


##############################################
# Terraform
##############################################

if [ "$HAS_TERRAFORM" != "true" ]; then

    echo ""
    echo "Generating Terraform..."

    mkdir -p "$TARGET_DIR/terraform"

    cp -R "$TERRAFORM_TEMPLATE/"* \
          "$TARGET_DIR/terraform/"

else

    echo "Terraform already exists."

fi

##############################################
# GitHub Actions
##############################################

if [ "$HAS_WORKFLOWS" != "true" ]; then

    echo ""
    echo "Generating GitHub Actions..."

    mkdir -p "$TARGET_DIR/.github/workflows"

    ##############################################
    # CI Workflow
    ##############################################

    echo ""
    echo "Generating ci.yml..."

    cp "$CICD_TEMPLATE/ci.yml" \
       "$TARGET_DIR/.github/workflows/ci.yml"

    ##############################################
    # Replace CI Placeholders
    ##############################################

    echo ""
    echo "Customizing ci.yml..."

    sed -i \
        "s|<PROJECT_FILE>|$APPLICATION_PROJECT|g" \
        "$TARGET_DIR/.github/workflows/ci.yml"

    echo "ci.yml customized successfully."

    ##############################################
    # CD Workflow
    ##############################################

    echo ""
    echo "Generating cd.yml..."

    cp "$CICD_TEMPLATE/cd.yml" \
       "$TARGET_DIR/.github/workflows/cd.yml"

    ##############################################
    # Preview Generated Workflows
    ##############################################

    echo ""
    echo "===== Generated CI Workflow ====="

    grep "PROJECT_FILE" \
        "$TARGET_DIR/.github/workflows/ci.yml"

    echo ""
    echo "===== Generated CD Workflow ====="

    head -20 \
        "$TARGET_DIR/.github/workflows/cd.yml"

else

    echo "GitHub workflows already exist. Skipping."

fi

##############################################
# Summary
##############################################

echo ""
echo "========================================="
echo "Generated Assets"
echo "========================================="

find "$TARGET_DIR" \
    \( -name Dockerfile \
    -o -name ".dockerignore" \
    -o -name "*.tf" \
    -o -name "*.yml" \)

echo ""
echo "========================================="
echo "Git Status"
echo "========================================="

git -C "$APP_HOME" status

echo ""

git -C "$APP_HOME" diff --name-only || true

echo ""

echo "========================================="
echo "Asset Generation Completed"
echo "========================================="