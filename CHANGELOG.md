# Changelog

All notable changes to BF-Dashboard-TX16S will be documented here.

## v1.3 - Current Working Build

### Added

- Battery ring now uses calculated cell-voltage percentage instead of Betaflight `Bat%`.
- Automatic LiPo cell-count detection from `RxBt` pack voltage.
- Better support for mixed battery capacities, such as 2S 450 mAh and 6S 1300 mAh.

### Changed

- Battery percentage display is now independent of pack mAh capacity.
- `Bat%` telemetry is retained only as fallback when pack voltage is unavailable.

## v1.2

### Added

- Dynamic TX battery icon.
- Cleaner `NO GPS` state when GPS sensors are missing.
- 2RSS hiding when ELRS only reports one receiver antenna value.
- Cleaner link statistics panel.

### Changed

- Improved GPS panel behaviour.
- Improved bottom status strip.

## v1.1

### Fixed

- Cell voltage calculation for 6S packs.
- Removed old hard-coded 4S divisor.
- Added automatic cell-count detection.

## v1.0

### Added

- EdgeTX/ELRS sensor-name fixes for `RQly`, `TQly`, `TPWR`, and `RFMD`.
- Betaflight armed/disarmed detection from `FM` using the `!` suffix.

### Fixed

- `AIR!` is now correctly interpreted as disarmed.
- `AIR` is now correctly interpreted as armed.
- `TPWR` text/numeric parsing.
- RFMD rate decoding.

## v0.x Development Builds

Early dashboard design iterations:

- Removed helicopter-specific display items.
- Replaced head speed with GPS speed.
- Added Betaflight/ELRS telemetry layout.
- Added Oxbot/multirotor image support.
- Added SATS, ALT, HDG and DIST HOME icons.
- Reworked box sizes and alignment for the TX16S MK3 screen.
