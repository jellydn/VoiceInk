# Changelog - VoiceInk (jellydn's modifications)

All notable changes by jellydn to the VoiceInk project are documented in this file.

## [2026-05] - Sync & Fixes

### Upstream Sync (v1.76)
Rebased fork onto Beingpax/VoiceInk@cf3ebd2 (38 new upstream commits). Includes:
- Recorder session metrics with model performance dashboard (#678)
- Cloud STT providers: AssemblyAI, Cartesia Ink Whisper (#677)
- Transcript formatting options (remove punctuation) (#675)
- Improved download UI (#674)
- Selective backup import (#688)
- Native Apple Speech asset fixes (#681)
- Recording startup race and mute timing fixes (#680)
- Transcription paste delay fixes (#679)
- Parakeet V3 int4/int8 encoder
- Stats store with CloudKit sync disabled
- SessionMetric migration service
- Various bug fixes and improvements

All fork modifications preserved after rebase.

### License Fixes
- **Commit: 94a4388** - Fix LicenseViewModel: use raw Notification.Name string to avoid extension dependency
- **Commit: 2b3f5ae** - Fix LicenseViewModel: remove unused PolarService and LicenseManager references
- **Commit: 1411308** - Force `LicenseViewModel` to always remain licensed in fork builds
- **Commit: 1411308** - Make `canUseApp` always return `true`
- **Commit: 1411308** - Short-circuit `validateLicense()` and keep app usable after `removeLicense()`

These changes prevent trial-expired and paywall gating from reappearing after upstream rebases by enforcing free-fork behavior at the license state source.

### Infrastructure
- **Commit: cb0401a** - Add .claude/settings.local.json to gitignore
- **Commit: 954346a** - Remove DMG from repository and add to gitignore

## [2025] - Modifications

### Major Changes

#### Removed Paywall/Premium Restrictions
- **Commit: a3f4f27** - Removed all premium/paywall checks for free fork version

These modifications remove all paywall and premium feature restrictions from VoiceInk, making all features freely available to users. All changes comply with the GNU General Public License v3.0 (GPLv3) terms.

### Build & Release Improvements

#### Build System Enhancements
- **Commit: 89b911e** - Enhanced Makefile with hot reload and build configuration targets
- **Commit: a4cd8df** - Enhanced Makefile with automatic framework path management

#### Release Workflow
- **Commit: b2b013e** - Added beta release workflow from main branch
- **Commit: ba46e10** - Simplified beta workflow: attach DMG to release, remove PR
- **Commit: f49a924** - Fix beta workflow: use Release configuration consistently
- **Commit: da47d63** - Fix beta release workflow: use ad-hoc signing

### Upstream Integration
- **Commit: 9d75109** - Merged pull request #454 from Beingpax/dictionary-refactor (historical)

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
