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

%% Task 4.1 Noise Injection

if exist('target_SNR_dB', 'var')
    % 1. Define Desired SNR
    % Already done in caller file
    
    % 2. Measure Signal Power
    % Reshape matrix to 1D vector to calculate average power of the whole frame
    sig_power = mean(abs(Mx_matrix(:)).^2);
    
    % 3. Calculate Required Noise Power
    % P_noise = P_signal / (10^(SNR/10))
    noise_power = sig_power / (10 ^ (target_SNR_dB / 10));
    
    % 4. Generate Noise
    % We need a noise matrix exactly the same size as the Mix_Matrix
    % Scaling by sqrt(noise_power/2) for both Real and Imaginary parts
    [Nr, Nd] = size(Mx_matrix); % Get dimensions
    noise_matrix = sqrt(noise_power / 2) * (randn(Nr, Nd) + 1i * randn(Nr, Nd));
    
    % 5. Inject Noise
    Mx_matrix = Mx_matrix + noise_matrix;
    
    fprintf('Noise Injected. Target SNR: %d dB\n', target_SNR_dB);
end