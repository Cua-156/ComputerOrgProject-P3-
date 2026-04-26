# Part 3 Executive Summary

This submission creates a complete `Part3` SISC processor project from the Part 2 baseline plus the provided Part 3 files. The original `From P2` and `Given(Part3)` folders were left unchanged.

## Work Completed
- Added Part 3 load/store support to the processor datapath.
- Integrated data memory as required with instance name `dm u11`.
- Added required selector muxes with instance names `mux4 u12` and `mux16 u13`.
- Updated `ctrl.v` with `dm_we`, `addr_sel`, and `rb_sel` control outputs.
- Implemented absolute and indexed load/store behavior for `LDA`, `LDX`, `STA`, and `STX`.
- Preserved the required top-level interface: `module sisc (clk, rst_f);`.
- Preserved all required autograder-visible instance names.

## Verification
- Part 2 regression checkpoint test: `15 / 15` checks passed.
- Part 3 checkpoint test: `22 / 22` checks passed.
- Part 3 final autograder test: `18 / 18` checks passed.

The Icarus Verilog `$readmemh` warnings about short memory files are expected because the provided memory files intentionally initialize only the addresses used by the tests.

## Package Contents
The `Part3` folder contains all final `.v` source files, provided memory/data files, test benches, `run_selftest.tcl`, `README.md`, golden reference material, this summary, and a `work` directory for packaging compatibility.
