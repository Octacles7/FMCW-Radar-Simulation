% =========================================================================
% Task 3.2 Tests
% Phase 3, Task 3.2: 2D FFT
% =========================================================================

classdef Task_3_2_Test < matlab.unittest.TestCase
    % Runs once before the file starts to allocate file path
    methods (TestClassSetup)
        function addProjectFolderToPath(testCase)
            import matlab.unittest.fixtures.PathFixture
            testCase.applyFixture(PathFixture('../App'));
        end
    end

    properties
        % We need to store these to check if the target location is correct
        expected_range = 50;   % From Task 3.1 settings
        expected_velocity = 10; % From Task 3.1 settings
    end

    methods (TestMethodSetup)
        function setupEnvironment(testCase)
            two_dimensional_fft; 
        end
    end
    
    methods (Test)
        function testOutputDimensions(testCase)
            % TEST 1: Matrix vs Axis Alignment
            % Objective: Ensure the RDM_matrix dimensions match the Plotting Axes.
            
            % 1. Run the Full Script Chain locally
            radar_config;
            waveform_generation;
            coherent_integration;
            two_dimensional_fft; 
            
            % 2. Get Dimensions of the generated matrix
            [rows, cols] = size(RDM_matrix);
            
            % 3. Assertions
            % Access variables 'velocity_axis' and 'range_axis' directly
            testCase.verifyEqual(rows, length(velocity_axis), ...
                'Mismatch: Number of RDM_matrix Rows does not match Velocity Axis length.');
                
            testCase.verifyEqual(cols, length(range_axis), ...
                'Mismatch: Number of RDM_matrix Columns does not match Range Axis length.');
        end
        
        function testPeakLocation(testCase)
            % TEST 2: Physical Accuracy Check
            % Objective: Find the peak energy in the map and verify it matches
            % the simulated target (50m, 10m/s).
            
            % 1. Run Simulation
            radar_config;
            waveform_generation;
            coherent_integration;
            two_dimensional_fft;
            
            % 2. Find the global maximum (The Target)
            [~, linear_idx] = max(RDM_matrix(:));
            [row_idx, col_idx] = ind2sub(size(RDM_matrix), linear_idx);
            
            % 3. Retrieve physical values at those indices directly
            detected_velocity = velocity_axis(row_idx);
            detected_range = range_axis(col_idx);
            
            % 4. Assert Range (Allow +/- 2m error for bin resolution)
            testCase.verifyEqual(detected_range, testCase.expected_range, 'AbsTol', 2.0, ...
                ['Target Range incorrect. Expected ~50m, got ', num2str(detected_range), 'm']);
                
            % 5. Assert Velocity (Allow +/- 2m/s error)
            testCase.verifyEqual(detected_velocity, testCase.expected_velocity, 'AbsTol', 2.0, ...
                ['Target Velocity incorrect. Expected ~10m/s, got ', num2str(detected_velocity), 'm/s']);
        end
        
        function testFFTShift(testCase)
            % TEST 3: Zero-Doppler Centering
            % Objective: Verify that 'fftshift' was applied correctly.
            % 0 m/s should be in the middle of the axis, not at the start.
            
            % 1. Run Simulation
            radar_config;
            two_dimensional_fft; % Running just the relevant scripts if variables persist, 
                                 % but safely running full chain is better:
            waveform_generation;
            coherent_integration;
            two_dimensional_fft;
            
            % 2. Verify Center
            mid_idx = floor(length(velocity_axis) / 2) + 1;
            mid_val = velocity_axis(mid_idx);
            
            testCase.verifyEqual(mid_val, 0, 'AbsTol', 5.0, ...
                'Velocity Axis does not seem centered. Did you run fftshift?');
        end
        
        function testDynamicRange(testCase)
            % TEST 4: Signal Strength (dB Check)
            % Objective: Verify the conversion to dB was successful.
            
            % 1. Run Simulation
            radar_config;
            waveform_generation;
            coherent_integration;
            two_dimensional_fft;
            
            % 2. Analyze RDM_matrix
            peak_val = max(RDM_matrix(:));
            mean_val = mean(RDM_matrix(:));
            
            % A strong target should be at least 10dB above the average background
            testCase.verifyGreaterThan(peak_val, mean_val + 10, ...
                'Target peak is too weak. Check normalization or log10 conversion.');
            
            % Verify values are not complex (must be magnitude/power)
            testCase.verifyTrue(isreal(RDM_matrix), ...
                'RDM_matrix should contain real dB values, not complex numbers.');
        end

        function testSurfPlot(testCase)
            % Should expect a peak at the target range and velocity
            two_dimensional_fft;
            figure('Name', 'Range-Velocity Map');

            surf(range_axis(1:FFT_length / 2), velocity_axis, RDM_matrix(:, 1:FFT_length / 2));
            
            shading interp;
            axis tight;
            grid on;
            view([0 90]);
            title('Range-Velocity Map');
            xlabel('Range (m)');
            ylabel('Velocity (m/s)');
            zlabel('Amplitude (dB)');
            colorbar;
        end
    end
end