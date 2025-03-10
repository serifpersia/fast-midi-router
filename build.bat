@echo off
setlocal enabledelayedexpansion

:: Check for CMake
where cmake >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo CMake not found!
    echo Would you like to install CMake using winget? [Y/N]
    set /p INSTALL_CMAKE=
    if /i "!INSTALL_CMAKE!"=="Y" (
        winget install Kitware.CMake
        if !ERRORLEVEL! neq 0 (
            echo Failed to install CMake. Please install it manually from https://cmake.org/download/
            exit /b 1
        )
    ) else (
        echo Please install CMake manually from https://cmake.org/download/
        exit /b 1
    )
)

:: Check for compiler
set COMPILER_FOUND=0
set COMPILER_TYPE=unknown

:: Check for MinGW
where g++ >nul 2>nul
if %ERRORLEVEL% equ 0 (
    set COMPILER_FOUND=1
    set COMPILER_TYPE=mingw
    goto COMPILER_FOUND
)

:: Check for MSVC
where cl >nul 2>nul
if %ERRORLEVEL% equ 0 (
    set COMPILER_FOUND=1
    set COMPILER_TYPE=msvc
    goto COMPILER_FOUND
)

:NO_COMPILER
echo No C++ compiler found!
echo Would you like to install MinGW using winget? [Y/N]
set /p INSTALL_MINGW=
if /i "!INSTALL_MINGW!"=="Y" (
    winget install GnuWin32.Make
    winget install mingw
    if !ERRORLEVEL! neq 0 (
        echo Failed to install MinGW.
        echo Please install MinGW manually from https://sourceforge.net/projects/mingw-w64/
        exit /b 1
    )
    set COMPILER_TYPE=mingw
) else (
    echo Please install either MinGW or Visual Studio with C++ development tools
    echo MinGW: https://sourceforge.net/projects/mingw-w64/
    echo Visual Studio: https://visualstudio.microsoft.com/downloads/
    exit /b 1
)

:COMPILER_FOUND

:: Download and extract RtMidi if not exists
if not exist rtmidi (
    echo Downloading RtMidi...
    powershell -Command "& {Invoke-WebRequest -Uri 'https://github.com/thestk/rtmidi/archive/refs/heads/master.zip' -OutFile 'rtmidi.zip'}"
    
    echo Extracting RtMidi...
    powershell -Command "& {Expand-Archive -Path 'rtmidi.zip' -DestinationPath '.' -Force}"
    
    :: Create rtmidi directory and copy necessary files
    mkdir rtmidi
    copy /Y "rtmidi-master\*.h" "rtmidi\"
    copy /Y "rtmidi-master\*.cpp" "rtmidi\"
    
    :: Cleanup
    del rtmidi.zip
    rd /s /q rtmidi-master
)

:: Create build directory
if not exist build mkdir build
cd build

:: Configure based on compiler type
if "%COMPILER_TYPE%"=="mingw" (
    echo Configuring project with MinGW...
    cmake -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE=Release ..
    if !ERRORLEVEL! neq 0 (
        echo CMake configuration failed!
        exit /b 1
    )
    
    echo Building project...
    mingw32-make
    if !ERRORLEVEL! neq 0 (
        echo Build failed!
        exit /b 1
    )
) else if "%COMPILER_TYPE%"=="msvc" (
    echo Configuring project with MSVC...
    cmake -G "Visual Studio 17 2022" -A x64 ..
    if !ERRORLEVEL! neq 0 (
        echo CMake configuration failed!
        exit /b 1
    )
    
    echo Building project...
    cmake --build . --config Release
    if !ERRORLEVEL! neq 0 (
        echo Build failed!
        exit /b 1
    )
)

echo Build completed successfully!
if "%COMPILER_TYPE%"=="mingw" (
    echo Executable location: build\MIDIRouter.exe
) else (
    echo Executable location: build\Release\MIDIRouter.exe
)
cd ..