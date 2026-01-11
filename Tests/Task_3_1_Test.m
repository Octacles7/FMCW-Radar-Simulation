% =========================================================================
% Task 3.1 Tests
% Phase 3, Task 3.1: Coherent Integration
% =========================================================================

% Important Note: These tests should only be ran with the noise injection
% disabled.

classdef Task_3_1_Test < matlab.unittest.TestCase
    % Runs once before the file starts to allocate file path
    methods (TestClassSetup)
        function addProjectFolderToPath(testCase)
            import matlab.unittest.fixtures.PathFixture
            testCase.applyFixture(PathFixture('../App'));
        end
    end
    
    properties
        % Environment variables to be loaded from config
        c_env;
        fc_env;
        lambda_env;
        T_chirp_env;
    end
    
    methods (TestMethodSetup)
        function setupEnvironment(testCase)
            % 1. Load the Configuration
            % We run the user's config script to get physics constants
            radar_config;
            
            % 2. Store Key Physics Parameters for Validation
            testCase.c_env = c;
            testCase.fc_env = fc;
            testCase.lambda_env = c / fc;
            testCase.T_chirp_env = T_chirp;
        end
    end
    
    methods (Test)
        function testMatrixDimensions(testCase)
            % TEST 1: Data Cube Dimensions
            % Objective: Ensure Mx_matrix is size [N x Samples].
            % Reference: "Mx_matrix = zeros(N, length(t));"
            
            % 1. Run the Simulation
            % This executes the user's loop and populates Mx_matrix
            coherent_integration;
            
            % 2. Verify Dimensions
            % N should be 128 (2^7) as per screenshot
            expected_rows = 128;
            % Cols should match time vector length
            expected_cols = length(t);
            
            testCase.verifyEqual(size(Mx_matrix), [expected_rows, expected_cols], ...
                'Mx_matrix dimensions are incorrect. Should be [N x Fast_Time].');
        end
        
        function testSignalIntegrity(testCase)
            % TEST 2: Signal Content Check
            % Objective: Ensure the matrix is not empty or all zeros.
            
            coherent_integration;
            
            % Check if data is populated
            total_energy = sum(abs(Mx_matrix(:)));
            testCase.verifyGreaterThan(total_energy, 0, ...
                'Mx_matrix is empty or all zeros. The mixer loop may not be saving data.');
            
            % Check if data is complex (Phase information requires complex numbers)
            testCase.verifyTrue(~isreal(Mx_matrix), ...
                'Mx_matrix should be complex-valued to contain phase info.');
        end
        
        function testDopplerPhaseShift(testCase)
            % TEST 3: Doppler Signature Verification
            % Objective: A moving target (v=10) must create a specific phase rotation
            % between consecutive chirps (Row 1 vs Row 2).
            
            % 1. Run Simulation
            coherent_integration;
            
            % 2. Extract Phase Shift
            % We compare the phase of the same range bin across two chirps.
            % We use the middle sample to avoid edge artifacts.
            sample_idx = round(length(t)/2);
            
            phasor_1 = Mx_matrix(1, sample_idx);
            phasor_2 = Mx_matrix(2, sample_idx);
            
            % Calculate phase difference (Delta Phi)
            measured_dphi = angle(phasor_2 * conj(phasor_1));
            
            % 3. Calculate Expected Phase Shift (Theoretical)
            % Formula: dPhi = 2 * pi * f_doppler * T_chirp
            % f_doppler = 2 * v / lambda
            
            v_target = 10; % Hardcoded in user script
            fd = 2 * v_target / testCase.lambda_env;
            expected_dphi = 2 * pi * fd * testCase.T_chirp_env;
            
            % Wrap expected phase to [-pi, pi] for comparison
            expected_dphi = angle(exp(1i * expected_dphi));
            
            % 4. Assert
            % We allow a small tolerance for floating point arithmetic
            testCase.verifyEqual(measured_dphi, expected_dphi, 'AbsTol', 1e-1, ...
                ['Doppler phase shift is incorrect. Expected approx ', num2str(expected_dphi), ...
                 ' rad, got ', num2str(measured_dphi), ' rad.']);
        end
        
        function testSlowTimeEvolution(testCase)
             % TEST 4: Target Movement Simulation
             % Objective: Verify that the target is actually moving in the simulation logic.
             % The phase should evolve linearly across all N chirps.
             
             coherent_integration;
             
             % Take a slice of slow time (one column)
             slow_time_signal = Mx_matrix(:, round(length(t)/2));
             
             % The unwrapped phase of this signal should be linear
             phase_unwrapped = unwrap(angle(slow_time_signal));
             
             % Fit a line to the phase
             p = polyfit(1:length(phase_unwrapped), phase_unwrapped', 1);
             r_squared = 1 - sum((phase_unwrapped' - polyval(p, 1:length(phase_unwrapped))).^2) / sum((phase_unwrapped - mean(phase_unwrapped)).^2);
             
             % If the target is moving at constant velocity, phase change is constant (Linear Phase)
             testCase.verifyGreaterThan(r_squared, 0.99, ...
                 'Phase evolution across chirps is not linear. Verify target_range update logic.');
        end
    end
end