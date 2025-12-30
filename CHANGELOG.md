# Changelog - VoiceInk (jellydn's modifications)

All notable changes by jellydn to the VoiceInk project are documented in this file.

## [2025] - Modifications

### Major Changes

#### Removed Paywall/Premium Restrictions
- **Commit: 0044c6b** - Removed all premium/paywall checks for free fork version
- **Commit: a5a6142** - Removed paywall in debug mode for WhisperState
- **Commit: c389aaa** - Enabled debug mode to bypass license restrictions

These modifications remove all paywall and premium feature restrictions from VoiceInk, making all features freely available to users. All changes comply with the GNU General Public License v3.0 (GPLv3) terms.

### Build & Release Improvements

#### Build System Enhancements
- **Commit: d621f72** - Enhanced Makefile with hot reload and build configuration targets
- **Commit: f56139c** - Enhanced Makefile with automatic framework path management

#### Release Workflow
- **Commit: 41e2a64** - Added beta release workflow from main branch
- **Commit: 1f42da6** - Fixed beta release workflow: Add DMG creation, remove circular PR
- **Commit: 061865d** - Fixed DMG cleanup in beta release workflow
- **Commit: 6b1ab74** - Fixed beta release: Use Debug builds and add ad-hoc signing
- **Commit: b8558cf** - Reverted ad-hoc signing and added Gatekeeper bypass instructions

### Code Refactoring & Improvements

#### Dependency & Service Updates
- **Commit: 6211417** - Simplified SelectedTextService to remove external dependency
- **Commit: 60125c3** - Migrated dictionary data from UserDefaults to SwiftData

#### Data Persistence
- **Commit: 2a9bf12** - Removed unused isEnabled property from VocabularyWord
- **Commit: 4e55192** - Fixed Soniox vocabulary integration to read from SwiftData
- **Commit: 60125c3** - Migrated dictionary data from UserDefaults to SwiftData

#### Error Handling & Stability
- **Commit: a631043** - Added error handling for dictionary save operations
- **Commit: 4e55192** - Fixed Soniox vocabulary integration to read from SwiftData
- **Commit: 7beb63e** - Prevented crashes and duplicates in import operations
- **Commit: bf3c035** - Added rollback for failed dictionary operations
- **Commit: 93f8811** - Added missing rollback in dictionary import error handling

#### UI Improvements
- **Commit: 3a2721e** - Reduced hero section size and created reusable component

### Upstream Integration
- **Commit: 9d75109** - Merged pull request #454 from Beingpax/dictionary-refactor

---

## License

This project retains the **GNU General Public License v3.0 (GPLv3)** license. All modifications are made available under the same license terms, ensuring that the freedoms granted to users and developers are preserved.

### GPLv3 Compliance

As per GPLv3 requirements:
- ✅ Complete source code is available
- ✅ Original copyright notices are retained
- ✅ Modifications are clearly documented
- ✅ The modified version uses the same GPLv3 license
- ✅ All freedoms are shared with downstream users

---

## Original Project

VoiceInk - Transcribe your thoughts with Whisper
- Original Repository: [Beingpax/VoiceInk](https://github.com/Beingpax/VoiceInk)
- License: GNU General Public License v3.0

---

## Contributing

To contribute to this fork, please follow the guidelines in [CONTRIBUTING.md](CONTRIBUTING.md).
