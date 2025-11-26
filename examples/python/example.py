"""
Apple AI Server - Python Example

Install: pip install requests
Run: python example.py
"""

import requests
import json
from typing import Optional

SERVER_URL = 'http://localhost:8080/completion'


def ask_ai(
    prompt: str, 
    system_prompt: Optional[str] = None,
    temperature: Optional[float] = None,
    max_tokens: Optional[int] = None
) -> str:
    """
    Ask the AI a question
    
    Args:
        prompt: Your question or instruction
        system_prompt: Optional behavior/role for the AI
        temperature: 0.0 = deterministic, 2.0 = creative
        max_tokens: Maximum response length
        
    Returns:
        AI response text
        
    Raises:
        Exception: If request fails or API returns error
    """
    payload = {
        'prompt': prompt,
        'systemPrompt': system_prompt,
        'temperature': temperature,
        'maxTokens': max_tokens
    }
    
    # Remove None values
    payload = {k: v for k, v in payload.items() if v is not None}
    
    try:
        response = requests.post(
            SERVER_URL,
            headers={'Content-Type': 'application/json'},
            json=payload,
            timeout=30
        )
        response.raise_for_status()
        
        data = response.json()
        
        if data.get('error'):
            raise Exception(data['error'])
        
        return data['response']
        
    except requests.exceptions.RequestException as e:
        raise Exception(f"Failed to connect to AI server: {e}")


def example1_simple_question():
    """Example 1: Simple question"""
    print("Example 1: Simple Question")
    print("=" * 40)
    print()
    
    answer = ask_ai("What is the capital of France?")
    
    print("Q: What is the capital of France?")
    print(f"A: {answer}")
    print()


def example2_code_generation():
    """Example 2: Code generation with system prompt"""
    print("Example 2: Code Generation")
    print("=" * 40)
    print()
    
    code = ask_ai(
        "Write a Python function to calculate fibonacci numbers",
        system_prompt="You are an expert Python developer. Write clean, idiomatic Python."
    )
    
    print("Q: Write a fibonacci function")
    print(f"A:\n{code}")
    print()


def example3_content_writing():
    """Example 3: Creative content with higher temperature"""
    print("Example 3: Creative Writing")
    print("=" * 40)
    print()
    
    blog_intro = ask_ai(
        "Write an engaging introduction for a blog post about local AI development",
        system_prompt="You are a technical blogger. Be engaging and informative.",
        temperature=1.2
    )
    
    print("Q: Write a blog introduction")
    print(f"A:\n{blog_intro}")
    print()


def example4_structured_data():
    """Example 4: Extracting structured information"""
    print("Example 4: Structured Data Extraction")
    print("=" * 40)
    print()
    
    result = ask_ai(
        "Extract the key points from this text as a bullet list: 'Python is a high-level programming language. It emphasizes code readability. It supports multiple programming paradigms.'",
        system_prompt="Extract information as a concise bullet list."
    )
    
    print("Q: Extract key points as bullets")
    print(f"A:\n{result}")
    print()


def example5_deterministic():
    """Example 5: Deterministic responses"""
    print("Example 5: Deterministic Responses")
    print("=" * 40)
    print()
    
    prompt = "List the first 3 programming paradigms"
    
    print("Asking the same question twice with temperature=0.0...")
    print()
    
    answer1 = ask_ai(prompt, temperature=0.0)
    answer2 = ask_ai(prompt, temperature=0.0)
    
    print(f"First: {answer1}")
    print(f"Second: {answer2}")
    print(f"Identical: {'YES ✓' if answer1 == answer2 else 'NO ✗'}")
    print()


def example6_token_limit():
    """Example 6: Limiting response length"""
    print("Example 6: Token Limits")
    print("=" * 40)
    print()
    
    short = ask_ai(
        "Explain what an API is",
        max_tokens=50
    )
    
    long = ask_ai(
        "Explain what an API is",
        max_tokens=200
    )
    
    print("Short response (max 50 tokens):")
    print(short)
    print()
    print("Long response (max 200 tokens):")
    print(long)
    print()


def example7_error_handling():
    """Example 7: Error handling"""
    print("Example 7: Error Handling")
    print("=" * 40)
    print()
    
    try:
        # Try to connect to wrong port
        wrong_url = 'http://localhost:9999/completion'
        response = requests.post(
            wrong_url,
            json={'prompt': 'Hello'},
            timeout=1
        )
    except requests.exceptions.RequestException as e:
        print(f"Caught expected error: {type(e).__name__}")
        print("This demonstrates proper error handling ✓")
    print()


def main():
    """Run all examples"""
    print("Apple AI Server - Python Examples")
    print("=" * 40)
    print()
    print("Make sure the server is running: swift run")
    print()
    
    try:
        example1_simple_question()
        example2_code_generation()
        example3_content_writing()
        example4_structured_data()
        example5_deterministic()
        example6_token_limit()
        example7_error_handling()
        
        print("All examples completed! ✨")
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        print("\nTroubleshooting:")
        print("1. Is the server running? (swift run)")
        print("2. Is it on port 8080?")
        print("3. Is Apple Intelligence enabled?")
        print("4. Do you have the requests library? (pip install requests)")


if __name__ == '__main__':
    main()
