#!/bin/bash

ollamaList=$(/usr/local/bin/ollama list | grep deepseek)

result=$(if [[ "$ollamaList" == *"deepseek"* ]]; then 
	echo "$ollamaList"
else
	echo "Not detected"
fi
)

echo "<result>$result</result>"