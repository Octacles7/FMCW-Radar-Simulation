% =========================================================================
% Task 1.2 Tests
% Phase 1, Task 1.2: Waveform Generation
% =========================================================================

classdef Task_1_2_Test < matlab.unittest.TestCase
    % Runs once before the file starts to allocate file path
    methods (TestClassSetup)
        function addProjectFolderToPath(testCase)
            import matlab.unittest.fixtures.PathFixture
            testCase.applyFixture(PathFixture('../App'));
        end
    end
    
    methods (Test)
        function testSignalAmplitude(testCase)
            waveform_generation;
            testCase.assertEqual(abs(Tx), ones(size(Tx)), 'RelTol', 1e-6);
        end

        function testStartEndFrequency(testCase)
            waveform_generation;
            frequencyVector = diff(unwrap(angle(Tx))); % Calculated as digital frequency in radians
            testCase.assertEqual(mean(frequencyVector(1:10)), 0, 'AbsTol', 1e-2);
            testCase.assertEqual(max(frequencyVector), pi, 'RelTol', 2e-2);
        end

        function testChirpLinearity(testCase)
            waveform_generation;
            frequencyVector = diff(unwrap(angle(Tx))) * (fs / (2 * pi)); % Calculates frequency in Hz
            slopeVector = diff(frequencyVector) * fs;
            testCase.assertEqual(mean(slopeVector), S, 'RelTol', 1e-6); % Checking that the slope is consistent
            testCase.assertLessThan(std(slopeVector) / mean(slopeVector), 1e-9); % Checking that the slope does not vary
        end

        % Visual verification of generated waveform
        function testSignalManual(testCase)
            waveform_generation;
            % Should see blue with a clear diagonal yellow line going up
            spectrogram(Tx, 128, 120, 128, fs, 'yaxis');
            title("FMCW Waveform Spectrogram");
        end

        % Graphs instantaneous frequency
        function testFrequencyWaveform(testCase)
            waveform_generation;

            % 1. Setup Demonstration Signal (4 Chirps)
            % Define number of repetitions
            N_demo = 4;
            
            % Repeat the single chirp signal 4 times sequentially
            % Using repmat assumes Tx is a row vector [1 x N_samples]
            Tx_demo = repmat(Tx, 1, N_demo);
            
            % Calculate total samples and create a new continuous time vector
            total_samples = length(Tx_demo);
            dt = 1/fs;
            % New time vector from 0 to 4*T_chirp
            t_demo = (0:total_samples-1) * dt;
            
            % 2. Calculate Instantaneous Frequency
            % Step A: Extract and unwrap the phase of the concatenated signal.
            % 'unwrap' is crucial here. As the chirp resets from f_max back to f_0,
            % the phase drops sharply. unwrap makes this continuous.
            phase_demo_unwrapped = unwrap(angle(Tx_demo));
            
            % Step B: Calculate frequency as the time derivative of phase.
            % f = (1 / 2pi) * (d(phi) / dt)
            % We use discrete difference 'diff' to approximate the derivative.
            f_inst_demo = diff(phase_demo_unwrapped) / (2 * pi * dt);
            
            % Create corresponding time vector for plotting (length is N-1 due to diff)
            t_freq_demo = t_demo(1:end-1);
            
            % 3. Visualization
            figure('Name', 'Multi-Chirp Instantaneous Frequency', 'NumberTitle', 'off');
            plot(t_freq_demo, f_inst_demo, 'b', 'LineWidth', 1.5);
            grid on;
            hold on;
            
            % Formatting
            title('Instantaneous Frequency of Chirp Signals');
            xlabel('Time (s)');
            ylabel('Frequency (Hz)');
            axis tight;
            
            % Add visual guides for Chirp Boundaries and Bandwidth
            yline(B, '--k', ['Bandwidth (', num2str(B/1e6), ' MHz)'], 'LabelHorizontalAlignment', 'left');
            for k = 1:N_demo
                xline(k * T_chirp, '--r', ['Chirp ', num2str(k)]);
            end
            
            legend('Instantaneous Freq', 'Limits/Boundaries');
            hold off;
        end
    end
end