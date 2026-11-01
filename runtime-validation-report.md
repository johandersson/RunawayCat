# Runtime Validation Report

**Generated**: 2026-11-01T15:05:31+01:00  
**Target**: Katten på rymmen (LÖVE 11.5 desktop game)

## Summary

| Step | Status | Exit Code | Details |
|---|---|---:|---|
| Startup | PASS | n/a | `lovec.exe` remained alive after the startup grace period (PID 1888) |
| Busted tests | PASS | 0 | 5 spec files, 14 tests, 14 passed |
| Lua 5.1 syntax | PASS | 0 | 13 production files validated with `luac -p` |
| Browser E2E | N/A | n/a | Native LÖVE desktop application; no browser boundary exists |

**Overall**: PASS

## TDD Evidence

1. Characterization harness: 2 tests passed against the original monolith.
2. Red phase: 4 suites failed because the planned class modules did not exist.
3. Green phase: the class modules were implemented and all 14 tests passed.
4. Refactor phase: `main.lua` was connected to the tested classes and all 14 tests passed again.
5. Runtime phase: the refactored game started successfully in LÖVE 11.5.

## Environment

- Docker: unavailable (not installed); not required because the game has no infrastructure dependencies.
- Node.js: available (`v22.13.1`); browser testing is not applicable to a native LÖVE application.
- Primary validation stack: Busted 2.3.0, Lua 5.1 syntax validation, and native LÖVE startup verification.
- External dependencies: none at runtime.

## Coverage

- LÖVE callback registration and startup flow
- Jump buffering, coyote time, and variable jump height
- Food scoring and one-time collection
- Hazard collision and platform landing
- Environment selection and independent zone data
- Progressive speed, gap, platform-height, and hazard difficulty
- Safe jump-distance constraints for every generated gap
