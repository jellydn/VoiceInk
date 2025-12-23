# Define a directory for dependencies in the user's home folder
DEPS_DIR := $(HOME)/VoiceInk-Dependencies
WHISPER_CPP_DIR := $(DEPS_DIR)/whisper.cpp
FRAMEWORK_PATH := $(WHISPER_CPP_DIR)/build-apple/whisper.xcframework
PROJECT_DIR := $(shell pwd)
PROJECT_FILE := $(PROJECT_DIR)/VoiceInk.xcodeproj/project.pbxproj

.PHONY: all clean whisper setup build release check healthcheck help dev run fix-xcode-path

# Default target
all: check release

# Development workflow
dev: build run

# Prerequisites
check:
	@echo "Checking prerequisites..."
	@command -v git >/dev/null 2>&1 || { echo "git is not installed"; exit 1; }
	@command -v xcodebuild >/dev/null 2>&1 || { echo "xcodebuild is not installed (need Xcode)"; exit 1; }
	@command -v swift >/dev/null 2>&1 || { echo "swift is not installed"; exit 1; }
	@echo "Prerequisites OK"

healthcheck: check

# Build process
whisper:
	@mkdir -p $(DEPS_DIR)
	@if [ ! -d "$(FRAMEWORK_PATH)" ]; then \
		echo "Building whisper.xcframework in $(DEPS_DIR)..."; \
		if [ ! -d "$(WHISPER_CPP_DIR)" ]; then \
			git clone https://github.com/ggerganov/whisper.cpp.git $(WHISPER_CPP_DIR); \
		else \
			(cd $(WHISPER_CPP_DIR) && git pull); \
		fi; \
		cd $(WHISPER_CPP_DIR) && ./build-xcframework.sh; \
	else \
		echo "whisper.xcframework already built in $(DEPS_DIR), skipping build"; \
	fi

# Calculate relative path from project to framework and update Xcode project
fix-xcode-path:
	@if [ ! -f "$(FRAMEWORK_PATH)/Info.plist" ]; then \
		echo "Error: Framework not found at $(FRAMEWORK_PATH)"; \
		echo "Please run 'make whisper' first to build the framework."; \
		exit 1; \
	fi
	@echo "Updating Xcode project to reference framework..."
	@bash -c " \
	RELATIVE_PATH=\$$(python3 -c 'import os, sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))' '$(FRAMEWORK_PATH)' '$(PROJECT_DIR)' 2>/dev/null); \
	if [ -z \"\$$RELATIVE_PATH\" ] || echo \"\$$RELATIVE_PATH\" | grep -qE '(Error|Traceback|File.*line)'; then \
		RELATIVE_PATH=\$$(perl -MFile::Spec -e 'print File::Spec->abs2rel(q{$(FRAMEWORK_PATH)}, q{$(PROJECT_DIR)})' 2>/dev/null); \
	fi; \
	if [ -z \"\$$RELATIVE_PATH\" ]; then \
		if command -v realpath >/dev/null 2>&1; then \
			RELATIVE_PATH=\$$(cd '$(PROJECT_DIR)' && realpath --relative-to='$(PROJECT_DIR)' '$(FRAMEWORK_PATH)' 2>/dev/null); \
		fi; \
	fi; \
	if [ -z \"\$$RELATIVE_PATH\" ]; then \
		echo 'Warning: Could not calculate relative path automatically.'; \
		echo 'Framework is at: $(FRAMEWORK_PATH)'; \
		echo 'Please manually update the path in Xcode project settings.'; \
		exit 1; \
	fi; \
	echo \"Calculated relative path: \$$RELATIVE_PATH\"; \
	if ! grep -q 'E1A0BD052EB1E7B800266859.*whisper.xcframework' '$(PROJECT_FILE)'; then \
		echo 'Error: Could not find whisper.xcframework reference in project file'; \
		exit 1; \
	fi; \
	if [ \"\$$(uname)\" = \"Darwin\" ]; then \
		sed -i '' 's|path = \"[^\"]*whisper\\.xcframework\";|path = \"'\$$RELATIVE_PATH'\";|g' '$(PROJECT_FILE)'; \
	else \
		sed -i 's|path = \"[^\"]*whisper\\.xcframework\";|path = \"'\$$RELATIVE_PATH'\";|g' '$(PROJECT_FILE)'; \
	fi; \
	echo \"✓ Updated Xcode project path to: \$$RELATIVE_PATH\" \
	"
	@# Remove duplicate/unused framework references if they exist
	@if grep -q "E1B2DCAA2E3DE70A008DFD68\|E1CE28772E4336150082B758" "$(PROJECT_FILE)" 2>/dev/null; then \
		if [ "$$(uname)" = "Darwin" ]; then \
			sed -i '' '/E1B2DCAA2E3DE70A008DFD68\|E1CE28772E4336150082B758/d' "$(PROJECT_FILE)"; \
		else \
			sed -i '/E1B2DCAA2E3DE70A008DFD68\|E1CE28772E4336150082B758/d' "$(PROJECT_FILE)"; \
		fi; \
	fi

setup: whisper fix-xcode-path
	@echo "Whisper framework is ready at $(FRAMEWORK_PATH)"
	@echo "✓ Xcode project has been automatically updated to reference the framework."

build: setup
	xcodebuild -project VoiceInk.xcodeproj -scheme VoiceInk -configuration Debug CODE_SIGN_IDENTITY="" build

release: setup
	xcodebuild -project VoiceInk.xcodeproj -scheme VoiceInk -configuration Release CODE_SIGN_IDENTITY="" build

# Run application
run:
	@echo "Looking for VoiceInk.app..."
	@APP_PATH=$$(find "$$HOME/Library/Developer/Xcode/DerivedData" -name "VoiceInk.app" -type d | head -1) && \
	if [ -n "$$APP_PATH" ]; then \
		echo "Found app at: $$APP_PATH"; \
		open "$$APP_PATH"; \
	else \
		echo "VoiceInk.app not found. Please run 'make build' first."; \
		exit 1; \
	fi

# Cleanup
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(DEPS_DIR)
	@echo "Clean complete"

# Help
help:
	@echo "Available targets:"
	@echo "  check/healthcheck  Check if required CLI tools are installed"
	@echo "  whisper            Clone and build whisper.cpp XCFramework"
	@echo "  fix-xcode-path     Update Xcode project to reference the framework (auto-run in setup)"
	@echo "  setup              Build framework and update Xcode project paths automatically"
	@echo "  build              Build the VoiceInk Xcode project"
	@echo "  run                Launch the built VoiceInk app"
	@echo "  dev                Build and run the app (for development)"
	@echo "  all                Run full build process (default)"
	@echo "  clean              Remove build artifacts"
	@echo "  help               Show this help message"