#!/usr/bin/env python3
"""
Assemble role-specific system prompts from system-comps.

Usage: ./build_prompt.py <role_name>
Example: ./build_prompt.py orchestrator
"""

import sys
import yaml
from pathlib import Path
from datetime import datetime

def estimate_tokens(text: str) -> int:
    """Rough token estimate: ~4 chars per token"""
    return len(text) // 4

def build_prompt(role_name: str) -> str:
    """Assemble system prompt from comps for given role"""

    # Load configuration
    config_path = Path('prompts.yaml')
    if not config_path.exists():
        print(f"Error: prompts.yaml not found", file=sys.stderr)
        sys.exit(1)

    with open(config_path) as f:
        config = yaml.safe_load(f)

    if role_name not in config['roles']:
        print(f"Error: Unknown role '{role_name}'", file=sys.stderr)
        print(f"Available roles: {', '.join(config['roles'].keys())}", file=sys.stderr)
        sys.exit(1)

    role_config = config['roles'][role_name]
    max_tokens = role_config.get('max_tokens', 8000)

    # Assemble prompt from comps
    prompt_parts = []
    total_tokens = 0

    for comp_path in role_config['system_comps']:
        full_path = Path('system-comps') / comp_path

        if not full_path.exists():
            print(f"Warning: System-comp not found: {comp_path}", file=sys.stderr)
            continue

        content = full_path.read_text()
        tokens = estimate_tokens(content)

        if total_tokens + tokens > max_tokens:
            print(f"Warning: Prompt for {role_name} exceeds {max_tokens} tokens at {comp_path}",
                  file=sys.stderr)
            print(f"Current total: {total_tokens + tokens} tokens", file=sys.stderr)
            # Continue anyway - Claude can handle it

        prompt_parts.append(content)
        total_tokens += tokens

    # Final prompt
    prompt = '\n\n---\n\n'.join(prompt_parts)

    # Add footer with metadata
    footer = f"""
---

**Role:** {role_name.title()}
**Prompt assembled from:** {len(prompt_parts)} system-comps
**Estimated tokens:** {total_tokens}
**Generated:** {datetime.now().isoformat()}
"""

    return prompt + footer

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: ./build_prompt.py <role_name>", file=sys.stderr)
        sys.exit(1)

    role = sys.argv[1]
    prompt = build_prompt(role)
    print(prompt)
