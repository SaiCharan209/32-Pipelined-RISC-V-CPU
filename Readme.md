# 5-Stage Pipelined RV32I Processor

**Built using Verilog , RTL based CPU design**

## Overview

This project is a custom-designed 32 bit 5 stage pipelined RV32I processor, it supports R,I,S,B,U and J instructions and handles various pipeline hazards using efficient architectural techniques

The processor simulates intruction execution through five stages:
**IF → ID → EX → MEM → WB**, with custom hazard resolution techniques for **Data**,**Control** and **Structural hazards**.

---

## Instruction Format

The RV32I intruction set architecture supports 6 type of instructions

![Instruction Formats](
