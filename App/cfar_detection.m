% =========================================================================
% FMCW CFAR Detection Script
% Phase 3, Task 3.3: CFAR Detection
% =========================================================================

%% Step 0: Variable Retrievement
two_dimensional_fft; 

% 1. Convert from Logarithmic (dB) to Linear Power (Watts)
% Note: Averaging must be done in linear space. Averaging dB values is mathematically incorrect.
RDM_linear = 10.^(magnitude_matrix / 10);

% 2. Slice the Matrix (Remove Mirror Image)
% The Range FFT (Dimension 2) produces a symmetric output for real inputs.
% We keep only the first half (Positive Frequencies) to remove the ghost target.
% We also add a tiny epsilon (1e-6) to prevent "Divide by Zero" errors in empty noise.
RDM_linear = RDM_linear(:, 1:end/2) + 1e-6;

% 3. Retrieve Dimensions
% Nd = Number of Doppler Bins (Rows)
% Nr = Number of Range Bins (Columns)
[Nd, Nr] = size(RDM_linear);

%% Step 1: Define CFAR Kernel Parameters
% -------------------------------------------------------------------------
% Purpose: Define the size of the sliding window used for detection.
% Structure: [Training Cells | Guard Cells | CUT | Guard Cells | Training Cells]
% -------------------------------------------------------------------------

% Training Cells: Used to estimate the Noise Floor
Tr = 10; % Range Dimension (Columns)
Td = 8;  % Doppler Dimension (Rows)

% Guard Cells: Used to prevent the target itself from biasing the noise estimate
Gr = 12; % Range Guard (Larger to cover target side lobes)
Gd = 4;  % Doppler Guard

% Offset: The Threshold Factor (SNR requirement)
% If Offset = 15dB, the Signal must be 15dB louder than the noise to be detected.
offset_dB = 15;
offset_linear = 10^(offset_dB / 10);

%% Step 2: 2D CFAR Processing Loop
% -------------------------------------------------------------------------
% Purpose: Slide the window across the map to detect targets.
% Method: Cell Averaging (CA-CFAR)
% -------------------------------------------------------------------------

% Initialize the binary output map
CFAR_Map = zeros(Nd, Nr);

% Pre-calculate the number of training cells (Total Window - Guard Window)
% 
N_training = (2*Tr + 2*Gr + 1) * (2*Td + 2*Gd + 1) - ...
             (2*Gr + 1) * (2*Gd + 1);

% Loop through the RDM
% Note: Loop limits are set to avoid "Index Out of Bounds" at the edges.
for i = (Td + Gd + 1) : (Nd - (Td + Gd))     % Iterate Rows (Velocity)
    for j = (Tr + Gr + 1) : (Nr - (Tr + Gr)) % Iterate Columns (Range)
        
        % --- A. Extract Total Window (Training + Guard + CUT) ---
        r_start = i - (Td + Gd); r_end = i + (Td + Gd);
        c_start = j - (Tr + Gr); c_end = j + (Tr + Gr);
        
        total_sum = sum(sum(RDM_linear(r_start:r_end, c_start:c_end)));
        
        % --- B. Extract Inner Guard Window (Guard + CUT) ---
        r_g_start = i - Gd; r_g_end = i + Gd;
        c_g_start = j - Gr; c_g_end = j + Gr;
        
        guard_sum = sum(sum(RDM_linear(r_g_start:r_g_end, c_g_start:c_g_end)));
        
        % --- C. Calculate Adaptive Threshold ---
        % 1. Estimate Noise Level (Average of Training Cells only)
        noise_level = (total_sum - guard_sum) / N_training;
        
        % 2. Scale Noise by Offset to get Threshold
        threshold = noise_level * offset_linear;
        
        % --- D. Decision Logic ---
        % Check if the Cell Under Test (CUT) exceeds the threshold
        if RDM_linear(i, j) > threshold
            CFAR_Map(i, j) = 1; % Detection!
        end
        
    end
end