% =========================================================================
% FMCW Radar Configuration Script
% Phase 1, Task 1.1: Parameter Definition
% =========================================================================

%% Step 1 System Requirements
R_max = 200; % Maximum distance the radar needs to see
d_res = 1; % Range resolution, the smallest distinguishable distance between two objects
v_max = 100; % The maximum speed the radar needs to detect
c = 3e8; % Speed of light

%% Step 2 Parameter Calculations
% Bandwidth calculation
BW = c / (2 * d_res);

% Chirp duration calculation
t_max = 2 * R_max / c; % Maximum round trip time
T_chirp = 5.5 * t_max; % Chirp duration should be 5-6 times longer than max trip time

% Chirp slope calculation
S = BW / T_chirp; % The rate at which frequency changes with respect to time

% Carrier frequency
fc = 7.7e10; % Automotive standard carrier frequency
