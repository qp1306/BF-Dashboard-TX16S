# Customization Guide

## Changing Sensor Names

All telemetry sensor mapping is currently in `main.lua` inside the `refresh()` function.

Example:

```lua
local lq = num(sensor({"RQly", "RQLY", "RQLy", "LQ"}, 0), 0)
```

To add another possible sensor name, add it to the list:

```lua
local lq = num(sensor({"RQly", "RQLY", "RQLy", "LQ", "LinkQ"}, 0), 0)
```

## Changing RF Rate Text

Edit `decode_rate()`:

```lua
local map = {
  [8] = "D250",
  [9] = "D500"
}
```

If your ExpressLRS setup reports `RFMD = 8` but you know it is `D500`, change:

```lua
[8] = "D500"
```

## Changing Battery Curve

Edit `battery_percent_from_cell()`.

Current approximation:

```text
4.20V+ = 100%
3.80V  = 50%
3.50V  = 15%
3.30V  = 0%
```

If you want the ring to read lower or higher, adjust these thresholds.

## Changing Cell Detection

Edit `auto_cell_count()`:

```lua
local cells = math.floor((pack_v / 4.35) + 1.0)
```

This works well for normal LiPo packs, but can be changed for Li-ion or unusual battery setups.

## Changing Layout Position

The widget uses a 480 x 272 layout base and scales to the screen.

Most drawing calls look like this:

```lua
lcd.drawText(X(240), Y(112), value, CENTER + VCENTER + DBLSIZE)
```

- X coordinate moves left/right.
- Y coordinate moves up/down.
- Text size is controlled by `SMLSIZE`, `MIDSIZE`, `DBLSIZE`, etc.

## Model Image

The widget tries to load a model-specific image based on the model name.

Example:

```text
Model name: Multirotor
Image path: /WIDGETS/BF_Dashboard/Multirotor.png
```

If the image does not exist, it uses:

```text
/WIDGETS/BF_Dashboard/default.png
```

## Planned Improvements

Future versions should move user settings into a separate `settings.lua` file so common changes can be made without editing the main drawing code.
