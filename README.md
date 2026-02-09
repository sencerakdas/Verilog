# World War III: Dead Hand Protocol Simulation ☢️🛡️

This repository contains a **Verilog HDL** implementation of the "Dead Hand Protocol," a sophisticated automated defense system designed for the **BBM233 Logic Design Laboratory** final project.

## 🚀 Project Overview
The "Dead Hand" system is a fail-lethal automated engagement protocol. It monitors threat levels, communication status, and system integrity to transition between peace and total engagement. The design utilizes a dual-layer **Finite State Machine (FSM)**: a Main FSM for strategic status and an Engagement Sub-FSM for tactical execution.

## ✨ Key Features
- [cite_start]**Multi-Level Threat Assessment:** Transitions between states (`PEACE`, `ALERT`, `MOBILIZATION`, `ENGAGEMENT`) based on a 2-bit threat level input[cite: 5, 18, 22, 27].
- [cite_start]**Fail-Lethal Logic:** If a `system_fault` is detected at any non-terminal state, the system automatically transitions to `GLOBAL_WAR`.
- **Hierarchical FSM Architecture:**
    - [cite_start]**Main FSM:** Manages global escalation and de-escalation[cite: 16].
    - [cite_start]**Engagement Sub-FSM:** Manages sub-states like `ARM`, `TRACK`, and `AUTHORIZE` during active combat scenarios[cite: 7, 33, 34, 35].
- **Diplomatic Override & Lock-in:** Includes a `diplomatic_override` mechanism. [cite_start]Crucially, it implements "late override rejection" where overrides are ignored once the authorization timer passes a critical threshold[cite: 14, 15].
- [cite_start]**Synchronous Logic:** Operates on a 1 Hz clock with synchronous active-high reset[cite: 1, 2, 9].

## 🛠️ Technical Details
- [cite_start]**States:** PEACE (000), ALERT (001), MOBILIZATION (010), ENGAGEMENT (011), GLOBAL_WAR (101), DEADLOCK (110)[cite: 5, 6].
- [cite_start]**Sub-States:** ARM (00), TRACK (01), AUTHORIZE (10), ABORT (11)[cite: 7].
- [cite_start]**Timers:** Independent 32-bit timers for tracking state durations and trigger conditions[cite: 8].

## 📂 File Structure
- [cite_start]`dead_hand.v`: The primary Verilog module containing the FSM and output logic[cite: 1].
- `testbench/`: (Recommended) Include your testbench files here for simulation verification.

## 💻 Simulation & Synthesis
This module is designed for synthesis and can be simulated using tools such as:
- **Vivado Design Suite**
- **ModelSim**
- **Icarus Verilog** with GTKWave for waveform analysis.

```bash
# Example compilation with Icarus Verilog
iverilog -o dead_hand_sim dead_hand.v dead_hand_tb.v
vvp dead_hand_sim
