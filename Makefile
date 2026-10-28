APP        := Lidless
VERSION    := $(shell /usr/libexec/PlistBuddy -c 'Print CFBundleShortVersionString' Info.plist)
BUILD      := build
BUNDLE     := $(BUILD)/$(APP).app
PREFIX     ?= $(HOME)/Applications
MIN_MACOS  := 13
SUDOERS    := /etc/sudoers.d/lidless
SWIFTFLAGS := -O -swift-version 6

.PHONY: all build install uninstall sudoers dist clean

all: build

build: $(BUNDLE)

# Pin -target: newer toolchains can default to a macOS newer than the host, which won't launch.
$(BUNDLE): Sources/main.swift Info.plist
	@mkdir -p $(BUNDLE)/Contents/MacOS
	cp Info.plist $(BUNDLE)/Contents/Info.plist
	swiftc $(SWIFTFLAGS) -target arm64-apple-macos$(MIN_MACOS) Sources/main.swift -o $(BUILD)/$(APP)-arm64
	swiftc $(SWIFTFLAGS) -target x86_64-apple-macos$(MIN_MACOS) Sources/main.swift -o $(BUILD)/$(APP)-x86_64
	lipo -create $(BUILD)/$(APP)-arm64 $(BUILD)/$(APP)-x86_64 -output $(BUNDLE)/Contents/MacOS/$(APP)
	codesign --force --sign - $(BUNDLE)

install: build
	@pkill -x $(APP) && sleep 1 || true
	@mkdir -p $(PREFIX)
	rm -rf $(PREFIX)/$(APP).app
	cp -R $(BUNDLE) $(PREFIX)/
	open $(PREFIX)/$(APP).app

sudoers:
	@mkdir -p $(BUILD)
	@echo '$(shell id -un) ALL=(root) NOPASSWD: /usr/bin/pmset disablesleep 0, /usr/bin/pmset disablesleep 1' > $(BUILD)/lidless.sudoers
	sudo visudo -cf $(BUILD)/lidless.sudoers
	sudo install -m 0440 -o root -g wheel $(BUILD)/lidless.sudoers $(SUDOERS)

# SleepDisabled persists without the app, so restore sleep first.
uninstall:
	-sudo -n /usr/bin/pmset disablesleep 0
	@pkill -x $(APP) || true
	-osascript -e 'tell application "System Events" to delete login item "$(APP)"' 2>/dev/null
	rm -rf $(PREFIX)/$(APP).app
	sudo rm -f $(SUDOERS)

dist: build
	rm -f $(BUILD)/$(APP)-$(VERSION).zip
	ditto -c -k --norsrc --noextattr --keepParent $(BUNDLE) $(BUILD)/$(APP)-$(VERSION).zip

clean:
	rm -rf $(BUILD)
