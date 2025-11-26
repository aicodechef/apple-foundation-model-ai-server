// Apple AI Server - Node.js Example
// 
// Install: npm install node-fetch
// Run: node example.js

const fetch = require('node-fetch');

const SERVER_URL = 'http://localhost:8080/completion';

/**
 * Ask the AI a question
 * 
 * @param {string} prompt - Your question or instruction
 * @param {string} systemPrompt - Optional: Sets AI behavior
 * @param {number} temperature - Optional: 0.0 = deterministic, 2.0 = creative
 * @returns {Promise<string>} AI response
 */
async function askAI(prompt, systemPrompt = null, temperature = null) {
  try {
    const response = await fetch(SERVER_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ 
        prompt,
        systemPrompt,
        temperature
      })
    });

    const data = await response.json();
    
    if (data.error) {
      throw new Error(data.error);
    }
    
    return data.response;
  } catch (error) {
    throw new Error(`Failed to get AI response: ${error.message}`);
  }
}

// Example 1: Simple question
async function example1() {
  console.log('Example 1: Simple Question');
  console.log('===========================\n');
  
  const answer = await askAI('What is the capital of France?');
  console.log('Q: What is the capital of France?');
  console.log('A:', answer);
  console.log('\n');
}

// Example 2: Code generation
async function example2() {
  console.log('Example 2: Code Generation');
  console.log('==========================\n');
  
  const code = await askAI(
    'Write a JavaScript function that debounces a function call',
    'You are an expert JavaScript developer. Provide clean, production-ready code.'
  );
  
  console.log('Q: Write a debounce function');
  console.log('A:\n', code);
  console.log('\n');
}

// Example 3: Creative writing
async function example3() {
  console.log('Example 3: Creative Writing');
  console.log('===========================\n');
  
  const tagline = await askAI(
    'Write a catchy tagline for a coffee shop that serves AI developers',
    'You are a creative copywriter',
    1.5  // Higher temperature for creativity
  );
  
  console.log('Q: Coffee shop tagline for AI developers');
  console.log('A:', tagline);
  console.log('\n');
}

// Example 4: Deterministic responses
async function example4() {
  console.log('Example 4: Deterministic Responses');
  console.log('===================================\n');
  
  console.log('Asking the same question twice with temperature=0.0...\n');
  
  const prompt = 'List the first 5 prime numbers';
  
  const answer1 = await askAI(prompt, null, 0.0);
  const answer2 = await askAI(prompt, null, 0.0);
  
  console.log('First response:', answer1);
  console.log('Second response:', answer2);
  console.log('Are they the same?', answer1 === answer2 ? 'YES ✓' : 'NO ✗');
  console.log('\n');
}

// Example 5: Error handling
async function example5() {
  console.log('Example 5: Error Handling');
  console.log('=========================\n');
  
  try {
    // Try to connect to wrong port
    const wrongURL = 'http://localhost:9999/completion';
    const response = await fetch(wrongURL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ prompt: 'Hello' })
    });
    
    const data = await response.json();
    console.log(data);
  } catch (error) {
    console.log('Caught expected error:', error.message);
    console.log('This shows proper error handling ✓');
  }
  
  console.log('\n');
}

// Run all examples
async function main() {
  console.log('Apple AI Server - Node.js Examples');
  console.log('===================================\n');
  console.log('Make sure the server is running: swift run\n');
  
  try {
    await example1();
    await example2();
    await example3();
    await example4();
    await example5();
    
    console.log('All examples completed! ✨');
  } catch (error) {
    console.error('\n❌ Error:', error.message);
    console.error('\nTroubleshooting:');
    console.error('1. Is the server running? (swift run)');
    console.error('2. Is it on port 8080?');
    console.error('3. Is Apple Intelligence enabled?');
  }
}

main();
