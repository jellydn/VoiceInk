# Define a directory for dependencies in the user's home folder
DEPS_DIR := $(HOME)/VoiceInk-Dependencies
WHISPER_CPP_DIR := $(DEPS_DIR)/whisper.cpp
FRAMEWORK_PATH := $(WHISPER_CPP_DIR)/build-apple/whisper.xcframework

.PHONY: all clean whisper setup build release check healthcheck help dev dev-hot run run-release fix-xcode-path kill-app

# Default target
all: check build

# Development workflow
dev: build run

# Hot reload development - watches for changes and auto-rebuilds
dev-hot:
	@echo "Starting hot reload development mode..."
	@command -v fswatch >/dev/null 2>&1 || { \
		echo "fswatch is not installed. Install with: brew install fswatch"; \
		echo "Falling back to regular dev mode..."; \
		$(MAKE) dev; \
		exit 0; \
	}
	@echo "Watching for changes in VoiceInk/*.swift..."
	@$(MAKE) build
	@$(MAKE) run &
	@sleep 2
	@fswatch -o -r VoiceInk/*.swift VoiceInk/**/*.swift | while read num; do \
		echo ""; \
		echo "🔄 Changes detected! Rebuilding..."; \
		$(MAKE) kill-app; \
		$(MAKE) build; \
		$(MAKE) run & \
		sleep 2; \
		echo "✓ Ready and watching for changes... (Ctrl+C to stop)"; \
	done

# Kill running VoiceInk app
kill-app:
	@pkill -x "VoiceInk" 2>/dev/null || true
	@sleep 0.5

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

setup: whisper
	@echo "Whisper framework is ready at $(FRAMEWORK_PATH)"
	@echo "Please ensure your Xcode project references the framework from this new location."

build: setup
	xcodebuild -project VoiceInk.xcodeproj -scheme VoiceInk -configuration Debug CODE_SIGN_IDENTITY="" build

# Release build
release: setup
	xcodebuild -project VoiceInk.xcodeproj -scheme VoiceInk -configuration Release CODE_SIGN_IDENTITY="" build

# Run application (Debug configuration by default)
run:
	@echo "Looking for VoiceInk.app (Debug build)..."
	@APP_PATH=$$(find "$$HOME/Library/Developer/Xcode/DerivedData" -path "*/Debug/VoiceInk.app" -type d | head -1) && \
	if [ -n "$$APP_PATH" ]; then \
		echo "Found Debug app at: $$APP_PATH"; \
		open "$$APP_PATH"; \
	else \
		echo "Debug VoiceInk.app not found. Please run 'make build' first."; \
		exit 1; \
	fi

# Run application (Release configuration)
run-release:
	@echo "Looking for VoiceInk.app (Release build)..."
	@APP_PATH=$$(find "$$HOME/Library/Developer/Xcode/DerivedData" -path "*/Release/VoiceInk.app" -type d | head -1) && \
	if [ -n "$$APP_PATH" ]; then \
		echo "Found Release app at: $$APP_PATH"; \
		open "$$APP_PATH"; \
	else \
		echo "Release VoiceInk.app not found. Please run 'make release' first."; \
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
	@echo "  build              Build the VoiceInk Xcode project (Debug)"
	@echo "  release            Build the VoiceInk Xcode project (Release)"
	@echo "  run                Launch the Debug build"
	@echo "  run-release        Launch the Release build"
	@echo "  dev                Build and run the Debug app (for development)"
	@echo "  dev-hot            Build with hot reload - auto-rebuilds on file changes (requires: brew install fswatch)"
	@echo "  kill-app           Kill any running VoiceInk app instances"
	@echo "  all                Run full build process (default)"
	@echo "  clean              Remove build artifacts"
	@echo "  help               Show this help message"