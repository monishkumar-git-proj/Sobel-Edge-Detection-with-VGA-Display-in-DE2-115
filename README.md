# Sobel Edge Detection with VGA Display in DE2-115

FPGA pipeline that reads pixel data from an image ROM, converts it to grayscale, applies a Sobel edge-detection kernel, and drives the result out over VGA.

## Overview

The Sobel operator computes intensity gradients and is only defined for a single scalar value per pixel. Since a colour image carries three independent channels (R, G, B), the pipeline first collapses each pixel to grayscale, then runs Sobel on the resulting intensity map, and finally re-packs the edge magnitude into R/G/B for VGA output.

## Pipeline Stages

Image ROM → Grayscale Converter → Sobel Window → Output R/G/B → Display

See `Block_diagram.drawio.png` for the full visual pipeline.

## 1. Pixel Clock Generation

A 25 MHz pixel clock is generated from the input clock by toggling a register on every rising edge of the input clock. This halves the input clock frequency and produces the pixel clock used to drive the VGA controller and the entire processing pipeline.

## 2. ROM Addressing

A 256×256 image region is addressed using the current VGA scan position. As long as both the horizontal and vertical coordinates fall within the 256×256 range, the ROM address is calculated from the row and column position; outside that region, the address defaults to zero.

## 3. Datapath

- The VGA controller generates the raw horizontal and vertical scan coordinates, along with the raw horizontal sync, vertical sync, and active-video signals.
- The image ROM outputs the raw 8-bit pixel data for the current address.
- The grayscale converter takes that raw pixel data and produces an 8-bit grayscale value.
- The Sobel window block computes the edge magnitude from the grayscale stream.

## 4. Pipeline Latency — 4 Clock Cycles

Because pixel data takes a few clock cycles to move through the grayscale conversion and Sobel computation stages, the sync signals and scan coordinates must be delayed by the same amount so they stay aligned with the fully processed pixel.

This is done using 4-bit shift registers for the horizontal sync, vertical sync, and active-video signals, and a 4-stage delay chain for both the horizontal and vertical scan coordinates. On every pixel clock edge, each register shifts in the newest value while passing its previous contents one stage further along the chain. The final, most-delayed bit or coordinate is what's used to drive the actual sync outputs and to decide what gets displayed.

Total pipeline latency = 4 clock cycles. At a 25 MHz pixel clock, this is 160 nanoseconds from pixel read to display output.

| Clock | Concurrent pixel-data stage |
|-------|-------------------------------|
| 1 | Entering grayscale converter |
| 2 | Entering Sobel window |
| 3 | Sobel gradient computing |
| 4 | Fully processed pixel output (drives sync and blank signals) |

## 5. Output Assignment

The image is only drawn where the delayed scan coordinates fall inside the 256×256 image region and the delayed active-video signal is high. In that region, all three colour channels (R, G, B) are driven from the same Sobel edge output, producing a grayscale edge-detected image on screen; everywhere else, the output is held at black.

## Repository Contents

- `Block_diagram.drawio.png` — visual block diagram of the memory-to-VGA Sobel pipeline
- `SOBEL.v` — top-level module
- Source RTL / simulation files (add paths here as applicable)

## Status

Simulation verified: grayscale conversion, Sobel edge detection, and VGA sync/coordinate alignment across the 4-cycle pipeline confirmed correct.
