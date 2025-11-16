---
name: create-plugin
description: Interactive guide for creating strategy plugin Python code (separate from YAML config)
---

Launch the Interactive Strategy Plugin Builder.

This creates the PYTHON PLUGIN CODE for a strategy. For YAML configuration, use `/create-strategy`.

The plugin builder will guide you through:
1. Plugin identity (class name, module name)
2. Parameter model definition (PARAM_MODEL)
3. Strategy state and warmup
4. Signal generation logic
5. Position management
6. Logging configuration
7. Code generation
8. Testing and validation

**Important**: This creates the Python implementation file. You'll need to create the matching YAML configuration separately using `/create-strategy`.

To begin, invoke the create-plugin skill.
