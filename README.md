# Edge-AI RISC-V Vision System

[![RTL Regression](https://github.com/NGAURAV951/edge-ai-riscv-vision/actions/workflows/rtl-regression.yml/badge.svg?branch=main)](https://github.com/NGAURAV951/edge-ai-riscv-vision/actions/workflows/rtl-regression.yml) [![Yosys Synthesis](https://github.com/NGAURAV951/edge-ai-riscv-vision/actions/workflows/yosys-synthesis.yml/badge.svg?branch=main)](https://github.com/NGAURAV951/edge-ai-riscv-vision/actions/workflows/yosys-synthesis.yml)

A hardware-aware Edge AI project exploring INT8 inference, tiled dot-product computation, embedded C driver modeling, and a SystemVerilog accelerator with a memory-mapped register interface.

The project combines a Python software reference pipeline with simulation-based RTL verification. It is a simulation-first prototype: **physical FPGA deployment and RISC-V processor integration are future work**, not completed features.

## Project status

**Current status: Python/software and RTL simulation prototype**

Implemented areas include:
- Python demo inference and feature extraction
- INT8 MNIST inference and tiled numerical reference code
- 16-element signed INT8 dot-product RTL with a 32-bit accumulator
- Memory-mapped control/status and result-register interface
- Embedded C driver model
- Python tests and SystemVerilog testbenches

Not yet implemented:
- Physical FPGA deployment or measured FPGA performance
- Integration with a physical RISC-V processor
- A physical bus connection between the C driver and RTL hardware

## Architecture

~~~text
             Input image / feature vector
                         |
                         v
             Python inference pipeline
                         |
                         v
              INT8 / integer computation
                         |
                         v
            784 values split into 49 tiles
                  (16 values per tile)
                         |
                         v
          16-element signed INT8 RTL MAC
                         |
                         v
          Memory-mapped control/status model
                         |
                         v
                Result / verification
~~~

The Python tiled reference checks that splitting a 784-element dot product into 49 tiles of 16 values produces the same result as a direct reference calculation. The RTL testbenches independently verify the hardware datapath and register interface in simulation; they do not establish physical hardware integration.

## Key design details

| Component | Description |
|---|---|
| Input shape for MNIST | 28 × 28 pixels = 784 values |
| Tile size | 16 elements |
| Tiles per 784-element vector | 49 |
| RTL arithmetic | Signed 8-bit operands read from packed byte vectors |
| Accumulator | Signed 32-bit |
| MAC architecture | Sequential, one element per clock while busy |
| Register interface | Vector A, vector B, control, status, and result bytes |
| Hardware validation | Icarus Verilog simulation |

### Register map

| Address | Register | Purpose |
|---|---|---|
| 0x00–0x0F | A[0]–A[15] | Signed 8-bit vector A |
| 0x10–0x1F | B[0]–B[15] | Signed 8-bit vector B |
| 0x20 | CTRL | Write bit 0 as 1 to request a start |
| 0x21 | STATUS | Bit 0 = busy, bit 1 = done |
| 0x22 | RESULT_BYTE_0 | Result bits [7:0] |
| 0x23 | RESULT_BYTE_1 | Result bits [15:8] |
| 0x24 | RESULT_BYTE_2 | Result bits [23:16] |
| 0x25 | RESULT_BYTE_3 | Result bits [31:24] |

The register interface exposes the complete signed 32-bit accumulator result across four byte-wide registers. Software should combine the bytes in little-endian order (0x22 is the least-significant byte).

## Verification

The project includes multiple independent checks:
- Python unit tests for demo inference and accelerator/reference score matching
- A tiled dot-product comparison against NumPy
- 105 RTL dot-product cases: five directed edge cases and 100 deterministic pseudo-random input-vector tests
- Comparison of tiled and non-tiled MNIST predictions
- RTL testbenches for signed dot-product arithmetic and latency
- Optional Yosys generic synthesis/statistics report generated in CI
- RTL testbench for register writes, status, and all four result bytes
- Full 32-bit signed-result readback check
- A C driver-model test for register-control concepts

Representative simulation markers include:

~~~text
TILED_REFERENCE_PASS
SIGNED_DOT_PRODUCT_PASS
LATENCY_PASS
STATUS_PASS
RESULT_PASS
REGISTER_LATENCY_PASS
FULL_32BIT_RESULT_PASS
ALL_REGISTER_TESTS_PASS
~~~

The signed 16-element RTL test uses the vectors A = [1, -2, 3, -4, ..., 15, -16] and B = [1, 2, 3, 4, ..., 15, 16], with an expected dot product of **-136**. The register-interface test verifies the full result as **0xFFFFFF78** (signed **-136**), confirms status **0x02** (done=1, busy=0), and checks a measured completion latency of **17 cycles** in simulation.

The MNIST accuracy figure previously recorded for this project is **94/100 (94%) on a 100-image spot check**. This is a small spot check, not a full-dataset accuracy claim. Reproduce MNIST checks only when the required dataset is available locally.

## Repository layout

~~~text
edge-ai-riscv-vision/
├── ai/          # Inference, quantization, and tiled MNIST reference code
├── edge_ai/     # Edge-AI demo package
├── firmware/    # Embedded C driver model and inference stub
├── rtl/         # Dot-product RTL, register interface, and testbenches
├── tests/       # Python tests
├── docs/        # Architecture documentation
├── website/     # Animated dashboard + local inference API
├── android-app/ # Native Kotlin / Jetpack Compose companion app
├── projects/    # Additional project work
├── requirements.txt
├── LICENSE
└── README.md
~~~

The exact files available may evolve as the project develops. Generated simulation binaries, Python caches, virtual environments, and local datasets should not be committed.

## Requirements

- Python 3.10 or later recommended
- NumPy
- pytest
- Icarus Verilog for RTL simulation
- A C compiler for the C driver-model test

The project was developed and tested in a Windows environment using Python, MSYS2 UCRT64 GCC, Icarus Verilog, and GitHub Desktop.

## Quick start: Python

Clone the repository and enter its directory:

~~~bash
git clone https://github.com/NGAURAV951/edge-ai-riscv-vision.git
cd edge-ai-riscv-vision
~~~

Create and activate a virtual environment on Windows PowerShell:

~~~powershell
py -m venv .venv
.\.venv\Scripts\Activate.ps1
~~~

Install dependencies and run the demo:

~~~powershell
py -m pip install -r requirements.txt
py -m edge_ai.demo
~~~

Run the Python tests:

~~~powershell
py -m pytest -q
~~~

**Dataset note:** Two MNIST evaluation tests require the optional local dataset at data/mnist.npz. When it is absent, pytest marks those tests as skipped; add the expected dataset file to run them.

## Android app

A native Kotlin + Jetpack Compose companion app with the animated EDGE//AI visual style, an interactive synthetic signal viewer, a preview prediction panel, architecture details, and a developer credit for Nikhil Gaurav.

- Android source and build instructions: [android-app/README.md](android-app/README.md)
- Automated APK build: [Android app build workflow](https://github.com/NGAURAV951/edge-ai-riscv-vision/actions/workflows/android-app.yml)
- After a successful workflow, download the edge-ai-lab-debug-apk artifact from its run page.

The app currently uses an illustrative on-device preview classifier. It does not yet package the Python inference engine or connect to a physical FPGA; timing and hardware integration are future work.

## Animated website

This repository includes an animated responsive dashboard with an interactive synthetic-signal lab, model output panel, architecture walkthrough, and CI verification view.

Run it locally to connect the interface to the **actual Python classifier** and software benchmark:

~~~powershell
py -m pip install -r requirements.txt
py -m website.server
~~~

Then open http://127.0.0.1:8000. The hosted GitHub Pages version runs as a static preview; local Python timing appears only when using the local server. Follow the website-specific setup notes in [website/README.md](website/README.md).

## Automated RTL regression

Run the complete RTL regression from the repository root in an MSYS2 UCRT64 terminal (or another Bash terminal with Icarus Verilog installed):

~~~bash
bash scripts/run_rtl_regression.sh
~~~

The runner compiles and simulates all three RTL testbenches, including 100 deterministic pseudo-random dot-product cases and five directed edge cases. It checks required success markers, detects failure markers, and exits with a non-zero status if a compile, simulation, or assertion check fails. A watchdog in each testbench also turns a stalled simulation into a clear timeout failure instead of waiting indefinitely.

Generated simulation binaries and logs are written to `build/rtl-regression/`, which is covered by `.gitignore`. The GitHub Actions workflow runs this regression on pushes and pull requests that change RTL or the regression files; it can also be started manually from the Actions tab.

Expected final summary:

~~~text
RTL_REGRESSION_PASS: 3/3 testbenches passed
~~~

## Yosys synthesis statistics

A separate GitHub Actions workflow installs Yosys and attempts a generic synthesis/statistics pass for the register-interface top module. To run it locally:

~~~bash
bash scripts/run_yosys_synthesis.sh
~~~

The report is written to `build/synthesis/yosys-stat.log` and is also uploaded by the workflow as the `yosys-synthesis-report` artifact. These are preliminary generic logic statistics only; they are not FPGA-specific LUT/BRAM/DSP counts, place-and-route timing, power measurements, or proof of physical deployment.

## Run the RTL dot-product test

With Icarus Verilog installed, compile and run the testbench from the repository root:

~~~bash
iverilog -g2012 -o dot_product_sim rtl/dot_product.s rtl/tb_dot_product.s
vvp dot_product_sim
~~~

The testbench checks signed arithmetic and the expected -136 result. The generated dot_product_sim file is a build artifact and should not be committed.

## Run the register-interface test

~~~bash
iverilog -g2012 -o accelerator_regs_sim rtl/dot_product.s rtl/accelerator_regs.s rtl/tb_accelerator_regs.s
vvp accelerator_regs_sim
~~~

This test checks register writes, accelerator start, busy/done status, result reads, and start-to-completion latency.

## Current limitations and future work

Future development could include:
- FPGA-specific synthesis, place-and-route, and timing closure
- Deploying to an FPGA board
- Integrating a RISC-V processor and a real bus interface
- Connecting the software driver to the hardware implementation
- Running a reproducible full MNIST test-set evaluation
- Measuring hardware latency, resource use, and power

No physical FPGA speedup, power, or resource figures are claimed in this version.

## Resume summary

Developed a hardware-aware Edge AI prototype combining INT8 inference, 16-element tiled dot-product computation, embedded C driver modeling, and a SystemVerilog sequential MAC accelerator. Added a memory-mapped register interface and Python/RTL simulation checks for numerical correctness. Physical FPGA deployment and RISC-V integration remain future work.

## License

This project is released under the MIT License. See [LICENSE](LICENSE) for details.

## Author

**Nikhil Gaurav**

GitHub: [@NGAURAV951](https://github.com/NGAURAV951)
