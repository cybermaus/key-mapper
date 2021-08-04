## my_version
This fork is merely to keep my own mods organized. If you want to use it, no problem!<br/>
The main branch is to track the origin and should never receive commits directly from me.<br/>
The my_version branch is how I run it

Installation instructions below updated for my_version.

Mods:
- added exitpgm macro function
- example exitpgm shell for Dahua camera conrol from a numeric keypad.

<p align="center"><img src="data/key-mapper.svg" width=100/></p>

<h1 align="center">Key Mapper</h1>

<p align="center">
  An easy to use tool to change the mapping of your input device buttons.<br/>
  Supports mice, keyboards, gamepads, X11, Wayland, combined buttons and programmable macros.
</p>

<p align="center"><a href="readme/usage.md">Usage</a> - <a href="readme/macros.md">Macros</a> - <a href="#installation">Installation</a> - <a href="readme/development.md">Development</a> - <a href="#screenshots">Screenshots</a></p>

<p align="center"><img src="readme/pylint.svg"/> <img src="readme/coverage.svg"/></p>

## Installation

##### Raspberry Pi OS 
Former Raspian, probably also works on Ubuntu & Debian, except for the use of the `tvservice` 
call to blank the screen

```bash
sudo apt install git python3-setuptools
sudo apt install gettext 
git clone my_version https://github.com/cybermaus/key-mapper.git
cd key-mapper; ./scripts/build.sh
sudo apt install ./dist/key-mapper-1.0.0.deb
```

If it doesn't seem to install, you can also try `sudo python3 setup.py install`

## Screenshots

<p align="center">
  <img src="readme/screenshot.png"/>
</p>

<p align="center">
  <img src="readme/screenshot_2.png"/>
</p>
