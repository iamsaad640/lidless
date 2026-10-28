# Sleep Toggle

Menu bar app that toggles `pmset disablesleep`. Left-click flips sleep on/off, right-click for Open at Login and Quit.

## Build

```sh
mkdir -p ~/Applications/SleepToggle.app/Contents/MacOS
cp Info.plist ~/Applications/SleepToggle.app/Contents/
swiftc -O -swift-version 6 -target arm64-apple-macos13 main.swift -o ~/Applications/SleepToggle.app/Contents/MacOS/SleepToggle
codesign --force --sign - ~/Applications/SleepToggle.app
```

Keep the explicit `-target`: without it swiftc can target a newer macOS than the one installed and the app won't launch.

## sudo rule

The app runs `sudo -n pmset disablesleep`, which needs a NOPASSWD rule:

```sh
sudo install -m 440 -o root -g wheel pmset.sudoers /etc/sudoers.d/pmset
sudo visudo -cf /etc/sudoers.d/pmset
```
