#!/bin/bash

if [[ "$1" == "search" ]]; then
    # Remove the first argument and join the rest with spaces
    shift
    query="$*"
    
    # Get API key directly from pass
    JINA_API_KEY=$(pass show llm/jina 2>/dev/null) || { echo "Error: Jina API key not found in Pass" >&2; exit 1; }
    
    # Make the API call
    response=$(curl -X POST "https://s.jina.ai/" \
        -H "Authorization: Bearer ${JINA_API_KEY}" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        -d "{\"q\":\"${query}\"}" 2>/dev/null) || { echo "Error: Failed to perform search" >&2; exit 1; }
    
    # Pretty-print the JSON response
    echo "${response}" | jq .

elif [[ "$1" == "read" ]]; then
    url="$2"
    
    # Get API key directly from pass
    JINA_API_KEY=$(pass show llm/jina 2>/dev/null) || { echo "Error: Jina API key not found in Pass" >&2; exit 1; }
    
    # Make the API call
    response=$(curl -X POST "https://r.jina.ai/" \
        -H "Authorization: Bearer ${JINA_API_KEY}" \
        -H "Content-Type: application/json" \
        -H "Accept: application/json" \
        -d "{\"url\":\"${url}\"}" 2>/dev/null) || { echo "Error: Failed to read URL" >&2; exit 1; }
    
    # Extract and print the content
    echo "${response}" | jq -r '.data.content'

else
    echo "Usage:"
    echo "  jina search <search terms>"
    echo "  jina read <url>"
    exit 1
fi

