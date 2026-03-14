# ZMK Build and Flash commands

FLASH_MOUNT := "/run/media/df/NICENANO"

# Build both sides and copy to target/
build: build-left build-right
	@echo "✅ Build complete! Files are in target/:"
	@echo "   - target/do52pro_left.uf2"
	@echo "   - target/do52pro_right.uf2"

# Build the left half (v2 is default for nice_nano in this ZMK version)
build-left: build-left-v2

# Build the left half (v2)
build-left-v2:
	cd zmk-workspace && west build -p -s zmk.git/app -b nice_nano -- -DSHIELD=do52pro_left -DZMK_CONFIG="{{invocation_directory()}}/config"
	mkdir -p target
	cp zmk-workspace/build/zephyr/zmk.uf2 ./target/do52pro_left.uf2

# Build the right half (v2 is default for nice_nano in this ZMK version)
build-right: build-right-v2

# Build the right half (v2)
build-right-v2:
	cd zmk-workspace && west build -p -s zmk.git/app -b nice_nano -d build/right -- -DSHIELD=do52pro_right -DZMK_CONFIG="{{invocation_directory()}}/config"
	mkdir -p target
	cp zmk-workspace/build/right/zephyr/zmk.uf2 ./target/do52pro_right.uf2

# Flash the left half (ensure NICENANO is in bootloader mode)
flash-left:
	@DEV=$(lsblk -no NAME,LABEL | grep "NICENANO" | awk '{print "/dev/"$$1}') && \
	if [ -n "$$DEV" ]; then \
		if [ ! -d {{FLASH_MOUNT}} ]; then \
			echo "🔍 Mounting NICENANO ($$DEV)..."; \
			udisksctl mount -b $$DEV || true; \
		fi; \
		echo "⚡ Flashing left half..."; \
		cp target/do52pro_left.uf2 {{FLASH_MOUNT}}/; \
	else \
		echo "❌ NICENANO device not found. Did you double-tap the reset button?"; \
		exit 1; \
	fi

# Flash the right half (ensure NICENANO is in bootloader mode)
flash-right:
	@DEV=$(lsblk -no NAME,LABEL | grep "NICENANO" | awk '{print "/dev/"$$1}') && \
	if [ -n "$$DEV" ]; then \
		if [ ! -d {{FLASH_MOUNT}} ]; then \
			echo "🔍 Mounting NICENANO ($$DEV)..."; \
			udisksctl mount -b $$DEV || true; \
		fi; \
		echo "⚡ Flashing right half..."; \
		cp target/do52pro_right.uf2 {{FLASH_MOUNT}}/; \
	else \
		echo "❌ NICENANO device not found. Did you double-tap the reset button?"; \
		exit 1; \
	fi

# Build and flash the left half
build-flash-left: build-left flash-left

# Build and flash the right half
build-flash-right: build-right flash-right

# Clean build artifacts
clean:
	rm -rf zmk-workspace/build
	rm -rf target/
