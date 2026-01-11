% =========================================================================
% Task 2.2 Tests
% Phase 2, Task 2.2: Signal Mixer
% =========================================================================

classdef Task_2_2_Test < matlab.unittest.TestCase
    % Runs once before the file starts to allocate file path
    methods (TestClassSetup)
        function addProjectFolderToPath(testCase)
            import matlab.unittest.fixtures.PathFixture
            testCase.applyFixture(PathFixture('../App'));
        end
    end
    
    methods (Test)
        function testBeatFrequency(testCase)
            signal_mixer;

            % Extracting data fromm valid region only
            valid_data = Mx(t > delay);
            frequency = diff(unwrap(angle(valid_data))) * (fs / (2 * pi));
            testCase.assertEqual(mean(frequency), S * 2 * target_range / c, 'RelTol', 1e-2);
        end

        function testTonePurity(testCase)
            signal_mixer;
            valid_data = Mx(t > delay);
            frequency = diff(unwrap(angle(valid_data))) * (fs / (2 * pi));
            testCase.assertLessThan(std(frequency), 1e3);
        end

        % Visual verification of reflected waveform
        function testSignalManual(testCase)
            signal_mixer;
            % The mixed signal should be a pure sinusoid where the
            % frequency (beat frequency) is proportional to the range.
            % f_beat = S * t_max. Hence, a horizontal yellow line should be
            % observed.
            spectrogram(Mx, 128, 120, 128, fs, 'yaxis');
        end
    end
end