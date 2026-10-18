"""Serve the static dashboard and the real Python inference demo.

Run from the repository root with: py -m website.server
The server binds to 127.0.0.1 only and does not expose itself to your network.
"""
from __future__ import annotations

import json
import sys
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlparse

import numpy as np

REPOSITORY_ROOT = Path(__file__).resolve().parent.parent
STATIC_ROOT = Path(__file__).resolve().parent / "public"
if str(REPOSITORY_ROOT) not in sys.path:
    sys.path.insert(0, str(REPOSITORY_ROOT))

from ai.dataset import make_demo_frame
from ai.inference import EdgeClassifier
from ai.benchmark import benchmark

HOST = "127.0.0.1"
PORT = 8000


class DashboardHandler(SimpleHTTPRequestHandler):
    """Static-file handler with a small JSON API for real local inference."""

    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(STATIC_ROOT), **kwargs)

    def log_message(self, fmt: str, *args) -> None:
        print("[edge-ai-web] " + (fmt % args))

    def send_json(self, payload: dict, status: int = 200) -> None:
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self) -> None:
        route = urlparse(self.path)
        if route.path == "/api/health":
            self.send_json({"ok": True, "mode": "python-api"})
            return
        if route.path == "/api/demo":
            self.handle_demo(parse_qs(route.query))
            return
        if route.path.startswith("/api/"):
            self.send_json({"error": "Unknown API endpoint"}, status=404)
            return
        super().do_GET()

    def handle_demo(self, query: dict[str, list[str]]) -> None:
        try:
            brightness = float(query.get("brightness", ["1.0"])[0])
            seed = int(query.get("seed", ["7"])[0])
            if not 0.25 <= brightness <= 1.75:
                raise ValueError("Brightness must be between 0.25 and 1.75.")
            if not 0 <= seed <= 999999:
                raise ValueError("Seed must be between 0 and 999999.")
        except (TypeError, ValueError) as exc:
            self.send_json({"error": str(exc)}, status=400)
            return

        frame = make_demo_frame(seed=seed)
        frame = np.clip(frame.astype(np.float32) * brightness, 0, 255).astype(np.uint8)
        model = EdgeClassifier()
        result = model.predict(frame)
        score, _ = model.score(frame)
        accelerator_score, _ = model.accelerator_score(frame)
        stats = benchmark(model, frame, repeats=500)

        self.send_json({
            "mode": "python-api",
            "label": result.label,
            "confidence": round(result.confidence, 4),
            "features": [int(value) for value in result.features.tolist()],
            "score": int(score),
            "latency_ms": round(float(stats["mean_ms"]), 5),
            "fps": round(float(stats["fps"]), 1),
            "benchmark_repeats": int(stats["repeats"]),
            "seed": seed,
            "brightness": brightness,
            "accelerator_match": int(score) == int(accelerator_score),
            "note": "Software benchmark on this computer; not an FPGA measurement."
        })


def main() -> None:
    if not STATIC_ROOT.is_dir():
        raise SystemExit(f"Website files were not found: {STATIC_ROOT}")
    server = ThreadingHTTPServer((HOST, PORT), DashboardHandler)
    print()
    print("  EDGE//AI — interactive dashboard")
    print(f"  Open: http://{HOST}:{PORT}")
    print("  API:  local Python inference + software benchmark")
    print("  Stop the server with Ctrl+C.")
    print()
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopping the Edge-AI dashboard...")
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
