# BF-Dashboard-TX16S

A Betaflight and ExpressLRS/CRSF telemetry dashboard widget for the RadioMaster TX16S MK3 running EdgeTX.

Current working dashboard version: **v1.4**

Main v1.4 changes:

- Added support for GPS sensors discovered as `GPS`, `GSpd`, `Hdg`, `GAlt`, and `Sats`.
- Added `NO FIX` handling when GPS exists but has no satellite lock.
- Keeps the voltage-based battery ring from v1.3.
- Uses EdgeTX/CRSF sensor names such as `RQly`, `TQly`, `RFMD`, `TPWR`, `RxBt`, `Curr`, `Capa`, and `FM`.

Copy the widget folder to:

```text
SDCARD/WIDGETS/BF_Dashboard/
```

Required files include `main.lua`, `background.png`, `default.png`, `Multirotor.png`, and the icon PNG files.

Tested with RadioMaster TX16S MK3, EdgeTX RadioMaster pre-2.12.0 build, ExpressLRS CRSF telemetry, and Betaflight.
