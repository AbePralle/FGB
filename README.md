# FGB

A weird and wonderful action adventure for Game Boy Color. Developed in 2000 by Abe Pralle and Jacob Stevens. Playable but never completed.

![Preview Video](Media/FGBPreview.mp4)

About     | Current Release
----------|-----------------------
Version   | 1.1
Date      | 2020.07.05
Target    | Game Boy Color
Build     | macOS, Windows, Linux
Editors   | Windows
Licenses  | MIT (source code) and Creative Commons (IP) - see the [LICENSE](LICENSE).

## ROM
The pre-compiled FGB ROM for Game Boy Color is [here](ROMS/fgb.gb).

## Building from Source
1. Install the Rogue language from here to take advantage of the Rogo build system:
    - [https://github.com/AbePralle/Rogue](https://github.com/AbePralle/Rogue)
2. Install the RGBDS assembler:
    - [https://github.com/rednex/rgbds](https://github.com/rednex/rgbds)
3. Run `rogo` in this project's base folder.

## Tools
- Each of the following tools is provided as a precompiled Windows `exe` along with their original source code.
- These `exe` files were last compiled circa 2000. No attempt has been made to update their project source. The Level Editor and Image Converter `exe`'s are both confirmed to work on Windows 10.
- During its original development, FGB was essentially a single folder containing hundreds of files. Because of this, each tool typically expects its data files to be in the same folder as the tool itself.
- This project has now been reorganized to cleanly separate original assets, converted data, and source code into separate folders.
- As such data files will generally need to be moved into each tool folder as inputs and the results moved back to the appropriate location if the editors are used.
- Ideally at some point Abe Pralle or a contributer will update the editor projects to be in a modern Visual Studio format and adjust the input and output locations to utilize the current folder structure.

### LevelEditor

![Level Editor](Media/Screenshots/LevelEditor.png)

1. Refer to `Media/DesignDocs/WorldMap.xls` (slightly out of date) to identify levels you want to edit.
2. Copy corresponding `Data/Levels/*.lvl` files to `Tools/LevelEditor`.
3. Run `Tools/LevelEditor`, load, edit, and save the levels.
4. Copy the modified levels back to `Data/Levels/`.

### GBConv2

![GBConv2](Media/Screenshots/GBConv2.png)

1.


## About
