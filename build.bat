@echo off
setlocal

set RTMIDI_REPO=https://github.com/thestk/rtmidi.git

where g++ >nul 2>nul
if errorlevel 1 (
    echo Failed to find MSYS2 MinGW64 compiler. Install it first and add the compiler bin dir to System PATH.
    echo Download: https://github.com/msys2/msys2-installer/releases/download/2024-07-27/msys2-x86_64-20240727.exe
    exit /b
)

where cmake >nul 2>nul
if errorlevel 1 (
    echo Failed to find CMake. Install it first.
    echo Download: https://github.com/Kitware/CMake/releases/latest/download/cmake-3.30.5-windows-x86_64.msi
    exit /b
)

if not exist rtmidi (git clone %RTMIDI_REPO%)

cd rtmidi
if not exist build (mkdir build)
cd build
cmake .. -G "MinGW Makefiles" && cmake --build . --config Release

cd ..\..
if not exist build (mkdir build)
cd build

:: Clean task - use the default clean target
cmake .. -G "MinGW Makefiles"
cmake --build . --target clean --config Release

:: Main build task
cmake --build . --config Release

endlocal
pause
