% =========================================================================
% MAIN_FAST.m - High-Performance DSP Pipeline (FFT & High-Order FIR)
% =========================================================================
pkg load signal;
clear; clc;

% ----------------------
addpath('data');
addpath('utils');
% ----------------------

% =========================================================================
% SECTION 1: SETUP AND INITIALIZATION
% =========================================================================
fprintf('\n[1/5] STARTING HIGH-SPEED DSP PIPELINE...\n'); fflush(stdout);
load('x1_e_x2.mat');

fs_1 = 15000;
fs_2 = 10000;
fs_target = 30000;

L1 = fs_target / fs_1; % Upsampling factor for Signal 1 (L=2)
L2 = fs_target / fs_2; % Upsampling factor for Signal 2 (L=3)

% HIGH-PERFORMANCE UPGRADE: Massive filter order for brick-wall cutoff
filt_order = 1000;

% Create and open the text file for the metrics report
if ~exist('results', 'dir')
    mkdir('results');
end
fid = fopen('results/metrics_report_fast.txt', 'w');
fprintf(fid, '--- DSP PROJECT METRICS REPORT (FAST FFT VERSION) ---\n');
fprintf(fid, 'Target Common Frequency: %d Hz\n', fs_target);
fprintf(fid, 'FIR Filter Order: %d\n\n', filt_order);

% =========================================================================
% SECTION 2: SIGNAL 1 (15 kHz) - PRE-FILTERING, UPSAMPLING & EVALUATION
% =========================================================================
fprintf('[2/5] PROCESSING SIGNAL 1 (15 kHz)...\n'); fflush(stdout);

% 2.1 - Original Raw Spectrum
fprintf('      -> Computing Original Raw Spectrum...\n'); fflush(stdout);
[mag_x1_raw, f_axis_orig1] = compute_fast_spectrum(x1_15k, fs_1);
mag_x1_raw = mag_x1_raw / max(mag_x1_raw);

% 2.2 - Pre-filtering (3 kHz Noise Removal)
fprintf('      -> Applying Pre-Processing Noise Filter (3 kHz)...\n'); fflush(stdout);
fc_noise = 3000;
Wn_noise1 = fc_noise / (fs_1 / 2);
h_noise1 = fir1(filt_order, Wn_noise1);
x1_clean = filtfilt(h_noise1, 1, x1_15k);

[mag_x1_clean, ~] = compute_fast_spectrum(x1_clean, fs_1);
mag_x1_clean = mag_x1_clean / max(mag_x1_clean);

% 2.3 - Upsampling (With and Without Filter) using CLEANED signal
fprintf('      -> Upsampling (L=%d) and filtering...\n', L1); fflush(stdout);
x1_up_filt = upsample_channel(x1_clean, L1, filt_order);

fprintf('      -> Upsampling WITHOUT filtering...\n'); fflush(stdout);
x1_up_nofilt = zeros(1, length(x1_clean) * L1);
x1_up_nofilt(1:L1:end) = x1_clean(:)' * L1;

% 2.4 - Roundtrip Evaluation (Compared against CLEAN signal)
fprintf('      -> Downsampling to calculate metrics...\n'); fflush(stdout);
x1_recovered = downsample_channel(x1_up_filt, L1, filt_order);
mse_x1 = calculate_mse(x1_clean, x1_recovered);
snr_x1 = calculate_snr(x1_clean, x1_recovered);

fprintf(fid, 'SIGNAL 1 EVALUATION (15 kHz -> 30 kHz -> 15 kHz):\n');
fprintf(fid, 'Mean Squared Error (MSE): %e\n', mse_x1);
fprintf(fid, 'Signal-to-Noise Ratio (SNR): %.2f dB\n\n', snr_x1);

% 2.5 - Spectra for Plots
fprintf('      -> Computing Spectra for Plotting...\n'); fflush(stdout);
[mag_x1_up_nofilt, f_axis_up] = compute_fast_spectrum(x1_up_nofilt, fs_target);
[mag_x1_up_filt, ~]           = compute_fast_spectrum(x1_up_filt, fs_target);
[mag_x1_rec, ~]               = compute_fast_spectrum(x1_recovered, fs_1);

mag_x1_up_nofilt = mag_x1_up_nofilt / max(mag_x1_up_nofilt);
mag_x1_up_filt   = mag_x1_up_filt / max(mag_x1_up_filt);
mag_x1_rec       = mag_x1_rec / max(mag_x1_rec);

% --- PLOTS SIGNAL 1 ---
fig1 = figure('Visible', 'off', 'Position', [0, 0, 1600, 600]);
plot(f_axis_orig1, mag_x1_raw, 'k', 'LineWidth', 1.2); grid on;
xlim([0, fs_1/2]); ylim([0, 1.05]); set(gca, 'XTick', 0:750:fs_1/2);
title('Espectro do sinal x1[n] original');
xlabel('Frequência (Hz)'); ylabel('Magnitude Normalizada');
print(fig1, 'results/Original_Raw_Sig1_Fast.png', '-dpng', '-r400');

