function [mag_spectrum, f_axis] = compute_fast_spectrum(sig, fs)
    % COMPUTE_FAST_SPECTRUM Calculates the spectrum using Native FFT.
    % Uses zero-padding to the next power of 2 for maximum hardware speed.

    % Find the optimal FFT length (power of 2)
    N_fft = 2^nextpow2(length(sig));

    % Compute the Fast Fourier Transform and shift zero-frequency to center
    mag_spectrum = abs(fftshift(fft(sig, N_fft)));

    % Generate the physical frequency axis in Hertz
    f_axis = (-N_fft/2 : N_fft/2 - 1) * (fs / N_fft);
end
