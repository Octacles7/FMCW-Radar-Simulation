% =========================================================================
% Task 2.1 Tests
% Phase 2, Task 2.1: Target Simulation
% =========================================================================

classdef Task_2_1_Test < matlab.unittest.TestCase
    % Runs once before the file starts to allocate file path
    methods (TestClassSetup)
        function addProjectFolderToPath(testCase)
            import matlab.unittest.fixtures.PathFixture
            testCase.applyFixture(PathFixture('../App'));
        end
    end
    
    properties
        % Properties to store environment variables for verification
        c_env;
        fc_env;
        t_env;
    end
    
    methods (TestMethodSetup)
        function setupEnvironment(testCase)
            % 1. Run the Configuration Script
            % This loads 'c', 'fc', 'S', 'BW', etc. from your project.
            radar_config; 
            
            % 2. Run Waveform Generation
            % This generates the time vector 't' and transmit signal 'Tx'.
            waveform_generation;
            
            % 3. Capture critical variables for assertions
            testCase.c_env = c;
            testCase.fc_env = fc;
            testCase.t_env = t;
        end
    end
    
    methods (Test)
        function testCausality(testCase)
            % TEST 1: Causality Check
            % Objective: Verify Rx is 0.0 before the signal physically arrives.
            
            % 1. Define Test Inputs
            target_range = 500; % Far enough to create a measurable delay
            target_velocity = 0;
            
            % 2. Run the User Script
            % The script will pick up the 'target_range' variable we just set.
            target_simulation; 
            
            % 3. Calculate Expected Delay
            expected_delay = 2 * target_range / testCase.c_env;
            
            % 4. Verify Silence
            % Find indices where time is less than delay
            pre_arrival_indices = find(testCase.t_env < expected_delay);
            
            if isempty(pre_arrival_indices)
                warning('Target too close; signal arrives instantly relative to sampling.');
            else
                rx_pre_arrival = Rx(pre_arrival_indices);
                testCase.verifyEqual(rx_pre_arrival, zeros(size(rx_pre_arrival)), ...
                    'Signal should be zero before Round Trip Delay (Causality Violation)');
            end
        end
        
        function testStationaryDelayCalculation(testCase)
            % TEST 2: Range Calculation Accuracy
            % Objective: Ensure the 'delay' vector is calculated correctly for static objects.
            
            target_range = 100;
            target_velocity = 0;
            
            % Run Script
            target_simulation;
            
            % Check the first value of the 'delay' vector
            expected_val = 2 * target_range / testCase.c_env;
            
            testCase.verifyEqual(delay(1), expected_val, 'AbsTol', 1e-12, ...
                'Delay calculation is incorrect at t=0');
        end
        
        function testDopplerShiftLogic(testCase)
            % TEST 3: Doppler Effect on Delay
            % Objective: Verify that moving targets change the delay over time.
            
            % Case A: Moving Away
            target_range = 50;
            target_velocity = 100; % Moving Away
            target_simulation;
            delay_away = delay; % Store result
            
            % Case B: Moving Closer
            target_range = 50;
            target_velocity = -100; % Moving Closer
            target_simulation;
            delay_close = delay; % Store result
            
            % Assertion 1: Moving away -> Delay increases
            testCase.verifyTrue(delay_away(end) > delay_away(1), ...
                'Target moving away should result in increasing delay');
                
            % Assertion 2: Moving closer -> Delay decreases
            testCase.verifyTrue(delay_close(end) < delay_close(1), ...
                'Target moving closer should result in decreasing delay');
        end
        
        function testVariableOverride(testCase)
            % TEST 4: Manual Override Check
            % Objective: Verify the script respects existing workspace variables.
            % Code reference: "if ~exist('target_range', 'var')"
            
            target_range = 123.45; % Specific non-default value
            target_velocity = 0;
            
            % Run Script
            target_simulation;
            
            % Assert that target_range was NOT reset to 50
            testCase.verifyEqual(target_range, 123.45, ...
                'Script should not overwrite target_range if it is already defined.');
        end

        % Visual verification of reflected waveform
        function testSignalManual(testCase)
            target_simulation;
            % Should see similar results from original waveform, but
            % shifted to the right due to time delay
            spectrogram(Rx, 128, 120, 128, fs, 'yaxis');
        end
    end
end