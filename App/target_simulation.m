% =========================================================================
% FMCW Target Simulation Script
% Phase 2, Task 2.1: Target Simulation
% =========================================================================

%% Step 0 Variable Retrievement
waveform_generation;

%% Step 1 Target Parameters
% Default parameter settings allow for manual override
if ~exist('target_range', 'var')
    target_range = 50;
end
if ~exist('target_velocity', 'var')
    target_velocity = 10; % Positive is defined moving away from the radar
end

%% Step 2 Time Delay
delay = 2 * (target_range + target_velocity * t) / c;

%% Step 3 Waveform Generation
% Delay due to distance * Delay due to velocity
Rx = exp(1i * pi * S * (t - delay).^2) .* exp(-1i * 2 * pi * fc * delay);

% Enforcing causality
Rx = Rx .* (t >= delay);