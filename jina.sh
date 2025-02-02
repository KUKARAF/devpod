#!/bin/bash

# Function to get Jina API key from Pass and define search/read functions
setup_jina() {
    # Get Jina API key from Pass
    JINA_API_KEY=$(pass show llm/jina 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo "Error: Jina API key not found in Pass" >&2
        return 1
    fi
    
    # Set the API key as environment variable
    export JINA_API_KEY
    
    # Define the search function
    jina_search() {
        local query="$1"
        local url="https://s.jina.ai/"
        local headers=(
            "Authorization: Bearer ${JINA_API_KEY}"
            "Content-Type: application/json"
            "Accept: application/json"
        )
        
        # Make the API call
        local response=$(curl -X POST "${url}" -H "${headers[@]}" -d "{\"q\":\"${query}\"}" 2>/dev/null)
        if [ $? -ne 0 ]; then
            echo "Error: Failed to perform search" >&2
            return 1
        fi
        
        # Pretty-print the JSON response
        echo "${response}" | jq .
    }
    
    # Define the read function
    jina_read() {
        local url="$1"
        local headers=(
            "Authorization: Bearer ${JINA_API_KEY}"
            "Content-Type: application/json"
            "Accept: application/json"
        )
        
        # Make the API call
        local response=$(curl -X POST "https://r.jina.ai/" -H "${headers[@]}" -d "{\"url\":\"${url}\"}" 2>/dev/null)
        if [ $? -ne 0 ]; then
            echo "Error: Failed to read URL" >&2
            return 1
        fi
        
        # Extract and print the content
        echo "${response}" | jq -r '.data.content'
    }
}

# Example usage:
# setup_jina
# jina_search "What is Jina AI?"
# jina_read "https://jina.ai"

