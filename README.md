# A bootloader for SN32F2x-based keyboards

Based on [STM32duino-bootloader](https://github.com/rogerclarkmelbourne/STM32duino-bootloader).

## Known issues

- JTAG or SWD pins used as part of keyboard matrix can't be used for bootloader entry

## Compiling

A recent version of the [GNU Arm Embedded Toolchain](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm) is recommended for building this project. In order to build, execute the following commands:

```
mkdir build && cd build
cmake ..
make -j8
```

## Flashing the bootloader

The bootloader is flashed with the [Womier Flasher](https://github.com/xyzz/womier-flasher).

## Entering the bootloader

The bootloader is entered when any of the following is true during power up:

- A bootloader entry flag is set - this would be set by QMK when you press the `RESET` keycode.
- There is no firmware uploaded yet - this works by checking the validity of the reset vector (only checks the stack pointer)
- A button is pressed (inherited from the parent project, but not really used)
- A button from the keyboard matrix is pressed - this should be the main method used to enter the bootloader.

The last method is new to this fork. It enters the bootloader if a keyboard button is held during power up, i.e. a user holds a specific button while plugging in the keyboard. This is safer compared to QMK bootmagic feature as it does not rely on a valid firmware being present.

The specific button to be held will be different depending on the keyboard. See below on how to configure it.

## Flashing keyboard firmware

The QMK firmware can be flashed with the [Womier Flasher](https://github.com/xyzz/womier-flasher).

## Adding a new keyboard

To add a new keyboard, first edit `CMakeLists.txt` and append a new `add_bootloader()` entry at the end, e.g.

```
add_bootloader(new_keyboard)
```

Then, edit `src/config.h` and before the `#else` with the `#error` branch, add:

```
#elif defined(TARGET_NEW_KEYBOARD)
/* Configuration options - see other entries for a reference */
```

Finally, recompile the project and you should see your very own `bootloader-new_keyboard.bin` in the build folder. See flashing instructions above for how to flash.

Before releasing your product, you should configure a way to enter the bootloader. The recommended way is by holding a keyboard matrix button on power up.

Suppose you want to enter the bootloader when K_4, the middle button in the matrix is held during power up. To scan that single keycode, we need the bootloader to output on `col1` (PB10) and read the result from `row1` (PA4). The following snippet from `config.h` properly sets it up:

```
#elif defined(TARGET_BASICPAD_V1)
    /* Middle key in the 3x3 keymatrix */
    #define BL_OUTPUT_BANK GPIOB
    #define BL_OUTPUT_PIN 10
    #define BL_INPUT_BANK GPIOA
    #define BL_INPUT_PIN 4
```