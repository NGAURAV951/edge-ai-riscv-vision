# EDGE//AI — Animated dashboard

A responsive dark-neon dashboard for the Edge-AI RISC-V Vision prototype. The site includes animated chip artwork, responsive navigation, a synthetic signal viewer, an interactive prediction panel, the system architecture, and links to the project's verification workflows.

## Run the real Python inference locally

From the repository root, create/activate the existing virtual environment if necessary and install the project requirements:

~~~powershell
py -m pip install -r requirements.txt
py -m website.server
~~~

Open http://127.0.0.1:8000. The local server serves the static site and exposes a small API at /api/demo. The API calls the project's existing EdgeClassifier, compares its reference and accelerator-style scores, and measures software inference timing on the current computer.

Stop the server with Ctrl+C. It binds only to 127.0.0.1 and is not exposed to other devices on your network.

## Hosted preview

The Deploy animated website GitHub Actions workflow publishes website/public to GitHub Pages. The hosted version is static, so the interactive lab clearly falls back to browser preview mode; local Python timing is shown only when the local API is reachable.

If the workflow cannot enable Pages automatically, open the repository Settings → Pages and set the build/deployment source to GitHub Actions. Then open the Actions tab and rerun Deploy animated website.

## Accuracy and scope notes

- Browser preview mode is an illustrative UI fallback and is not execution of the Python model.
- Local API mode runs the actual Python classifier against a generated synthetic frame.
- Any timing and FPS shown by the local API are software measurements on the user's computer, not FPGA timings.
- The website does not claim physical FPGA deployment, measured power use, or completed RISC-V processor integration.
