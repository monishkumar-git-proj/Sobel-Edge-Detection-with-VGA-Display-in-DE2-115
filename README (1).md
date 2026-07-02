# Phase 1.C — Memory-to-VGA Sobel Edge Detection

FPGA pipeline that reads pixel data from memory (`.mem` image ROM), converts it to grayscale, and applies a Sobel edge-detection kernel before driving the result out over VGA.

## Overview

The Sobel operator computes intensity gradients to detect edges, and it is only defined for a **single scalar value per pixel**. Since a colour image carries three independent channels (R, G, B), edges in each channel can occur at different positions, and running Sobel per-channel and recombining gives unreliable results. The pipeline therefore collapses each pixel to grayscale first, then runs Sobel on the resulting intensity map.

## Pipeline Stages

```
ROM/Image (.mem) → Grayscale Converter → Line Buffer (3 rows) → Sobel Core (Gx/Gy) → VGA Formatter → Display
```

See [`block_diagram.pdf`](block_diagram.pdf) for the full visual pipeline, including the pixel-to-RGB bit mapping and sync-delay shift register.

## 1. Pixel Data — 8-bit RGB Bit Mapping

The 8-bit pixel data bus `[7:0]` is split across channels as follows:

| Bits | Channel |
|------|---------|
| `[7:6]` | Red |
| `[4:3]` | Green |
| `[1:0]` | Blue |

## 2. Colour → Grayscale Conversion

### Why convert?
- Sobel operates on intensity/brightness, not colour.
- Edges in R, G, B channels don't align spatially.
- Kernel arithmetic is defined for one scalar per pixel.

### ITU-R BT.601 Luminance Model
The human eye is most sensitive to green, moderately sensitive to red, and least sensitive to blue:

```
Y = 0.299 × R + 0.587 × G + 0.114 × B
```

| Channel | Weight | Integer Coeff (÷256) | Reason |
|---------|--------|------------------------|--------|
| Red     | 0.299  | 77  | Moderate eye sensitivity |
| Green   | 0.587  | 150 | Highest eye sensitivity |
| Blue    | 0.114  | 29  | Lowest eye sensitivity |

### FPGA-Friendly Integer Approximation
Floating-point/multiplier-based luminance is expensive on FPGA fabric, so the design uses a shift-only approximation — zero DSP blocks consumed:

```verilog
wire [7:0] gray_out = R>>2 + G>>1 + B>>3;
```

| Term | Equivalent Weight |
|------|--------------------|
| `R >> 2` | R × 0.25 |
| `G >> 1` | G × 0.50 |
| `B >> 3` | B × 0.125 |

Total ≈ `0.25R + 0.50G + 0.125B`, perceptually weighted toward green to match human eye sensitivity — all implemented as free bit-shifts.

## 3. Pipeline Latency

| Stage | Block | Delay |
|-------|-------|-------|
| 1 | ROM / Image in (`.mem` read) | 1 clock cycle (memory read latency) |
| 2 | Gray converter (`Y = R>>2 + G>>1 + B>>3`) | 1 clock cycle (combinational + output register) |
| 3 | Line buffer fill (r1 → r2 → r3) | 3 clock cycles (needs 2 full rows before the 3×3 window is complete) |
| 4 | Sobel core (Gx/Gy) | 0 (purely combinational — result ready same cycle as window) |
| 5 | VGA formatter register | 1 clock cycle |

**Total pipeline latency = 5 clock cycles**
At 25 MHz pixel clock: `5 × 40 ns = 200 ns` from pixel read to display output.

## 4. Sync-Signal Compensation

Because the pixel data takes 5 clock cycles to pass through the pipeline, `hsync`/`vsync`/`active_video` must be delayed by the same amount to stay aligned with the processed pixel:

```verilog
always @(posedge clk_25) begin
    hsync_delay  <= {hsync_delay[3:0], raw_hsync};
    vsync_delay  <= {vsync_delay[3:0], raw_vsync};
    active_delay <= {active_delay[3:0], active_video};
end
```

Each register is a 5-bit shift register that shifts the raw sync signal in one bit per clock:

| Clock | Sync bit position | Concurrent pixel-data stage |
|-------|--------------------|------------------------------|
| 1 | `hsync_delay[0]` | Entering grayscale converter |
| 2 | `hsync_delay[1]` | Moving through line buffers |
| 3 | `hsync_delay[2]` | Entering Sobel logic |
| 4 | `hsync_delay[3]` | Sobel gradients computing |
| 5 | `hsync_delay[4]` | Fully processed pixel output |

## Repository Contents

- `block_diagram.pdf` — visual block diagram of the full memory-to-VGA Sobel pipeline
- Source RTL / simulation files (add paths here as applicable)

## Status

Simulation verified: image-to-Sobel-window output and full-flow simulation confirmed correct grayscale conversion, edge detection, and VGA sync alignment.
