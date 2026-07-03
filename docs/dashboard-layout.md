# Dashboard Layout

The dashboard is designed around an 800 x 480 RadioMaster TX16S MK3 screen while using a 480 x 272 internal layout base that EdgeTX scales.

## Screen Sections

```text
┌────────────────────────────────────────────────────────┐
│ FM/ARM │ LQ │ SNR │ RATE │ PWR │ TX                  │
├────────┴────┴─────┴──────┴─────┴─────────────────────┤
│                                                        │
│   Battery Ring          GPS SPEED         Link Stats   │
│   Battery %             Large km/h        RSSI/LQ      │
│   mAh Used                                             │
│                                                        │
│   Pack / Cell Box       Model Image       GPS Box      │
│   Current / Watts       Quad Image        Sats/Alt/etc │
│                                                        │
├────────────────────────────────────────────────────────┤
│ Used mAh │ Max Speed │ Dist Home │ Flight │ Clock      │
└────────────────────────────────────────────────────────┘
```

## Top Telemetry Bar

Displays:

- `FM` flight mode
- ARMED / DISARMED
- `RQly` link quality
- `RSNR` signal-to-noise ratio
- `RFMD` decoded RF rate
- `TPWR` transmitter power
- radio battery voltage

## Battery Ring

The ring shows calculated battery remaining from cell voltage.

The text under the percentage shows `Capa` mAh used.

## Battery Details Box

Displays:

- pack voltage from `RxBt`
- calculated cell voltage
- current draw from `Curr`
- calculated watts from `RxBt x Curr`

## Centre GPS Speed

Displays `GSpd` in km/h.

If no GPS speed is available, it will show 0.

## Model Image

The widget attempts to load a model-specific PNG:

```text
/WIDGETS/BF_Dashboard/<Model_Name>.png
```

If no model image exists, it falls back to:

```text
/WIDGETS/BF_Dashboard/default.png
```

## Link Statistics Box

Displays uplink and downlink link values.

If `2RSS` is zero, it is hidden and the space is reused.

## GPS Box

Displays:

- satellites
- altitude
- heading
- distance home

If no GPS sensors are found, it displays `NO GPS` and leaves unavailable fields as `--`.

## Bottom Status Strip

Displays:

- mAh used
- max GPS speed while armed
- distance home
- armed flight timer
- radio clock
