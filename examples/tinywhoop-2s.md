# Example: 2S Tinywhoop / Micro Quad

Typical setup:

```text
Battery: 2S 450mAh
Telemetry link: ELRS / CRSF
GPS: usually none
```

Expected dashboard behaviour:

- Battery ring uses calculated cell voltage.
- `Capa` still shows mAh used.
- GPS box shows `NO GPS` unless a GPS is fitted.
- `2RSS` may be hidden if the receiver only reports one antenna.

Example telemetry:

```text
RxBt = 8.6V
Cell = 4.30V
Capa = 24mAh
RQly = 100%
RFMD = 8
TPWR = 100mW
FM = AIR! when disarmed
FM = AIR when armed
```

Recommended landing reference:

```text
Watch both cell voltage and mAh used.
For a 450mAh pack, many pilots land around 300-350mAh used, depending on battery health and voltage sag.
```
