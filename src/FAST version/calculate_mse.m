function mse_val = calculate_mse(reference_signal, reconstructed_signal)
    % CALCULATE_MSE Computes the Mean Squared Error between two signals.
    %
    % Inputs:
    %   reference_signal     - The original, perfect signal (vector)
    %   reconstructed_signal - The processed/resampled signal (vector)
    %
    % Outputs:
    %   mse_val              - Mean Squared Error value (scalar)

    ref = reference_signal(:);
    rec = reconstructed_signal(:);

    % 1. Align the signals (Truncate to the minimum length)
    min_len = min(length(ref), length(rec));
    ref_aligned = ref(1:min_len);
    rec_aligned = rec(1:min_len);

    % 2. Calculate the error point by point
    error_signal = ref_aligned - rec_aligned;

    % 3. Calculate the Mean Squared Error
    % We square the error to penalize large deviations and turn all values positive
    mse_val = mean(error_signal .^ 2);
end
