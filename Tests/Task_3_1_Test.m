% =========================================================================
% Task 3.1 Tests
% Phase 3, Task 3.1: Coherent Integration
% =========================================================================

classdef Task_3_1_Test < matlab.unittest.TestCase
    % Runs once before the file starts to allocate file path
    methods (TestClassSetup)
        function addProjectFolderToPath(testCase)
            import matlab.unittest.fixtures.PathFixture
            testCase.applyFixture(PathFixture('../App'));
        end
    end
    
    methods (Test)
       
    end
end