# Telemetry Sensor Guide

BF-Dashboard-TX16S reads EdgeTX telemetry sensors sent by Betaflight through ExpressLRS/CRSF.

## Important Rule

EdgeTX Lua sensor names are case-sensitive.

The dashboard checks multiple possible names for many sensors, but the exact discovered names still matter.

## Tested Sensor Names

These are the sensor names confirmed on the RadioMaster TX16S MK3 test setup:

| Sensor | Meaning |
|---|---|
| `1RSS` | Uplink RSSI antenna 1 |
| `2RSS` | Uplink RSSI antenna 2, often unused on ELRS |
| `RQly` | Uplink link quality |
| `RSNR` | Uplink signal-to-noise ratio |
| `RFMD` | RF mode / packet rate |
| `TPWR` | Transmit power |
| `TRSS` | Downlink RSSI |
| `TQly` | Downlink link quality |
| `TSNR` | Downlink SNR |
| `RxBt` | Flight pack voltage |
| `Curr` | Current draw |
| `Capa` | Capacity used in mAh |
| `Bat%` | Betaflight battery percent, not used for the v1.3 ring |
| `FM` | Betaflight flight mode |
| `Ptch` | Pitch attitude |
| `Roll` | Roll attitude |
| `Yaw` | Yaw attitude |
| `Alt` | Altitude |
| `VSpd` | Vertical speed |

## Flight Mode and Arming

Betaflight sends flight mode through `FM`.

On the tested setup:

```text
AIR! = disarmed
AIR  = armed
```

The dashboard removes the `!` from the displayed flight mode and uses it to determine armed state.

Fallback support for `*` is also included for other CRSF builds.

## ELRS RFMD Rate Decoding

`RFMD` is a number. The dashboard decodes it into readable text.

Current mapping:

| RFMD | Dashboard Rate |
|---:|---|
| 0 | 4Hz |
| 1 | 50Hz |
| 2 | 150 |
| 3 | 250 |
| 4 | 500 |
| 5 | F500 |
| 6 | F1000 |
| 7 | D50 |
| 8 | D250 |
| 9 | D500 |
| 10 | F500 |
| 11 | F1000 |

If your ELRS firmware reports a different mapping, edit the `decode_rate()` function in `main.lua`.

## Power

`TPWR` is shown as mW or W:

```text
100mW
250mW
500mW
1.0W
2.0W
```

## Battery

`RxBt` is the pack voltage.

`Curr` is current draw.

`Capa` is mAh used.

`Bat%` is intentionally not used for the main battery ring in v1.3 because it can be misleading across different batteries.
