# Troubleshooting

## No Telemetry Values in the Widget

First check whether EdgeTX has discovered sensors.

On the radio:

```text
Model Setup → Telemetry → Discover new sensors
```

If no sensors appear, the issue is not the Lua widget. Check:

- Receiver is bound.
- Flight controller is powered.
- Betaflight receiver protocol is CRSF.
- Correct UART has Serial RX enabled.
- Betaflight telemetry is enabled.

## Telemetry Works in EdgeTX but Not in the Widget

This is usually a sensor-name mismatch.

EdgeTX Lua names are case-sensitive.

Example:

```text
RQly works
RQLY may not work
```

Add the discovered name to the relevant sensor list in `main.lua`.

Example:

```lua
local lq = num(sensor({"RQly", "RQLY", "RQLy", "LQ"}, 0), 0)
```

## Wrong Armed / Disarmed State

The tested setup uses:

```text
AIR! = disarmed
AIR  = armed
```

The script checks for `!` and also supports `*` as a fallback.

If your setup uses a different suffix, edit this section:

```lua
local is_disarmed = (string.find(fm, "!", 1, true) ~= nil) or (string.find(fm, "*", 1, true) ~= nil)
```

## Cell Voltage Is Wrong

The widget calculates cell count from pack voltage.

If your pack is unusual or voltage is badly calibrated, check Betaflight voltage calibration first.

If needed, change `auto_cell_count()` in `main.lua`.

## Battery Ring Looks Wrong

From v1.3 onward, the ring is calculated from cell voltage, not `Bat%`.

This is deliberate so the widget works across different battery capacities.

## Rate Shows the Wrong Value

Edit the RFMD table in `decode_rate()`.

Example:

```lua
[8] = "D250"
```

Change the text to match your ExpressLRS packet rate.

## GPS Shows NO GPS

The dashboard will show `NO GPS` when it cannot find GPS sensors or GPS values.

Check for:

```text
GSpd
Sats
Hdg
Dist
GPS
```

If Betaflight does not send these, the dashboard cannot display them.

## Missing Images or Icons

Make sure these files are on the SD card:

```text
background.png
default.png
ico_alt.png
ico_hdg.png
ico_home.png
ico_sat.png
```

They must be in:

```text
/WIDGETS/BF_Dashboard/
```
