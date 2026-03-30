% MAIN_TEST.m
% Script to load initial data and validate the DTFT module
pkg load signal;
clear; clc;

% 1. Load the provided dataset
load('x1_e_x2.mat'); 

% 2. Initial parameters setup
fs_1 = 15000; % Sampling frequency for signal 1
fs_2 = 10000; % Sampling frequency for signal 2
resolution = 1000; % Points for DTFT resolution

% 3. Compute the pure DTFT using our new module
[mag_x1, w_axis] = compute_dtft(x1_15k, resolution);
[mag_x2, ~]      = compute_dtft(x2_10k, resolution);

% 4. Convert normalized angular frequency to physical frequency (Hertz)
% Formula: f = (w / 2*pi) * Fs
f_axis_1 = (w_axis / (2*pi)) * fs_1;
f_axis_2 = (w_axis / (2*pi)) * fs_2;

% 5. Visualization
figure('Name', 'Original Signals Spectra');

% Plot Signal 1 Spectrum
subplot(2,1,1);
plot(f_axis_1, mag_x1, 'b', 'LineWidth', 1.2);
title('Original Signal 1 Spectrum (15 kHz)');
xlabel('Frequency (Hz)'); ylabel('Magnitude');
grid on;

% Plot Signal 2 Spectrum
subplot(2,1,2);
plot(f_axis_2, mag_x2, 'r', 'LineWidth', 1.2);
title('Original Signal 2 Spectrum (10 kHz)');
xlabel('Frequency (Hz)'); ylabel('Magnitude');
grid on;