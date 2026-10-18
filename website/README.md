# Edge AI Lab website

A clean, responsive website for the Edge-AI RISC-V Vision engineering prototype. It includes a synthetic signal explorer, an architecture walkthrough, and links to automated RTL regression results. The visual design intentionally stays restrained and readable instead of relying on heavy neon effects.

## Run the Python-backed demo locally

From the repository root, install the requirements and start the local server:

~~~powershell
py -m pip install -r requirements.txt
py -m website.server
~~~

Open http://127.0.0.1:8000. The local server serves the website and exposes a small API at \`/api/demo\`. This endpoint calls the project's Python \`EdgeClassifier\`, checks the reference/accelerator-style score match, and measures software inference timing on the current computer.

The server binds only to \`127.0.0.1\`; it is not exposed to other devices on your network. Stop it with Ctrl+C.

## Publish the hosted website

The GitHub Actions workflow publishes \`website/public\` to GitHub Pages. If Pages has not been enabled for this repository, complete this one-time setup:

1. Open the repository's **Settings → Pages**.
2. Under **Build and deployment**, choose **GitHub Actions** as the source.
3. Open **Actions → Deploy animated website** and rerun the workflow.

The hosted version is static, so the lab clearly falls back to a browser preview. The real Python classifier and software timing are available when running the local server.

## Accuracy and scope

- Browser-preview output is an illustrative UI fallback; it does not execute the Python model.
- Local API mode runs the actual Python classifier against a generated synthetic frame.
- Local latency and throughput are software measurements, not FPGA timing or power measurements.
- Physical FPGA deployment, board testing, and full RISC-V processor integration are future work.