fig3 = figure('Visible', 'off', 'Position', [0, 0, 1600, 600]);
plot(f_axis_orig1, mag_x1_clean, 'b', 'LineWidth', 1.2); grid on;
xlim([0, fs_1/2]); ylim([0, 1.05]); set(gca, 'XTick', 0:750:fs_1/2);
title('Sinal x1[n] após a aplicação do filtro FIR passa-baixa (3 kHz)');
xlabel('Frequência (Hz)'); ylabel('Magnitude Normalizada');
print(fig3, 'results/PreFiltered_Clean_Sig1_Fast.png', '-dpng', '-r400');

fig6 = figure('Visible', 'off', 'Position', [0, 0, 1600, 600]);
plot(f_axis_up, mag_x1_up_nofilt, 'r', 'LineWidth', 1.2); grid on;
xlim([0, fs_target/2]); ylim([0, 1.05]); set(gca, 'XTick', 0:1500:15000);
title('Espectro do sinal x1[n] após superamostragem (L=2) sem filtragem');
xlabel('Frequência (Hz)'); ylabel('Magnitude Normalizada');
print(fig6, 'results/Upsample_NoFilt_Sig1_Fast.png', '-dpng', '-r400');

fig7 = figure('Visible', 'off', 'Position', [0, 0, 1600, 600]);
plot(f_axis_up, mag_x1_up_filt, 'b', 'LineWidth', 1.2); grid on;
xlim([0, fs_target/2]); ylim([0, 1.05]); set(gca, 'XTick', 0:1500:15000);
title('Espectro do sinal x1[n] após a aplicação do filtro interpolador (L=2)');
xlabel('Frequência (Hz)'); ylabel('Magnitude Normalizada');
print(fig7, 'results/Upsample_Filt_Sig1_Fast.png', '-dpng', '-r400');

fig_rec1 = figure('Visible', 'off', 'Position', [0, 0, 1600, 900]);
subplot(2,1,1); plot(f_axis_orig1, mag_x1_clean, 'k', 'LineWidth', 1.2); grid on;
xlim([0, fs_1/2]); ylim([0, 1.05]); set(gca, 'XTick', 0:750:fs_1/2);
title('Sinal x1[n] Limpo (Referência pré-reamostragem)');
xlabel('Frequência (Hz)'); ylabel('Magnitude Normalizada');
subplot(2,1,2); plot(f_axis_orig1, mag_x1_rec, 'b', 'LineWidth', 1.2); grid on;
xlim([0, fs_1/2]); ylim([0, 1.05]); set(gca, 'XTick', 0:750:fs_1/2);
title('Sinal x1[n] Recuperado (Após super e subamostragem)');
xlabel('Frequência (Hz)'); ylabel('Magnitude Normalizada');
print(fig_rec1, 'results/Comparacao_Roundtrip_Sig1_Fast.png', '-dpng', '-r400');

% =========================================================================
% SECTION 3: SIGNAL 2 (10 kHz) - PRE-FILTERING, UPSAMPLING & EVALUATION
% =========================================================================
fprintf('\n[3/5] PROCESSING SIGNAL 2 (10 kHz)...\n'); fflush(stdout);

% 3.1 - Original Raw Spectrum
fprintf('      -> Computing Original Raw Spectrum...\n'); fflush(stdout);
[mag_x2_raw, f_axis_orig2] = compute_fast_spectrum(x2_10k, fs_2);
mag_x2_raw = mag_x2_raw / max(mag_x2_raw);

% 3.2 - Pre-filtering (3 kHz Noise Removal)
fprintf('      -> Applying Pre-Processing Noise Filter (3 kHz)...\n'); fflush(stdout);
Wn_noise2 = fc_noise / (fs_2 / 2);
h_noise2 = fir1(filt_order, Wn_noise2);
x2_clean = filtfilt(h_noise2, 1, x2_10k);

[mag_x2_clean, ~] = compute_fast_spectrum(x2_clean, fs_2);
mag_x2_clean = mag_x2_clean / max(mag_x2_clean);

% 3.3 - Upsampling (With and Without Filter) using CLEANED signal
fprintf('      -> Upsampling (L=%d) and filtering...\n', L2); fflush(stdout);
x2_up_filt = upsample_channel(x2_clean, L2, filt_order);

fprintf('      -> Upsampling WITHOUT filtering...\n'); fflush(stdout);
x2_up_nofilt = zeros(1, length(x2_clean) * L2);
x2_up_nofilt(1:L2:end) = x2_clean(:)' * L2;

