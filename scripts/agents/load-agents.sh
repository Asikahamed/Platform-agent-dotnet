#!/bin/bash

set -e

echo "========================================="
echo "Platform Agent - Loading AI Agents"
echo "========================================="

##############################################
# Validate Environment
##############################################

if [ -z "$PLATFORM_HOME" ]; then
    echo "ERROR: PLATFORM_HOME is not set."
    exit 1
fi

AGENT_DIR="$PLATFORM_HOME/.github/agents"

echo "Platform Home   : $PLATFORM_HOME"
echo "Agent Directory : $AGENT_DIR"

##############################################
# Validate Agent Directory
##############################################

if [ ! -d "$AGENT_DIR" ]; then
    echo "ERROR: Agent directory not found."
    exit 1
fi

##############################################
# Required Agents
##############################################

REQUIRED_AGENTS=(
    docker-agent
    terraform-agent
    cicd-agent
)

echo ""
echo "Loading required agents..."

for agent in "${REQUIRED_AGENTS[@]}"
do

    AGENT_FILE="$AGENT_DIR/$agent.agent.md"

    if [ ! -f "$AGENT_FILE" ]; then
        echo "ERROR: $agent.agent.md not found."
        exit 1
    fi

    echo "Loaded $agent"

    OUTPUT_NAME=$(echo "$agent" | tr '-' '_')

    echo "${OUTPUT_NAME}=$AGENT_FILE" >> "$GITHUB_OUTPUT"

done

##############################################
# Optional Agents
##############################################

OPTIONAL_AGENTS=(
    kubernetes-agent
)

echo ""
echo "Loading optional agents..."

for agent in "${OPTIONAL_AGENTS[@]}"
do

    AGENT_FILE="$AGENT_DIR/$agent.agent.md"

    if [ -f "$AGENT_FILE" ]; then

        echo "Loaded $agent"

        OUTPUT_NAME=$(echo "$agent" | tr '-' '_')

        echo "${OUTPUT_NAME}=$AGENT_FILE" >> "$GITHUB_OUTPUT"

    else

        echo "$agent not found (optional)"

    fi

done

##############################################
# Display Loaded Agents
##############################################

echo ""
echo "========================================="
echo "Loaded AI Agents"
echo "========================================="

for agent in "${REQUIRED_AGENTS[@]}"
do

    AGENT_FILE="$AGENT_DIR/$agent.agent.md"

    echo ""
    echo "$agent"
    echo "-----------------------------------------"

    cat "$AGENT_FILE"

done

for agent in "${OPTIONAL_AGENTS[@]}"
do

    AGENT_FILE="$AGENT_DIR/$agent.agent.md"

    if [ -f "$AGENT_FILE" ]; then

        echo ""
        echo "$agent"
        echo "-----------------------------------------"

        cat "$AGENT_FILE"

    fi

done

echo ""
echo "========================================="
echo "All AI Agents Loaded Successfully"
echo "========================================="