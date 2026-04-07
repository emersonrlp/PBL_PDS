% =========================================================================
% MAIN_FAST.m - High-Performance DSP Pipeline (FFT & High-Order FIR)
% =========================================================================
pkg load signal;
clear; clc;

% =========================================================================
% SECTION 1: SETUP AND INITIALIZATION
% =========================================================================
fprintf('\n[1/4] STARTING HIGH-SPEED DSP PIPELINE...\n'); fflush(stdout);
load('x1_e_x2.mat');

fs_1 = 15000;
fs_2 = 10000;
fs_target = 30000;

L1 = fs_target / fs_1; % Upsampling factor for Signal 1 (L=2)
L2 = fs_target / fs_2; % Upsampling factor for Signal 2 (L=3)

% HIGH-PERFORMANCE UPGRADE: Massive filter order for brick-wall cutoff
filt_order = 1000;

% Create and open the text file for the metrics report
fid = fopen('metrics_report_fast.txt', 'w');
fprintf(fid, '--- DSP PROJECT METRICS REPORT (FAST FFT VERSION) ---\n');
fprintf(fid, 'Target Common Frequency: %d Hz\n', fs_target);
fprintf(fid, 'FIR Filter Order: %d\n\n', filt_order);

% =========================================================================
% SECTION 2: SIGNAL 1 (15 kHz) - PROCESSING AND EVALUATION
% =========================================================================
fprintf('[2/4] PROCESSING SIGNAL 1 (15 kHz)...\n'); fflush(stdout);

% 2.1 - Original Signal FFT
fprintf('      -> Computing Original FFT...\n'); fflush(stdout);
[mag_x1_orig, f_axis_orig1] = compute_fast_spectrum(x1_15k, fs_1);

% 2.2 - Upsampling (With and Without Filter)
fprintf('      -> Upsampling (L=%d) and filtering...\n', L1); fflush(stdout);
x1_up_filt = upsample_channel(x1_15k, L1, filt_order);

fprintf('      -> Upsampling WITHOUT filtering (for visualization)...\n'); fflush(stdout);
x1_up_nofilt = zeros(1, length(x1_15k) * L1);
x1_up_nofilt(1:L1:end) = x1_15k(:)' * L1;

% 2.3 - Roundtrip Evaluation (Recovering the signal)
fprintf('      -> Downsampling to recover signal and calculate metrics...\n'); fflush(stdout);
x1_recovered = downsample_channel(x1_up_filt, L1, filt_order);
mse_x1 = calculate_mse(x1_15k, x1_recovered);
snr_x1 = calculate_snr(x1_15k, x1_recovered);

fprintf(fid, 'SIGNAL 1 EVALUATION (15 kHz -> 30 kHz -> 15 kHz):\n');
fprintf(fid, 'Mean Squared Error (MSE): %e\n', mse_x1);
fprintf(fid, 'Signal-to-Noise Ratio (SNR): %.2f dB\n\n', snr_x1);

% 2.4 - FFTs for Plots
fprintf('      -> Computing FFTs for Plotting...\n'); fflush(stdout);
[mag_x1_nofilt, f_axis_up] = compute_fast_spectrum(x1_up_nofilt, fs_target);
[mag_x1_filt, ~]           = compute_fast_spectrum(x1_up_filt, fs_target);
[mag_x1_rec, ~]            = compute_fast_spectrum(x1_recovered, fs_1);

% --- PLOT 1A: Upsampling Filter Evaluation ---
fig_eval1 = figure('Name', 'Signal 1: Filter Evaluation', 'Visible', 'off', 'Position', [0, 0, 1600, 900]);
subplot(2,1,1); plot(f_axis_up, mag_x1_nofilt, 'r'); grid on;
xlim([-fs_target/2, fs_target/2]); ylim([0, max(mag_x1_nofilt)*1.05]);
set(gca, 'XTick', -15000:2500:15000);
title('Signal 1 Upsampled WITHOUT Filter (Notice the False Images)'); ylabel('Magnitude');

