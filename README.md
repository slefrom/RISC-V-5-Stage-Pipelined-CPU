# RISC-V-5-Stage-Pipelined-CPU

A 5 stage pipelined processor I made, with full hazard detection, forwarding, and branch penalty resolution. Verified Using cocotb, and ran it through OpenROAD ASIC flow, on SkyWater 130 nm HD using the OpenROAD-flow-scripts RTL-GDSII flow. 

---

## 2. Implementation Results (PPA Metrics)

| Metric Category | Parameter | Measured Value |
| :--- | :--- | :--- |
| **Performance** | Target Clock Frequency | 100 MHz (10.00 ns) |
| | Maximum Operating Frequency ($F_{\text{max}}$) | 118.15 MHz (8.46 ns period) |
| | Setup Worst Negative Slack (WNS) | +1.54 ns (MET) |
| | Worst Hold Slack | +0.08 ns (MET) |
| | Setup / Hold Violations | 0 / 0 |
| | Clock Tree Skew | 0.32 ns |
| **Physical Area** | Total Standard Cell Area | 95,355 µm² (~0.095 mm²) |
| | Total Standard Cell Count | 6,054 cells |
| | Sequential Cells / Area Ratio | 1,620 DFFs / 54.49% |
| | Architectural Register File Footprint | 1,024 cells (32 × 32-bit DFFE) |
| **Power (100 MHz)** | Total Power Dissipation | 21.4 mW |
| | Internal Power | 14.3 mW (66.5%) |
| | Switching Power | 7.18 mW (33.5%) |
| | Leakage Power | 34.9 nW (< 0.01%) |
| **DRC / LVS** | Magic DRC Errors | 0 |
| | Netgen LVS Status | Clean |

---

## 3. Some images during the process:

Final Layout:

<img width="1099" height="1099" alt="final_all" src="https://github.com/user-attachments/assets/9a3402d4-36da-4f6a-b6b8-1a4e42f34234" />

Clock Tree Synthesis Layout:

<img width="1099" height="1099" alt="cts_default_clk_layout" src="https://github.com/user-attachments/assets/cc2c1463-6c11-4d72-847f-a934c5026b71" />

Worst Path:

<img width="1099" height="1099" alt="final_worst_path" src="https://github.com/user-attachments/assets/ee49d6f1-414a-403b-bfed-a028ce761f34" />







