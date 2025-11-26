# Apple AI Server

> **A simple HTTP server that makes Apple Intelligence accessible to web developers**

Bridge the gap between Apple's on-device Foundation Models and your web applications. No Swift knowledge required—just make HTTP requests and get AI-powered responses running entirely on your Mac.

## Why This Exists

Apple's Foundation Models framework (introduced in macOS 26 Tahoe) provides powerful on-device AI through a Swift API. Great for native apps, but what about web developers?

This server solves that problem:
- ✅ **Privacy-first**: All inference happens locally on your Mac
- ✅ **Zero API costs**: Unlimited requests, no usage fees
- ✅ **No Swift required**: Call it from JavaScript, Python, or any language
- ✅ **Fast**: Optimized for Apple Silicon (M1/M2/M3/M4)
- ✅ **Offline**: Works without internet connection

Perfect for web developers who want to experiment with local AI without learning Swift or dealing with cloud API costs.

## Quick Start

### Requirements

- **macOS 26 (Tahoe)** or later
- **Apple Silicon Mac** (M1/M2/M3/M4) that supports Apple Intelligence
- **Apple Intelligence enabled** (System Settings → Apple Intelligence)
- **Xcode Command Line Tools**: `xcode-select --install`

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/apple-ai-server.git
cd apple-ai-server

# Build and run
swift run
```

You should see:
```
✅ Apple AI Server running on http://localhost:8080
📝 POST to http://localhost:8080/completion
```

### First Request

```bash
curl -X POST http://localhost:8080/completion \
  -H "Content-Type: application/json" \
  -d '{"prompt": "Write a haiku about coding"}'
```

Response:
```json
{
  "response": "Code flows like water,\nLogic dances on the screen—\nBugs flee from debugger.",
  "error": null
}
```

**That's it!** Your Mac just generated that response locally using Apple Intelligence.

## API Documentation

### POST /completion

Generate AI completions.

**Request:**
```json
{
  "prompt": "Your question or instruction",
  "systemPrompt": "Optional: Sets AI behavior/role",
  "temperature": 0.7,
  "maxTokens": 500
}
```

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `prompt` | string | Yes | Your question or instruction to the AI |
| `systemPrompt` | string | No | Sets the AI's behavior (e.g., "You are a helpful coding assistant") |
| `temperature` | float | No | Controls randomness: `0.0` = deterministic, `2.0` = very creative. Default: ~1.0 |
| `maxTokens` | int | No | Maximum response length in tokens |

**Response:**
```json
{
  "response": "AI-generated text here",
  "error": null
}
```

On error:
```json
{
  "response": "",
  "error": "Error message here"
}
```

### POST /reset

Clear conversation history and start a fresh session.

**Request:** Empty body

**Response:**
```json
{
  "response": "Session reset successfully",
  "error": null
}
```

## Examples

### JavaScript (Browser)

```javascript
async function askAI(prompt) {
  const response = await fetch('http://localhost:8080/completion', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ prompt })
  });
  
  const data = await response.json();
  return data.response;
}

// Use it
const answer = await askAI('Explain closures in JavaScript');
console.log(answer);
```

### JavaScript (Node.js)

```javascript
const fetch = require('node-fetch');

async function askAI(prompt, systemPrompt = null) {
  const response = await fetch('http://localhost:8080/completion', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ 
      prompt,
      systemPrompt,
      temperature: 0.7
    })
  });
  
  const data = await response.json();
  
  if (data.error) {
    throw new Error(data.error);
  }
  
  return data.response;
}

// Example: Code assistant
const code = await askAI(
  'Write a function to reverse a string',
  'You are an expert JavaScript developer'
);

console.log(code);
```

### Python

```python
import requests
import json

def ask_ai(prompt, system_prompt=None, temperature=0.7):
    response = requests.post(
        'http://localhost:8080/completion',
        headers={'Content-Type': 'application/json'},
        json={
            'prompt': prompt,
            'systemPrompt': system_prompt,
            'temperature': temperature
        }
    )
    
    data = response.json()
    
    if data.get('error'):
        raise Exception(data['error'])
    
    return data['response']

# Example: Content generation
article = ask_ai(
    'Write an introduction about local AI development',
    system_prompt='You are a technical writer',
    temperature=0.8
)

print(article)
```

### cURL

```bash
# Simple question
curl -X POST http://localhost:8080/completion \
  -H "Content-Type: application/json" \
  -d '{"prompt": "What is recursion?"}'

# With system prompt for specific behavior
curl -X POST http://localhost:8080/completion \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "Explain async/await",
    "systemPrompt": "You are a patient teacher. Use simple analogies.",
    "temperature": 0.5
  }'

# Deterministic responses (always same answer)
curl -X POST http://localhost:8080/completion \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "List the days of the week",
    "temperature": 0.0
  }'

