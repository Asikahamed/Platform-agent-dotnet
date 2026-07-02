#!/bin/bash

set -ex

echo "========================================="
echo "Platform Agent -- Repository Analysis"
echo "========================================="

echo ""
echo "========== DEBUG =========="

pwd

echo ""
echo "Searching .csproj"

find . -name "*.csproj"

echo ""
echo "Searching solution"

find . -name "*.sln"

echo ""
echo "==========================="

##############################################
# Detect Application
##############################################

##############################################
# Detect Solution
##############################################

SOLUTION_FILE=$(find . -type f -name "*.sln" | head -1)

##############################################
# Detect Deployable Project
##############################################

APPLICATION_PROJECT=""

echo ""
echo "Searching for deployable .NET application..."


##############################################
# ASP.NET Core Web SDK
##############################################

while IFS= read -r project
do
    if [[ "$project" =~ (Test|Tests|UnitTest|UnitTests|IntegrationTest|IntegrationTests|Benchmark) ]]; then
        continue
    fi

    if grep -q "Microsoft.NET.Sdk.Web" "$project"; then
        APPLICATION_PROJECT="$project"
        echo "Detected ASP.NET Core project."
        break
    fi

done < <(find . -type f -name "*.csproj")

##############################################
# Worker Service
##############################################

if [ -z "$APPLICATION_PROJECT" ]; then

    while IFS= read -r project
    do
        if [[ "$project" =~ (Test|Tests|UnitTest|UnitTests|IntegrationTest|IntegrationTests|Benchmark) ]]; then
            continue
        fi

        if grep -q "Microsoft.NET.Sdk.Worker" "$project"; then
            APPLICATION_PROJECT="$project"
            echo "Detected Worker Service project."
            break
        fi

    done < <(find . -type f -name "*.csproj")

fi

##############################################
# Any Non-Test Project
##############################################

if [ -z "$APPLICATION_PROJECT" ]; then

    while IFS= read -r project
    do
        if [[ "$project" =~ (Test|Tests|UnitTest|UnitTests|IntegrationTest|IntegrationTests|Benchmark) ]]; then
            continue
        fi

        APPLICATION_PROJECT="$project"
        echo "Detected generic .NET project."
        break

    done < <(find . -type f -name "*.csproj")

fi

##############################################
# Validate
##############################################

if [ -z "$APPLICATION_PROJECT" ]; then
    echo "No deployable .NET application found."
    exit 1
fi

echo ""
echo "APPLICATION_PROJECT='$APPLICATION_PROJECT'"

APP_PATH=$(dirname "$APPLICATION_PROJECT")

echo ""
echo "Application Path : $APP_PATH"

if [ -n "$SOLUTION_FILE" ]; then
    echo "Solution File    : $SOLUTION_FILE"
else
    echo "Solution File    : Not Found"
fi

echo "Application File : $APPLICATION_PROJECT"

##############################################
# Outputs
##############################################

echo "app_path=$APP_PATH" >> "$GITHUB_OUTPUT"
echo "solution_file=$SOLUTION_FILE" >> "$GITHUB_OUTPUT"
echo "application_project=$APPLICATION_PROJECT" >> "$GITHUB_OUTPUT"

##############################################
# Language
##############################################

LANGUAGE="dotnet"

echo "language=$LANGUAGE" >> "$GITHUB_OUTPUT"

##############################################
# Build Tool
##############################################

BUILD_TOOL="dotnet"

echo "build_tool=$BUILD_TOOL" >> "$GITHUB_OUTPUT"

##############################################
# Target Framework
##############################################

TARGET_FRAMEWORK=$(grep -oPm1 '(?<=<TargetFramework>)[^<]+' "$APPLICATION_PROJECT" || true)

if [ -z "$TARGET_FRAMEWORK" ]; then
    TARGET_FRAMEWORK="net8.0"
fi

DOTNET_VERSION=$(echo "$TARGET_FRAMEWORK" | sed 's/net//')

echo "Detected Target Framework : $TARGET_FRAMEWORK"

echo "target_framework=$TARGET_FRAMEWORK" >> "$GITHUB_OUTPUT"
echo "dotnet_version=$DOTNET_VERSION" >> "$GITHUB_OUTPUT"

