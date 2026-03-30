% MAIN_TEST.m
% Script to load initial data, validate the DTFT module, and save plots
pkg load signal;
clear; clc;

fprintf('Starting processing...\n');
fflush(stdout); % Forces Octave to update the console immediately

% 1. Load the provided dataset
fprintf('Loading audio files...\n');
fflush(stdout);
load('x1_e_x2.mat');

% 2. Initial parameters setup
fs_1 = 15000; % Sampling frequency for signal 1
fs_2 = 10000; % Sampling frequency for signal 2
resolution = 1000; % Points for DTFT resolution

% 3. Compute the pure DTFT
fprintf('Computing DTFT for Signal 1 (This may take a few seconds)...\n');
fflush(stdout);
[mag_x1, w_axis] = compute_dtft(x1_15k, resolution);

fprintf('Computing DTFT for Signal 2...\n');
fflush(stdout);
[mag_x2, ~]      = compute_dtft(x2_10k, resolution);

% 4. Convert normalized angular frequency to physical frequency (Hertz)
f_axis_1 = (w_axis / (2*pi)) * fs_1;
f_axis_2 = (w_axis / (2*pi)) * fs_2;

% 5. Visualization
fprintf('Generating and saving plots...\n');
fflush(stdout);

% Store the figure handle in a variable (fig1) to save it later
fig1 = figure('Name', 'Original Signals Spectra');

% Plot Signal 1 Spectrum
subplot(2,1,1);
plot(f_axis_1, mag_x1, 'b', 'LineWidth', 1.2);
title('Original Signal 1 Spectrum (15 kHz)');
xlabel('Frequency (Hz)'); ylabel('Magnitude');
grid on;
xlim([-fs_1/2, fs_1/2]); % Limits the visual axis to Nyquist frequency

% Plot Signal 2 Spectrum
subplot(2,1,2);
plot(f_axis_2, mag_x2, 'r', 'LineWidth', 1.2);
title('Original Signal 2 Spectrum (10 kHz)');
xlabel('Frequency (Hz)'); ylabel('Magnitude');
grid on;
xlim([-fs_2/2, fs_2/2]);

% 6. Save the figure automatically in high resolution (300 dpi)
print(fig1, 'Original_Spectra_HighRes.png', '-dpng', '-r300');

fprintf('Step 1 successfully completed! Image saved in your folder.\n');
fflush(stdout);
