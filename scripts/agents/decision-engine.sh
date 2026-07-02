#!/bin/bash

set -e

echo "========================================="
echo "Platform Agent - Decision Engine"
echo "========================================="

##############################################
# Validate Environment
##############################################

if [ -z "$PLATFORM_HOME" ]; then
    echo "ERROR: PLATFORM_HOME is not set."
    exit 1
fi

##############################################
# Repository Context
##############################################

LANGUAGE="${LANGUAGE:-dotnet}"
BUILD_TOOL="${BUILD_TOOL:-dotnet}"
FRAMEWORK="${FRAMEWORK:-aspnetcore}"
DEPLOYMENT_TARGET="${DEPLOYMENT_TARGET:-cloudrun}"

echo "Language          : $LANGUAGE"
echo "Framework         : $FRAMEWORK"
echo "Build Tool        : $BUILD_TOOL"
echo "Deployment Target : $DEPLOYMENT_TARGET"

echo ""

##############################################
# Docker Template
##############################################

case "$LANGUAGE" in

    dotnet)

        DOCKER_TEMPLATE="$PLATFORM_HOME/platform-templates/docker/dotnet"
        ;;

    *)

        echo "Unsupported language: $LANGUAGE"
        exit 1
        ;;

esac

##############################################
# Terraform Template
##############################################

case "$DEPLOYMENT_TARGET" in

    cloudrun)

        TERRAFORM_TEMPLATE="$PLATFORM_HOME/platform-templates/terraform/gcp-cloudrun"
        ;;

    gke)

        TERRAFORM_TEMPLATE="$PLATFORM_HOME/platform-templates/terraform/gke"
        ;;

    *)

        echo "Unsupported deployment target: $DEPLOYMENT_TARGET"
        exit 1
        ;;

esac

##############################################
# GitHub Actions Template
##############################################

case "$LANGUAGE-$BUILD_TOOL-$DEPLOYMENT_TARGET" in

    dotnet-dotnet-cloudrun)

        CICD_TEMPLATE="$PLATFORM_HOME/platform-templates/github-actions/dotnet"
        ;;

    *)

        echo "No matching CI/CD template found."
        exit 1
        ;;

esac

##############################################
# Validate Templates
##############################################

for TEMPLATE in \
    "$DOCKER_TEMPLATE" \
    "$TERRAFORM_TEMPLATE" \
    "$CICD_TEMPLATE"
do

    if [ ! -d "$TEMPLATE" ]; then
        echo "Template not found:"
        echo "$TEMPLATE"
        exit 1
    fi

done

##############################################
# Export Outputs
##############################################

echo "docker_template=$DOCKER_TEMPLATE" >> "$GITHUB_OUTPUT"
echo "terraform_template=$TERRAFORM_TEMPLATE" >> "$GITHUB_OUTPUT"
echo "cicd_template=$CICD_TEMPLATE" >> "$GITHUB_OUTPUT"

##############################################
# Summary
##############################################

echo ""
echo "========================================="
echo "Selected Templates"
echo "========================================="

echo "Docker Template     : $DOCKER_TEMPLATE"
echo "Terraform Template  : $TERRAFORM_TEMPLATE"
echo "GitHub Actions      : $CICD_TEMPLATE"

echo "========================================="
echo "Decision Completed Successfully"
echo "========================================="