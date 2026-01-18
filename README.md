# Ring Oscillator PUF (RO-PUF) – RTL Implementation

This repository contains an RTL-level implementation of a **Ring Oscillator based Physically Unclonable Function (RO-PUF)** written in Verilog.  
The design implements the complete challenge–response path including ring oscillators, challenge-controlled multiplexers, measurement window logic, edge counters, and response generation.

---

## Overview

A Ring Oscillator PUF exploits small delay variations between identically designed ring oscillators.  
For a given challenge, two ring oscillators are selected, their oscillation frequencies are compared over a fixed time window, and a single response bit is generated.

At RTL level, the design focuses on **functional correctness** of the architecture and control logic.

---

## Architecture Description

The RO-PUF consists of the following blocks:

- **Ring Oscillator Bank**
  - 8 ring oscillators with different delay parameters
  - Each oscillator is enabled only during the measurement window

- **Challenge-Controlled Multiplexers**
  - Two 4:1 multiplexers
  - Select one oscillator from each group based on the challenge input

- **Measurement Window Timer**
  - Defines the active counting interval
  - Ensures both oscillators are measured for the same duration

- **Edge Counters**
  - Count rising edges of the selected ring oscillator outputs
  - Active only during the measurement window

- **Comparator**
  - Compares the two counter values
  - Generates a single response bit

---

## Module Description

### `ring_oscillator`
Implements a 5-stage ring oscillator using inverters with configurable delay.

### `mux4`
4:1 multiplexer used to select ring oscillator outputs based on the challenge bits.

### `window_timer`
Generates an enable signal defining the measurement window duration.

### `edge_counter`
Counts the number of edges from a selected ring oscillator during the active window.

### `ro_puf_top`
Top-level module that integrates all blocks and produces the final PUF response.

---

## Challenge–Response Operation

1. A 4-bit challenge is applied.
2. Two multiplexers select one ring oscillator from each group.
3. The measurement window is opened using the `start` signal.
4. Both edge counters count oscillations during the window.
5. After the window closes, the counter values are compared.
6. The response bit is generated:
   - `1` if counter A > counter B
   - `0` otherwise

---

## Testbench

The testbench:
- Generates a 100 MHz system clock
- Applies reset and multiple challenge values
- Opens and closes the measurement window using `start`
- Monitors the response bit for each challenge

Multiple challenges are applied sequentially to verify correct signal flow and response generation.

---

## Simulation Notes

- RTL simulation produces **deterministic responses**
- This is expected because RTL simulators do not model real physical delay variations
- True PUF behavior emerges only after:
  - Synthesis
  - Placement and routing
  - Parasitic extraction
  - Post-layout simulation

---

## File Structure

├── ro_puf_top.v
├── ring_oscillator.v
├── mux4.v
├── window_timer.v
├── edge_counter.v
├── testbench.v
└── README.md


---

## Tools Used

- Verilog HDL
- Cadence Xcelium (nclaunch) for RTL simulation
- GitHub for version control

---

## Author

Nikshitha Shree C V , Aadhirai Lakshmi Sai B , Aditya R Rao , Deep Mahesh Patange
B.Tech – VLSI Design and Technology  
Aspiring RTL / Hardware Design Engineer

---

## Future Work

- Synthesis using Cadence Genus
- Physical design using Cadence Innovus
- Post-layout simulations with extracted parasitics
- Reliability and uniqueness evaluation across multiple challenges
