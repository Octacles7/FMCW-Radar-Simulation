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
        end
    end
end