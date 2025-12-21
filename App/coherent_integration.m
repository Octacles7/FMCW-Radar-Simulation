% =========================================================================
% FMCW Coherent Integration Script
% Phase 3, Task 3.1: Coherent Integration
% =========================================================================

%% Step 0 Variable Retrievement
waveform_generation;

%% Step 1 Frame Parameters
N = 2^7; % Velocity resolution

%% Step 2 Simulation Loop
Mx_matrix = zeros(N, length(t));

target_range_original = 50;
target_velocity = 10;
for i = 1:N
    current_time = (i - 1) * T_chirp;
    target_range = target_range_original + target_velocity * current_time;
    signal_mixer;
    Mx_matrix(i, :) = Mx;
end