subplot(2,1,2); plot(f_axis_up, mag_x1_filt, 'b'); grid on;
xlim([-fs_target/2, fs_target/2]); ylim([0, max(mag_x1_filt)*1.05]);
set(gca, 'XTick', -15000:2500:15000);
title('Signal 1 Upsampled WITH FIR Filter (Clean Spectrum)'); xlabel('Frequency (Hz)'); ylabel('Magnitude');
print(fig_eval1, '1A_Eval_Upsample_Sig1_Fast.png', '-dpng', '-r400');

% --- PLOT 1A-EXTRA: Filtered Signal ---
fig_filt1 = figure('Name', 'Signal 1: Filtered Zoom', 'Visible', 'off', 'Position', [0, 0, 1600, 600]);
plot(f_axis_up, mag_x1_filt, 'b', 'LineWidth', 1.2); grid on;
xlim([-5000, 5000]); ylim([0, max(mag_x1_filt)*1.05]); % Zoom brutal nos dados úteis
set(gca, 'XTick', -5000:500:5000); % Ticks detalhados revelando os 3kHz
title('Signal 1 Upsampled WITH FIR Filter (ISOLATED & ZOOMED)'); xlabel('Frequency (Hz)'); ylabel('Magnitude');
print(fig_filt1, '1A_Extra_Filtered_Zoom_Sig1_Fast.png', '-dpng', '-r400');

% --- PLOT 1B: Original vs Reconstructed ---
fig_rec1 = figure('Name', 'Signal 1: Original vs Recovered', 'Visible', 'off', 'Position', [0, 0, 1600, 900]);
subplot(2,1,1); plot(f_axis_orig1, mag_x1_orig, 'k'); grid on;
xlim([-5000, 5000]); ylim([0, max(mag_x1_orig)*1.05]); % Cortado os vazios além de 5kHz
set(gca, 'XTick', -5000:500:5000);
title('ORIGINAL Signal 1 Spectrum (15 kHz)'); ylabel('Magnitude');

subplot(2,1,2); plot(f_axis_orig1, mag_x1_rec, 'b'); grid on;
xlim([-5000, 5000]); ylim([0, max(mag_x1_rec)*1.05]);
set(gca, 'XTick', -5000:500:5000);
title('RECOVERED Signal 1 Spectrum (15 kHz)'); xlabel('Frequency (Hz)'); ylabel('Magnitude');
print(fig_rec1, '1B_Original_vs_Recovered_Sig1_Fast.png', '-dpng', '-r400');


% =========================================================================
% SECTION 3: SIGNAL 2 (10 kHz) - PROCESSING AND EVALUATION
% =========================================================================
fprintf('\n[3/4] PROCESSING SIGNAL 2 (10 kHz)...\n'); fflush(stdout);

% 3.1 - Original Signal FFT
fprintf('      -> Computing Original FFT...\n'); fflush(stdout);
[mag_x2_orig, f_axis_orig2] = compute_fast_spectrum(x2_10k, fs_2);

% 3.2 - Upsampling (With and Without Filter)
fprintf('      -> Upsampling (L=%d) and filtering...\n', L2); fflush(stdout);
x2_up_filt = upsample_channel(x2_10k, L2, filt_order);

fprintf('      -> Upsampling WITHOUT filtering (for visualization)...\n'); fflush(stdout);
x2_up_nofilt = zeros(1, length(x2_10k) * L2);
x2_up_nofilt(1:L2:end) = x2_10k(:)' * L2;

% 3.3 - Roundtrip Evaluation (Recovering the signal)
fprintf('      -> Downsampling to recover signal and calculate metrics...\n'); fflush(stdout);
x2_recovered = downsample_channel(x2_up_filt, L2, filt_order);
mse_x2 = calculate_mse(x2_10k, x2_recovered);
snr_x2 = calculate_snr(x2_10k, x2_recovered);

