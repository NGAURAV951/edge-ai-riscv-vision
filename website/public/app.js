(() => {
  "use strict";

  const $ = (selector) => document.querySelector(selector);
  const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  const intensityInput = $("#intensity");
  const intensityOutput = $("#intensity-output");
  const runButton = $("#run-inference");
  const runLabel = $("#run-label");
  const signalCanvas = $("#signal-canvas");
  const signalContext = signalCanvas ? signalCanvas.getContext("2d") : null;
  const toast = $("#toast");

  let seed = 7;
  let runCount = 0;
  let isRunning = false;
  let toastTimer = null;

  const clamp = (value, min, max) => Math.min(max, Math.max(min, value));

  function showToast(message) {
    if (!toast) return;
    toast.textContent = message;
    toast.classList.add("visible");
    window.clearTimeout(toastTimer);
    toastTimer = window.setTimeout(() => toast.classList.remove("visible"), 3200);
  }

  function setRangeProgress() {
    const value = Number(intensityInput.value);
    const min = Number(intensityInput.min);
    const max = Number(intensityInput.max);
    const percent = ((value - min) / (max - min)) * 100;
    intensityInput.style.background =
      "linear-gradient(90deg, var(--cyan) 0%, var(--lime) " +
      percent + "%, #2a314b " + percent + "%, #2a314b 100%)";
    const label = value.toFixed(2) + "×";
    intensityOutput.textContent = label;
    $("#signal-level").textContent = "INTENSITY " + label;
  }

  // A deterministic 32x32 synthetic frame, rendered at native pixel scale.
  // The Python endpoint is authoritative in local-server mode; this canvas is a UI preview.
  function drawSignal(frameSeed = seed, intensity = Number(intensityInput.value)) {
    if (!signalContext) return;
    const cell = 10;
    const frame = signalContext;
    frame.clearRect(0, 0, signalCanvas.width, signalCanvas.height);
    let state = (frameSeed >>> 0) || 7;
    const next = () => {
      state ^= state << 13;
      state ^= state >>> 17;
      state ^= state << 5;
      return (state >>> 0) / 4294967295;
    };
    for (let y = 0; y < 32; y += 1) {
      for (let x = 0; x < 32; x += 1) {
        let value = 9 + next() * 22;
        const isObject = x >= 12 && x < 20 && y >= 8 && y < 24;
        if (isObject) value += 92 + next() * 38;
        value = clamp(Math.round(value * intensity), 2, 255);
        const r = Math.round(value * 0.73);
        const g = Math.round(value * 0.98);
        const b = Math.round(value * 0.92 + 5);
        frame.fillStyle = "rgb(" + r + "," + g + "," + b + ")";
        frame.fillRect(x * cell, y * cell, cell - 1, cell - 1);
      }
    }
    // Bright object outline gives the synthetic frame a readable visual focus.
    const outline = clamp(Math.round(92 * intensity), 20, 255);
    frame.strokeStyle = "rgba(217,255,112," + Math.min(.85, outline / 300) + ")";
    frame.lineWidth = 1;
    frame.strokeRect(12 * cell + .5, 8 * cell + .5, 8 * cell - 1, 16 * cell - 1);
  }

  function fallbackInference(brightness) {
    // Transparent browser-only approximation of the demo's linear classifier.
    // It does not run the project Python code or claim measured latency.
    const mean = Math.round(clamp(31 * brightness, 0, 255));
    const active = Math.round(clamp(12 * brightness, 0, 100));
    const peak = Math.round(clamp(127 * brightness, 0, 255));
    const score = mean * 3 + active * 5 + peak * 2 - 350;
    const confidence = 1 / (1 + Math.exp(-score / 100));
    return {
      mode: "browser-preview",
      label: score >= 0 ? "ALERT" : "SAFE",
      confidence,
      features: [mean, active, peak],
      score,
      latency_ms: null,
      fps: null,
      seed,
      brightness,
      accelerator_match: null,
      note: "Browser preview only. Start the local Python server for real model inference and software timing."
    };
  }

  function updateFeature(index, value) {
    const ids = [
      ["#feature-mean", "#meter-mean", 255],
      ["#feature-active", "#meter-active", 100],
      ["#feature-peak", "#meter-peak", 255]
    ];
    const [textSelector, meterSelector, max] = ids[index];
    $(textSelector).textContent = String(value);
    $(meterSelector).style.width = clamp((Number(value) / max) * 100, 2, 100) + "%";
  }

  function renderResult(data) {
    const isLocal = data.mode === "python-api";
    const confidence = clamp(Number(data.confidence) * 100, 0, 100);
    const isAlert = data.label === "ALERT";

    $("#connection-label").textContent = isLocal ? "LOCAL PYTHON API" : "PREVIEW MODE";
    $("#console-mode").textContent = isLocal ? "PYTHON API CONNECTED" : "BROWSER PREVIEW";
    $("#prediction-class").textContent = data.label;
    $("#prediction-class").classList.toggle("alert-class", isAlert);
    $("#prediction-class").classList.toggle("safe-class", !isAlert);
    $("#prediction-symbol").textContent = isAlert ? "↗" : "✓";
    $("#prediction-symbol").classList.toggle("safe-symbol", !isAlert);
    $("#confidence-value").textContent = confidence.toFixed(1) + "%";
    $("#confidence-bar").style.width = confidence.toFixed(1) + "%";
    $("#result-description").textContent = isAlert
      ? "Signal signature crossed the current classifier threshold."
      : "Signal signature remains below the current classifier threshold.";
    (data.features || [0, 0, 0]).forEach((value, index) => updateFeature(index, value));
    $("#latency-value").innerHTML = isLocal
      ? Number(data.latency_ms).toFixed(4) + ' <small>ms</small>'
      : '— <small>ms</small>';
    $("#fps-value").innerHTML = isLocal
      ? Number(data.fps).toLocaleString(undefined, { maximumFractionDigits: 0 }) + ' <small>FPS</small>'
      : '— <small>FPS</small>';
    $("#seed-display").textContent = String(data.seed ?? seed).padStart(4, "0");
    $("#prediction-id").textContent = "RUN #" + String(runCount).padStart(3, "0");
    $("#last-run").textContent = "LAST RUN / " + new Date().toLocaleTimeString([], {
      hour: "2-digit", minute: "2-digit", second: "2-digit"
    });
    $("#result-note").textContent = isLocal
      ? (data.note || "Latency and throughput measured by the local Python benchmark; not FPGA measurements.")
      : (data.note || "Preview mode: start the local Python server for real model timing.");
    $("#signal-canvas").setAttribute("aria-label",
      "Synthetic grayscale frame. Current browser display intensity is " +
      Number(data.brightness ?? intensityInput.value).toFixed(2) + " times.");
    document.querySelector(".output-live").innerHTML =
      '<i></i> ' + (isLocal ? "PYTHON RESULT" : "PREVIEW RESULT");
  }

  async function runInference() {
    if (isRunning) return;
    isRunning = true;
    runButton.disabled = true;
    runLabel.textContent = "Processing signal…";
    runButton.classList.add("is-running");
    $(".signal-visual").classList.add("is-processing");
    runCount += 1;
    const brightness = Number(intensityInput.value);
    drawSignal(seed, brightness);
    let result;

    try {
      const query = new URLSearchParams({
        brightness: String(brightness),
        seed: String(seed)
      });
      const response = await fetch("/api/demo?" + query.toString(), {
        method: "GET",
        cache: "no-store",
        headers: { "Accept": "application/json" }
      });
      if (!response.ok) throw new Error("Local inference API unavailable");
      const payload = await response.json();
      if (payload.mode !== "python-api" || !Array.isArray(payload.features)) {
        throw new Error("Unexpected demo API response");
      }
      result = payload;
    } catch (_) {
      result = fallbackInference(brightness);
    }

    renderResult(result);
    if (result.mode === "python-api" && result.accelerator_match === false) {
      showToast("Check the model/reference score comparison before using this result.");
    }
    runButton.disabled = false;
    runLabel.textContent = "Run inference";
    runButton.classList.remove("is-running");
    $(".signal-visual").classList.remove("is-processing");
    isRunning = false;
  }

  function generateFrame() {
    seed = Math.floor(Math.random() * 9000) + 1000;
    $("#seed-display").textContent = String(seed).padStart(4, "0");
    drawSignal(seed);
    showToast("Synthetic frame regenerated. Run inference to evaluate it.");
  }

  if (intensityInput) {
    intensityInput.addEventListener("input", () => {
      setRangeProgress();
      drawSignal(seed, Number(intensityInput.value));
    });
  }
  if (runButton) runButton.addEventListener("click", runInference);
  $("#new-frame")?.addEventListener("click", generateFrame);

  // Mobile navigation.
  const menuToggle = $("#menu-toggle");
  const nav = $(".main-nav");
  if (menuToggle && nav) {
    menuToggle.addEventListener("click", () => {
      const expanded = menuToggle.getAttribute("aria-expanded") === "true";
      menuToggle.setAttribute("aria-expanded", String(!expanded));
      nav.classList.toggle("open", !expanded);
      menuToggle.setAttribute("aria-label", expanded ? "Open navigation" : "Close navigation");
    });
    nav.querySelectorAll("a").forEach((link) => link.addEventListener("click", () => {
      nav.classList.remove("open");
      menuToggle.setAttribute("aria-expanded", "false");
      menuToggle.setAttribute("aria-label", "Open navigation");
    }));
  }

  // Scroll progress bar.
  const progress = $("#scroll-progress");
  function updateScrollProgress() {
    const scrollable = document.documentElement.scrollHeight - window.innerHeight;
    const amount = scrollable > 0 ? (window.scrollY / scrollable) * 100 : 0;
    if (progress) progress.style.width = clamp(amount, 0, 100) + "%";
  }
  window.addEventListener("scroll", updateScrollProgress, { passive: true });
  updateScrollProgress();

  // Reveal elements only as they enter the viewport.
  const revealElements = document.querySelectorAll(".reveal");
  if ("IntersectionObserver" in window && !reduceMotion) {
    const revealObserver = new IntersectionObserver((entries, observer) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add("is-visible");
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.12, rootMargin: "0px 0px -35px 0px" });
    revealElements.forEach((element) => revealObserver.observe(element));
  } else {
    revealElements.forEach((element) => element.classList.add("is-visible"));
  }

  // Subtle cursor tilt on large-screen cards. It stays disabled on touch and reduced-motion devices.
  if (!reduceMotion && window.matchMedia("(pointer:fine)").matches) {
    document.querySelectorAll(".arch-node, .validation-card").forEach((card) => {
      card.addEventListener("pointermove", (event) => {
        const rect = card.getBoundingClientRect();
        const x = (event.clientX - rect.left) / rect.width - 0.5;
        const y = (event.clientY - rect.top) / rect.height - 0.5;
        card.style.transform = "perspective(800px) rotateX(" + (-y * 2.3).toFixed(2) +
          "deg) rotateY(" + (x * 2.8).toFixed(2) + "deg) translateY(-3px)";
      });
      card.addEventListener("pointerleave", () => { card.style.transform = ""; });
    });
  }

  // Background particle network is decorative and automatically quiets for reduced-motion users.
  const particleCanvas = $("#particle-field");
  const particleContext = particleCanvas ? particleCanvas.getContext("2d") : null;
  if (particleCanvas && particleContext) {
    let points = [];
    let canvasWidth = 0;
    let canvasHeight = 0;
    const makePoints = () => {
      const rect = particleCanvas.getBoundingClientRect();
      const dpr = Math.min(window.devicePixelRatio || 1, 1.5);
      canvasWidth = Math.max(1, rect.width);
      canvasHeight = Math.max(1, rect.height);
      particleCanvas.width = Math.round(canvasWidth * dpr);
      particleCanvas.height = Math.round(canvasHeight * dpr);
      particleContext.setTransform(dpr, 0, 0, dpr, 0, 0);
      const count = Math.min(62, Math.max(20, Math.floor(canvasWidth / 17)));
      points = Array.from({ length: count }, () => ({
        x: Math.random() * canvasWidth,
        y: Math.random() * canvasHeight,
        vx: (Math.random() - .5) * .16,
        vy: (Math.random() - .5) * .16,
        r: Math.random() * 1.4 + .4
      }));
      drawParticles(false);
    };
    const drawParticles = (move = true) => {
      if (!particleContext) return;
      particleContext.clearRect(0, 0, canvasWidth, canvasHeight);
      points.forEach((point, i) => {
        if (move && !reduceMotion) {
          point.x += point.vx;
          point.y += point.vy;
          if (point.x < 0 || point.x > canvasWidth) point.vx *= -1;
          if (point.y < 0 || point.y > canvasHeight) point.vy *= -1;
        }
        particleContext.beginPath();
        particleContext.arc(point.x, point.y, point.r, 0, Math.PI * 2);
        particleContext.fillStyle = i % 5 === 0 ? "rgba(217,255,112,.62)" : "rgba(98,245,230,.38)";
        particleContext.fill();
        for (let j = i + 1; j < points.length; j += 1) {
          const next = points[j];
          const dx = next.x - point.x;
          const dy = next.y - point.y;
          const distance = Math.sqrt(dx * dx + dy * dy);
          if (distance < 105) {
            particleContext.beginPath();
            particleContext.moveTo(point.x, point.y);
            particleContext.lineTo(next.x, next.y);
            particleContext.strokeStyle = "rgba(122,154,224," + ((1 - distance / 105) * .11) + ")";
            particleContext.lineWidth = .6;
            particleContext.stroke();
          }
        }
      });
      if (move && !reduceMotion) window.requestAnimationFrame(() => drawParticles(true));
    };
    if ("IntersectionObserver" in window) {
      const canvasObserver = new IntersectionObserver((entries) => {
        if (entries.some((entry) => entry.isIntersecting)) drawParticles(true);
      });
      canvasObserver.observe(particleCanvas);
    } else {
      makePoints();
      drawParticles(true);
    }
    makePoints();
    if (reduceMotion) drawParticles(false);
  }

  setRangeProgress();
  drawSignal(seed, Number(intensityInput?.value || 1));
  // Automatically tries the local Python API; hosted static pages fall back to preview mode.
  window.setTimeout(runInference, 650);
})();
