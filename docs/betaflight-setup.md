# Betaflight Setup

## Receiver

In Betaflight Configurator:

```text
Receiver Mode: Serial
Serial Receiver Provider: CRSF
```

## Ports

On the UART connected to the ELRS receiver:

```text
Serial RX: ON
```

Telemetry output is normally not required for CRSF serial receiver wiring.

## Telemetry

Enable telemetry in Betaflight.

Recommended telemetry fields:

```text
Voltage: enabled
Current: enabled
Capacity used: enabled
Mode: enabled
Heading: enabled if GPS/heading is used
Altitude: enabled if altitude is used
Ground speed: enabled if GPS speed is used
Distance: enabled if distance-home is used
```

ESC telemetry fields are not required for this dashboard.

## CLI Checks

Useful CLI commands:

```text
get serialrx_provider
get telemetry
```

Expected:

```text
serialrx_provider = CRSF
```

Capacity used should not be disabled:

```text
telemetry_disabled_cap_used = OFF
```

If it is ON, run:

```text
set telemetry_disabled_cap_used = OFF
save
```

## Voltage and Current Calibration

The dashboard depends on Betaflight's voltage and current telemetry.

If pack voltage is wrong in EdgeTX, fix Betaflight voltage calibration before changing the Lua.

If current or mAh used is wrong, calibrate the current sensor in Betaflight.
