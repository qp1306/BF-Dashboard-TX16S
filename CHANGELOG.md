# Changelog

## v1.4 - Current Working Build

- Added support for discovered GPS sensors: `GPS`, `GSpd`, `Hdg`, `GAlt`, and `Sats`.
- Added GPS present / no satellite lock handling.
- Retained v1.3 voltage-based battery ring.
- Updated documentation for latest telemetry mapping.

## v1.3

- Battery ring uses calculated cell-voltage percentage instead of Betaflight `Bat%`.
- Automatic LiPo cell-count detection from `RxBt` pack voltage.
- Better support for mixed battery capacities.

## v1.2

- Dynamic TX battery icon.
- Cleaner `NO GPS` state.
- Cleaner link statistics panel.

## v1.1

- Fixed cell voltage calculation for 6S packs.
- Removed old hard-coded 4S divisor.

## v1.0

- Fixed EdgeTX/ELRS sensor-name handling for `RQly`, `TQly`, `TPWR`, and `RFMD`.
- Fixed Betaflight armed/disarmed detection from `FM` using the `!` suffix.
