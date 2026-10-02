5ebb67e4-e55a-465a-b832-f8f1fdc39ba6.ini

File

this one

Pasted markdown.md

File

this is the readme



Yes — this is the README you currently have, and I checked the uploaded file.



And I spotted an important issue before you publish it:



Your content is good, but the Markdown formatting needs fixing



The architecture section is present in your README.



However, some of the code blocks and headings have been broken during the copy/paste. For example, around the architecture section, the closing code fence is missing before the next section, so GitHub may display a large portion of the README as plain code instead of formatted Markdown.



Also, near the bottom, your README currently contains this:



\### One important thing before publishing



and instructions saying that docs/architecture.md is outdated.



That should NOT be in your published README. That's guidance for you, not project documentation.



So I recommend we do this properly



I'll make your final publish-ready README.md with:



✅ Correct Markdown formatting

✅ Proper architecture diagram

✅ Proper hardware/software co-design diagram

✅ All your verified results

✅ Correct headings

✅ Proper GitHub code blocks

✅ Proper tables

✅ No interview-preparation section

✅ No instructions to yourself

✅ No unnecessary ChatGPT-related text

✅ No false FPGA/RISC-V claims

✅ Professional engineering-project presentation



And I will base it on this exact README you uploaded, rather than replacing it with unrelated content.



If you want, I can give you the 

clean final README in one copy-paste block, ready to put directly into GitHub.



Give me the clean final README in one copy-paste block



Absolutely. I reviewed the README you uploaded and kept the actual implemented/verified content, while fixing the Markdown structure and removing the internal publishing instructions at the bottom.



Copy everything inside this block and paste it directly into README.md:



\# Edge-AI RISC-V Vision System



A hardware-aware Edge AI vision system combining quantized machine learning, embedded C firmware, and RTL-based hardware acceleration.



The project explores low-latency on-device inference using INT8 arithmetic, tiled dot-product computation, memory-mapped accelerator registers, and verification of the software and RTL datapaths.



\---



\## Project Status



\*\*Current status: Software + RTL MVP verified\*\*



The current repository contains:



\- INT8 quantized MNIST inference

\- 784-element tiled inference using 16-element tiles

\- 49 tiles per MNIST input

\- Signed INT8 RTL dot-product accelerator

\- 32-bit accumulation

\- Memory-mapped RTL register interface

\- Embedded C accelerator driver model

\- Python verification tests

\- RTL simulation testbenches

\- Full-score software-to-tiled verification



\### Hardware Status



The current implementation is verified through simulation and software models.



A physical FPGA implementation and RISC-V CPU integration are \*\*future hardware targets\*\* and are not claimed as completed in this version.



\---



\# 1. Project Goal



The goal of this project is to explore how a lightweight neural-network inference workload can be mapped onto an embedded hardware accelerator.



Instead of treating AI inference as only a software problem, this project connects three areas:



\### Machine Learning



\- Lightweight neural-network model

\- INT8 quantization

\- MNIST inference



\### Embedded Software



\- C accelerator driver model

\- Memory-mapped register concepts

\- Integer arithmetic



\### Digital Hardware



\- SystemVerilog RTL

\- Sequential multiply-accumulate operation

\- Signed INT8 arithmetic

\- 32-bit accumulation

\- Register interface

\- Simulation-based verification



\---



\# 2. System Architecture



The overall software and hardware flow is:



