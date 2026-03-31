% =========================================================================
% MAIN.m - Full DSP Pipeline for Resampling, Evaluation, and Combination
% =========================================================================
pkg load signal;
clear; clc;

% 1. Setup and Initialization
fprintf('1. Starting DSP Pipeline and Loading Data...\n'); fflush(stdout);
load('x1_e_x2.mat');

fs_1 = 15000;
fs_2 = 10000;
fs_target = 30000;

L1 = fs_target / fs_1; % Upsampling factor for Signal 1 (L=2)
L2 = fs_target / fs_2; % Upsampling factor for Signal 2 (L=3)
filt_order = 150;
res = 1000;

% Create and open the text file for the metrics report
fid = fopen('metrics_report.txt', 'w');
fprintf(fid, '--- DSP PROJECT METRICS REPORT ---\n');
fprintf(fid, 'Target Common Frequency: %d Hz\n\n', fs_target);

% =========================================================================
% 2. Signal 1 (15kHz) - Processing and Pipeline Evaluation
% =========================================================================
fprintf('2. Processing Signal 1 (15 kHz) and Calculating Metrics...\n'); fflush(stdout);

% Original Signal 1's Spectrum
fprintf('   -> Computing Original DTFT for Signal 1... \n'); fflush(stdout);
[mag_x1_orig, w_orig1] = compute_dtft(x1_15k, res);
f_axis_orig1 = (w_orig1 / (2*pi)) * fs_1;

% A. Upsampling WITH Filter (The correct way)
fprintf('   -> Upsampling Signal 1 and filtering... \n'); fflush(stdout);
x1_up_filt = upsample_channel(x1_15k, L1, filt_order);

% B. Upsampling WITHOUT Filter (To prove the appearance of spectral images)
fprintf('   -> Upsampling Signal 1 w/o filtering... \n'); fflush(stdout);
x1_up_nofilt = zeros(1, length(x1_15k) * L1);
x1_up_nofilt(1:L1:end) = x1_15k * L1;

% C. Evaluation (Roundtrip: Upsample -> Downsample back to 15kHz)
fprintf('   -> Roundtripping Signal 1... \n'); fflush(stdout);
x1_recovered = downsample_channel(x1_up_filt, L1, filt_order);
mse_x1 = calculate_mse(x1_15k, x1_recovered);
snr_x1 = calculate_snr(x1_15k, x1_recovered);

% Write Signal 1 metrics to file
fprintf(fid, 'SIGNAL 1 EVALUATION (15 kHz -> 30 kHz -> 15 kHz):\n');
fprintf(fid, 'Mean Squared Error (MSE): %e\n', mse_x1);
fprintf(fid, 'Signal-to-Noise Ratio (SNR): %.2f dB\n\n', snr_x1);

% D. Compute DTFT to visualize the filter's action
fprintf('   -> Computing DTFTs for no filtered Signal 1... \n'); fflush(stdout);
[mag_x1_nofilt, w_up] = compute_dtft(x1_up_nofilt, res);
fprintf('   -> Computing DTFTs for filtered Signal 1... \n'); fflush(stdout);
[mag_x1_filt, ~]      = compute_dtft(x1_up_filt, res);
f_axis_up = (w_up / (2*pi)) * fs_target;

% Save Signal 1 Plot
fig1 = figure('Name', 'Signal 1: Filter Evaluation', 'Visible', 'off');
subplot(2,1,1); plot(f_axis_up, mag_x1_nofilt, 'r'); grid on; xlim([-fs_target/2, fs_target/2]);
title('Signal 1 Upsampled WITHOUT Filter (Notice the False Images)');
ylabel('Magnitude');
subplot(2,1,2); plot(f_axis_up, mag_x1_filt, 'b'); grid on; xlim([-fs_target/2, fs_target/2]);
title('Signal 1 Upsampled WITH FIR Filter (Clean Spectrum)');
xlabel('Frequency (Hz)'); ylabel('Magnitude');
print(fig1, 'Evaluation_Signal_1.png', '-dpng', '-r300');

% Save Original Signal 1 Spectrum Plot
fig_orig1 = figure('Name', 'Original Signal 1', 'Visible', 'off');
plot(f_axis_orig1, mag_x1_orig, 'b', 'LineWidth', 1.2); grid on; xlim([-fs_1/2, fs_1/2]);
title('Original Signal 1 Spectrum (15 kHz)');
xlabel('Frequency (Hz)'); ylabel('Magnitude');
print(fig_orig1, 'Original_Signal_1.png', '-dpng', '-r300');

