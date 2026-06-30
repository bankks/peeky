.PHONY: build install uninstall clean reset-ql

build:
	@bash scripts/build.sh

install: build
	@echo "→ Installing to /Applications..."
	@rm -rf /Applications/Peeky.app
	@cp -r dist/Peeky.app /Applications/Peeky.app
	@echo "→ Registering Quick Look extension..."
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

clean:
	@rm -rf build/ dist/
	@echo "✓ Build artifacts removed."

reset-ql:
	@killall -9 QuickLookUIService 2>/dev/null || true
	@qlmanage -r && qlmanage -r cache
	@killall Finder
	@echo "✓ Quick Look reset."
