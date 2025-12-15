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
    
    methods (Test)
        % Visual verification of reflected waveform
        function testSignalManual(testCase)
            target_simulation;
            % Should see similar results from original waveform, but
            % shifted to the right due to time delay and more fuzzy due to
            % added noise
            spectrogram(Rx, 128, 120, 128, fs, 'yaxis');
        end
    end
end