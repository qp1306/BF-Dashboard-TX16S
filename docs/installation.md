# Installation Guide

## 1. Copy the Widget to the Radio SD Card

Copy the dashboard folder to:

```text
SDCARD/WIDGETS/BF_Dashboard/
```

Expected folder:

```text
WIDGETS/
└── BF_Dashboard/
    ├── main.lua
    ├── background.png
    ├── default.png
    ├── Multirotor.png
    ├── ico_alt.png
    ├── ico_ant.png
    ├── ico_batt.png
    ├── ico_bolt.png
    ├── ico_clock.png
    ├── ico_hdg.png
    ├── ico_home.png
    ├── ico_link.png
    ├── ico_sat.png
    └── ico_stop.png
```

## 2. Discover Telemetry Sensors

On the TX16S:

```text
Model Setup
→ Telemetry
→ Delete all sensors
→ Discover new sensors
```

Power the quad with the receiver connected and wait 10 to 30 seconds.

## 3. Add the Widget

On the radio:

```text
Telemetry Screen Setup
→ Add screen
→ Full screen widget
→ BF Dashboard
```

## 4. Confirm Values

Expected values with a powered quad:

```text
FM      AIR! or AIR
RQly    100%
RSNR    signal-to-noise value
RFMD    numeric ELRS mode
TPWR    10mW / 25mW / 100mW etc
RxBt    flight pack voltage
Curr    current draw
Capa    mAh used
```

## 5. Common First-Run Issues

### Widget loads but values are zero

The radio has not discovered sensors, or the discovered sensor names differ from the script.

### Lua panic

Usually caused by missing assets or unsupported EdgeTX Lua functions.

### No GPS

This is normal if no GPS is installed or Betaflight GPS telemetry is not enabled.
