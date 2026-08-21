# DAL Determination — Draft

> **Draft. Non-binding.** This is an illustrative rationale for a webinar/demonstration case study, not a certification artifact. Actual Design Assurance Level (DAL) assignment is a formal, project-specific safety-assessment activity (functional hazard assessment, PSSA, etc. under ARP4754A/ARP4761) performed by qualified engineers with system-level context this repository does not have (aircraft installation, failure-effect analysis, redundancy/monitoring architecture, etc.).

## Illustrative scope

`uav_altitude_hold` is a single discrete-time altitude-hold control law for a small UAV: it computes a throttle command from commanded/measured altitude, measured vertical rate, and a sensor-valid flag, with explicit input-validity gating and a safe hover fallback.

## Illustrative rationale (for discussion only)

A loss-of-control or erroneous-throttle-command failure mode from this function, in isolation, on a small UAV without passengers, would plausibly be classified as **Major** to **Hazardous** depending on the platform's operational context (populated areas, BVLOS, etc.) — suggesting an illustrative target of **DAL C** for this case study, consistent with the repository's own top-level disclaimer that none of this constitutes certification evidence.

Factors a real DAL determination would need that this repository does not establish:
- The aircraft-level Functional Hazard Assessment and the actual failure effect of this function's malfunction or loss, in the context of the full flight-control architecture (is there a redundant/monitoring path? A pilot override?).
- Whether this function is a single point of failure or one input among several to a higher-level authority-limiting or monitoring function.
- The operational category (e.g., under 14 CFR Part 107 vs. a certified aircraft type).

## What this repository actually provides

Structural/requirements-based verification evidence (see `docs/verification_evidence_summary.md`) built to a rigor consistent with an illustrative DAL C target: HLR/LLR traceability, MC/DC structural coverage, static analysis (MISRA + soundness proof) on the generated code, and both model-level and code-level test suites — useful as a demonstration of the *workflow*, not as evidence that DAL C has actually been assigned or satisfied for a real aircraft program.
