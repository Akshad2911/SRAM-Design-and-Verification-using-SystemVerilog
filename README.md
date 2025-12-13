# SRAM-Design-and-Verification-using-SystemVerilog

This project implements a Static Random Access Memory (SRAM) using SystemVerilog, supporting synchronous read and write operations. The design is verified using a SystemVerilog testbench to ensure correct memory functionality and timing behavior.

---

## 📌 Project Overview

This project presents a clean and synthesizable implementation of a **Static Random Access Memory (SRAM)** using **SystemVerilog**, along with a structured testbench for functional verification. The objective is to demonstrate correct SRAM behavior, control logic, and timing suitable for VLSI and digital design learning.

---

## 🎯 Objectives

* Design a parameterized single-port SRAM in SystemVerilog
* Support synchronous read and write operations
* Verify functionality using a simulation-based testbench
* Ensure clarity, modularity, and synthesizability of RTL code

---

## 🧩 SRAM Description

SRAM is a high-speed volatile memory that stores data using latch-based cells. It does not require refresh cycles, making it ideal for cache memory and performance-critical applications.

---

## ⚙️ Design Specifications

* **Memory Type**: Single-Port SRAM
* **HDL**: SystemVerilog
* **Read**: Synchronous
* **Write**: Synchronous
* **Key Signals**:

  * `clk`  : Clock
  * `we`   : Write Enable
  * `re`   : Read Enable
  * `addr` : Address bus
  * `din`  : Data input
  * `dout` : Data output

---

## 🔄 Functional Operation

* On each rising edge of `clk`:

  * If `we` is high, input data is written to the addressed memory location
  * If `re` is high, data from the addressed location is driven to the output

* Read and write are controlled to avoid conflicts

---

## 🧪 Verification Environment and Approach

The verification environment is built using **SystemVerilog** to ensure functional correctness and robustness of the SRAM design. It follows a structured and modular testbench approach commonly used in industry-level RTL verification.

### 🔹 Verification Environment Components

* **Testbench Top**: Instantiates the SRAM DUT and connects all interfaces
* **Clock Generator**: Produces a stable periodic clock
* **Stimulus Generator**: Drives address, data, and control signals (`we`, `re`)
* **Monitor**: Observes DUT inputs and outputs during simulation
* **Checker / Scoreboard**: Compares expected data with actual SRAM output

### 🔹 Verification Strategy

* Perform write operations across multiple memory addresses
* Read back stored data and compare with expected values
* Verify correct behavior for sequential and boundary addresses
* Ensure read and write operations occur only on clock edges

This verification setup ensures protocol correctness, data integrity, and timing-aligned operation of the SRAM.

---

## 🗂️ Project Structure

```
SRAM_SystemVerilog/

├── sram.sv   // SRAM RTL design

├── tb_sram.sv     // Verification testbench

├── README.md      // Documentation
```

---

## 🛠️ Tools and Environment

* **Language**: SystemVerilog
* **Simulation**: ModelSim / QuestaSim / any SV-compatible simulator

---

## 🚀 Applications

* Cache and memory subsystem design
* VLSI and ASIC fundamentals
* Digital system design practice

---

## 🎓 Learning Outcomes

* Practical understanding of SRAM architecture
* Writing clean and synthesizable SystemVerilog RTL
* Developing basic verification testbenches

---

