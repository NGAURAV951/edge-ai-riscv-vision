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

## Memory-mapped register interface

The accelerator exposes a simple memory-mapped register interface. The software driver writes the input vectors and control information, then reads the computed result.

| Address | Register | Description |
|---|---|---|
| `0x00` | `A0` | Vector A element 0 |
| `0x01` | `A1` | Vector A element 1 |
| `0x02` | `A2` | Vector A element 2 |
| `0x03` | `A3` | Vector A element 3 |
| `0x04` | `B0` | Vector B element 0 |
| `0x05` | `B1` | Vector B element 1 |
| `0x06` | `B2` | Vector B element 2 |
| `0x07` | `B3` | Vector B element 3 |
| `0x08` | `CTRL` | Write `1` to start the accelerator |
| `0x09` | `STATUS` | Busy/done status |
| `0x0A` | `RESULT` | Result bits `[7:0]` |
| `0x0B` | `RESULT_HIGH` | Result bits `[15:8]` |

### Accelerator operation

1. Software writes four signed 8-bit values to vector A.
2. Software writes four signed 8-bit values to vector B.
3. Software writes `1` to `CTRL`.
4. The accelerator computes the dot product.
5. The result is available through `RESULT` and `RESULT_HIGH`.

For example:

A = [1, 2, 3, 4]
B = [10, 20, 30, 40]

```text
Result = 1×10 + 2×20 + 3×30 + 4×40
       = 300

       = 0x012C
```


