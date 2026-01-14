# AtariTrader

A trading game for the Atari 7800 console, developed using 7800basic.

## Overview

AtariTrader is a demonstration project showcasing how to develop Atari 7800 games using the 7800basic compiler with modern CMake build practices.

## Prerequisites

### Required Tools

1. **7800basic Compiler** - Download and install from:
   - GitHub: https://github.com/7800-devtools/7800basic
   - Documentation: https://www.randomterrain.com/7800basic.html

2. **CMake** (3.20 or higher)
   ```bash
   # macOS
   brew install cmake
   
   # Linux
   sudo apt-get install cmake
   ```

3. **wasmtime** (required for 7800basic)
   ```bash
   # macOS
   brew install wasmtime
   
   # Linux
   sudo apt install wasmtime
   
   # Or use the universal installer
   curl https://wasmtime.dev/install.sh -sSf | bash
   ```

### Optional Tools

- **Atari 7800 Emulator** - To test your games:
  - A7800 (recommended): https://github.com/7800-devtools/a7800
  - MAME: https://www.mamedev.org/

## Installation

### 1. Install 7800basic

#### macOS/Linux
```bash
# Download the latest release
cd ~/Downloads
wget https://github.com/7800-devtools/7800basic/releases/latest/download/7800basic-*.tar.gz

# Extract to home directory
cd ~
tar -xzf ~/Downloads/7800basic-*.tar.gz
cd 7800basic

# Run installer
./install_ux.sh
```

#### Windows
1. Download the latest zip from: https://github.com/7800-devtools/7800basic/releases
2. Extract to `C:\7800basic`
3. Run `install_win.bat`

### 2. Verify Installation

```bash
# Should show version and help
7800bas.bat --help  # Windows
7800basic.sh --help # macOS/Linux
```

## Building the Project

### Quick Start

```bash
# Clone or navigate to the project
cd AtariTrader

# Create build directory
mkdir -p build
cd build

# Configure with CMake
cmake ..

# Build all targets
cmake --build .

# Outputs will be in build/output/
```

### Build Targets

- **AtariTrader_main** - Main game executable
- **sample_simple** - Simple "Hello World" example
- **sample_joystick** - Joystick input demo
- **clean-7800** - Clean build artifacts

```bash
# Build specific target
cmake --build . --target sample_simple

# Clean 7800basic artifacts
cmake --build . --target clean-7800
```

## Project Structure

```
AtariTrader/
├── CMakeLists.txt       # CMake build configuration
├── README.md            # This file
├── src/                 # Main game source
│   └── main.bas         # Main game file
├── samples/             # Example programs
│   ├── simple.bas       # Basic example
│   └── joystick.bas     # Joystick demo
├── gfx/                 # Graphics assets (PNG files)
├── includes/            # Shared 7800basic includes
├── docs/                # Documentation
└── build/               # Build output (gitignored)
    └── output/          # Compiled .a78 and .bin files
```

## Running Your Game

After building, you'll find these files in `build/output/`:

- `*.a78` - ROM file with header (for emulators)
- `*.bin` - Raw ROM file (for cartridge production)

### Using an Emulator

```bash
# Example with A7800 emulator
a7800 build/output/main.a78

# Or drag and drop the .a78 file onto your emulator
```

## Development Workflow

### 1. Edit Source

Edit `.bas` files in `src/` or `samples/` directory:

```basic
   rem Your 7800basic code here
   set romsize 48k
   displaymode 160A
   
   clearscreen
   plotchars 'HELLO WORLD' 0 60 88
   drawscreen
   goto *
```

### 2. Build

```bash
cd build
cmake --build .
```

### 3. Test

Load the generated `.a78` file in your emulator.

### 4. Iterate

Repeat steps 1-3 as needed!

## 7800basic Language Basics

### Program Structure

```basic
   rem Set ROM size
   set romsize 48k
   
   rem Set display mode (160A, 320A, 320B)
   displaymode 160A
   
   rem Define variables
   dim playerx = a
   dim playery = b
   
   rem Main game loop
__Main_Loop
   clearscreen
   
   rem Your game logic here
   
   drawscreen
   goto __Main_Loop
```

### Key Commands

- `clearscreen` - Clear all sprites/characters
- `drawscreen` - Wait for display and vsync
- `plotchars` - Display text
- `plotsprite` - Display sprites
- `if...then` - Conditional logic
- `gosub` / `return` - Subroutines
- `goto` - Jump to label

### Display Modes

- **160A** - 160x192, 3 colors + transparent (most common)
- **320A** - 320x192, 1 color + transparent (high res)
- **320B** - 320x192, 3 colors + transparent

### Palettes

```basic
   rem Set palette 0 colors
   P0C1 = $26  rem Color 1
   P0C2 = $86  rem Color 2  
   P0C3 = $0F  rem Color 3
```

### Joystick Input

```basic
   if joy0up then playery = playery - 1
   if joy0down then playery = playery + 1
   if joy0left then playerx = playerx - 1
   if joy0right then playerx = playerx + 1
   if joy0fire0 then gosub __Fire_Action
```

## Adding Graphics

1. Create PNG files in the `gfx/` directory
2. Import in your .bas file:
   ```basic
   incgraphic gfx/player.png 160A
   ```
3. Plot the sprite:
   ```basic
   plotsprite player 0 playerx playery
   ```

## Resources

### Documentation
- **7800basic Guide**: https://www.randomterrain.com/7800basic.html
- **GitHub Repository**: https://github.com/7800-devtools/7800basic
- **AtariAge Forums**: https://forums.atariage.com/forum/63-atari-7800/

### Tools
- **A7800 Emulator**: https://github.com/7800-devtools/a7800
- **Tiled Map Editor**: https://www.mapeditor.org/ (for level design)
- **GIMP/Aseprite**: For creating sprite graphics

### Learning
- **Sample Programs**: Check the `samples/` directory
- **7800basic PDF Guide**: Included with 7800basic distribution
- **AtariAge Development Forum**: Active community support

## Troubleshooting

### 7800basic not found
```bash
# Verify PATH includes 7800basic
echo $PATH | grep 7800basic

# Re-run installer
cd ~/7800basic
./install_ux.sh
```

### CMake can't find 7800bas.bat
On macOS/Linux, edit `CMakeLists.txt` to use `7800basic.sh` instead of `7800bas.bat`.

### Build errors
```bash
# Clean and rebuild
rm -rf build
mkdir build
cd build
cmake ..
cmake --build .
```

### Emulator issues
- Ensure you're loading `.a78` files (not `.bin`)
- Check that emulator supports Atari 7800 mode
- Try a different emulator (A7800 vs MAME)

## Contributing

Contributions welcome! Areas of focus:

- Game features and mechanics
- Graphics and sprites
- Sound effects
- Documentation improvements
- Build system enhancements

## License

This project is released under the MIT License. The 7800basic compiler has its own licensing (see 7800basic documentation).

## Credits

- **7800basic**: Created by Michael Saarna
- **Based on**: batari Basic by Fred Quimby
- **Additional tools**: dasm, zlib/libpng, LZSA compression

---

**Happy coding for the Atari 7800!** 🎮
# AtariTrader
