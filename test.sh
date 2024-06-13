#!/bin/bash
# Usage: ./test.sh "Hvilken diagnose har Erik Hansen?"

#$API_KEY and $SEARCH_KEY are codespace secrets
api_base="https://norwayeast.api.cognitive.microsoft.com"
deployment_id="test1"
search_endpoint="https://ai-search-kodefest.search.windows.net"
search_index="kodefest"

mkdir -p "output"

if [ "$1" = "" ] ; then
    echo "No question provided"
    exit 1
fi

curl -i -X POST $api_base/openai/deployments/$deployment_id/chat/completions?api-version=2024-02-15-preview \
  -H "Content-Type: application/json" \
  -H "api-key: $API_KEY" \
  -d \
'{
  "data_sources": [
    {
      "type": "azure_search",
      "parameters": {
        "endpoint": "'$search_endpoint'",
        "index_name": "'$search_index'",
        "semantic_configuration": "default",
        "query_type": "simple",
        "fields_mapping": {},
        "in_scope": true,
        "role_information": "You are an AI assistant that helps people find information.",
        "filter": null,
        "strictness": 3,
        "top_n_documents": 5,
        "authentication": {
          "type": "api_key",
          "key": "'$SEARCH_KEY'"
        }
      }
    }
  ],
  "messages": [
    {
      "role": "system",
      "content": "You are an AI assistant that helps people find information."
    },
    { "role": "user", "content": "'"$1"'" }
  ],
  "deployment": "test1",
  "temperature": 0,
  "top_p": 1,
  "max_tokens": 800,
  "stop": null,
  "stream": true
}' | tee output/response.txt

RESPONSE_DATA=$(cat output/response.txt | grep 'data: {' | sed 's/data: //' | tr '\n' ',' | sed 's/,$//')
printf '[%s]' "$RESPONSE_DATA" | jq -S > output/response_data.json
