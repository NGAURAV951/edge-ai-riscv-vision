# Edge-AI RISC-V Vision System

A portfolio-grade embedded AI project combining computer vision, quantized inference, embedded C, RISC-V concepts, RTL acceleration, and benchmarking.

> Current milestone: hardware-optional MVP. The software demo runs on a normal PC; the repository also contains the RTL, firmware, and FPGA/RISC-V integration path.

## Project goal

Build an edge device that analyzes camera frames locally and produces a safety decision without sending raw video to a cloud service.

Example use case: industrial safety monitoring.

```text
Camera / Image
      |
      v
Pre-processing
      |
      v
Quantized ML inference
      |
      +----> Decision / Alert
      |
      v
RISC-V / Accelerator interface
      |
      v
Firmware + telemetry
```

## Implemented

- Python reference inference pipeline
- Deterministic synthetic frame generator
- Lightweight quantized classifier
- Latency and throughput benchmark
- Unit tests
- Portable C firmware-style inference
- Verilog 8-bit signed dot-product accelerator
- RTL testbench
- Hardware/RISC-V roadmap

## Quick start

Requirements: Python 3.10+ and Git. Optional: Icarus Verilog.

```bash
git clone https://github.com/YOUR_USERNAME/edge-ai-riscv-vision.git
cd edge-ai-riscv-vision
python -m venv .venv
```

Windows:
```bash
.venv\Scripts\activate
```

Linux/macOS:
```bash
source .venv/bin/activate
```

Then:

```bash
pip install -r requirements.txt
python -m edge_ai.demo
pytest -q
```

## RTL simulation

With Icarus Verilog:

```bash
mkdir -p build
iverilog -g2012 -o build/dot_product_tb rtl/dot_product.s rtl/tb_dot_product.s
vvp build/dot_product_tb
```

Expected:
```text
DOT_PRODUCT_PASS
```

## Repository

```text
edge-ai-riscv-vision/
├── ai/
│   ├── dataset.py
│   ├── inference.py
│   └── benchmark.py
├── edge_ai/
│   └── demo.py
├── firmware/
│   └── inference_stub.c
├── rtl/
│   ├── dot_product.s
│   └── tb_dot_product.s
├── tests/
│   └── test_inference.py
├── docs/
│   ├── architecture.md
│   └── roadmap.md
├── requirements.txt
├── .gitignore
├── LICENSE
└── README.md
```

## Technical highlights

The reference pipeline uses compact numerical features and integer weights so the algorithm is straightforward to port to a microcontroller or hardware accelerator.

The RTL module implements an 8-bit signed vector dot product, a fundamental multiply-accumulate primitive used in neural-network layers.

The C implementation demonstrates fixed-width integer arithmetic suitable for embedded firmware.

## Hardware roadmap

### Milestone 1 — Software MVP
- [x] Reproducible frames
- [x] Quantized inference
- [x] Benchmark
- [x] Unit tests
- [x] RTL unit simulation

### Milestone 2 — FPGA
- [ ] Connect RTL accelerator to an FPGA bus
- [ ] Add UART telemetry
- [ ] Measure LUT/FF/DSP utilization
- [ ] Measure clock frequency

### Milestone 3 — RISC-V
- [ ] Integrate accelerator as a memory-mapped peripheral
- [ ] Run firmware on a RISC-V soft core
- [ ] Add interrupt support
- [ ] Compare software vs hardware inference

### Milestone 4 — Camera
- [ ] Connect camera sensor
- [ ] Add real frame capture
- [ ] Calibrate preprocessing
- [ ] Measure end-to-end latency

## Benchmarking

The project reports inference latency, FPS, classification output, and repeatability.

When hardware is available, add FPGA clock frequency, resource utilization, power, and measured hardware-vs-software speedup.

Do not claim hardware performance until it has been measured on the actual board.

## Resume description

**Edge-AI RISC-V Vision System — Embedded AI / FPGA / RTL**

> Developed a hardware-aware edge-AI vision pipeline with quantized inference, fixed-point embedded C, and an 8-bit RTL dot-product accelerator; added reproducible benchmarking, unit tests, and a software/RTL co-design architecture for future RISC-V FPGA integration.

## Interview topics

C/C++, Python, fixed-width arithmetic, RTL, digital logic, computer architecture, RISC-V concepts, embedded systems, quantization, computer-vision pipelines, hardware/software co-design, benchmarking, and Git.

## License

MIT
