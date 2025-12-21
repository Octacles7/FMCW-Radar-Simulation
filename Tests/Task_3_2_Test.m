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
    
    methods (Test)
        function testSurfPlot(testCase)
            % Should expect a peak at the target range and velocity
            two_dimensional_fft;
            figure('Name', 'Range-Velocity Map');

            surf(range_axis(1:FFT_length / 2), velocity_axis, magnitude_matrix(:, 1:FFT_length / 2));
            
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