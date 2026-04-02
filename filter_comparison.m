% =========================================================================
% FILTER_ANALYSIS.m - Visualizing the FIR Filters Frequency Response
% =========================================================================
pkg load signal;
clear; clc; % Adicione isso se não tiver

% --- O PULO DO GATO ---
addpath('utils'); % Esse script não carrega dados, mas é bom colocar para garantir
% ----------------------

fs_target = 30000;
L1 = 2; % Upsampling factor for Signal 1
Wn_1 = 1 / L1; % Normalized cutoff frequency

% Design the two filters we used in the project
h_fir_150 = fir1(150, Wn_1);
h_fir_1000 = fir1(1000, Wn_1);

% Compute frequency response (freqz)
[H_150, f_150] = freqz(h_fir_150, 1, 2048, fs_target);
[H_1000, f_1000] = freqz(h_fir_1000, 1, 2048, fs_target);

% Convert magnitude to Decibels (dB) for standard engineering view
mag_dB_150 = 20*log10(abs(H_150));
mag_dB_1000 = 20*log10(abs(H_1000));

% --- PLOT: FIR Filter Comparison ---
fig_filters = figure('Name', 'FIR Filters Comparison', 'Position', [0, 0, 1200, 600]);

plot(f_150, mag_dB_150, 'b', 'LineWidth', 1.5); hold on;
plot(f_1000, mag_dB_1000, 'r', 'LineWidth', 1.5); grid on;

% Visual limits and labels
xlim([0, fs_target/2]); ylim([-100, 10]);
title('FIR Filter Frequency Response Comparison (Magnitude in dB)');
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
legend('Order 150 (Normal Pipeline)', 'Order 1000 (Fast Pipeline)', 'Location', 'northeast');

print(fig_filters, 'Filter_Response_Comparison.png', '-dpng', '-r400');