fprintf(fid, 'SIGNAL 2 EVALUATION (10 kHz -> 30 kHz -> 10 kHz):\n');
fprintf(fid, 'Mean Squared Error (MSE): %e\n', mse_x2);
fprintf(fid, 'Signal-to-Noise Ratio (SNR): %.2f dB\n\n', snr_x2);

% 3.4 - FFTs for Plots
fprintf('      -> Computing FFTs for Plotting...\n'); fflush(stdout);
[mag_x2_nofilt, ~] = compute_fast_spectrum(x2_up_nofilt, fs_target);
[mag_x2_filt, ~]   = compute_fast_spectrum(x2_up_filt, fs_target);
[mag_x2_rec, ~]    = compute_fast_spectrum(x2_recovered, fs_2);

% --- PLOT 2A: Upsampling Filter Evaluation ---
fig_eval2 = figure('Name', 'Signal 2: Filter Evaluation', 'Visible', 'off', 'Position', [0, 0, 1600, 900]);
subplot(2,1,1); plot(f_axis_up, mag_x2_nofilt, 'r'); grid on;
xlim([-fs_target/2, fs_target/2]); ylim([0, max(mag_x2_nofilt)*1.05]);
set(gca, 'XTick', -15000:2500:15000);
title('Signal 2 Upsampled WITHOUT Filter'); ylabel('Magnitude');

subplot(2,1,2); plot(f_axis_up, mag_x2_filt, 'b'); grid on;
xlim([-fs_target/2, fs_target/2]); ylim([0, max(mag_x2_filt)*1.05]);
set(gca, 'XTick', -15000:2500:15000);
title('Signal 2 Upsampled WITH FIR Filter'); xlabel('Frequency (Hz)'); ylabel('Magnitude');
print(fig_eval2, '2A_Eval_Upsample_Sig2_Fast.png', '-dpng', '-r400');

% --- PLOT 2A-EXTRA: Filtered Signal ---
fig_filt2 = figure('Name', 'Signal 2: Filtered Zoom', 'Visible', 'off', 'Position', [0, 0, 1600, 600]);
plot(f_axis_up, mag_x2_filt, 'b', 'LineWidth', 1.2); grid on;
xlim([-4500, 4500]); ylim([0, max(mag_x2_filt)*1.05]);
set(gca, 'XTick', -4500:500:4500);
title('Signal 2 Upsampled WITH FIR Filter (ISOLATED & ZOOMED)'); xlabel('Frequency (Hz)'); ylabel('Magnitude');
print(fig_filt2, '2A_Extra_Filtered_Zoom_Sig2_Fast.png', '-dpng', '-r400');

% --- PLOT 2B: Original vs Reconstructed ---
fig_rec2 = figure('Name', 'Signal 2: Original vs Recovered', 'Visible', 'off', 'Position', [0, 0, 1600, 900]);
subplot(2,1,1); plot(f_axis_orig2, mag_x2_orig, 'k'); grid on;
xlim([-4500, 4500]); ylim([0, max(mag_x2_orig)*1.05]);
set(gca, 'XTick', -4500:500:4500);
title('ORIGINAL Signal 2 Spectrum (10 kHz)'); ylabel('Magnitude');

subplot(2,1,2); plot(f_axis_orig2, mag_x2_rec, 'b'); grid on;
xlim([-4500, 4500]); ylim([0, max(mag_x2_rec)*1.05]);
set(gca, 'XTick', -4500:500:4500);
title('RECOVERED Signal 2 Spectrum (10 kHz)'); xlabel('Frequency (Hz)'); ylabel('Magnitude');
print(fig_rec2, '2B_Original_vs_Recovered_Sig2_Fast.png', '-dpng', '-r400');


% =========================================================================
% SECTION 4: FINAL COMBINATION AT 30 kHz
% =========================================================================
fprintf('\n[4/4] COMBINING SIGNALS AT 30 kHz...\n'); fflush(stdout);

% Align vectors to the same size before summing
min_len = min(length(x1_up_filt), length(x2_up_filt));
final_audio = x1_up_filt(1:min_len) + x2_up_filt(1:min_len);




