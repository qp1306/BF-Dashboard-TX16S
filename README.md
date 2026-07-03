# BF-Dashboard-TX16S

A Betaflight and ExpressLRS/CRSF telemetry dashboard widget for the RadioMaster TX16S MK3 running EdgeTX.

This project started as a rebuild of a helicopter-focused EdgeTX telemetry widget and has been redesigned around Betaflight multirotors, ELRS link statistics, battery monitoring, GPS telemetry, and a clean full-screen dashboard layout.

## Current Status

Current working dashboard version: **v1.3**

Tested with:

- Radio: RadioMaster TX16S MK3
- EdgeTX: RadioMaster pre-2.12.0 build
- Link: ExpressLRS using CRSF telemetry
- Flight controller firmware: Betaflight
- Display target: 800 x 480 radio screen, scaled from a 480 x 272 layout base

## Main Features

- Betaflight flight mode display using the `FM` CRSF telemetry sensor
- Armed/disarmed detection using Betaflight's `!` flight-mode suffix
- ExpressLRS link quality display using `RQly`
- SNR display using `RSNR`
- RF rate display using `RFMD`
- TX power display using `TPWR`
- Uplink/downlink link-statistics panel
- Pack voltage from `RxBt`
- Current from `Curr`
- Capacity used from `Capa`
- Calculated watts from voltage x current
- Automatic LiPo cell-count detection
- Battery ring based on calculated cell voltage rather than fixed mAh capacity
- GPS speed, altitude, heading, satellites, and distance-home panel when sensors are available
- Clean `NO GPS` display when GPS sensors are absent
- TX battery voltage display
- Model image support

## Dashboard Layout

The screen is divided into these sections:

1. **Top telemetry bar** - flight mode, armed state, LQ, SNR, RF rate, TX power, radio battery.
2. **Battery ring** - calculated battery remaining based on cell voltage.
3. **Battery details box** - pack voltage, calculated cell voltage, current, and watts.
4. **Centre speed display** - GPS ground speed in km/h.
5. **Model image area** - model-specific quad image or default image.
6. **Link statistics box** - RSSI, TRSS, RQly, TQly.
7. **GPS box** - satellites, altitude, heading, distance home.
8. **Bottom status strip** - mAh used, max speed, distance home, flight time, clock.

See `docs/dashboard-layout.md` for the detailed annotated layout.

## Required EdgeTX Telemetry Sensors

At minimum, the dashboard expects some of these sensors to be discovered on the radio:

| Sensor | Purpose |
|---|---|
| `FM` | Betaflight flight mode and arm state |
| `RQly` | ELRS uplink link quality |
| `RSNR` | Uplink signal-to-noise ratio |
| `RFMD` | ELRS RF mode / packet rate |
| `TPWR` | ELRS TX power |
| `TRSS` | Downlink RSSI |
| `TQly` | Downlink link quality |
| `RxBt` | Flight pack voltage |
| `Curr` | Current draw |
| `Capa` | mAh used |
| `GSpd` | GPS speed |
| `Alt` | Altitude |
| `Sats` | GPS satellites |
| `Hdg` | Heading |
| `Dist` / `HomeDist` | Distance home |

Sensor names are case-sensitive in EdgeTX Lua. This is why the script checks both common Betaflight/CRSF names such as `RQly` and fallback names such as `RQLY`.

## Installation

Copy the widget folder to the SD card:

```text
SDCARD/WIDGETS/BF_Dashboard/
```

Required files:

```text
main.lua
background.png
default.png
Multirotor.png
ico_alt.png
ico_ant.png
ico_batt.png
ico_bolt.png
ico_clock.png
ico_hdg.png
ico_home.png
ico_link.png
ico_sat.png
ico_stop.png
```

Then on the radio:

1. Open the model.
2. Go to **Telemetry**.
3. Delete old sensors if needed.
4. Run **Discover new sensors** with the quad powered.
5. Add the widget to a full-screen telemetry page.

## Betaflight Setup

Recommended Betaflight setup:

- Receiver protocol: CRSF
- Telemetry: enabled
- Serial receiver: enabled on the receiver UART
- Capacity used telemetry: enabled
- Voltage, current, mode, heading, altitude, GPS speed, and distance telemetry enabled as required

See `docs/betaflight-setup.md`.

## Battery Logic

The v1.3 dashboard does not trust Betaflight's `Bat%` value for the ring.

Instead it:

1. Reads pack voltage from `RxBt`.
2. Auto-detects cell count from pack voltage.
3. Calculates cell voltage.
4. Estimates remaining battery from cell voltage.

This makes the same widget usable across different pack capacities, for example:

- 2S 450 mAh
- 2S 550 mAh
- 4S packs
- 6S 1300 mAh
- 6S 1500 mAh

## Project Roadmap

Planned improvements:

- Split the Lua into modules: telemetry, battery, draw, GPS, settings.
- Add configurable battery curves.
- Add selectable layouts for tinywhoop, freestyle, long range, and race builds.
- Add GitHub release ZIP packaging.
- Add full user manual with annotated screenshots.
- Add GitHub Pages documentation.

## Repository Structure

```text
BF-Dashboard-TX16S/
├── README.md
├── LICENSE
├── CHANGELOG.md
├── CONTRIBUTING.md
├── scripts/
│   └── BF_Dashboard/
│       └── main.lua
├── docs/
│   ├── installation.md
│   ├── betaflight-setup.md
│   ├── telemetry-sensors.md
│   ├── dashboard-layout.md
│   ├── battery-logic.md
│   ├── customization.md
│   └── troubleshooting.md
├── examples/
└── releases/
```

## License

MIT License. See `LICENSE`.
