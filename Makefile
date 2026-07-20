APP_NAME = Claude Usage
DIST = dist/$(APP_NAME).app
PRODUCT = .build/Build/Products/Release/$(APP_NAME).app

build:
	xcodegen
	xcodebuild -project ClaudeUsage.xcodeproj -scheme ClaudeUsage -configuration Release -derivedDataPath .build build
	rm -rf "$(DIST)"
	mkdir -p dist
	cp -R "$(PRODUCT)" "$(DIST)"

run: build
	open "$(DIST)"

install: build
	rm -rf "/Applications/$(APP_NAME).app"
	cp -R "$(DIST)" /Applications/

clean:
	rm -rf .build dist ClaudeUsage.xcodeproj
