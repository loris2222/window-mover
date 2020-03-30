# Window mover
This simple script allows to move windows across monitors in multi-monitor setups, useful when some of your monitors are off or disconnected but your windows are still there.

## Setup
Copy the .exe or compile with AutoIT v3.

Change settings in `/src/settings.ini`; options are well commented inside the file.

## Features
### Basic movement
Move windows by dragging a shrunk representation of your multi-monitor desktop area.
![ui](https://raw.githubusercontent.com/loris2222/window-mover/master/images/mainUI.png) 

### Window operations
1. Snap windows to origin or set a custom snap point.
2. Kill windows from inside the program's UI.
3. Ignore windows based on title
4. Ignore transparent windows
