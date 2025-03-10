@echo off
setlocal enabledelayedexpansion

:: Check for CMake
where cmake >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo CMake not found! Install with: winget install Kitware.CMake
    exit /b 1
)

:: Check for compiler
set COMPILER_FOUND=0
set COMPILER_TYPE=unknown

where g++ >nul 2>nul
if %ERRORLEVEL% equ 0 (
    set COMPILER_FOUND=1
    set COMPILER_TYPE=mingw
    goto COMPILER_FOUND
)

where cl >nul 2>nul
if %ERRORLEVEL% equ 0 (
    set COMPILER_FOUND=1
    set COMPILER_TYPE=msvc
    goto COMPILER_FOUND
)

echo No C++ compiler found! Install MinGW (winget install mingw) or Visual Studio.
exit /b 1

:COMPILER_FOUND

:: Download RtMidi if not exists
if not exist rtmidi (
    echo Downloading RtMidi...
    powershell -Command "Invoke-WebRequest -Uri 'https://github.com/thestk/rtmidi/archive/refs/heads/master.zip' -OutFile 'rtmidi.zip'"
    powershell -Command "Expand-Archive -Path 'rtmidi.zip' -DestinationPath '.' -Force"
    mkdir rtmidi
    copy /Y "rtmidi-master\*.h" "rtmidi\"
    copy /Y "rtmidi-master\*.cpp" "rtmidi\"
    del rtmidi.zip
    rd /s /q rtmidi-master
)

:: Create and build
if not exist build mkdir build
cd build

if "%COMPILER_TYPE%"=="mingw" (
    cmake -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-static -static-libgcc -static-libstdc++ -static-libgfortran" ..
    if !ERRORLEVEL! neq 0 exit /b 1
    mingw32-make
    if !ERRORLEVEL! neq 0 exit /b 1
) else (
    cmake -G "Visual Studio 17 2022" -A x64 ..
    if !ERRORLEVEL! neq 0 exit /b 1
    cmake --build . --config Release
    if !ERRORLEVEL! neq 0 exit /b 1
)

echo Build complete! Executable location: build\MIDIRouter.exe
cd ..