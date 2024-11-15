#!/bin/bash

set -e

check_and_install() {
    if command -v apt-get &> /dev/null; then
        # Debian/Ubuntu
        sudo apt-get update
        sudo apt-get install -y $1
    elif command -v dnf &> /dev/null; then
        # Fedora
        sudo dnf install -y $1
    elif command -v pacman &> /dev/null; then
        # Arch Linux
        sudo pacman -S --noconfirm $1
    elif command -v brew &> /dev/null; then
        # macOS (Homebrew)
        brew install $1
    else
        echo "Unable to install $1. Please install it manually."
        exit 1
    fi
}

if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
    echo "Neither curl nor wget found!"
    read -p "Would you like to install curl? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        check_and_install curl
    else
        echo "Please install curl or wget manually"
        exit 1
    fi
fi

if ! command -v unzip &> /dev/null; then
    echo "unzip not found!"
    read -p "Would you like to install unzip? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        check_and_install unzip
    else
        echo "Please install unzip manually"
        exit 1
    fi
fi

if ! command -v cmake &> /dev/null; then
    echo "CMake not found!"
    read -p "Would you like to install CMake? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        check_and_install cmake
    else
        echo "Please install CMake manually"
        exit 1
    fi
fi

if ! command -v g++ &> /dev/null && ! command -v clang++ &> /dev/null; then
    echo "No C++ compiler found!"
    read -p "Would you like to install GCC? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v apt-get &> /dev/null; then
            check_and_install "build-essential"
        else
            check_and_install "gcc gcc-c++"
        fi
    else
        echo "Please install a C++ compiler manually"
        exit 1
    fi
fi

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if ! pkg-config --exists alsa; then
        echo "ALSA development libraries not found!"
        read -p "Would you like to install ALSA dev libraries? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if command -v apt-get &> /dev/null; then
                check_and_install "libasound2-dev"
            elif command -v dnf &> /dev/null; then
                check_and_install "alsa-lib-devel"
            elif command -v pacman &> /dev/null; then
                check_and_install "alsa-lib"
            fi
        fi
    fi
fi

if [ ! -d "rtmidi" ]; then
    echo "Downloading RtMidi..."
    if command -v curl &> /dev/null; then
        curl -L https://github.com/thestk/rtmidi/archive/refs/heads/master.zip -o rtmidi.zip
    else
        wget https://github.com/thestk/rtmidi/archive/refs/heads/master.zip -O rtmidi.zip
    fi
    
    echo "Extracting RtMidi..."
    unzip -q rtmidi.zip
    
    mkdir -p rtmidi
    cp rtmidi-master/*.h rtmidi/
    cp rtmidi-master/*.cpp rtmidi/
    
    rm rtmidi.zip
    rm -rf rtmidi-master
    
    echo "RtMidi files prepared successfully"
fi

mkdir -p build
cd build

echo "Configuring project..."
cmake -DCMAKE_BUILD_TYPE=Release ..

echo "Building project..."
cmake --build . --config Release

echo "Build completed successfully!"
echo "Executable location: $(pwd)/MIDIRouter"

cd ..

chmod +x build/MIDIRouter

echo "Setup complete! You can now run the MIDIRouter executable."