% --- NOVO: FILTRO PASSA-BAIXAS DE 3 kHz ---
fprintf('      -> Aplicando filtro Passa-Baixas em 3 kHz...\n'); fflush(stdout);
fc_corte = 3000; % Frequência de corte desejada
Wn_corte = fc_corte / (fs_target / 2); % Frequência normalizada (Nyquist)
h_corte = fir1(filt_order, Wn_corte); % Cria o filtro com a ordem 1000
final_audio = filtfilt(h_corte, 1, final_audio); % Filtra o sinal sem atrasar a fase
% ------------------------------------------





fprintf('      -> Computing Final Combined FFT...\n'); fflush(stdout);
[mag_final, ~] = compute_fast_spectrum(final_audio, fs_target);

% --- PLOT 3: Final Combined Spectrum ---
fig_final = figure('Name', 'Final Combined Audio', 'Visible', 'off', 'Position', [0, 0, 1600, 900]);
plot(f_axis_up, mag_final, 'k', 'LineWidth', 1.2); grid on;
xlim([-5000, 5000]); ylim([0, max(mag_final)*1.05]);
set(gca, 'XTick', -5000:500:5000);
title('FINAL COMBINED SIGNAL SPECTRUM (30 kHz) - ZOOMED');
xlabel('Frequency (Hz)'); ylabel('Magnitude');
print(fig_final, '3_Final_Combined_Spectrum_Fast.png', '-dpng', '-r500');

% =========================================================================
% SECTION 5: FIR FILTERS FREQUENCY RESPONSE ANALYSIS
% =========================================================================
fprintf('\n[5/5] GENERATING FIR FILTER RESPONSES...\n'); fflush(stdout);

% Design the exact filters used in the upsampling/downsampling functions
Wn_1 = 1 / L1; % Cutoff for Signal 1
Wn_2 = 1 / L2; % Cutoff for Signal 2
h_filt1 = fir1(filt_order, Wn_1);
h_filt2 = fir1(filt_order, Wn_2);

% Compute frequency responses
[H1, f_H1] = freqz(h_filt1, 1, 2048, fs_target);
[H2, f_H2] = freqz(h_filt2, 1, 2048, fs_target);

% Convert to Decibels (dB)
mag_dB_H1 = 20*log10(abs(H1));
mag_dB_H2 = 20*log10(abs(H2));

% --- PLOT 4: FIR Filters Response ---
fig_filters = figure('Name', 'FIR Filters Frequency Response', 'Visible', 'off', 'Position', [0, 0, 1600, 900]);
plot(f_H1, mag_dB_H1, 'b', 'LineWidth', 1.5); hold on;
plot(f_H2, mag_dB_H2, 'r', 'LineWidth', 1.5); grid on;

% Visual limits and labels
xlim([0, fs_target/2]); ylim([-100, 10]);
title(sprintf('FIR Filters Frequency Response (Order: %d)', filt_order));
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');

% Dynamic legend based on calculated cutoff frequencies
legend(sprintf('Filter 1 (L=%d, Cutoff: %.0f Hz)', L1, (fs_target/2)*Wn_1), ...
       sprintf('Filter 2 (L=%d, Cutoff: %.0f Hz)', L2, (fs_target/2)*Wn_2), ...
       'Location', 'northeast');

print(fig_filters, '4_FIR_Filters_Response_Fast.png', '-dpng', '-r400');

% Close the text file and finalize
fclose(fid);
fprintf('\n>>> FAST PIPELINE COMPLETE! High-res plots and metrics saved successfully. <<<\n\n'); fflush(stdout);

% =========================================================================
% SECTION 6: EXTRA SESSION - DOWNSAMPLING TO 5 kHz
% =========================================================================
fprintf('\n[6/6] EXTRA SESSION: DOWNSAMPLING TO 5 kHz...\n'); fflush(stdout);

% Define target frequency and downsampling factors
fs_down = 5000;
M1 = fs_1 / fs_down; % 15000 / 5000 = 3
M2 = fs_2 / fs_down; % 10000 / 5000 = 2

