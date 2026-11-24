
# Asynchronous FIFO with Clock Domain Crossing (CDC)

## 1. Project Overview

This project implements an Asynchronous FIFO (First-In First-Out) using Verilog HDL.

An asynchronous FIFO is used to transfer data between two independent clock domains operating at different frequencies.

## 2. Project Objectives

- Design an asynchronous FIFO using Verilog HDL.
- Transfer data between independent write and read clocks.
- Implement Clock Domain Crossing (CDC).
- Use Gray-coded pointers for safe pointer synchronization.
- Detect FIFO full and empty conditions.
- Verify the design using simulation.

## 3. Design Specifications

| Parameter | Value |
|---|---|
| Data Width | 8 bits |
| Address Width | 4 bits |
| FIFO Depth | 16 |
| Pointer Width | 5 bits |
| Design Language | Verilog HDL |
| Simulation Tool | AMD Vivado |

## 4. Architecture

The design consists of:

- FIFO Memory
- Write Pointer and Full Detection
- Read Pointer and Empty Detection
- Two-Stage Synchronizers

## 5. Clock Domain Crossing

The write and read operations use independent clocks.

Gray code is used for pointer synchronization because only one bit changes between consecutive Gray-coded values.

Two-stage synchronizers help reduce the probability of metastability propagating into the destination clock domain.

## 6. Verification

The testbench checks:

- Reset operation
- FIFO filling
- Full flag detection
- FIFO draining
- Empty flag detection
- Random write and read operations
- Data ordering and integrity
- Overflow and underflow protection

## 7. Simulation Results

Verified simulation run:

- Total words written: 1335
- Total words read: 1335
- Blocked write attempts: 2906
- Blocked read attempts: 274
- Errors: 0
- Final status: TEST PASSED

## 8. Tools Used

- Verilog HDL
- AMD Vivado
- Ubuntu Linux
- Git and GitHub

## 9. Author

y.Chintha Mohan
B.Tech 3rd year
Electronics and Communication Engineering

