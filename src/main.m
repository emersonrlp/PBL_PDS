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
res = 2000;

% Create and open the text file for the metrics report
fid = fopen('metrics_report.txt', 'w');
fprintf(fid, '--- DSP PROJECT METRICS REPORT ---\n');
fprintf(fid, 'Target Common Frequency: %d Hz\n\n', fs_target);

% =========================================================================
% 2. Signal 1 (15kHz) - Processing and Pipeline Evaluation
% =========================================================================
fprintf('2. Processing Signal 1 (15 kHz) and Calculating Metrics...\n'); fflush(stdout);

% A. Upsampling WITH Filter (The correct way)
x1_up_filt = upsample_channel(x1_15k, L1, filt_order);

% B. Upsampling WITHOUT Filter (To prove the appearance of spectral images)
x1_up_nofilt = zeros(1, length(x1_15k) * L1);
x1_up_nofilt(1:L1:end) = x1_15k * L1;

% C. Evaluation (Roundtrip: Upsample -> Downsample back to 15kHz)
x1_recovered = downsample_channel(x1_up_filt, L1, filt_order);
mse_x1 = calculate_mse(x1_15k, x1_recovered);
snr_x1 = calculate_snr(x1_15k, x1_recovered);

% Write Signal 1 metrics to file
fprintf(fid, 'SIGNAL 1 EVALUATION (15 kHz -> 30 kHz -> 15 kHz):\n');
fprintf(fid, 'Mean Squared Error (MSE): %e\n', mse_x1);
fprintf(fid, 'Signal-to-Noise Ratio (SNR): %.2f dB\n\n', snr_x1);

% D. Compute DTFT to visualize the filter's action
fprintf('   -> Computing DTFTs for Signal 1... \n'); fflush(stdout);
[mag_x1_nofilt, w_up] = compute_dtft(x1_up_nofilt, res);
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

% =========================================================================
% 3. Signal 2 (10kHz) - Processing and Pipeline Evaluation
% =========================================================================
fprintf('3. Processing Signal 2 (10 kHz) and Calculating Metrics...\n'); fflush(stdout);

% A. Upsampling WITH Filter
x2_up_filt = upsample_channel(x2_10k, L2, filt_order);

% B. Evaluation (Roundtrip: Upsample -> Downsample back to 10kHz)
x2_recovered = downsample_channel(x2_up_filt, L2, filt_order);
mse_x2 = calculate_mse(x2_10k, x2_recovered);
snr_x2 = calculate_snr(x2_10k, x2_recovered);

% Write Signal 2 metrics to file
fprintf(fid, 'SIGNAL 2 EVALUATION (10 kHz -> 30 kHz -> 10 kHz):\n');
fprintf(fid, 'Mean Squared Error (MSE): %e\n', mse_x2);
fprintf(fid, 'Signal-to-Noise Ratio (SNR): %.2f dB\n\n', snr_x2);

% Compute DTFT for Signal 2
fprintf('   -> Computing DTFT for Signal 2... \n'); fflush(stdout);
[mag_x2_filt, ~] = compute_dtft(x2_up_filt, res);

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
