# Window mover
This simple script allows to move windows across monitors in multi-monitor setups, useful when some of your monitors are off or disconnected but your windows are still there.

## Setup
Copy the .exe or compile with AutoIT v3.

Change settings in `/src/settings.ini`; options are well commented inside the file.

## Features
### Basic movement (drag and drop)
Move windows by dragging a shrunk representation of your multi-monitor desktop area.
![ui](https://raw.githubusercontent.com/loris2222/window-mover/master/images/mainUI.png) 

### Window operations (right click)
Snap windows to origin or set a custom snap point.  
Kill windows from inside the program's UI.

### Filter windows
Ignore windows based on title.  
Ignore transparent windows.  

⚠️ The script needs admininstrator privileges because windows such as Task Manager are run as Admin and cannot be moved without privileges.
