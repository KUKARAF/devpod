#!/bin/bash

case "$1" in
    "search")
        shift
        curl -X POST "https://s.jina.ai/" \
            -H "Authorization: Bearer $(pass show llm/jina)" \
            -H "Content-Type: application/json" \
            -H "Accept: application/json" \
            -d "{\"q\":\"$*\"}" 2>/dev/null | jq . || echo "Error: Search failed" >&2
        ;;
    "read")
        curl -X POST "https://r.jina.ai/" \
            -H "Authorization: Bearer $(pass show llm/jina)" \
            -H "Content-Type: application/json" \
            -H "Accept: application/json" \
            -d "{\"url\":\"$2\"}" 2>/dev/null | jq -r '.data.content' || echo "Error: Read failed" >&2
        ;;
    *)
        echo "Usage:"
        echo "  jina search <search terms>"
        echo "  jina read <url>"
        exit 1
        ;;
esac

