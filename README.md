# UAV Altitude Hold Controller — Agentic DO-178C-Style Verification Case Study

> **Status: Draft.** Human engineering review required. This repository is a demonstration/webinar artifact and does **not** constitute a certification claim or certification evidence.

Companion case study for the *"Agentic AI Workflows with MATLAB and Simulink — UAV Case Study"* webinar. It walks a small UAV altitude-hold controller through a DO-178C / DO-331-style Model-Based Design workflow — requirements, model, code generation, static analysis, and test — using MATLAB/Simulink Agentic Toolkits and the Polyspace Agentic Toolkit to accelerate each step, with an engineer reviewing and approving the results.

## What's in the model

`model/uav_altitude_hold.slx` — a discrete (0.02 s fixed-step) altitude-hold controller:

- Proportional + rate-damping + bounded-integral control on altitude error, with a fixed 0.5 hover-trim bias
- Input validity gating (range + implicit finite checks on commanded/measured altitude, vertical rate, sensor-valid flag) with a safe 0.50 hover fallback
- Output command saturated to `[0.0, 1.0]`

## Repository layout

| Folder | Contents |
|---|---|
| `model/` | The Simulink model, plus two Simulink Test harnesses (`uav_altitude_hold_Harness1.slx`, `uav_altitude_hold_Harness2.slx`) |
| `requirements/` | `uav_altitude_hold_requirements.slreqx` — 7 HLRs, 13 LLRs, 26 traceability links (Requirements Toolbox) |
| `tests/` | `test_uav_altitude_hold.m` (MATLAB unit tests, model-level), `uav_altitude_hold_harness_tests.mldatx` (Simulink Test: harness + Test Sequence + baseline test cases), `c/` (PSTUnit C unit tests + build script) |
| `scripts/` | Model/requirements/harness/coverage generation scripts, and the Embedded Coder output (`uav_altitude_hold_ert_rtw/`) |
| `evidence/` | Tool-generated verification evidence: Model Advisor, Polyspace Bug Finder, Code Prover, coverage, PSTUnit results |
| `polyspace/` | Polyspace CLI run scripts and data-range specification used for Bug Finder / Code Prover |
| `docs/` | Verification evidence summary, DAL determination draft, Polyspace findings disposition, DO-178C background reading |

## Current verification status

| Activity | Result |
|---|---|
| Model regression tests (MATLAB unit tests) | 14/14 passed |
| Simulink Test (harness/Test Sequence/baseline) | 2/2 passed |
| Model Advisor (`mathworks.do178.*` checks) | 6/7 passed (1 reviewed & accepted — see below) |
| Structural coverage | Decision 100%, Condition 100%, MC/DC 100%, Execution 100% |
| PSTUnit C unit tests | 14/14 passed |
| Bug Finder (MISRA C:2023 + CWE) | 0 defects; 6 MISRA findings, all justified in-source |
| Code Prover (R2026a) | Green 29, Orange 0, Red 0 (100% proven) |
| SIL build | Blocked — two distinct environment-level toolchain failures, documented in `evidence/sil_equivalence_blocked.txt` |

Full detail and open items: [`docs/verification_evidence_summary.md`](docs/verification_evidence_summary.md). Every number above comes from an actual tool run on this repository's own artifacts — reproduce any of them via the corresponding script in `scripts/` or `polyspace/`.

## Reproducing the evidence

Requires MATLAB/Simulink R2026a with Requirements Toolbox, Simulink Test, Simulink Coverage, Embedded Coder, and Simulink Check, plus a Polyspace Bug Finder/Code Prover installation.

```matlab
% From the repository root, in MATLAB:
run('scripts/generate_requirements.m')     % builds requirements/*.slreqx
run('scripts/generate_test_harnesses.m')   % builds model/*_Harness*.slx
run('scripts/generate_harness_tests.m')    % builds tests/*.mldatx, runs it
runtests('tests/test_uav_altitude_hold.m') % MATLAB unit tests
run('scripts/collect_coverage.m')          % evidence/coverage/report.html
```

```bash
# Generate code (in MATLAB): rtwbuild('uav_altitude_hold') with
# GenCodeOnly='on', from the scripts/ folder.

# Then, from a shell, with POLYSPACE_ROOT set to your Polyspace install:
polyspace/run_bug_finder.sh
polyspace/run_code_prover.sh
tests/c/build_and_run.sh
```

## Why this exists

Everything above was scaffolded and executed with AI assistance (MATLAB MCP Server, Simulink Agentic Toolkit, Polyspace Agentic Toolkit) to show how much of the DO-178C-style evidence trail — requirements, model tests, coverage, static analysis, code generation, unit tests — can be accelerated end to end, while keeping DAL assignment, findings disposition, and sign-off as explicit, un-skippable human engineering decisions.
