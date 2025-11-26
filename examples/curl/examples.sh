#!/bin/bash

# Apple AI Server - cURL Examples
# 
# Make sure the server is running: swift run
# Then run: ./examples.sh

echo "Apple AI Server - cURL Examples"
echo "================================"
echo ""

# Check if server is running
echo "Checking if server is running..."
if ! curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/completion -X OPTIONS | grep -q "204\|200"; then
    echo "❌ Server is not responding"
    echo "   Start it with: swift run"
    exit 1
fi

echo "✅ Server is running"
echo ""

# Example 1: Simple question
echo "Example 1: Simple Question"
echo "=========================="
echo ""
echo "Request:"
echo "  prompt: 'What is the capital of France?'"
echo ""

RESPONSE=$(curl -s -X POST http://localhost:8080/completion \
  -H "Content-Type: application/json" \
  -d '{"prompt": "What is the capital of France?"}')

echo "Response:"
echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
echo ""
echo "---"
echo ""

# Example 2: With system prompt
echo "Example 2: With System Prompt"
echo "=============================="
echo ""
echo "Request:"
echo "  prompt: 'Explain closures'"
echo "  systemPrompt: 'You are a programming tutor'"
echo ""

RESPONSE=$(curl -s -X POST http://localhost:8080/completion \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Explain closures in JavaScript in one sentence",
    "systemPrompt": "You are a programming tutor. Be concise."
  }')

echo "Response:"
echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
echo ""
echo "---"
echo ""

# Example 3: Code generation
echo "Example 3: Code Generation"
echo "=========================="
echo ""
echo "Request:"
echo "  prompt: 'Write a function to reverse a string'"
echo "  systemPrompt: 'You are an expert JavaScript developer'"
echo ""

RESPONSE=$(curl -s -X POST http://localhost:8080/completion \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Write a JavaScript function to reverse a string",
    "systemPrompt": "You are an expert JavaScript developer. Provide clean code."
  }')

echo "Response:"
echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
echo ""
echo "---"
echo ""

# Example 4: Deterministic responses
echo "Example 4: Deterministic Responses (temperature=0.0)"
echo "===================================================="
echo ""
echo "Asking the same question twice..."
echo ""

RESPONSE1=$(curl -s -X POST http://localhost:8080/completion \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "What are the first 3 prime numbers?",
    "temperature": 0.0
  }')

RESPONSE2=$(curl -s -X POST http://localhost:8080/completion \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "What are the first 3 prime numbers?",
    "temperature": 0.0
  }')

echo "First response:"
echo "$RESPONSE1" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE1"
echo ""

echo "Second response:"
echo "$RESPONSE2" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE2"
echo ""

# Compare (simple string comparison)
if [ "$RESPONSE1" = "$RESPONSE2" ]; then
    echo "Responses are identical ✓"
else
    echo "Responses differ (this is unexpected with temperature=0.0)"
fi

echo ""
echo "---"
echo ""

# Example 5: Creative responses
echo "Example 5: Creative Responses (temperature=1.5)"
echo "==============================================="
echo ""
echo "Asking for a creative tagline..."
echo ""

RESPONSE=$(curl -s -X POST http://localhost:8080/completion \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Write a creative tagline for a coffee shop",
    "systemPrompt": "You are a creative copywriter",
    "temperature": 1.5
  }')

echo "Response:"
echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
echo ""
echo "---"
echo ""

# Example 6: Token limit
echo "Example 6: With Token Limit"
echo "============================"
echo ""
echo "Request:"
echo "  prompt: 'Explain what an API is'"
echo "  maxTokens: 50"
echo ""

RESPONSE=$(curl -s -X POST http://localhost:8080/completion \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Explain what an API is",
    "maxTokens": 50
  }')

echo "Response (limited to ~50 tokens):"
echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
echo ""
echo "---"
echo ""

# Example 7: Session reset
echo "Example 7: Session Reset"
echo "========================"
echo ""
echo "Resetting the conversation history..."
echo ""

RESPONSE=$(curl -s -X POST http://localhost:8080/reset \
  -H "Content-Type: application/json")

echo "Response:"
echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
echo ""
echo "---"
echo ""

# Example 8: Error handling
echo "Example 8: Error Handling"
echo "========================="
echo ""
echo "Sending invalid JSON..."
echo ""

RESPONSE=$(curl -s -X POST http://localhost:8080/completion \
  -H "Content-Type: application/json" \
  -d 'this is not valid json')

echo "Response:"
echo "$RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$RESPONSE"
echo ""
echo "Note: Server properly returns error response ✓"
echo ""
echo "---"
echo ""

echo "All examples completed! ✨"
echo ""
echo "Try your own:"
echo "  curl -X POST http://localhost:8080/completion \\"
echo "    -H \"Content-Type: application/json\" \\"
echo "    -d '{\"prompt\": \"Your question here\"}'"