##############################################
# Framework
##############################################

FRAMEWORK="dotnet"

if grep -q "Microsoft.NET.Sdk.Web" "$APPLICATION_PROJECT"; then

    FRAMEWORK="aspnetcore"

elif grep -q "Microsoft.NET.Sdk.Worker" "$APPLICATION_PROJECT"; then

    FRAMEWORK="worker"

elif grep -q "Microsoft.NET.Sdk" "$APPLICATION_PROJECT"; then

    FRAMEWORK="dotnet"

fi

echo "Detected Framework : $FRAMEWORK"

echo "framework=$FRAMEWORK" >> "$GITHUB_OUTPUT"

##############################################
# Application DLL
##############################################

ASSEMBLY_NAME=$(grep -oPm1 '(?<=<AssemblyName>)[^<]+' "$APPLICATION_PROJECT" || true)

if [ -z "$ASSEMBLY_NAME" ]; then
    ASSEMBLY_NAME=$(basename "$APPLICATION_PROJECT" .csproj)
fi

APPLICATION_DLL="${ASSEMBLY_NAME}.dll"

echo "Detected Application DLL : $APPLICATION_DLL"

echo "application_dll=$APPLICATION_DLL" >> "$GITHUB_OUTPUT"

##############################################
# Deployment Target
##############################################

DEPLOYMENT_TARGET="cloudrun"

echo "deployment_target=$DEPLOYMENT_TARGET" >> "$GITHUB_OUTPUT"

##############################################
# Dockerfile
##############################################

if [ -f "$APP_PATH/Dockerfile" ]; then
    HAS_DOCKERFILE=true
else
    HAS_DOCKERFILE=false
fi

echo "has_dockerfile=$HAS_DOCKERFILE" >> "$GITHUB_OUTPUT"

##############################################
# Terraform
##############################################

if [ -d "$APP_PATH/terraform" ]; then
    HAS_TERRAFORM=true
else
    HAS_TERRAFORM=false
fi

echo "has_terraform=$HAS_TERRAFORM" >> "$GITHUB_OUTPUT"

##############################################
# GitHub Actions
##############################################

HAS_WORKFLOWS=false

WORKFLOW_DIR="$APP_PATH/.github/workflows"

if [ -d "$WORKFLOW_DIR" ]; then

    echo ""
    echo "Inspecting GitHub Workflows..."

    for workflow in "$WORKFLOW_DIR"/*.yml "$WORKFLOW_DIR"/*.yaml
    do

        [ -e "$workflow" ] || continue

        FILE_NAME=$(basename "$workflow")

        ##########################################################
        # Ignore Platform Agent Caller Workflow
        ##########################################################

        if grep -q "Platform Agent" "$workflow" && \
           grep -q "platform-agent-reusable.yml" "$workflow"; then

            echo "Ignoring Platform Agent caller workflow : $FILE_NAME"
            continue

        fi

        ##########################################################
        # Application Workflow Found
        ##########################################################

        echo "Detected application workflow : $FILE_NAME"

        HAS_WORKFLOWS=true
        break

    done

fi

echo "has_workflows=$HAS_WORKFLOWS" >> "$GITHUB_OUTPUT"

##############################################
# Repository Summary
##############################################

echo ""
echo "========================================="
echo "Repository Summary"
echo "========================================="

echo "Application Path      : $APP_PATH"

if [ -n "$SOLUTION_FILE" ]; then
    echo "Solution File         : $SOLUTION_FILE"
else
    echo "Solution File         : Not Found"
fi

echo "Application Project   : $APPLICATION_PROJECT"
echo "Application DLL       : $APPLICATION_DLL"

echo ""

echo "Language              : $LANGUAGE"
echo "Framework             : $FRAMEWORK"
echo "Build Tool            : $BUILD_TOOL"
echo ".NET Version          : $DOTNET_VERSION"
echo "Target Framework      : $TARGET_FRAMEWORK"
echo "Deployment Target     : $DEPLOYMENT_TARGET"

echo ""

echo "Dockerfile Present    : $HAS_DOCKERFILE"
echo "Terraform Present     : $HAS_TERRAFORM"
echo "GitHub Workflow       : $HAS_WORKFLOWS"

echo "========================================="