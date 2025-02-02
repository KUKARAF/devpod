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
    "classify")
        shift
        if [[ "$1" == "text" ]]; then
            shift
            curl -X POST "https://api.jina.ai/v1/classify" \
                -H "Authorization: Bearer $(pass show llm/jina)" \
                -H "Content-Type: application/json" \
                -H "Accept: application/json" \
                -d "{\"model\":\"jina-embeddings-v3\", \"input\":[\"$1\"], \"labels\":[${*:2}]}" 2>/dev/null | jq . || echo "Error: Classification failed" >&2
        elif [[ "$1" == "image" ]]; then
            shift
            curl -X POST "https://api.jina.ai/v1/classify" \
                -H "Authorization: Bearer $(pass show llm/jina)" \
                -H "Content-Type: application/json" \
                -H "Accept: application/json" \
                -d "{\"model\":\"jina-clip-v2\", \"input\":[{\"image\":\"$(base64 -w 0 "$1")\"}], \"labels\":[${*:2}]}" 2>/dev/null | jq . || echo "Error: Classification failed" >&2
        fi
        ;;
    "embed")
        shift
        curl -X POST "https://api.jina.ai/v1/embeddings" \
            -H "Authorization: Bearer $(pass show llm/jina)" \
            -H "Content-Type: application/json" \
            -H "Accept: application/json" \
            -d "{\"model\":\"jina-embeddings-v3\", \"input\":[\"$*\"]}" 2>/dev/null | jq . || echo "Error: Embedding failed" >&2
        ;;
    "rerank")
        if [[ -z "$3" ]]; then
            echo "Error: Need query and at least one document to rerank" >&2
            exit 1
        fi
        query="$2"
        shift 2
        docs="["
        for doc in "$@"; do
            docs="$docs\"$doc\","
        done
        docs="${docs%,}]"
        curl -X POST "https://api.jina.ai/v1/rerank" \
            -H "Authorization: Bearer $(pass show llm/jina)" \
            -H "Content-Type: application/json" \
            -H "Accept: application/json" \
            -d "{\"model\":\"jina-reranker-v2-base-multilingual\", \"query\":\"$query\", \"documents\":$docs}" 2>/dev/null | jq . || echo "Error: Reranking failed" >&2
        ;;
    "ground")
        shift
        curl -X POST "https://g.jina.ai/" \
            -H "Authorization: Bearer $(pass show llm/jina)" \
            -H "Content-Type: application/json" \
            -H "Accept: application/json" \
            -d "{\"statement\":\"$*\"}" 2>/dev/null | jq . || echo "Error: Grounding failed" >&2
        ;;
    "segment")
        shift
        curl -X POST "https://segment.jina.ai/" \
            -H "Authorization: Bearer $(pass show llm/jina)" \
            -H "Content-Type: application/json" \
            -H "Accept: application/json" \
            -d "{\"content\":\"$*\", \"return_tokens\":true, \"return_chunks\":true}" 2>/dev/null | jq . || echo "Error: Segmentation failed" >&2
        ;;
    *)
        echo "Usage:"
        echo "  jina search <search terms>            - Search the web"
        echo "  jina read <url>                      - Extract content from URL"
        echo "  jina classify text <text> <labels>   - Classify text into categories"
        echo "  jina classify image <path> <labels>  - Classify image into categories"
        echo "  jina embed <text>                    - Generate embeddings for text"
        echo "  jina rerank <query> <doc1> [doc2..] - Rerank documents by relevance"
        echo "  jina ground <statement>              - Verify factual accuracy"
        echo "  jina segment <text>                  - Split text into chunks"
        exit 1
        ;;
esac

