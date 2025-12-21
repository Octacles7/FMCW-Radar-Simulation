% =========================================================================
% FMCW Range Estimation Script
% Phase 2, Task 2.3: Range Estimation
% =========================================================================

%% Step 0 Variable Retrievement
signal_mixer;

%% Step 1 Fast Fourier Transform
y = fft(Mx, FFT_length);
y_normalised = y / FFT_length;
frequency = (0:FFT_length - 1) * fs / FFT_length;

%% Step 2 Peak Calculation
[y_max, max_index] = max(abs(y_normalised));
beat_frequency = frequency(max_index);

%% Step 3 Range Calculation
calculated_range = c * beat_frequency / (2 * S);

% There is a slight discrepancy between the calculated range and the actual
% range due to non-idealities in the FFT resolution