% 3.4 - Roundtrip Evaluation (Compared against CLEAN signal)
fprintf('      -> Downsampling to calculate metrics...\n'); fflush(stdout);
x2_recovered = downsample_channel(x2_up_filt, L2, filt_order);
mse_x2 = calculate_mse(x2_clean, x2_recovered);
snr_x2 = calculate_snr(x2_clean, x2_recovered);

fprintf(fid, 'SIGNAL 2 EVALUATION (10 kHz -> 30 kHz -> 10 kHz):\n');
fprintf(fid, 'Mean Squared Error (MSE): %e\n', mse_x2);
fprintf(fid, 'Signal-to-Noise Ratio (SNR): %.2f dB\n\n', snr_x2);

% 3.5 - Spectra for Plots
fprintf('      -> Computing Spectra for Plotting...\n'); fflush(stdout);
[mag_x2_up_nofilt, ~] = compute_fast_spectrum(x2_up_nofilt, fs_target);
[mag_x2_up_filt, ~]   = compute_fast_spectrum(x2_up_filt, fs_target);
[mag_x2_rec, ~]       = compute_fast_spectrum(x2_recovered, fs_2);

mag_x2_up_nofilt = mag_x2_up_nofilt / max(mag_x2_up_nofilt);
mag_x2_up_filt   = mag_x2_up_filt / max(mag_x2_up_filt);
mag_x2_rec       = mag_x2_rec / max(mag_x2_rec);

% --- PLOTS SIGNAL 2 ---
fig2 = figure('Visible', 'off', 'Position', [0, 0, 1600, 600]);
plot(f_axis_orig2, mag_x2_raw, 'k', 'LineWidth', 1.2); grid on;
xlim([0, fs_2/2]); ylim([0, 1.05]); set(gca, 'XTick', 0:500:fs_2/2);
title('Espectro do sinal x2[n] original');
xlabel('Frequência (Hz)'); ylabel('Magnitude Normalizada');
print(fig2, 'results/Original_Raw_Sig2_Fast.png', '-dpng', '-r400');

fig4 = figure('Visible', 'off', 'Position', [0, 0, 1600, 600]);
plot(f_axis_orig2, mag_x2_clean, 'b', 'LineWidth', 1.2); grid on;
xlim([0, fs_2/2]); ylim([0, 1.05]); set(gca, 'XTick', 0:500:fs_2/2);
title('Sinal x2[n] após a aplicação do filtro FIR passa-baixa (3 kHz)');
xlabel('Frequência (Hz)'); ylabel('Magnitude Normalizada');
print(fig4, 'results/PreFiltered_Clean_Sig2_Fast.png', '-dpng', '-r400');

fig8 = figure('Visible', 'off', 'Position', [0, 0, 1600, 600]);
plot(f_axis_up, mag_x2_up_nofilt, 'r', 'LineWidth', 1.2); grid on;
xlim([0, fs_target/2]); ylim([0, 1.05]); set(gca, 'XTick', 0:1500:15000);
title('Espectro do sinal x2[n] após superamostragem (L=3) sem filtragem');
xlabel('Frequência (Hz)'); ylabel('Magnitude Normalizada');
print(fig8, 'results/Upsample_NoFilt_Sig2_Fast.png', '-dpng', '-r400');

fig9 = figure('Visible', 'off', 'Position', [0, 0, 1600, 600]);
plot(f_axis_up, mag_x2_up_filt, 'b', 'LineWidth', 1.2); grid on;
xlim([0, fs_target/2]); ylim([0, 1.05]); set(gca, 'XTick', 0:1500:15000);
title('Espectro do sinal x2[n] após a aplicação do filtro interpolador (L=3)');
xlabel('Frequência (Hz)'); ylabel('Magnitude Normalizada');
print(fig9, 'results/Upsample_Filt_Sig2_Fast.png', '-dpng', '-r400');

fig_rec2 = figure('Visible', 'off', 'Position', [0, 0, 1600, 900]);
subplot(2,1,1); plot(f_axis_orig2, mag_x2_clean, 'k', 'LineWidth', 1.2); grid on;
xlim([0, fs_2/2]); ylim([0, 1.05]); set(gca, 'XTick', 0:500:fs_2/2);
title('Sinal x2[n] Limpo (Referência pré-reamostragem)');
xlabel('Frequência (Hz)'); ylabel('Magnitude Normalizada');
subplot(2,1,2); plot(f_axis_orig2, mag_x2_rec, 'b', 'LineWidth', 1.2); grid on;
xlim([0, fs_2/2]); ylim([0, 1.05]); set(gca, 'XTick', 0:500:fs_2/2);
title('Sinal x2[n] Recuperado (Após super e subamostragem)');
xlabel('Frequência (Hz)'); ylabel('Magnitude Normalizada');
print(fig_rec2, 'results/Comparacao_Roundtrip_Sig2_Fast.png', '-dpng', '-r400');

