# Karabiner Fix

Simple MacOS utility to fix Karabiner-Elements sleep bug

## Install

```
brew tap launchquest/karabinerfix
brew install --cask karabinerfix
```

## What is this for?

Karabiner Elements is a fantastic utility that allows you to remap keyboards. Unfortunately on newer Macs, there's an issue with [keeping Macs awake](https://github.com/pqrs-org/Karabiner-Elements/issues/2880) which has required people to either find other applications or implement clever scripts.

Karabiner Fix is the tool you need to use the tool you want.

## How does it work?

It's a small utility that sits in the menu bar. If you go to the configure screen, you can set the required permissions (accessibility) and set it to launch at login. You configure a "Disabled" profile which copies your current profile but disables the devices. When your Mac sleeps, it switches to this profile, and when it wakes, it switches back.

![image](https://github.com/user-attachments/assets/55a94cc0-8c0d-4ba4-989b-450da2bed91e)

After this, Karabiner will work as you expect it to.

## Is it safe?

Yes, it's open source, and fully notarized by Apple etc.

## License

Karabiner Fix - Simple MacOS utility to fix Karabiner-Elements sleep bug
Copyright (C) 2025 Adam K Dean

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
