@echo off
REM Build script for AtariTrader (Windows)
REM Automates CMake configuration and building

setlocal enabledelayedexpansion

echo ================================
echo AtariTrader Build Script (Windows)
echo ================================

REM Check for CMake
where cmake >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: CMake not found
    echo Install from: https://cmake.org/download/
    exit /b 1
)

REM Set 7800basic installation path (Update this path for your system)
set BASIC7800_DIR=C:\7800basic
set BASIC7800_CMD=%BASIC7800_DIR%\7800bas.bat

REM Check for 7800basic
if not exist "%BASIC7800_CMD%" (
    echo Error: 7800basic not found at %BASIC7800_CMD%
    echo Please update BASIC7800_DIR in build.bat to match your installation
    exit /b 1
)

echo Using 7800basic: %BASIC7800_CMD%

REM Create build directory
if not exist "build" (
    echo Creating build directory...
    mkdir build
)

cd build

REM Configure with CMake
echo.
echo Configuring with CMake...
cmake -DBASIC7800_DIR="%BASIC7800_DIR%" .. || (
    echo CMake configuration failed
    exit /b 1
)

REM Build
echo.
echo Building project...
cmake --build . || (
    echo Build failed
    exit /b 1
)

REM Success
echo.
echo Build successful!
echo Output files are in: build\output\
echo.
dir /b output\*.a78 2>nul
echo.
echo Run with an emulator:
echo   a7800 output\main.a78

cd ..
