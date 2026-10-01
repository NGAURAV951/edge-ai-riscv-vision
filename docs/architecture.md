# Architecture

```text
Camera / test frame
        |
        v
Pre-processing
        |
        v
Feature extraction
(mean / active pixels / peak)
        |
        v
Quantized inference
        |
        +----> SAFE / ALERT
        |
        v
Dot-product accelerator
        |
        v
RISC-V memory-mapped peripheral
```

## Hardware/software co-design

Neural-network inference repeatedly uses multiply-accumulate operations. The dot-product RTL block is therefore a small, understandable accelerator primitive.

Proposed final FPGA structure:

```text
RISC-V CPU
   |
   | memory-mapped registers
   v
+------------------+
| Dot Product IP   |
| 8-bit signed MAC |
+------------------+
   |
   v
Result register
```

Final hardware reporting should include only measured clock frequency, LUT/FF/DSP use, latency, power, and speedup.
