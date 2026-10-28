# Lidless

**Keep your Mac awake with the lid closed. One click, right from the menu bar.**

[![Build](https://github.com/iamsaad640/lidless/actions/workflows/build.yml/badge.svg)](https://github.com/iamsaad640/lidless/actions/workflows/build.yml)
[![Release](https://img.shields.io/github/v/release/iamsaad640/lidless)](https://github.com/iamsaad640/lidless/releases/latest)
![macOS 13+](https://img.shields.io/badge/macOS-13%2B-black?logo=apple)
![Swift 6](https://img.shields.io/badge/Swift-6-F05138?logo=swift&logoColor=white)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Lidless is a tiny macOS menu bar app that switches system sleep off and on. Instead of holding a power assertion, it sets the system-wide `SleepDisabled` flag through `pmset`, so your Mac keeps running with the lid shut, on battery, and with no external display attached.

## Features

- **One-click toggle.** Left-click the menu bar icon to disable or re-enable sleep.
- **Works in clamshell mode.** Downloads, builds, servers and remote sessions keep running after you close the lid.
- **Always in sync.** The icon picks up changes made with `pmset` from the terminal.
- **Survives restarts.** The setting persists across reboots, and Lidless opens at login.
- **Small and private.** A single Swift file with no dependencies, no network access and no helper daemons.
- **Universal.** Runs natively on Apple silicon and Intel Macs.

## Usage

| Icon | Meaning |
| --- | --- |
| ☕ Cup and saucer | Sleep is disabled. Your Mac stays awake, lid open or closed. |
| 🌙 Moon | Sleep is allowed. Normal macOS behaviour. |

- **Left-click** toggles sleep.
- **Right-click** opens the menu with **Open at Login** and **Quit Lidless**.

## Requirements

- macOS 13 Ventura or later
- An administrator account, for the one-time sudo rule
- Xcode Command Line Tools to build from source (`xcode-select --install`)

## Installation

### Build from source

```sh
git clone https://github.com/iamsaad640/lidless.git
cd lidless
make sudoers   # one-time: lets your user run `pmset disablesleep` without a password
make install   # builds Lidless.app into ~/Applications and launches it
```

### Download a release

1. Download `Lidless-<version>.zip` from the [latest release](https://github.com/iamsaad640/lidless/releases/latest), unzip it, and move `Lidless.app` to `~/Applications` or `/Applications`.
2. Lidless is ad-hoc signed but not notarized, so macOS blocks the first launch. Clear the quarantine flag:

   ```sh
   xattr -dr com.apple.quarantine ~/Applications/Lidless.app
   ```

   Alternatively, open the app once, then choose **Open Anyway** in **System Settings → Privacy & Security**.
3. Install the sudo rule:

   ```sh
   echo "$(id -un) ALL=(root) NOPASSWD: /usr/bin/pmset disablesleep 0, /usr/bin/pmset disablesleep 1" > /tmp/lidless.sudoers
   sudo visudo -cf /tmp/lidless.sudoers && sudo install -m 0440 -o root -g wheel /tmp/lidless.sudoers /etc/sudoers.d/lidless
   ```

## How it works

Lidless reads the current state from the `SleepDisabled` property of IOKit's `IOPMrootDomain` and changes it by running `sudo -n /usr/bin/pmset disablesleep 1` or `0`. The sudo rule allows exactly those two commands for your user and nothing else:

```text
<your-user> ALL=(root) NOPASSWD: /usr/bin/pmset disablesleep 0, /usr/bin/pmset disablesleep 1
```

On first launch Lidless registers itself as a login item through `SMAppService`. You can turn this off from the right-click menu or in **System Settings → General → Login Items**.

### Why not `caffeinate`?

`caffeinate` and similar tools hold a power assertion. That keeps the Mac awake while the lid is open, but closing the lid still puts it to sleep unless it is connected to power, an external display and an input device. `pmset disablesleep` prevents sleep entirely, including when the lid closes.

## Things to know

- **Watch heat and battery.** A Mac that cannot sleep keeps drawing power. Do not put it in a bag with sleep disabled.
- **The setting outlives the app.** macOS stores `SleepDisabled` itself, so quitting or deleting Lidless does not turn sleep back on. Click the icon first, or run `sudo pmset disablesleep 0`.

## Uninstall

```sh
make uninstall
```

This turns sleep back on, quits Lidless, removes its login item, deletes `~/Applications/Lidless.app` and removes `/etc/sudoers.d/lidless`.

## Make targets

| Command | Description |
| --- | --- |
| `make` | Build the universal app into `build/Lidless.app` |
| `make install` | Build and install to `~/Applications` (override with `PREFIX=/path`) |
| `make sudoers` | Install the sudo rule to `/etc/sudoers.d/lidless` |
| `make dist` | Package `build/Lidless-<version>.zip` for a release |
| `make uninstall` | Remove the app, login item and sudo rule, and re-enable sleep |
| `make clean` | Delete the `build/` directory |

## Contributing

Bug reports and pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md), and report security issues as described in [SECURITY.md](SECURITY.md).

## License

Lidless is released under the [MIT License](LICENSE).
