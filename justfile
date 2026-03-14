# ZMK Build commands

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

# Clean build artifacts
clean:
	rm -rf zmk-workspace/build
	rm -rf target/