% =========================================================================
% 3. Signal 2 (10kHz) - Processing and Pipeline Evaluation
% =========================================================================
fprintf('3. Processing Signal 2 (10 kHz) and Calculating Metrics...\n'); fflush(stdout);

% Original Signal 2's Spectrum
fprintf('   -> Computing Original DTFT for Signal 2... \n'); fflush(stdout);
[mag_x2_orig, w_orig2] = compute_dtft(x2_10k, res);
f_axis_orig2 = (w_orig2 / (2*pi)) * fs_2;

% A. Upsampling WITH Filter
fprintf('   -> Upsampling Signal 2 and filtering... \n'); fflush(stdout);
x2_up_filt = upsample_channel(x2_10k, L2, filt_order);

% B. Upsampling WITHOUT Filter for Signal 2 (For plotting)
fprintf('   -> Upsampling Signal 2 w/o filtering... \n'); fflush(stdout);
x2_up_nofilt = zeros(1, length(x2_10k) * L2);
x2_up_nofilt(1:L2:end) = x2_10k * L2;

% C. Evaluation (Roundtrip: Upsample -> Downsample back to 10kHz)
fprintf('   -> Roundtripping Signal 2... \n'); fflush(stdout);
x2_recovered = downsample_channel(x2_up_filt, L2, filt_order);
mse_x2 = calculate_mse(x2_10k, x2_recovered);
snr_x2 = calculate_snr(x2_10k, x2_recovered);

% Write Signal 2 metrics to file
fprintf(fid, 'SIGNAL 2 EVALUATION (10 kHz -> 30 kHz -> 10 kHz):\n');
fprintf(fid, 'Mean Squared Error (MSE): %e\n', mse_x2);
fprintf(fid, 'Signal-to-Noise Ratio (SNR): %.2f dB\n\n', snr_x2);

% D. Compute DTFT for Signal 2
fprintf('   -> Computing DTFTs for no filtered Signal 2... \n'); fflush(stdout);
[mag_x2_nofilt, ~] = compute_dtft(x2_up_nofilt, res);
fprintf('   -> Computing DTFTs for filtered Signal 2... \n'); fflush(stdout);
[mag_x2_filt, ~]   = compute_dtft(x2_up_filt, res);

% Save Signal 2 Plot
fig_s2 = figure('Name', 'Signal 2: Filter Evaluation', 'Visible', 'off');
subplot(2,1,1); plot(f_axis_up, mag_x2_nofilt, 'r'); grid on; xlim([-fs_target/2, fs_target/2]);
title('Signal 2 Upsampled WITHOUT Filter');
ylabel('Magnitude');
subplot(2,1,2); plot(f_axis_up, mag_x2_filt, 'b'); grid on; xlim([-fs_target/2, fs_target/2]);
title('Signal 2 Upsampled WITH FIR Filter');
xlabel('Frequency (Hz)'); ylabel('Magnitude');
print(fig_s2, 'Evaluation_Signal_2.png', '-dpng', '-r300');

% Save Original Signal 2 Spectrum Plot
fig_orig2 = figure('Name', 'Original Signal 2', 'Visible', 'off');
plot(f_axis_orig2, mag_x2_orig, 'r', 'LineWidth', 1.2); grid on; xlim([-fs_2/2, fs_2/2]);
title('Original Signal 2 Spectrum (10 kHz)');
xlabel('Frequency (Hz)'); ylabel('Magnitude');
print(fig_orig2, 'Original_Signal_2.png', '-dpng', '-r300');

% =========================================================================
% 4. Final Combination at 30 kHz
% =========================================================================
fprintf('4. Combining Signals at 30 kHz...\n'); fflush(stdout);

% Align vectors to the same size before summing
min_len = min(length(x1_up_filt), length(x2_up_filt));
final_audio = x1_up_filt(1:min_len) + x2_up_filt(1:min_len);

fprintf('   -> Computing Final Combined DTFT...\n'); fflush(stdout);
[mag_final, ~] = compute_dtft(final_audio, res);

% Save Final Combined Plot
fig2 = figure('Name', 'Final Combined Audio', 'Visible', 'off');
plot(f_axis_up, mag_final, 'k', 'LineWidth', 1.2); grid on; xlim([-fs_target/2, fs_target/2]);
title('Final Combined Signal Spectrum (30 kHz)');
xlabel('Frequency (Hz)'); ylabel('Magnitude');
print(fig2, 'Final_Combined_Spectrum.png', '-dpng', '-r300');

% Close the text file and finalize
fclose(fid);
fprintf('5. Pipeline Complete! Check the saved .txt and .png files in your folder.\n'); fflush(stdout);
