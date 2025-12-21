% =========================================================================
% FMCW 2D FFT Script
% Phase 3, Task 3.2: 2D FFT
% =========================================================================

%% Step 0 Variable Retrievement
coherent_integration;

%% Step 1 2D FFT
y1 = fft(Mx_matrix, [], 2); % FFT of each Mx signal along the rows
y2 = fft(y1, [], 1); % FFT across the loops along the columns
y3 = fftshift(y2, 1); % Centering to put 0 m/s in the middle

% Data matrix
magnitude_matrix = 10 * log10(abs(y3));

%% Step 2 Axis Creation
max_velocity = c / (4 * fc * T_chirp);

velocity_axis = linspace(-max_velocity, max_velocity, N);
frequency_axis = linspace(0, fs, FFT_length);
range_axis = c * frequency_axis / (2 * S);