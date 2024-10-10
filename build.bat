@echo off
setlocal

:: Set paths
set RTMIDI_REPO=https://github.com/thestk/rtmidi.git
set RTMIDI_DIR=rtmidi
set BUILD_DIR=%RTMIDI_DIR%\build
set INSTALL_DIR=%USERPROFILE%\Documents\GitHub\midi-router\rtmidi

:: Check for MSYS2 MinGW64 compiler
where g++ >nul 2>nul
if errorlevel 1 (
    echo Failed to find MSYS2 MinGW64 compiler. Install it first and add the compiler bin dir to System PATH.
    echo Download: https://github.com/msys2/msys2-installer/releases/download/2024-07-27/msys2-x86_64-20240727.exe
    pause
    exit /b
)

:: Check for CMake
where cmake >nul 2>nul
if errorlevel 1 (
    echo Failed to find CMake. Install it first.
    echo Download: https://github.com/Kitware/CMake/releases/download/v3.30.5/cmake-3.30.5-windows-x86_64.msi
    pause
    exit /b
)

:: Clone the RtMidi repository if it doesn't exist
if not exist %RTMIDI_DIR% (
    git clone %RTMIDI_REPO% %RTMIDI_DIR%
)

:: Navigate to the RtMidi directory
cd %RTMIDI_DIR%

:: Create a build directory if it doesn't exist
if not exist %BUILD_DIR% (
    mkdir %BUILD_DIR%
)

:: Build RtMidi using CMake
cmake -B %BUILD_DIR% -G "MinGW Makefiles"
cmake --build %BUILD_DIR%
cmake --install %BUILD_DIR% --prefix %INSTALL_DIR%

:: Navigate back to the MIDI Router project directory
cd ..

:: Build the MIDI router project
cmake -B build -G "MinGW Makefiles"
cmake --build build

echo Build completed successfully.
endlocal
pause
