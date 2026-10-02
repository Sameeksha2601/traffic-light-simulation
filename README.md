# Traffic Light Controller — Verilog RTL

A digital hardware implementation of a two-road traffic light controller using a **4-state Moore FSM** and a **50 MHz timer/clock-enable generator**.

The project started as a C-based traffic-light simulation and was upgraded into a synthesizable **Verilog RTL design**, followed by functional verification and RTL synthesis using **Icarus Verilog, GTKWave, Yosys, and ABC**.

---

## 1. Project Overview

The controller manages traffic lights for two roads:

* Road A
* Road B

Only one road is allowed to have the green light at a time.

The controller follows this repeating sequence:

```text
Road A GREEN  → Road A YELLOW
       ↓
Road B GREEN  → Road B YELLOW
       ↓
     Repeat
```

Timing:

| State | Road A | Road B | Duration |
| ----- | ------ | ------ | -------: |
| S0    | GREEN  | RED    |      5 s |
| S1    | YELLOW | RED    |      2 s |
| S2    | RED    | GREEN  |      5 s |
| S3    | RED    | YELLOW |      2 s |

Complete cycle:

```text
5 + 2 + 5 + 2 = 14 seconds
```

---

## 2. Hardware Architecture

```text
                 50 MHz Clock
                      │
                      ▼
          ┌─────────────────────┐
          │ Traffic Light Timer │
          │     26-bit Counter  │
          └──────────┬──────────┘
                     │
                     │ 1-second tick
                     ▼
          ┌─────────────────────┐
          │   4-State Moore FSM │
          │                     │
          │ S0 → S1 → S2 → S3  │
          │ ↑               │   │
          │ └───────────────┘   │
          └──────────┬──────────┘
                     │
                     ▼
          ┌─────────────────────┐
          │   Traffic Outputs   │
          │                     │
          │ Road A: R Y G       │
          │ Road B: R Y G       │
          └─────────────────────┘
```

The timer generates a one-clock-cycle **clock-enable pulse** every simulated second.

The FSM uses this pulse to control the traffic-light state transitions.

---

## 3. FSM Design

The controller contains four states:

```text
S0 → S1 → S2 → S3 → S0
```

### State S0

```text
Road A = GREEN
Road B = RED
Duration = 5 seconds
```

### State S1

```text
Road A = YELLOW
Road B = RED
Duration = 2 seconds
```

### State S2

```text
Road A = RED
Road B = GREEN
Duration = 5 seconds
```

### State S3

```text
Road A = RED
Road B = YELLOW
Duration = 2 seconds
```

The FSM is implemented as a **Moore machine**, meaning the traffic-light outputs depend only on the current FSM state.

---

## 4. Module Structure

### `traffic_light_timer.v`

Generates the one-second timing enable from the 50 MHz input clock.

For a 50 MHz clock:

```text
Clock frequency = 50,000,000 Hz
Clock period     = 20 ns
```

The timer counts:

```text
50,000,000 clock cycles = 1 second
```

A 26-bit counter is sufficient because:

```text
2^25  = 33,554,432
2^26  = 67,108,864
```

Therefore:

```text
25 bits → insufficient
26 bits → sufficient
```

### `traffic_light_fsm.v`

Implements:

* FSM state register
* State transition logic
* State duration counter
* Traffic-light output decoding

### `traffic_light_top.v`

Integrates the timer and FSM into one top-level hardware module.

---

## 5. Verification

The design was verified using **Icarus Verilog**.

The testbench checks:

* Correct FSM sequence
* Correct 5-second green duration
* Correct 2-second yellow duration
* No conflicting lights
* No simultaneous green lights
* Every road always has an active signal
* Correct state restart after S3

Simulation result:

```text
========================================
ALL SEQUENCE CHECKS PASSED
========================================
```

The integrated top-level testbench also passed:

```text
========================================
TOP-LEVEL TEST PASSED
========================================
```

---

## 6. Waveform Verification

VCD waveform files were generated for inspection using GTKWave.

Generated files include:

```text
traffic_light.vcd
traffic_light_top.vcd
```

The waveform can be used to observe:

* Clock
* Reset
* One-second tick
* FSM state
* Traffic-light outputs
* State transitions

---

## 7. Simulation

For fast simulation, the testbench uses:

```verilog
CLK_FREQ = 10
```

instead of the real 50 MHz value.

Therefore:

```text
10 clock cycles = 1 simulated second
```

This allows the complete 14-second traffic sequence to be verified quickly.

Example compilation:

```bash
iverilog -o traffic_sim traffic_light_timer.v traffic_light_fsm.v traffic_light_fsm_tb.v
vvp traffic_sim
```

Top-level simulation:

```bash
iverilog -o traffic_top_sim traffic_light_timer.v traffic_light_fsm.v traffic_light_top.v traffic_light_top_tb.v
vvp traffic_top_sim
```

---

## 8. RTL Synthesis

The RTL was synthesized using **Yosys** and optimized using **ABC**.

Command:

```bash
yosys -p "read_verilog traffic_light_timer.v traffic_light_fsm.v traffic_light_top.v; hierarchy -top traffic_light_top; proc; opt; fsm; opt; techmap; opt; abc -g simple; stat" > synthesis_report.txt
```

Final synthesized design:

```text
Total generic cells: 163
```

Hierarchy:

| Module | Generic cells |
| ------ | ------------: |
| Timer  |           121 |
| FSM    |            42 |
| Total  |           163 |

The timer uses more hardware because it contains the large counter required to generate the one-second timing enable from the 50 MHz clock.

**Note:** 163 is a generic synthesized-cell count from Yosys/ABC. It is not a physical ASIC area measurement.

---

## 9. Tools Used

| Tool           | Purpose                 |
| -------------- | ----------------------- |
| Verilog        | RTL design              |
| Icarus Verilog | Simulation              |
| GTKWave        | Waveform analysis       |
| Yosys          | RTL synthesis           |
| ABC            | Logic optimization      |
| MSYS2 UCRT64   | Development environment |

---

## 10. Project Structure

```text
traffic-light-simulation/
│
├── C/
│   └── traffic_light.c
│
├── Verilog/
│   ├── traffic_light_timer.v
│   ├── traffic_light_fsm.v
│   ├── traffic_light_top.v
│   ├── traffic_light_fsm_tb.v
│   ├── traffic_light_top_tb.v
│   ├── traffic_light.vcd
│   ├── traffic_light_top.vcd
│   └── synthesis_report.txt
│
├── .gitignore
└── README.md
```

---

## 11. Key Digital Design Concepts Demonstrated

* Finite State Machines
* Moore FSM
* State encoding
* Sequential logic
* Combinational logic
* Counters
* Clock enables
* Asynchronous reset
* Parameterized RTL
* Self-checking testbenches
* Functional verification
* RTL synthesis
* Logic optimization
* Hardware resource analysis

---

## 12. Future Improvements

Possible extensions include:

* Pedestrian crossing control
* Emergency vehicle priority
* Sensor-based traffic control
* Configurable timing
* Seven-segment countdown display
* FPGA board implementation
* Formal verification
* Technology-specific timing and area analysis

---

## 13. Project Outcome

This project demonstrates the complete digital-design flow:

```text
C Simulation
     ↓
Hardware Specification
     ↓
Verilog RTL
     ↓
FSM + Timer Design
     ↓
Simulation
     ↓
Self-Checking Verification
     ↓
Waveform Analysis
     ↓
RTL Synthesis
     ↓
Logic Optimization
```

The final design was functionally verified and synthesized to **163 generic cells** using Yosys/ABC.
