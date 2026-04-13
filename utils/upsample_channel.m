function y_out = upsample_channel(x_in, L, filter_order)
    % UPSAMPLE_CHANNEL Increases the sampling rate of a signal by an integer factor L.
    %
    % Inputs:
    %   x_in         - Original input signal (vector)
    %   L            - Upsampling/Interpolation factor (integer)
    %   filter_order - Order of the FIR filter (must be even for zero-delay compensation)
    %
    % Outputs:
    %   y_out        - Upsampled and interpolated signal

    % 1. Expansion (Insert L-1 zeros between original samples)
    N = length(x_in);
    x_expanded = zeros(1, N * L);
    x_expanded(1:L:end) = x_in;

    % 2. Anti-imaging FIR Filter Design
    % The normalized cutoff frequency Wn must be 1/L to respect the original Nyquist limit
    Wn = 1 / L;
    h_filter = fir1(filter_order, Wn);

    % 3. Apply the filter and adjust the gain
    % The amplitude drops when inserting zeros, so we multiply by L to restore it
    y_filtered = L * filter(h_filter, 1, x_expanded);

    % 4. Group Delay Compensation
    % FIR filters introduce a delay of (filter_order / 2) samples.
    delay = filter_order / 2;
    y_out = y_filtered(delay + 1 : end);
end
