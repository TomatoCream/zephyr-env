# ZMK Build and Flash commands

FLASH_MOUNT := "/run/media/df/NICENANO"

# Build both sides and copy to target/
build: build-left build-right
	mkdir -p target
	cp zmk-workspace/build/zephyr/zmk.uf2 ./target/do52pro_left.uf2
	cp zmk-workspace/build/right/zephyr/zmk.uf2 ./target/do52pro_right.uf2
	@echo "✅ Build complete! Files are in target/:"
	@echo "   - target/do52pro_left.uf2"
	@echo "   - target/do52pro_right.uf2"

# Build the left half
build-left:
	cd zmk-workspace && west build -p -s zmk.git/app -b nice_nano -- -DSHIELD=do52pro_left -DZMK_CONFIG="{{invocation_directory()}}/config"

# Build the right half
build-right:
	cd zmk-workspace && west build -p -s zmk.git/app -b nice_nano -d build/right -- -DSHIELD=do52pro_right -DZMK_CONFIG="{{invocation_directory()}}/config"

# Flash the left half (ensure NICENANO is in bootloader mode)
flash-left:
	@if [ ! -d {{FLASH_MOUNT}} ]; then echo "❌ NICENANO not found at {{FLASH_MOUNT}}"; exit 1; fi
	cp target/do52pro_left.uf2 {{FLASH_MOUNT}}/
	@echo "⚡ Flashed left half!"

# Flash the right half (ensure NICENANO is in bootloader mode)
flash-right:
	@if [ ! -d {{FLASH_MOUNT}} ]; then echo "❌ NICENANO not found at {{FLASH_MOUNT}}"; exit 1; fi
	cp target/do52pro_right.uf2 {{FLASH_MOUNT}}/
	@echo "⚡ Flashed right half!"

# Build and flash the left half
build-flash-left: build-left flash-left

# Build and flash the right half
build-flash-right: build-right flash-right

# Clean build artifacts
clean:
	rm -rf zmk-workspace/build
	rm -rf target/
