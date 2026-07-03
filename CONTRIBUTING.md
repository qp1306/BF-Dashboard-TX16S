# Contributing

Thanks for helping improve BF-Dashboard-TX16S.

This project is focused on creating a clean Betaflight/ELRS telemetry dashboard for EdgeTX radios, especially the RadioMaster TX16S MK3.

## Good Contributions

Useful contributions include:

- Fixes for different EdgeTX sensor names.
- Improvements to Betaflight telemetry mapping.
- Better battery-voltage curves.
- GPS display improvements.
- New layouts for tinywhoop, freestyle, race, long-range and fixed-wing models.
- Documentation improvements.
- Screenshots from different radios.
- Bug reports with telemetry sensor photos.

## Bug Reports

When reporting a bug, include:

- Radio model.
- EdgeTX version.
- Betaflight version.
- ExpressLRS version if known.
- Receiver type.
- A photo of the EdgeTX telemetry sensor list.
- A photo of the dashboard screen.
- The battery cell count and capacity used during the test.

## Sensor Names Matter

EdgeTX Lua sensor names are case-sensitive.

For example, these are different:

```text
RQly
RQLY
RQly%
```

If a value is missing on the dashboard but works in the EdgeTX telemetry page, the first thing to check is the exact sensor name.

## Code Style

Current code is a single-file widget for compatibility and easy installation.

Planned structure:

```text
main.lua
telemetry.lua
battery.lua
draw.lua
gps.lua
settings.lua
```

Until the code is split into modules, keep changes simple and easy to follow.

## Testing Checklist

Before submitting changes, test where possible:

- Widget loads without Lua panic.
- No telemetry connected state.
- Receiver connected but no flight battery.
- Flight battery connected.
- Armed/disarmed state.
- 2S pack voltage.
- 4S or 6S pack voltage if available.
- ELRS `RQly`, `RFMD`, `TPWR` values.
- No GPS installed.
- GPS installed, if available.

## Safety

Always remove props when testing armed state on the bench.
