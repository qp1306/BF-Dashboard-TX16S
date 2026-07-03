# Battery Logic

## Why the Dashboard Does Not Use Betaflight Bat%

Betaflight sends a `Bat%` telemetry value, but that value is voltage-based and can be misleading depending on:

- battery cell count
- battery chemistry
- voltage sag under load
- Betaflight battery settings
- pack condition
- pack capacity

For v1.3, the dashboard uses its own voltage-based battery ring.

## How the Battery Ring Works

The dashboard:

1. Reads pack voltage from `RxBt`.
2. Auto-detects cell count.
3. Calculates cell voltage.
4. Converts cell voltage into a remaining percentage.
5. Draws the ring from that calculated value.

## Auto Cell Detection

The dashboard uses the pack voltage to estimate cell count:

```lua
local cells = math.floor((pack_v / 4.35) + 1.0)
```

Examples:

| Pack | Voltage | Detected Cells | Cell Voltage |
|---|---:|---:|---:|
| 2S | 8.6V | 2 | 4.30V |
| 4S | 16.0V | 4 | 4.00V |
| 6S | 22.3V | 6 | 3.72V |

## Battery Percentage Curve

The dashboard uses this LiPo approximation:

| Cell Voltage | Displayed % |
|---:|---:|
| 4.20V+ | 100% |
| 3.80V | 50% |
| 3.50V | 15% |
| 3.30V | 0% |

This is designed to be useful across different pack capacities.

## mAh Used

The dashboard still displays `Capa` under the ring.

That value comes from Betaflight and is useful for tracking how much capacity has been consumed.

For example:

```text
2S 450mAh pack: land around 300-350mAh used
6S 1300mAh pack: land around 900-1100mAh used
```

Exact landing limits depend on your battery, flying style and voltage sag.
