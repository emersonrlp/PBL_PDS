% =========================================================================
% THEORETICAL PLOTS GENERATOR FOR REPORT
% Generates simple examples of Upsampling, Downsampling, and Aliasing.
% =========================================================================
pkg load signal;
clear; clc;

% Create output directory if it doesn't exist
if ~exist('results', 'dir')
    mkdir('results');
end

fprintf('Generating theoretical plots...\n');

% =========================================================================
% 1. UPSAMPLING (Zero Insertion) & DOWNSAMPLING (Sample Removal)
% =========================================================================
% Base signal: Simple sine wave (low frequency for easy stem visualization)
n_base = 0:15;
x_base = sin(2 * pi * 0.08 * n_base);

% --- Upsampling (L = 2) ---
L = 2;
x_up = zeros(1, length(x_base) * L);
x_up(1:L:end) = x_base;
n_up = 0:(length(x_up)-1);

% --- Downsampling (M = 2) ---
M = 2;
x_down = x_base(1:M:end);
n_down = 0:(length(x_down)-1);

% --- PLOT: Upsampling (Zero Insertion) ---
fig_up = figure('Visible', 'off', 'Position', [0, 0, 1000, 400]);
stem(n_up, x_up, 'b', 'filled', 'LineWidth', 1.5, 'MarkerSize', 6);
grid on;
title('Superamostragem (L=2): Inserção de Zeros');
xlabel('Amostras (n)'); ylabel('Amplitude');
ylim([-1.2, 1.2]);
print(fig_up, 'results/Teoria_Upsampling.png', '-dpng', '-r400');

% --- PLOT: Downsampling (Sample Removal) ---
fig_down = figure('Visible', 'off', 'Position', [0, 0, 1000, 400]);
subplot(1,2,1);
stem(n_base, x_base, 'k', 'filled', 'LineWidth', 1.5, 'MarkerSize', 6);
grid on; title('Sinal Original'); xlabel('Amostras (n)'); ylabel('Amplitude'); ylim([-1.2, 1.2]);
subplot(1,2,2);
stem(n_down, x_down, 'r', 'filled', 'LineWidth', 1.5, 'MarkerSize', 6);
grid on; title('Subamostragem (M=2): Remoção de Amostras'); xlabel('Amostras (n)'); ylabel('Amplitude'); ylim([-1.2, 1.2]);
print(fig_down, 'results/Teoria_Downsampling.png', '-dpng', '-r400');


% =========================================================================
% 2. ALIASING (Continuous vs Discrete Representation)
% =========================================================================
% High resolution time for continuous curves
t_cont = 0:0.001:1;

f_fund = 2;   % Fundamental frequency (2 Hz)
f_alias = 12; % Aliased frequency (12 Hz)

% Sampling frequency (fs = 10 Hz) -> Nyquist is 5 Hz.
% Therefore, 12 Hz will fold back into 2 Hz (12 - 10 = 2).
fs = 10;
t_samp = 0:(1/fs):1;

% Continuous waves
y_fund_cont = sin(2 * pi * f_fund * t_cont);
y_alias_cont = sin(2 * pi * f_alias * t_cont);

% Discrete samples
y_samp = sin(2 * pi * f_fund * t_samp); % Both 2Hz and 12Hz produce these exact same samples

% --- PLOT: Aliasing ---
fig_alias = figure('Visible', 'off', 'Position', [0, 0, 1000, 500]);
plot(t_cont, y_fund_cont, 'b', 'LineWidth', 2); hold on;
plot(t_cont, y_alias_cont, 'r--', 'LineWidth', 1.2);
stem(t_samp, y_samp, 'k', 'filled', 'LineWidth', 1.5, 'MarkerSize', 8);
grid on;

title('Efeito de Aliasing: Múltiplas frequências gerando as mesmas amostras');
xlabel('Tempo (s)'); ylabel('Amplitude');
legend('Sinal Real (2 Hz)', 'Sinal Aliasing (12 Hz)', 'Amostras Digitais (fs = 10 Hz)', 'Location', 'northeast');
ylim([-1.5, 1.5]);

print(fig_alias, 'results/Teoria_Aliasing.png', '-dpng', '-r400');

fprintf('Plots generated successfully in the "results" folder.\n');