```text

&#x20;                   +----------------------+

&#x20;                   |     Input Image      |

&#x20;                   |      28 x 28         |

&#x20;                   |       MNIST          |

&#x20;                   +----------+-----------+

&#x20;                              |

&#x20;                              v

&#x20;                   +----------------------+

&#x20;                   | Image Representation |

&#x20;                   |      uint8 pixels    |

&#x20;                   +----------+-----------+

&#x20;                              |

&#x20;                              v

&#x20;                   +----------------------+

&#x20;                   | INT8 Quantized       |

&#x20;                   | Neural Network       |

&#x20;                   | 10-Class Classifier  |

&#x20;                   +----------+-----------+

&#x20;                              |

&#x20;                              v

&#x20;                +-----------------------------+

&#x20;                | 784-Element Dot Product     |

&#x20;                |                             |

&#x20;                | 49 x 16-Element Tiles       |

&#x20;                +-------------+---------------+

&#x20;                              |

&#x20;                              v

&#x20;                +-----------------------------+

&#x20;                | 16-Element INT8 RTL         |

&#x20;                | Dot-Product Accelerator     |

&#x20;                |                             |

&#x20;                | Sequential MAC              |

&#x20;                | 32-bit Accumulator          |

&#x20;                +-------------+---------------+

&#x20;                              |

&#x20;                              v

&#x20;                +-----------------------------+

&#x20;                | Memory-Mapped Register      |

&#x20;                | Interface                   |

&#x20;                |                             |

&#x20;                | A\[0:15] / B\[0:15]           |

&#x20;                | CTRL / STATUS / RESULT      |

&#x20;                +-------------+---------------+

&#x20;                              |

&#x20;                              v

&#x20;                   +----------------------+

&#x20;                   |   Inference Result   |

&#x20;                   |    Predicted Digit   |

&#x20;                   +----------------------+

3\. Hardware / Software Co-Design



The project uses the same basic dot-product structure in both software and RTL.



&#x20;         SOFTWARE                         RTL HARDWARE



+----------------------+          +--------------------------+

| MNIST Image          |          | 16-Element INT8 MAC      |

| 28 x 28 = 784       |          | Accelerator              |

+----------+-----------+          +------------+-------------+

&#x20;          |                                   |

&#x20;          v                                   |

+----------------------+                        |

| INT8 Quantization    |                        |

+----------+-----------+                        |

&#x20;          |                                   |

&#x20;          v                                   |

+----------------------+                        |

| 784-Element Vector  |                        |

+----------+-----------+                        |

&#x20;          |                                   |

&#x20;          v                                   |

+----------------------+                        |

| 49 x 16-Element     +------------------------+

| Tiles                |

+----------+-----------+

&#x20;          |

&#x20;          v

+----------------------+

| Final Classification |

+----------------------+



The Python implementation verifies the full 784-element calculation using the same 16-element tile structure implemented by the RTL accelerator.



4\. Machine Learning Pipeline



The project uses the MNIST handwritten-digit dataset.



Each MNIST image contains:



28 x 28 pixels = 784 input values



The inference pipeline is:



MNIST image

&#x20;    |

&#x20;    v

784 pixel values

&#x20;    |

&#x20;    v

INT8 quantized weights

&#x20;    |

&#x20;    v

784-element dot products

&#x20;    |

&#x20;    v

49 x 16-element tiles

&#x20;    |

&#x20;    v

Class scores

&#x20;    |

&#x20;    v

Predicted digit



The classifier contains 10 output classes corresponding to:



0 1 2 3 4 5 6 7 8 9

5\. INT8 Quantized Inference



The project includes an INT8 inference implementation.



The neural-network weights are quantized from floating-point values into signed 8-bit integers.



The inference datapath uses:



Input pixels      : uint8

Weights           : int8

Multiplication    : integer

Accumulation      : int32



This allows the inference computation to be represented using integer arithmetic suitable for embedded hardware acceleration.



The current INT8 classifier was tested on a 100-image MNIST spot check.



Tiled INT8 accuracy: 94.00%

Correct:             94/100

Tiles per class:     49

Classes:             10



TILED\_MNIST\_PASS



Note: The 94% figure is a 100-image verification spot check, not a claim of full-dataset accuracy.



6\. Tiled Inference



A complete MNIST input contains 784 values.



The hardware accelerator processes:



16 elements per tile



Therefore:



784 / 16 = 49 tiles



For each output class, the 49 tile results are accumulated to produce the final class score.



784-element vector

&#x20;      |

&#x20;      +-- Tile 0   : 16 elements

&#x20;      |

&#x20;      +-- Tile 1   : 16 elements

&#x20;      |

&#x20;      +-- Tile 2   : 16 elements

&#x20;      |

&#x20;      +-- ...

&#x20;      |

&#x20;      +-- Tile 48  : 16 elements

&#x20;      |

&#x20;      v

Final 784-element score



The tiled software implementation was compared against a direct NumPy dot product.



Verification Result

Reference dot product: 343

Tiled dot product:     343

Tiles:                 49



TILED\_REFERENCE\_PASS

7\. Full-Score Verification



The project also verifies that the tiled implementation produces exactly the same class scores as the non-tiled reference implementation.



Example Verification

Expected digit:       5



Reference scores:

\[  19355 -192241   85530  245427 -283665

&#x20;  180856  -26094  -51210   28114  -6801]



Tiled scores:

\[  19355 -192241   85530  245427 -283665

&#x20;  180856  -26094  -51210   28114  -6801]



Tiles per class:      49



FULL\_SCORE\_PASS



Reference prediction: 3

Tiled prediction:     3



PREDICTION\_MATCH\_PASS



This verifies that splitting the 784-element calculation into 49 tiles does not change the numerical result.



8\. RTL Dot-Product Accelerator



The RTL accelerator is implemented in SystemVerilog.



The current accelerator processes:



16 signed INT8 values



For every element, it performs:



A\[i] × B\[i]



and accumulates the result into a:



32-bit signed accumulator



The basic operation is:



result = A0×B0 + A1×B1 + ... + A15×B15



The accelerator uses a sequential MAC architecture.



&#x20;             +------------------+

A\[0:15] ----->|                  |

&#x20;             |  INT8 Multiply   |

B\[0:15] ----->|       +          |

&#x20;             |  Accumulator     |

&#x20;             |                  |

&#x20;             +--------+---------+

&#x20;                      |

&#x20;                      v

&#x20;                32-bit result

9\. Signed Arithmetic Verification



Signed INT8 arithmetic is important because neural-network weights can contain both positive and negative values.



The RTL was tested using:



A = \[1, -2, 3, -4, 5, -6, 7, -8,

&#x20;    9, -10, 11, -12, 13, -14, 15, -16]



B = \[1, 2, 3, 4, 5, 6, 7, 8,

&#x20;    9, 10, 11, 12, 13, 14, 15, 16]



The verified result was:



RESULT=-136

BUSY=0

DONE=0

CYCLES=16



SIGNED\_DOT\_PRODUCT\_PASS result=-136

LATENCY\_PASS cycles=16



The 16 cycles represent the 16 sequential MAC operations.



10\. Positive Dot-Product Verification



A second 16-element test was also performed using positive input values.



The verified result was:



RESULT=1496

CYCLES=16



DOT\_PRODUCT\_PASS

LATENCY\_PASS cycles=16



Additional smaller configurations were also tested during development.



11\. MNIST Tile RTL Verification



A dedicated 16-element MNIST tile testbench verifies the signed INT8 hardware datapath.



The simulation produced:



MNIST\_TILE\_RESULT=-512

MNIST\_TILE\_BUSY=0

MNIST\_TILE\_DONE=0

MNIST\_TILE\_CYCLES=16



MNIST\_TILE\_PASS result=-512

MNIST\_TILE\_LATENCY\_PASS cycles=16



This verifies the tile-level hardware computation before connecting the concept to the full 784-element software inference flow.



12\. Memory-Mapped Accelerator Interface



The project includes a SystemVerilog register interface around the dot-product accelerator.



The current RTL register layout is designed for a 16-element vector.



Address	Register	Description

0x00 - 0x0F	A\[0] - A\[15]	Signed 8-bit vector A

0x10 - 0x1F	B\[0] - B\[15]	Signed 8-bit vector B

0x20	CTRL	Accelerator control

0x21	STATUS	Busy/done status

0x22	RESULT	Result bits \[7:0]

0x23	RESULT\_HIGH	Result bits \[15:8]

Control Register



Writing:



CTRL = 1



starts the accelerator when it is not busy.



Status Register



The status register contains:



bit 0 = BUSY

bit 1 = DONE

Result Registers



The result is exposed through:



RESULT      = result\[7:0]

RESULT\_HIGH = result\[15:8]



The underlying RTL computation uses a 32-bit signed accumulator.



13\. Register Interface Verification



The complete register interface was tested using a SystemVerilog testbench.



The testbench:



Resets the accelerator.

Writes 16 signed values to vector A.

Writes 16 signed values to vector B.

Starts the accelerator.

Monitors the busy state.

Waits for completion.

Reads the status register.

Reads the result registers.

Checks the expected result.

Verified Output

STATUS=0x02

BUSY=0

DONE=1

CYCLES=17

RESULT=0xff78



STATUS\_PASS

RESULT\_PASS result=0xff78 signed=-136

REGISTER\_LATENCY\_PASS cycles=17



The 17-cycle measurement is the start-to-completion latency of the register-controlled operation.



It should not be interpreted as 17 MAC operations.



The underlying dot-product computation performs 16 MAC cycles.



14\. Embedded C Driver Model



The repository also contains an embedded C accelerator driver model.



The driver demonstrates concepts such as:



Memory-mapped registers

Writing vector data

Starting an accelerator

Reading status

Reading result registers

Signed result interpretation



The C driver test produced:



A = \[1, -2, 3, -4]

B = \[1, 2, 3, 4]



STATUS = 0x02

RAW RESULT = 0xFFF6

SIGNED RESULT = -10



SIGNED\_DRIVER\_TEST\_PASS result=-10

Important Implementation Note



The current C driver is a software driver model and is not physically connected to the SystemVerilog RTL or a RISC-V processor.



The current RTL register interface uses a 16-element vector, while the existing C driver test models a smaller 4-element register-level example.



The future hardware implementation will unify the software driver, RISC-V processor, bus interface, and RTL accelerator.



15\. Verification Strategy



The project uses multiple levels of verification.



Level 1

&#x20; |

&#x20; +--> Python unit tests

&#x20; |

Level 2

&#x20; |

&#x20; +--> Tiled numerical reference

&#x20; |

Level 3

&#x20; |

&#x20; +--> Full 784-element score comparison

&#x20; |

Level 4

&#x20; |

&#x20; +--> RTL dot-product simulation

&#x20; |

Level 5

&#x20; |

&#x20; +--> RTL register-interface simulation

&#x20; |

Level 6

&#x20; |

&#x20; +--> C accelerator driver model



This provides independent checks for the software and hardware portions of the project.



16\. Python Test Suite



The repository contains automated Python tests covering:



Deterministic demo-frame generation

Feature extraction

Demo classification

Zero-frame classification

Accelerator score/reference matching

INT8 inference

Tiled dot-product verification

Tiled MNIST prediction matching

Current Test Result

8 passed



Run the test suite with:



py -m pytest -q

17\. Software Demo



The original Edge-AI demonstration pipeline produces:



=== Edge-AI RISC-V Vision MVP ===

class:      ALERT

confidence: 0.639

features:   \[31, 12, 127]

latency:    0.0322 ms

throughput: 31095.9 FPS



This provides a lightweight demonstration of feature extraction, classification, and timing measurement.



Exact latency and throughput can vary between systems.



18\. Repository Structure

edge-ai-riscv-vision/

│

├── ai/

│   ├── mnist\_full\_score\_reference.py

│   ├── mnist\_int8.py

│   ├── mnist\_tiled\_inference.py

│   ├── mnist\_tiled\_reference.py

│   ├── quantize\_mnist.py

│   └── train\_mnist.py

│

├── firmware/

│   ├── accelerator\_driver.c

│   ├── accelerator\_driver.h

│   ├── accelerator\_driver\_test.c

│   └── inference\_stub.c

│

├── rtl/

│   ├── accelerator\_regs.s

│   ├── dot\_product.s

│   ├── tb\_accelerator\_regs.s

│   ├── tb\_dot\_product.s

│   └── tb\_mnist\_tile.s

│

├── tests/

│   └── test\_inference.py

│

├── docs/

│   └── architecture.md

│

├── models/

│   └── ...

│

├── data/

│   └── ...

│

├── README.md

└── .gitignore



Generated binaries, Python caches, virtual environments, and local datasets/models are excluded using .gitignore where appropriate.



19\. Tools and Technologies

Software

Python

NumPy

Pytest

Embedded C

Hardware Description

SystemVerilog

Icarus Verilog

Development Environment

Windows

MSYS2 UCRT64

GitHub Desktop

Machine Learning

MNIST

NumPy-based training

INT8 quantization

Integer inference

20\. Quick Start



Clone the repository:



git clone https://github.com/NGAURAV951/edge-ai-riscv-vision.git



Enter the project:



cd edge-ai-riscv-vision



Create the Python environment:



py -m venv .venv



Activate it in MSYS2:



source .venv/Scripts/activate



Install dependencies:



py -m pip install "numpy<3,>=1.26" "pytest<9,>=8"



Run the Python tests:



py -m pytest -q

21\. Run the Edge-AI Demo



Run:



py -m edge\_ai.demo



Expected output is similar to:



=== Edge-AI RISC-V Vision MVP ===

class:      ALERT

confidence: 0.639

features:   \[31, 12, 127]

latency:    0.0322 ms

throughput: 31095.9 FPS



Exact latency and throughput can vary between systems.



22\. Run Tiled MNIST Verification



Run:



py -m ai.mnist\_tiled\_reference



Expected:



Reference dot product: 343

Tiled dot product:     343

Tiles:                 49



TILED\_REFERENCE\_PASS



Run the tiled MNIST inference:



py -m ai.mnist\_tiled\_inference



The implementation uses:



784 input values

49 tiles

16 values per tile

10 output classes

23\. RTL Simulation



The RTL can be simulated using Icarus Verilog.



Compile the dot-product accelerator:



iverilog -g2012 -o dot\_product\_sim rtl/dot\_product.s rtl/tb\_dot\_product.s



Run:



vvp dot\_product\_sim



The testbench verifies:



Signed arithmetic

16-element dot product

16-cycle MAC latency



Generated simulation binaries should not be committed to the repository.



24\. Register Interface Simulation



Compile:



iverilog -g2012 -o accelerator\_regs\_sim rtl/dot\_product.s rtl/accelerator\_regs.s rtl/tb\_accelerator\_regs.s



Run:



vvp accelerator\_regs\_sim



The register testbench verifies:



Register writes

Accelerator start

Busy state

Done state

Result registers

Signed result

Start-to-completion latency



Expected verification includes:



STATUS\_PASS

RESULT\_PASS

REGISTER\_LATENCY\_PASS

25\. Design Decisions

Why INT8?



INT8 arithmetic reduces the data width compared with floating-point inference and is commonly useful for resource-constrained embedded inference.



Why 16-Element Tiles?



A 16-element tile provides a simple hardware structure that maps naturally to a sequential MAC accelerator while allowing the 784-element MNIST computation to be divided into manageable blocks.



784 / 16 = 49 tiles

Why a Sequential MAC?



A sequential MAC structure is relatively simple to understand, simulate, verify, and later map to FPGA hardware.



It also provides a clear baseline for future comparisons against more parallel accelerator architectures.



Why Memory-Mapped Registers?



Memory-mapped control provides a straightforward software/hardware interface that can later be connected to a processor bus such as a RISC-V-based system.



26\. Current Limitations



This version has several deliberate limitations.



No Physical FPGA Implementation Yet



The RTL has been verified through simulation, but it has not yet been synthesized and deployed to a physical FPGA board.



No Physical RISC-V CPU Integration Yet



The RISC-V component is currently part of the planned hardware architecture rather than a completed processor implementation.



C Driver Is Currently a Software Model



The C driver demonstrates the control and register concepts but is not yet connected to physical hardware.



INT8 Accuracy Evaluation



The reported 94% INT8 result is based on a 100-image spot check.



A complete test-set evaluation and improved quantization calibration are future improvements.



27\. Future Hardware Roadmap



The next development stages are:



Current

&#x20; |

&#x20; v

Python INT8 inference

&#x20; |

&#x20; v

Verified 16-element RTL accelerator

&#x20; |

&#x20; v

Verified memory-mapped register interface

&#x20; |

&#x20; v

RTL synthesis

&#x20; |

&#x20; v

FPGA implementation

&#x20; |

&#x20; v

RISC-V CPU integration

&#x20; |

&#x20; v

Memory-mapped hardware accelerator

&#x20; |

&#x20; v

On-device inference benchmark

Future Work

FPGA synthesis

LUT / FF / DSP utilization analysis

Timing analysis

Clock-frequency measurement

RISC-V processor integration

AXI/APB/Wishbone-style bus integration

DMA-based data movement

More parallel MAC units

Pipeline optimization

Hardware/software latency comparison

Power estimation

Full MNIST test-set evaluation

Improved INT8 quantization

28\. Benchmarking Plan



Once the accelerator is implemented on FPGA hardware, the following metrics will be measured:



Metric	Current Status

Python inference	Verified

INT8 inference	Verified

Tiled inference	Verified

RTL functional simulation	Verified

Register-interface simulation	Verified

RTL synthesis	Future

FPGA clock frequency	Future

LUT utilization	Future

FF utilization	Future

DSP utilization	Future

FPGA power	Future

Hardware/software speedup	Future



No FPGA performance numbers are claimed until the hardware implementation is actually synthesized and measured.



29\. Engineering Highlights



This project demonstrates practical experience with:



Quantized machine learning

INT8 arithmetic

Embedded C

SystemVerilog RTL

Multiply-accumulate datapaths

Signed arithmetic

Memory-mapped register interfaces

Hardware/software co-design

Simulation-based verification

Automated Python testing

Tiled numerical computation

Edge AI concepts

30\. Project Verification Summary



The current implementation has been verified at multiple levels.



Python test suite

8 tests passed



Tiled dot product

TILED\_REFERENCE\_PASS



Full score comparison

FULL\_SCORE\_PASS



Prediction comparison

PREDICTION\_MATCH\_PASS



INT8 MNIST spot check

94/100



Signed RTL dot product

SIGNED\_DOT\_PRODUCT\_PASS



RTL latency

16 MAC cycles



MNIST RTL tile

MNIST\_TILE\_PASS



Register interface

STATUS\_PASS

RESULT\_PASS

REGISTER\_LATENCY\_PASS

31\. Resume Project Description

Short Version



Hardware-aware Edge AI vision system using INT8 quantized inference, embedded C, and SystemVerilog RTL acceleration. Implemented a 16-element signed INT8 MAC accelerator, memory-mapped register interface, 49-tile MNIST inference pipeline, and multi-level Python/RTL verification.



Technical Version



Developed a hardware-aware Edge AI inference pipeline with INT8 quantization and 16-element tiled dot-product acceleration. Implemented SystemVerilog RTL with signed INT8 MAC operations, 32-bit accumulation, memory-mapped control/status registers, and simulation-based verification, with Python reference models and automated tests for software/RTL numerical consistency.



32\. License



This project is released under the MIT License.



See LICENSE for details.



Hardware Status



This repository intentionally distinguishes between implemented and planned components.



Currently Implemented and Verified

Working Python inference

INT8 inference

Tiled computation

SystemVerilog RTL

RTL testbenches

Register-interface simulation

C driver modeling

Automated verification

Future Implementation Targets

Physical FPGA deployment

RISC-V processor integration

Physical memory-mapped hardware connection

FPGA resource and power measurements



The documentation reflects the current verified implementation and separates it from future hardware targets.





This version is the one I would use as your \*\*GitHub-facing README\*\*. It keeps the architecture prominent and removes the internal “what you should do next” text that was accidentally included in the uploaded version. :contentReference\[oaicite:1]{index=1}

give me this all in notepad



Done. I created the complete README as a Notepad .txt file.



Download README.txt



Open it in Notepad, copy the entire content, and paste it into your GitHub repository's README.md file. 



README.txt

Document

You’re out of data analysis for now. Start a free Plus trial for more, or try again tomorrow after 9:50 PM.

Try Plus free



README.txt

Edge-AI RISC-V Vision System

&#x20;   16 MAC cycles





&#x20;   MNIST RTL tile

&#x20;   MNIST\_TILE\_PASS





&#x20;   Register interface

&#x20;   STATUS\_PASS

&#x20;   RESULT\_PASS

&#x20;   REGISTER\_LATENCY\_PASS





\------------------------------------------------------------------------





31\. Resume Project Description





Short Version





&#x20; Hardware-aware Edge AI vision system using INT8 quantized inference,

&#x20; embedded C, and SystemVerilog RTL acceleration. Implemented a

&#x20; 16-element signed INT8 MAC accelerator, memory-mapped register

&#x20; interface, 49-tile MNIST inference pipeline, and multi-level

&#x20; Python/RTL verification.





Technical Version





&#x20; Developed a hardware-aware Edge AI inference pipeline with INT8

&#x20; quantization and 16-element tiled dot-product acceleration.

&#x20; Implemented SystemVerilog RTL with signed INT8 MAC operations, 32-bit

&#x20; accumulation, memory-mapped control/status registers, and

&#x20; simulation-based verification, with Python reference models and

&#x20; automated tests for software/RTL numerical consistency.





\------------------------------------------------------------------------





32\. License





This project is released under the MIT License.





See LICENSE for details.





\------------------------------------------------------------------------





Hardware Status





This repository intentionally distinguishes between implemented and

planned components.





Currently Implemented and Verified





\-   Working Python inference

\-   INT8 inference

\-   Tiled computation

\-   SystemVerilog RTL

\-   RTL testbenches

\-   Register-interface simulation

\-   C driver modeling

\-   Automated verification





Future Implementation Targets





\-   Physical FPGA deployment

\-   RISC-V processor integration

\-   Physical memory-mapped hardware connection

\-   FPGA resource and power measurements





The documentation reflects the current verified implementation and

separates it from future hardware targets.





