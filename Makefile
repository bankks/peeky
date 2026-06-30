DMG_NAME = dist/Peeky.dmg
DMG_STAGE = /tmp/peeky-dmg-stage

.PHONY: build install uninstall dmg dmg-only clean reset-ql

build:
	@bash scripts/build.sh

install: build
	@echo "→ Installing to /Applications..."
	@rm -rf /Applications/Peeky.app
	@cp -r dist/Peeky.app /Applications/Peeky.app
	@echo "→ Registering Quick Look extension..."
	@pluginkit -a /Applications/Peeky.app/Contents/PlugIns/PeekyExtension.appex
	@killall -9 QuickLookUIService 2>/dev/null || true
	@qlmanage -r
	@qlmanage -r cache
	@killall Finder
	@echo "✓ Peeky installed. Press Space on any .md file to test."

uninstall:
	@echo "→ Removing Peeky..."
	@rm -rf /Applications/Peeky.app
	@killall -9 QuickLookUIService 2>/dev/null || true
	@qlmanage -r
	@qlmanage -r cache
	@killall Finder
	@echo "✓ Peeky uninstalled."

dmg: build dmg-only

dmg-only:
	@echo "→ Creating DMG..."
	@rm -rf $(DMG_STAGE) $(DMG_NAME)
	@mkdir -p $(DMG_STAGE)
	@cp -r dist/Peeky.app $(DMG_STAGE)/
	@ln -s /Applications $(DMG_STAGE)/Applications
	@hdiutil create \
	  -volname "Peeky" \
	  -srcfolder $(DMG_STAGE) \
	  -ov -format UDZO \
	  $(DMG_NAME) -quiet
	@rm -rf $(DMG_STAGE)
	@echo "✓ DMG → $(DMG_NAME)"

clean:
	@rm -rf build/ dist/
	@echo "✓ Build artifacts removed."

reset-ql:
	@killall -9 QuickLookUIService 2>/dev/null || true
	@qlmanage -r && qlmanage -r cache
	@killall Finder
	@echo "✓ Quick Look reset."
