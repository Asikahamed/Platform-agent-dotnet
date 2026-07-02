#!/bin/bash

set -e

echo "========================================="
echo "Platform Agent - Git Operations"
echo "========================================="

##############################################
# Configure Git
##############################################

git config user.name "platform-agent"
git config user.email "platform-agent@users.noreply.github.com"

echo "Git configured."

##############################################
# Create Feature Branch
##############################################

BRANCH_NAME="platform-agent-$(date +%Y%m%d-%H%M%S)"

echo "Creating branch: $BRANCH_NAME"

git checkout -b "$BRANCH_NAME"

echo "branch_name=$BRANCH_NAME" >> "$GITHUB_OUTPUT"

##############################################
# Stage Changes
##############################################

git add .

##############################################
# Check if Anything Changed
##############################################

if git diff --cached --quiet; then

    echo ""
    echo "========================================="
    echo "No changes detected."
    echo "Skipping commit and push."
    echo "========================================="

    echo "changes=false" >> "$GITHUB_OUTPUT"

    exit 0

fi

echo "changes=true" >> "$GITHUB_OUTPUT"

##############################################
# Commit Changes
##############################################

git commit -m "chore(platform-agent): generate DevOps assets for ${LANGUAGE} application"
##############################################
# Push Branch
##############################################

echo "Pushing branch..."

git push origin "$BRANCH_NAME"

##############################################
# Summary
##############################################

echo ""
echo "========================================="
echo "Git Summary"
echo "========================================="

echo "Branch : $BRANCH_NAME"

echo ""

git log --oneline -1

echo ""

git status

echo ""

echo "Git operations completed successfully."