% =========================================================================
% FMCW Radar Configuration Script
% Phase 2, Task 2.2: Signal Mixer
% =========================================================================

%% Step 0 Variable Retrievement
target_simulation;

%% Step 1 Mixer
Mx = Tx .* conj(Rx);