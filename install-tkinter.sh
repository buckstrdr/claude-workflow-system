#!/bin/bash
# Install Tkinter for Python 3

echo "Installing Python Tkinter..."

# Detect Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "Cannot detect Linux distribution"
    exit 1
fi

case $OS in
    ubuntu|debian|linuxmint|pop|elementary|zorin)
        echo "Detected Ubuntu/Debian-based system ($OS)"
        sudo apt-get update
        sudo apt-get install -y python3-tk
        ;;
    fedora|rhel|centos)
        echo "Detected Fedora/RHEL/CentOS"
        sudo dnf install -y python3-tkinter
        ;;
    arch|manjaro)
        echo "Detected Arch/Manjaro"
        sudo pacman -S tk
        ;;
    *)
        echo "Unsupported distribution: $OS"
        echo ""
        echo "Since Linux Mint is Ubuntu-based, try:"
        echo "  sudo apt-get update"
        echo "  sudo apt-get install -y python3-tk"
        exit 1
        ;;
esac

echo ""
echo "Testing installation..."
if python3 -c "import tkinter" 2>/dev/null; then
    echo "✅ Tkinter installed successfully!"
else
    echo "❌ Tkinter installation failed"
    exit 1
fi
