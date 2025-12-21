% =========================================================================
% Task 2.2 Tests
% Phase 2, Task 2.3: Range Estimation
% =========================================================================

classdef Task_2_3_Test < matlab.unittest.TestCase
    % Runs once before the file starts to allocate file path
    methods (TestClassSetup)
        function addProjectFolderToPath(testCase)
            import matlab.unittest.fixtures.PathFixture
            testCase.applyFixture(PathFixture('../App'));
        end
    end
    
    methods (Test)
        function testRangeAccuracy(testCase)
            % Run the simulation scripts to get data
            range_estimation;

            % We allow a tolerance of +/- 1.5 meters (Range Resolution + margin)
            testCase.verifyEqual(calculated_range, target_range, 'AbsTol', 1.5);
        end

        function testSignalToNoiseRatio(testCase)
            % This ensures the target is clearly visible above the noise floor
            signal_mixer;
            
            N = 2^12;
            spectrum = abs(fft(Mx, N));
            half_spectrum = spectrum(1:N/2+1);
            
            [peak_val, peak_idx] = max(half_spectrum);
            
            % Remove the peak (and neighbors) to estimate the noise floor
            % We simply ignore the immediate area around the target
            noise_floor_indices = [1:peak_idx-5, peak_idx+5:length(half_spectrum)];
            noise_floor = mean(half_spectrum(noise_floor_indices));
            
            % Check if Peak is at least 10x (20dB) higher than noise
            testCase.verifyGreaterThan(peak_val, 10 * noise_floor);
        end
        
        function testGhostRejection(testCase)
             % This ensures we aren't detecting the "Negative Frequency" alias
             % The spectrum should be mostly empty at the very high end (near Fs/2)
             signal_mixer;
             
             N = 2048;
             spectrum = abs(fft(Mx, N));
             
             % Check the last 10% of the spectrum (highest frequencies)
             % For a target at 50m (Low Freq), this area should be silence/noise.
             high_freq_noise = mean(spectrum(end-100:end));
             peak_val = max(spectrum);
             
             % The high freq noise should be tiny (< 1% of peak)
             testCase.verifyLessThan(high_freq_noise, 0.01 * peak_val);
        end

        function testSignalManual(testCase)
            range_estimation;
            figure;
            subplot 211;
            plot(frequency, abs(y_normalised));
            grid on;
            title("Magnitude plot of FFT");
            ylabel("Magnitude");

            subplot 212;
            plot(frequency, angle(y_normalised));
            grid on;
            title("Phase plot of FFT");
            xlabel("Frequency (Hz)");
            ylabel("Phase (rad)");
        end
    end
end