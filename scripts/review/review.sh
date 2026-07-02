#!/bin/bash

set -e

echo "Generating Platform Review..."

cat <<EOF >> "$GITHUB_STEP_SUMMARY"

# 🤖 .NET Platform Agent Review

## Repository Analysis

| Property | Value |
|----------|-------|
| Language | ${LANGUAGE} |
| Framework | ${FRAMEWORK} |
| Build Tool | ${BUILD_TOOL} |
| .NET Version | ${DOTNET_VERSION} |
| Deployment Target | ${DEPLOYMENT_TARGET} |
| Solution File | ${SOLUTION_FILE} |
| Project File | ${PROJECT_FILE} |
| Application DLL | ${APPLICATION_DLL} |

---

## Selected Templates

| Asset | Template |
|-------|----------|
| Docker | ${DOCKER_TEMPLATE} |
| Terraform | ${TERRAFORM_TEMPLATE} |
| GitHub Actions | ${CICD_TEMPLATE} |

---

## Generated Assets

- ✅ Dockerfile
- ✅ .dockerignore
- ✅ Terraform Configuration
- ✅ GitHub Actions CI Workflow
- ✅ GitHub Actions CD Workflow

---

## Git Status

| Property | Value |
|----------|-------|
| Branch | ${BRANCH_NAME} |
| Changes | ${CHANGES} |

EOF

echo "Platform Review Completed."