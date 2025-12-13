% =========================================================================
% Task 1.1 Tests
% Phase 1, Task 1.1: Parameter Definition
% =========================================================================

classdef Task_1_1_Test < matlab.unittest.TestCase
    % Runs once before the file starts to allocate file path
    methods (TestClassSetup)
        function addProjectFolderToPath(testCase)
            import matlab.unittest.fixtures.PathFixture
            testCase.applyFixture(PathFixture('../App'));
        end
    end
    
    methods (Test)
        function testBandwidthCalculation(testCase)
            radar_config;
            BW_expected = c / (2 * d_res);
            testCase.assertEqual(BW, BW_expected, 'RelTol', 1e-4);
        end

        function testChirpTime(testCase)
            radar_config;
            testCase.assertGreaterThan(T_chirp, 0);
        end

        function testChirpSlope(testCase)
            radar_config;
            testCase.assertGreaterThan(S, 0);
        end
    end
end