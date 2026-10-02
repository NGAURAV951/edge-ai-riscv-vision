\# System Architecture



\## 1. Overview



The Edge-AI RISC-V Vision System is a hardware-aware Edge AI project combining:



\- INT8 quantized machine learning

\- Python reference inference

\- Embedded C driver modeling

\- SystemVerilog RTL acceleration

\- Memory-mapped accelerator registers

\- Simulation-based verification



The current implementation is a \*\*software + RTL MVP\*\*. Physical FPGA deployment and RISC-V processor integration are future hardware targets.



\---



\## 2. High-Level Architecture



```text

&#x20;                   +----------------------+

&#x20;                   |      MNIST Image     |

&#x20;                   |        28 x 28       |

&#x20;                   |       784 pixels     |

&#x20;                   +----------+-----------+

&#x20;                              |

&#x20;                              v

&#x20;                   +----------------------+

&#x20;                   |   INT8 Quantized     |

&#x20;                   |   Neural Network     |

&#x20;                   |    10 Classes        |

&#x20;                   +----------+-----------+

&#x20;                              |

&#x20;                              v

&#x20;                   +----------------------+

&#x20;                   | 784-Element Vector   |

&#x20;                   +----------+-----------+

&#x20;                              |

&#x20;                              v

&#x20;                   +----------------------+

&#x20;                   | 49 x 16-Element      |

&#x20;                   | Tiles                |

&#x20;                   +----------+-----------+

&#x20;                              |

&#x20;                              v

&#x20;                   +----------------------+

&#x20;                   | 16-Element INT8      |

&#x20;                   | Dot-Product RTL      |

&#x20;                   | Accelerator          |

&#x20;                   +----------+-----------+

&#x20;                              |

&#x20;                              v

&#x20;                   +----------------------+

&#x20;                   | Memory-Mapped        |

&#x20;                   | Register Interface   |

&#x20;                   +----------+-----------+

&#x20;                              |

&#x20;                              v

&#x20;                   +----------------------+

&#x20;                   | Classification       |

&#x20;                   | Result               |

&#x20;                   +----------------------+  



3\. Software / Hardware Co-Design



The project uses the same fundamental dot-product operation in software and RTL.



&#x20;             SOFTWARE                         RTL



&#x20;     +------------------+          +----------------------+

&#x20;     | MNIST Image      |          | 16-element INT8 MAC |

&#x20;     | 28 x 28          |          | Accelerator          |

&#x20;     +--------+---------+          +----------+-----------+

&#x20;              |                               |

&#x20;              v                               |

&#x20;     +------------------+                     |

&#x20;     | INT8 Quantized   |                     |

&#x20;     | Weights          |                     |

&#x20;     +--------+---------+                     |

&#x20;              |                               |

&#x20;              v                               |

&#x20;     +------------------+                     |

&#x20;     | 784-element      |                     |

&#x20;     | Vector           |                     |

&#x20;     +--------+---------+                     |

&#x20;              |                               |

&#x20;              v                               |

&#x20;     +------------------+                     |

&#x20;     | 49 x 16-element  +---------------------+

&#x20;     | Tiles            |

&#x20;     +--------+---------+

&#x20;              |

&#x20;              v

&#x20;     +------------------+

&#x20;     | Class Scores     |

&#x20;     +--------+---------+

&#x20;              |

&#x20;              v

&#x20;     +------------------+

&#x20;     | Predicted Digit  |

&#x20;     +------------------+



The Python tiled implementation verifies that splitting the 784-element calculation into 49 tiles produces the same numerical result as the direct dot-product reference.



4\. MNIST Data Path



Each MNIST image contains:



28 x 28 = 784 pixels



The current tiled computation uses:



Tile size = 16 elements

Number of tiles = 784 / 16 = 49



For each output class:



784-element input

&#x20;      |

&#x20;      +--> Tile 0   (16 elements)

&#x20;      |

&#x20;      +--> Tile 1   (16 elements)

&#x20;      |

&#x20;      +--> Tile 2   (16 elements)

&#x20;      |

&#x20;      +--> ...

&#x20;      |

&#x20;      +--> Tile 48  (16 elements)

&#x20;      |

&#x20;      v

Final class score



There are 10 output classes corresponding to digits 0 through 9.



5\. RTL Dot-Product Accelerator



The main RTL accelerator is implemented in:



rtl/dot\_product.s



The accelerator processes:



16 signed INT8 values from A

16 signed INT8 values from B



The operation is:



result =

&#x20;   A\[0]  \* B\[0]  +

&#x20;   A\[1]  \* B\[1]  +

&#x20;   ...

&#x20;   A\[15] \* B\[15]



The accumulator is:



32-bit signed



The accelerator uses a sequential multiply-accumulate architecture.



&#x20;               +-------------------+

A\[0:15] ------->|                   |

&#x20;               |   INT8 Multiply   |

B\[0:15] ------->|        +          |

&#x20;               |   Accumulator     |

&#x20;               |                   |

&#x20;               +---------+---------+

&#x20;                         |

&#x20;                         v

&#x20;                   32-bit result

6\. Sequential MAC Operation



The accelerator processes one vector element per MAC cycle.



For a 16-element vector:



16 elements

&#x20;    |

&#x20;    v

16 sequential MAC operations

&#x20;    |

&#x20;    v

32-bit accumulated result



The verified RTL latency for the direct dot-product operation is:



16 MAC cycles



This represents the 16 multiply-accumulate operations.



7\. Signed INT8 Arithmetic



The RTL supports signed 8-bit values.



Example verification vectors:



A =

\[1, -2, 3, -4, 5, -6, 7, -8,

&#x20;9, -10, 11, -12, 13, -14, 15, -16]



B =

\[1, 2, 3, 4, 5, 6, 7, 8,

&#x20;9, 10, 11, 12, 13, 14, 15, 16]



The verified result is:



RESULT = -136



The RTL simulation produced:



RESULT=-136

BUSY=0

DONE=0

CYCLES=16



SIGNED\_DOT\_PRODUCT\_PASS result=-136

LATENCY\_PASS cycles=16

8\. Memory-Mapped Register Interface



The register interface is implemented in:



rtl/accelerator\_regs.s



The current interface is designed around a 16-element vector.



Address	Register	Description

0x00 - 0x0F	A\[0] - A\[15]	Signed 8-bit vector A

0x10 - 0x1F	B\[0] - B\[15]	Signed 8-bit vector B

0x20	CTRL	Accelerator control

0x21	STATUS	Busy/done status

0x22	RESULT	Result bits \[7:0]

0x23	RESULT\_HIGH	Result bits \[15:8]

9\. Control Register



The control register is located at:



0x20



Writing:



CTRL = 1



starts the accelerator when it is not busy.



The start signal is internally generated from the control write.



10\. Status Register



The status register is located at:



0x21



The current status format is:



bit 0 = BUSY

bit 1 = DONE



Therefore:



STATUS = 0x02



represents:



BUSY = 0

DONE = 1



The register interface keeps the completion indication available after the accelerator finishes.



11\. Result Registers



The result is exposed through:



0x22  RESULT

0x23  RESULT\_HIGH



The current register interface exposes:



RESULT      = result\[7:0]

RESULT\_HIGH = result\[15:8]



The internal computation still uses the full:



32-bit signed accumulator

12\. Register-Controlled Accelerator Flow



The register-controlled operation follows this sequence:



1\. Reset accelerator

&#x20;       |

&#x20;       v

2\. Write A\[0:15]

&#x20;       |

&#x20;       v

3\. Write B\[0:15]

&#x20;       |

&#x20;       v

4\. Write CTRL = 1

&#x20;       |

&#x20;       v

5\. Accelerator starts

&#x20;       |

&#x20;       v

6\. BUSY becomes active

&#x20;       |

&#x20;       v

7\. 16 sequential MAC operations

&#x20;       |

&#x20;       v

8\. Result becomes available

&#x20;       |

&#x20;       v

9\. DONE becomes active

&#x20;       |

&#x20;       v

10\. Software reads result

13\. Register Interface Verification



The register interface is verified using:



rtl/tb\_accelerator\_regs.s



The testbench performs:



Reset

Write 16 signed values to vector A

Write 16 signed values to vector B

Start the accelerator

Monitor the busy state

Wait for completion

Read status

Read result

Compare against the expected result



Verified output:



STATUS=0x02

BUSY=0

DONE=1

CYCLES=17

RESULT=0xff78



STATUS\_PASS

RESULT\_PASS result=0xff78 signed=-136

REGISTER\_LATENCY\_PASS cycles=17

Important latency distinction



The register-controlled test reports:



17 cycles



This is the measured start-to-completion latency of the register-controlled operation.



It does not mean that the accelerator performs 17 MAC operations.



The actual dot-product computation performs:



16 MAC cycles

14\. Software Tiled Reference



The Python reference implementation is located in:



ai/mnist\_tiled\_reference.py



It divides the input and weight vectors into 16-element tiles.



The software reference verifies:



Reference dot product

&#x20;       ==

Tiled dot product



Example:



Reference dot product: 343

Tiled dot product:     343

Tiles:                 49



TILED\_REFERENCE\_PASS

15\. Full MNIST Score Verification



The full-score reference is implemented in:



ai/mnist\_full\_score\_reference.py



It verifies that the tiled 49-tile calculation produces exactly the same class scores as the direct 784-element calculation.



Example:



Expected digit:       5



Reference prediction: 3

Tiled prediction:     3



FULL\_SCORE\_PASS

PREDICTION\_MATCH\_PASS



This verifies numerical consistency between:



Direct 784-element calculation



and:



49 x 16-element tiled calculation

16\. INT8 Inference



The tiled MNIST implementation is located in:



ai/mnist\_tiled\_inference.py



The inference structure is:



Input image

&#x20;    |

&#x20;    v

784 uint8 pixels

&#x20;    |

&#x20;    v

16-element tiles

&#x20;    |

&#x20;    v

49 tiles

&#x20;    |

&#x20;    v

INT8 weights

&#x20;    |

&#x20;    v

INT32 accumulation

&#x20;    |

&#x20;    v

10 class scores

&#x20;    |

&#x20;    v

Predicted digit



The current 100-image spot check produced:



Tiled INT8 accuracy: 94.00%

Correct:             94/100

Tiles per class:     49

Classes:             10



TILED\_MNIST\_PASS



This is a spot-check result and not a full-dataset accuracy claim.



17\. Embedded C Driver Model



The repository contains:



firmware/accelerator\_driver.c

firmware/accelerator\_driver.h

firmware/accelerator\_driver\_test.c



The C code demonstrates concepts including:



Memory-mapped register access

Vector input

Accelerator control

Status checking

Result reading

Signed result interpretation



The current driver test uses a smaller 4-element software model:



A = \[1, -2, 3, -4]

B = \[1, 2, 3, 4]



RESULT = -10



Verified output:



STATUS = 0x02

RAW RESULT = 0xFFF6

SIGNED RESULT = -10



SIGNED\_DRIVER\_TEST\_PASS result=-10

Current implementation boundary



The C driver is currently a software model.



It is not physically connected to:



A RISC-V processor

A physical FPGA

The SystemVerilog register interface



The current RTL register interface uses 16-element vectors, while the existing C driver test demonstrates a smaller 4-element software register model.



18\. Verification Architecture



The project uses multiple verification layers:



&#x20;                +----------------------+

&#x20;                | Python Unit Tests    |

&#x20;                +----------+-----------+

&#x20;                           |

&#x20;                           v

&#x20;                +----------------------+

&#x20;                | Tiled Reference     |

&#x20;                +----------+-----------+

&#x20;                           |

&#x20;                           v

&#x20;                +----------------------+

&#x20;                | Full Score Check    |

&#x20;                +----------+-----------+

&#x20;                           |

&#x20;                           v

&#x20;                +----------------------+

&#x20;                | RTL Dot Product     |

&#x20;                +----------+-----------+

&#x20;                           |

&#x20;                           v

&#x20;                +----------------------+

&#x20;                | RTL Register Test   |

&#x20;                +----------+-----------+

&#x20;                           |

&#x20;                           v

&#x20;                +----------------------+

&#x20;                | C Driver Model      |

&#x20;                +----------------------+



Each layer provides an independent verification point.



19\. Python Verification



The automated Python test suite is located in:



tests/test\_inference.py



The current suite contains:



Deterministic demo-frame verification

Feature extraction verification

Demo classification verification

Zero-frame classification verification

Accelerator/reference score matching

INT8 inference verification

Tiled dot-product verification

Tiled MNIST prediction matching



Current result:



8 passed

20\. Repository Architecture

edge-ai-riscv-vision/

|

+-- ai/

|   +-- mnist\_full\_score\_reference.py

|   +-- mnist\_int8.py

|   +-- mnist\_tiled\_inference.py

|   +-- mnist\_tiled\_reference.py

|   +-- quantize\_mnist.py

|   +-- train\_mnist.py

|

+-- firmware/

|   +-- accelerator\_driver.c

|   +-- accelerator\_driver.h

|   +-- accelerator\_driver\_test.c

|   +-- inference\_stub.c

|

+-- rtl/

|   +-- accelerator\_regs.s

|   +-- dot\_product.s

|   +-- tb\_accelerator\_regs.s

|   +-- tb\_dot\_product.s

|   +-- tb\_mnist\_tile.s

|

+-- tests/

|   +-- test\_inference.py

|

+-- docs/

|   +-- architecture.md

|

+-- models/

+-- data/

+-- README.md

+-- .gitignore

21\. Current Implementation Status

Implemented and Verified

Python inference

INT8 quantization

784-element tiled inference

16-element RTL dot-product accelerator

Signed INT8 arithmetic

32-bit accumulation

RTL simulation

Memory-mapped register interface

Register-interface simulation

Embedded C driver model

Automated Python tests

Full-score tiled verification

Not Yet Implemented

Physical FPGA deployment

RISC-V processor integration

Physical processor-to-accelerator bus connection

FPGA synthesis measurements

FPGA timing measurements

FPGA power measurements

Hardware/software speedup measurements

22\. Future Hardware Architecture



The planned hardware architecture is:



&#x20;                    RISC-V CPU

&#x20;                        |

&#x20;                        |

&#x20;                 Memory-Mapped Bus

&#x20;                        |

&#x20;                        v

&#x20;             +----------------------+

&#x20;             | Accelerator Registers|

&#x20;             +----------+-----------+

&#x20;                        |

&#x20;                        v

&#x20;             +----------------------+

&#x20;             | 16-Element INT8 MAC  |

&#x20;             | Accelerator          |

&#x20;             +----------+-----------+

&#x20;                        |

&#x20;                        v

&#x20;                 Result Register



This is a future hardware architecture.



It should not be interpreted as a completed physical RISC-V or FPGA implementation.



23\. Future Development Roadmap

Current

&#x20;  |

&#x20;  v

Verified Python INT8 inference

&#x20;  |

&#x20;  v

Verified tiled computation

&#x20;  |

&#x20;  v

Verified RTL MAC accelerator

&#x20;  |

&#x20;  v

Verified memory-mapped register interface

&#x20;  |

&#x20;  v

RTL synthesis

&#x20;  |

&#x20;  v

FPGA implementation

&#x20;  |

&#x20;  v

RISC-V processor integration

&#x20;  |

&#x20;  v

Physical memory-mapped accelerator

&#x20;  |

&#x20;  v

Hardware/software benchmarking



Future measurements will include:



FPGA clock frequency

LUT utilization

Flip-flop utilization

DSP utilization

Timing

Power

Hardware/software latency

Hardware/software speedup



No physical FPGA measurements are claimed until the design is synthesized and deployed.



24\. Design Rationale

INT8 Arithmetic



INT8 reduces data width compared with floating-point computation and provides a practical representation for embedded inference acceleration.



16-Element Tile



The 16-element tile provides a simple hardware datapath while allowing the 784-element MNIST calculation to be divided into manageable blocks.



784 / 16 = 49 tiles

Sequential MAC



A sequential MAC architecture is simple to understand, simulate, and verify. It also provides a baseline for future experiments with more parallel architectures.



Memory-Mapped Interface



A memory-mapped register interface provides a clear software/hardware control model and can later be connected to a processor bus.



25\. Architecture Summary



The current project demonstrates a complete verified path from:



MNIST Image

&#x20;    |

&#x20;    v

INT8 Quantized Inference

&#x20;    |

&#x20;    v

784-Element Vector

&#x20;    |

&#x20;    v

49 x 16-Element Tiles

&#x20;    |

&#x20;    v

16-Element Signed INT8 MAC

&#x20;    |

&#x20;    v

32-bit Accumulator

&#x20;    |

&#x20;    v

Memory-Mapped Register Interface

&#x20;    |

&#x20;    v

Verified Result



The software and RTL portions have been verified independently and through numerical consistency checks.



The next major engineering step is physical FPGA implementation followed by RISC-V processor integration.







