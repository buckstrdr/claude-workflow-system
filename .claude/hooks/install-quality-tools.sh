#!/bin/bash
# Install Python code quality tools

echo "Installing Python code quality tools..."

pip install black flake8 pylint vulture

echo ""
echo "✓ Installed:"
echo "  - black (code formatter)"
echo "  - flake8 (style guide)"
echo "  - pylint (code analysis)"
echo "  - vulture (dead code detection)"
echo ""
echo "To run manually:"
echo "  black --line-length 100 topstepx_backend/"
echo "  flake8 --max-line-length=100 topstepx_backend/"
echo "  pylint topstepx_backend/"
echo "  vulture topstepx_backend/"
