# DO-178C / DO-331 Background

Brief context for readers unfamiliar with the standards this case study's workflow is modeled on. Not a substitute for the actual documents.

## DO-178C

*Software Considerations in Airborne Systems and Equipment Certification*, the primary standard civil aviation authorities (FAA, EASA) use to assess software in airborne systems. It doesn't mandate specific techniques; it defines **objectives** a software life cycle must satisfy, scaled by **Design Assurance Level (DAL)** — from DAL A (catastrophic failure condition) down to DAL E (no safety effect). Higher DAL means more objectives, and more of them requiring independence between the person who does the work and the person who verifies it.

Core activities DO-178C expects, all mirrored (at illustrative, non-certified scale) in this repository:

- **High-level and low-level requirements**, with **bidirectional traceability** to the design and code (→ `requirements/`, Requirements Toolbox).
- **Verification of requirements-based tests**, both at the model/software level and, once code exists, against the actual generated code (→ `tests/`, MATLAB unit tests, Simulink Test harnesses, PSTUnit).
- **Structural coverage analysis** — Statement, Decision, and (at DAL A) Modified Condition/Decision Coverage (MC/DC) — to catch code that requirements-based tests didn't reach, or (worse) code that does something requirements don't describe (→ `evidence/coverage/`).
- **Software Quality Assurance** style review of coding standards and static analysis findings (→ Polyspace Bug Finder/Code Prover, `docs/polyspace_findings_disposition.md`).

## DO-331

*Model-Based Development and Verification Supplement to DO-178C and DO-278A*. DO-178C predates widespread Model-Based Design; DO-331 adapts its objectives for projects where a Simulink-style model is itself a design artifact (or, with qualified code generation, treated as if it were the low-level requirements/source). Key DO-331 concepts reflected here:

- **Model coverage** as an analogue to code structural coverage, applicable to the model itself.
- Distinguishing a model used **for design communication only** from one used as the actual **basis for code generation** — this repository's model is the latter (Embedded Coder generates `uav_altitude_hold.c` directly from it).
- Additional model-specific verification: e.g., Model Advisor-style checks for modeling-standard conformance (this repo uses the `mathworks.do178.*` Model Advisor check group specifically built for this purpose).

## What "DO-178C-style" means for this repository

Nothing here has gone through an actual certification liaison process, a real Stage of Involvement audit, or genuine independence between authors and reviewers — it was scaffolded end-to-end with AI assistance in one working session. The value is in showing how much of the *evidence-generation mechanics* (traceability, coverage, static analysis, requirements-based test authoring) can be accelerated, while making unmistakably clear — via this document and the top-level README disclaimer — that DAL assignment, findings disposition, and sign-off remain human engineering judgment calls, not something a tool (or an agent) can certify on its own.