% Downsample channels
fprintf('      -> Downsampling Signal 1 (M=%d) and Signal 2 (M=%d)...\n', M1, M2); fflush(stdout);
x1_down_filt = downsample_channel(x1_15k, M1, filt_order);
x2_down_filt = downsample_channel(x2_10k, M2, filt_order);

% Compute FFTs and capture the correct frequency axis for 5 kHz
fprintf('      -> Computing FFTs for downsampled signals...\n'); fflush(stdout);
[mag_x1_down, f_axis_down] = compute_fast_spectrum(x1_down_filt, fs_down);
[mag_x2_down, ~]           = compute_fast_spectrum(x2_down_filt, fs_down);

% --- PLOT 5A: Downsampled Signal 1 ---
fig_down1 = figure('Name', 'Signal 1: Downsampled to 5kHz', 'Visible', 'off', 'Position', [0, 0, 1600, 600]);
plot(f_axis_down, mag_x1_down, 'b', 'LineWidth', 1.2); grid on;
xlim([-fs_down, fs_down]); ylim([0, max(mag_x1_down)*1.05]);
set(gca, 'XTick', -2500:500:2500); % Ticks specific for 5kHz Nyquist limit
title('Signal 1 DOWNSAMPLED to 5 kHz (fs = 5 kHz)'); xlabel('Frequency (Hz)'); ylabel('Magnitude');
print(fig_down1, '5A_Downsampled_Sig1_5kHz.png', '-dpng', '-r400');

fig_orig1 = figure('Name', 'Signal 1: Original', 'Visible', 'off', 'Position', [0, 0, 1600, 900]);
subplot(2,1,1); plot(f_axis_orig1, mag_x1_orig, 'k'); grid on;
xlim([-5000, 5000]); ylim([0, max(mag_x1_orig)*1.05]); % Cortado os vazios além de 5kHz
set(gca, 'XTick', -5000:500:5000);
title('ORIGINAL Signal 1 Spectrum (15 kHz)'); ylabel('Magnitude');
print(fig_orig1, '1_Original.png', '-dpng', '-r400');


% --- PLOT 5B: Downsampled Signal 2 ---
fig_down2 = figure('Name', 'Signal 2: Downsampled to 5kHz', 'Visible', 'off', 'Position', [0, 0, 1600, 600]);
plot(f_axis_down, mag_x2_down, 'r', 'LineWidth', 1.2); grid on;
xlim([-fs_down, fs_down]); ylim([0, max(mag_x2_down)*1.05]);
set(gca, 'XTick', -2500:500:2500);
title('Signal 2 DOWNSAMPLED to 5 kHz (fs = 5 kHz)'); xlabel('Frequency (Hz)'); ylabel('Magnitude');
print(fig_down2, '5B_Downsampled_Sig2_5kHz.png', '-dpng', '-r400');

fig_orig2 = figure('Name', 'Signal 2: Original vs Recovered', 'Visible', 'off', 'Position', [0, 0, 1600, 900]);
subplot(2,1,1); plot(f_axis_orig2, mag_x2_orig, 'k'); grid on;
xlim([-4500, 4500]); ylim([0, max(mag_x2_orig)*1.05]);
set(gca, 'XTick', -4500:500:4500);
title('ORIGINAL Signal 2 Spectrum (10 kHz)'); ylabel('Magnitude');
print(fig_orig2, '2_Original.png', '-dpng', '-r400');

fprintf('      -> Extra session complete!\n'); fflush(stdout);


% =========================================================================
% REPRODUÇÃO DO ÁUDIO
% =========================================================================
fprintf('\n====================================================\n');
fprintf(' Pressione ENTER na Command Window para ouvir o áudio!\n');
fprintf('====================================================\n');

%pause; % Este é o comando mágico que congela o script até o ENTER ser pressionado

%soundsc(final_audio, fs_target); % Toca o áudio com volume normalizado
