# UAV Altitude Hold Controller — Agentic DO-178C-Style Verification Case Study

> **Status: Draft.** Human engineering review required. This repository is a demonstration/webinar artifact and does **not** constitute a certification claim or certification evidence.

Companion case study for the *"Agentic AI Workflows with MATLAB and Simulink — UAV Case Study"* webinar. It walks a small UAV altitude-hold controller through a DO-178C / DO-331-style Model-Based Design workflow — requirements, model, code generation, static analysis, and test — using MATLAB/Simulink Agentic Toolkits and the Polyspace Agentic Toolkit to accelerate each step, with an engineer reviewing and approving the results.

## What's in the model

`model/uav_altitude_hold.slx` — a discrete (0.02 s fixed-step) altitude-hold controller:

- Proportional + rate-damping + bounded-integral control on altitude error
- Input validity gating (range + finite checks on commanded/measured altitude, vertical rate, sensor-valid flag) with a safe 0.50 hover fallback
- Output command saturated to `[0.0, 1.0]`

## Repository layout

| Folder | Contents |
|---|---|
| `model/` | The Simulink model, plus two Simulink Test harnesses (`uav_altitude_hold_Harness1.slx`, `uav_altitude_hold_Harness2.slx`) |
| `requirements/` | `uav_altitude_hold_requirements.slreqx` — 7 HLRs, 13 LLRs, 26 traceability links (Requirements Toolbox) |
| `tests/` | `test_uav_altitude_hold.m` (MATLAB unit tests, model-level), `uav_altitude_hold_harness_tests.mldatx` (Simulink Test: harness + Test Sequence + baseline test cases), `c/` (PSTUnit C unit tests + build) |
| `scripts/` | Model/requirements generation and analysis scripts (coverage, SIL, robustness upgrade) |
| `evidence/` | Tool-generated verification evidence: Model Advisor, Polyspace Bug Finder, Code Prover, coverage, SIL build, PSTUnit results — pruned to the latest run per activity |
| `polyspace/` | Polyspace build options and checkers configuration |
| `docs/` | Verification evidence summary, DAL determination draft, Polyspace findings disposition, DO-178C background reading |

## Current verification status

| Activity | Result |
|---|---|
| Model regression tests | 9/9 passed |
| Simulink Test (harness/Test Sequence/baseline) | 2/2 passed |
| Model Advisor | 11/11 checks passed |
| Structural coverage | Decision 12/12, Condition 28/28, MC/DC 7/7 |
| PSTUnit C unit tests | 9/10 passed (1 known re-initialization defect) |
| Code Prover (R2026a) | Green 35, Orange 4, Red 0 |
| SIL object-code build | Succeeds; SIL numerical-equivalence co-simulation still blocked (see `evidence/sil_equivalence_blocked.txt`) |

Full detail and open items: [`docs/verification_evidence_summary.md`](docs/verification_evidence_summary.md).

## Why this exists

Everything above was scaffolded and executed with AI assistance (MATLAB MCP Server, Simulink Agentic Toolkit, Polyspace Agentic Toolkit) to show how much of the DO-178C-style evidence trail — requirements, model tests, coverage, static analysis, code generation, unit tests — can be accelerated end to end, while keeping DAL assignment, findings disposition, and sign-off as explicit, un-skippable human engineering decisions.