% =========================================================================
% SECTION 4: FINAL COMBINATION & TIME DOMAIN
% =========================================================================
fprintf('\n[4/5] COMBINING CLEAN SIGNALS...\n'); fflush(stdout);

% Align vectors to the same size before summing
min_len = min(length(x1_up_filt), length(x2_up_filt));
final_audio = x1_up_filt(1:min_len) + x2_up_filt(1:min_len);

fprintf('      -> Computing Final Combined Spectrum...\n'); fflush(stdout);
[mag_final, ~] = compute_fast_spectrum(final_audio, fs_target);
mag_final = mag_final / max(mag_final);

fig_final_freq = figure('Visible', 'off', 'Position', [0, 0, 1600, 600]);
plot(f_axis_up, mag_final, 'k', 'LineWidth', 1.2); grid on;
xlim([0, 5000]); ylim([0, 1.05]); set(gca, 'XTick', 0:250:5000);
title('Espectro do Sinal Combinado Final (fs = 30 kHz)');
xlabel('Frequência (Hz)'); ylabel('Magnitude Normalizada');
print(fig_final_freq, 'results/Espectro_Combinado_Final_Fast.png', '-dpng', '-r400');

% --- PLOT: Time Domain ---
fprintf('      -> Generating Time Domain Plot...\n'); fflush(stdout);
num_samples = 500;
t_ms_target = (0:num_samples-1) * (1000 / fs_target);

fig10 = figure('Visible', 'off', 'Position', [0, 0, 1600, 600]);
plot(t_ms_target, final_audio(1:num_samples), 'k', 'LineWidth', 1.2); grid on;
title('Sinal resultante da soma de x1[n] e x2[n] no domínio do tempo');
xlabel('Tempo (ms)'); ylabel('Amplitude');
print(fig10, 'results/TimeDomain_Final_Combined_Fast.png', '-dpng', '-r400');

% =========================================================================
% SECTION 5: FIR FILTERS FREQUENCY RESPONSE ANALYSIS
% =========================================================================
fprintf('\n[5/5] GENERATING FIR FILTER RESPONSES...\n'); fflush(stdout);

Wn_1 = 1 / L1; % Cutoff for Signal 1
Wn_2 = 1 / L2; % Cutoff for Signal 2
Wn_3 = fc_noise / (fs_target / 2); % Equivalent Cutoff for 3 kHz noise

h_filt1 = fir1(filt_order, Wn_1);
h_filt2 = fir1(filt_order, Wn_2);
h_filt3 = fir1(filt_order, Wn_3);

[H1, f_H1] = freqz(h_filt1, 1, 4096, fs_target);
[H2, f_H2] = freqz(h_filt2, 1, 4096, fs_target);
[H3, f_H3] = freqz(h_filt3, 1, 4096, fs_target);

mag_dB_H1 = 20*log10(abs(H1)); mag_dB_H1 = mag_dB_H1 - max(mag_dB_H1);
mag_dB_H2 = 20*log10(abs(H2)); mag_dB_H2 = mag_dB_H2 - max(mag_dB_H2);
mag_dB_H3 = 20*log10(abs(H3)); mag_dB_H3 = mag_dB_H3 - max(mag_dB_H3);

% --- PLOT: Filtros Projetados ---
fig5 = figure('Visible', 'off', 'Position', [0, 0, 1600, 900]);
plot(f_H1, mag_dB_H1, 'b', 'LineWidth', 1.5); hold on;
plot(f_H2, mag_dB_H2, 'r', 'LineWidth', 1.5); hold on;
plot(f_H3, mag_dB_H3, 'g', 'LineWidth', 1.5); grid on;

xlim([0, fs_target/2]); ylim([-100, 5]);
title(sprintf('Resposta em Frequência dos Filtros FIR Projetados (Ordem: %d)', filt_order));
xlabel('Frequência (Hz)'); ylabel('Magnitude (dB)');

legend(sprintf('Filtro Interpolador x1 (Corte: %.0f Hz)', (fs_target/2)*Wn_1), ...
       sprintf('Filtro Interpolador x2 (Corte: %.0f Hz)', (fs_target/2)*Wn_2), ...
       sprintf('Filtro de Ruído passa-baixa (Corte: %.0f Hz)', (fs_target/2)*Wn_3), ...
       'Location', 'northeast');

print(fig5, 'results/FIR_Filters_Response_Fast.png', '-dpng', '-r400');

fclose(fid);
fprintf('\n>>> FAST PIPELINE COMPLETE! <<< \n'); fflush(stdout);
