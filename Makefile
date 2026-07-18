APP = ClaudeUsage
APP_NAME = Claude Usage
DIST = dist/$(APP_NAME).app

build:
	swift build -c release
	rm -rf "$(DIST)"
	mkdir -p "$(DIST)/Contents/MacOS"
	cp .build/release/$(APP) "$(DIST)/Contents/MacOS/"
	cp Info.plist "$(DIST)/Contents/"
	mkdir -p "$(DIST)/Contents/Resources"
	cp AppIcon.icns "$(DIST)/Contents/Resources/"
	codesign --force --sign - "$(DIST)"

run: build
	open "$(DIST)"

install: build
	rm -rf "/Applications/$(APP_NAME).app"
	cp -R "$(DIST)" /Applications/

clean:
	rm -rf .build dist
