% =========================================================================
% Task 3.3 Tests
% Phase 3, Task 3.3: CFAR Detection
% =========================================================================

classdef Task_3_3_Test < matlab.unittest.TestCase
    % Runs once before the file starts to allocate file path
    methods (TestClassSetup)
        function addProjectFolderToPath(testCase)
            import matlab.unittest.fixtures.PathFixture
            testCase.applyFixture(PathFixture('../App'));
        end
    end
    
    methods (Test)
        function testDetectionMap(testCase)
            target_SNR_dB = -10;
            cfar_detection;
            
            % Purpose: Visualize the binary detection map and extract coordinates.
            figure('Name', 'CFAR Detection Result');
            
            % 1. Recalculate Range Axis
            % The RDM size changed when we sliced it. We must generate a new axis
            % that perfectly matches the number of columns in CFAR_map.
            max_range_calc = (c * fs) / (4 * S); % (c * Fs) / (4 * Slope)
            range_axis_cfar = linspace(0, max_range_calc, Nr);
            
            % 2. Plot the Map
            % Note: Using imagesc(x, y, C) where X=Range, Y=Velocity
            imagesc(range_axis_cfar, velocity_axis, CFAR_map);
            colormap(flipud(gray)); % White background, Black detection points
            xlabel('Range (m)');
            ylabel('Velocity (m/s)');
            title(sprintf('CFAR Detection Map (Offset = %d dB)', offset_dB));
            grid on;
            set(gca, 'YDir', 'normal'); % Fix Y-axis direction
            
            % 3. Extract and Print Coordinates
            [row_indices, col_indices] = find(CFAR_map == 1);
            
            if ~isempty(row_indices)
                % Calculate the center of mass of the detection cluster
                vel_idx_center = round(mean(row_indices));
                rng_idx_center = round(mean(col_indices));
                
                % Map indices to real-world physical units
                detected_velocity = velocity_axis(vel_idx_center);
                detected_range    = range_axis_cfar(rng_idx_center);
                
                fprintf('\n------------------------------\n');
                fprintf('✅ CFAR Detection Successful!\n');
                fprintf('------------------------------\n');
                fprintf('Detected Coordinates:\n');
                fprintf(' -> Velocity: %.2f m/s\n', detected_velocity);
                fprintf(' -> Range:    %.2f m\n', detected_range);
            else
                fprintf('\n❌ No Target Detected.\n');
                fprintf('Try lowering the Offset or adjusting Guard Cells.\n');
            end
        end
    end
end