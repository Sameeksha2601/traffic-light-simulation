# Traffic Light Controller Simulation
### B.Tech ECE — 2nd Year Mini Project

A C program simulating a real-world traffic light controller at a 4-way
intersection with two perpendicular roads (North-South and East-West),
implemented using a **finite state machine (FSM)** so only one road is
ever green at a time — just like a real signal controller.

## Objective

To design and implement a finite state machine in C that models the
timed transitions of a two-road traffic light intersection, correctly
coordinating both directions so they never conflict (i.e. both roads
green simultaneously), and to apply structured/table-driven control logic
instead of hardcoded if-else chains.

## Tools & Technologies

- Language: C (ISO C99)
- Compiler: GCC
- No external libraries; uses only the standard library and OS sleep
  functions (`unistd.h` on Linux/macOS, `windows.h` on Windows — handled
  automatically via conditional compilation)

## How it works

The intersection cycles through 4 phases, defined in a small lookup table
(`phases[]`) rather than nested if-else logic:

| Phase | Road A (N-S) | Road B (E-W) | Duration |
|---|---|---|---|
| 1 | GREEN  | RED    | 5s |
| 2 | YELLOW | RED    | 2s |
| 3 | RED    | GREEN  | 5s |
| 4 | RED    | YELLOW | 2s |

This table-driven design is a common embedded-systems pattern: adding a
3rd road, changing durations, or adding a pedestrian-crossing phase only
means editing the table, not rewriting control flow.

## Build

```bash
gcc -O2 -Wall -o traffic_light traffic_light.c
```

## Run

**Real-time mode** (waits 1 real second per simulated second, like an
actual traffic light):
```bash
./traffic_light
```

**Fast/demo mode** (no waiting — useful for quick testing or a live demo
without sitting through real seconds):
```bash
./traffic_light --fast
```

**Limit to a specific number of full cycles** (default runs forever until
Ctrl+C):
```bash
./traffic_light --fast --cycles 3
```

Sample output:
```
[Road A (N-S)] Light : GREEN    |   [Road B (E-W)] Light : RED      (next change in 5s)
[Road A (N-S)] Light : GREEN    |   [Road B (E-W)] Light : RED      (next change in 4s)
...
[Road A (N-S)] Light : RED      |   [Road B (E-W)] Light : GREEN    (next change in 5s)
...
```

## Concepts demonstrated

- **Finite state machines**: representing a system's behavior as a fixed
  set of states with defined transitions — foundational in digital
  systems/embedded design.
- **Table-driven design**: encoding transition logic as data (a struct
  array) rather than branching code, a common real-world embedded pattern.
- **Timing and synchronization**: coordinating two independent signals so
  they never enter a conflicting state at the same time.
- **Cross-platform C**: conditional compilation (`#ifdef _WIN32`) to
  handle OS-specific sleep functions.

## Possible extensions

- Add a 3rd/4th road for a full 4-way junction
- Add a pedestrian "WALK/DON'T WALK" signal phase
- Add an emergency-vehicle override mode (force one road green)
- Drive it from a hardware timer/interrupt if ported to a microcontroller
  (e.g. Arduino/8051) instead of software `sleep()`
