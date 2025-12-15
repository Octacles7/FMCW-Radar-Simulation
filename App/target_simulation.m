% =========================================================================
% FMCW Radar Configuration Script
% Phase 2, Task 2.1: Target Simulation
% =========================================================================

%% Step 0 Variable Retrievement
waveform_generation;

%% Step 1 Target Parameters
target_range = 50;
target_velocity = 10; % Positive is defined moving away from the radar

%% Step 2 Time Delay
delay = 2 * (target_range + target_velocity * t) / c;

%% Step 3 Waveform Generation
% Delay due to distance * Delay due to velocity
Rx = exp(1i * pi * S * (t - delay).^2) .* exp(-1i * 2 * pi * fc * delay);

% Enforcing causality
Rx = Rx .* (t >= delay);

%% Step 4 Noise Simulation
noise_factor = 0.01;
Rx_noise = Rx + noise_factor * (randn + 1i * randn);