# Reset conversation
curl -X POST http://localhost:8080/reset
```

See the [examples](examples/) directory for complete working examples.

## Use Cases

### Code Assistant
```javascript
const systemPrompt = "You are an expert Swift developer. Provide clean, idiomatic code.";
const code = await askAI("Write a function to parse JSON in Swift", systemPrompt);
```

### Content Generation
```javascript
const systemPrompt = "You are a creative copywriter.";
const tagline = await askAI("Write a tagline for a coffee shop", systemPrompt);
```

### Learning Tool
```javascript
const systemPrompt = "You are a patient tutor. Use simple explanations.";
const explanation = await askAI("How do promises work in JavaScript?", systemPrompt);
```

### Documentation Helper
```javascript
const systemPrompt = "You are a technical writer. Be concise and clear.";
const docs = await askAI("Document this API endpoint: GET /users/:id", systemPrompt);
```

## Performance

**First request:** ~2-3 seconds (model loads)  
**Subsequent requests:** <1 second for typical responses  
**Memory usage:** ~2-4 GB  
**CPU:** Uses Apple Neural Engine + GPU  

On an M4 Max, responses are very snappy after the initial load.

## How It Works

```
┌─────────────┐      HTTP      ┌──────────────┐      Swift API      ┌─────────────────┐
│   Your      │ ────────────►  │   Apple AI   │  ─────────────────► │ Foundation      │
│   Web App   │    POST /      │   Server     │    LanguageModel    │ Models (3B)     │
│             │   completion   │   (Swift)    │       Session       │ Apple Silicon   │
│ JS/Python/  │                │              │                     │                 │
│ Any Language│ ◄────────────  │   Port 8080  │ ◄─────────────────  │ Neural Engine   │
└─────────────┘      JSON      └──────────────┘      response       └─────────────────┘
                    response                                          (On-Device AI)
```

1. Your app sends HTTP POST with a prompt
2. Swift server receives and validates request
3. Calls Apple's Foundation Models API
4. AI runs locally on your Mac's Neural Engine
5. Response returned as JSON
6. No data leaves your machine

## Comparison

| Feature | Apple AI Server | Cloud APIs (OpenAI, etc) | Ollama |
|---------|----------------|------------------------|--------|
| **Privacy** | ✅ 100% local | ❌ Cloud-based | ✅ Local |
| **Cost** | ✅ Free | ❌ Pay per use | ✅ Free |
| **Setup** | Built into macOS 26 | API keys, billing | Separate install |
| **Speed** | ✅ Fast on Apple Silicon | ⚠️ Network latency | ✅ Fast |
| **Offline** | ✅ Yes | ❌ No | ✅ Yes |
| **Model Choice** | Apple's 3B model | Many options | Many options |
| **Model Size** | ~3B parameters | Much larger | Configurable |

## Troubleshooting

### "Foundation Models not available"

**Check these:**
1. Running macOS 26 (Tahoe) or later: `sw_vers`
2. Apple Intelligence enabled: System Settings → Apple Intelligence
3. Mac supports Apple Intelligence (M1 or newer)
4. Model downloaded (happens automatically when enabled)

### "Failed to connect to localhost port 8080"

**Solutions:**
- Server isn't running: `swift run`
- Port in use: `lsof -ti:8080 | xargs kill -9`
- Wrong port: Check server output for actual port

### First request is slow

This is **normal**! The model loads on first use (~2-3 seconds). Subsequent requests are much faster.

### Responses seem off-topic

The session maintains context. Use `/reset` to start fresh:
```bash
curl -X POST http://localhost:8080/reset
```

## Limitations

**Model Capabilities:**
- ~3B parameters (smaller than GPT-4, Claude, etc.)
- Not designed for advanced reasoning or world knowledge
- Best for: content generation, summarization, simple Q&A
- Avoid: Complex math, latest news, specialized knowledge

**Device Requirements:**
- Requires Apple Intelligence (iPhone 15 Pro+, or M1+ Macs)
- Uses ~2-4 GB RAM
- First request loads model

**Not Production-Ready:**
- No authentication
- No rate limiting
- Single-threaded request handling
- Basic error messages

This is a **development tool**, not a production server. Great for prototyping, learning, and local development.

## Development

### Project Structure

```
apple-ai-server/
├── Sources/
│   └── main.swift          # Server implementation
├── examples/
│   ├── javascript/         # JS examples
│   ├── python/            # Python examples
│   ├── curl/              # Shell examples
│   └── web/               # HTML/browser examples
├── Package.swift          # Swift package config
└── README.md             # This file
```

### Building from Source

```bash
# Debug build (faster compilation)
swift build

# Release build (optimized)
swift build -c release

# Run directly
swift run

# Run release binary
.build/release/AppleAIServer
```

### Customizing

**Change port:**

Edit `Sources/main.swift`:
```swift
let server = try await AppleAIHTTPServer(port: 3000)
```

**Add authentication:**

Add header checking in `processRequest()`:
```swift
guard request.contains("Authorization: Bearer YOUR_TOKEN") else {
    return errorResponse("Unauthorized", statusCode: 401)
}
```

**Add logging:**

Expand the print statements or integrate a logging library.

**Like this?** Star the repo and share with other web developers who want to experiment with local AI!
