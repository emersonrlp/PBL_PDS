function snr_db = calculate_snr(reference_signal, reconstructed_signal)
    % CALCULATE_SNR Computes the Signal-to-Noise Ratio in decibels (dB).
    %
    % Inputs:
    %   reference_signal     - The original, perfect signal (vector)
    %   reconstructed_signal - The processed/resampled signal (vector)
    %
    % Outputs:
    %   snr_db               - Signal-to-Noise Ratio in dB (scalar)

    % 1. Align the signals (Truncate to the minimum length)
    min_len = min(length(reference_signal), length(reconstructed_signal));
    ref_aligned = reference_signal(1:min_len);
    rec_aligned = reconstructed_signal(1:min_len);

    % 2. Calculate Signal Power (Mean of the squared reference values)
    signal_power = mean(ref_aligned .^ 2);

    % 3. Calculate Noise Power (Mean of the squared error)
    error_signal = ref_aligned - rec_aligned;
    noise_power = mean(error_signal .^ 2);

    % 4. Compute SNR in Decibels
    % If noise_power is exactly 0 (perfect match), return infinity to avoid log10(0) error
    if noise_power == 0
        snr_db = Inf;
    else
        snr_db = 10 * log10(signal_power / noise_power);
    end
end
