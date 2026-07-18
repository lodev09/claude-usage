APP = ClaudeUsage
DIST = dist/$(APP).app

build:
	swift build -c release
	rm -rf $(DIST)
	mkdir -p $(DIST)/Contents/MacOS
	cp .build/release/$(APP) $(DIST)/Contents/MacOS/
	cp Info.plist $(DIST)/Contents/
	mkdir -p $(DIST)/Contents/Resources
	cp AppIcon.icns $(DIST)/Contents/Resources/
	codesign --force --sign - $(DIST)

run: build
	open $(DIST)

install: build
	rm -rf /Applications/$(APP).app
	cp -R $(DIST) /Applications/

clean:
	rm -rf .build dist
