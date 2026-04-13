function y_out = downsample_channel(x_in, M, filter_order)
    % DOWNSAMPLE_CHANNEL Decreases the sampling rate of a signal by an integer factor M.
    %
    % Inputs:
    %   x_in         - Original input signal (vector)
    %   M            - Downsampling/Decimation factor (integer)
    %   filter_order - Order of the FIR filter (must be even for zero-delay compensation)
    %
    % Outputs:
    %   y_out        - Filtered and decimated signal

    % 1. Anti-aliasing FIR Filter Design
    % The normalized cutoff frequency Wn must be 1/M to respect the NEW Nyquist limit
    Wn = 1 / M;
    h_filter = fir1(filter_order, Wn);

    % 2. Apply the filter BEFORE throwing away samples
    y_filtered = filter(h_filter, 1, x_in);

    % 3. Group Delay Compensation
    % We must compensate for the filter's delay while we still have all the samples.
    delay = filter_order / 2;
    y_aligned = y_filtered(delay + 1 : end);

    % 4. Compression (Keep 1 every M samples)
    % Now it is safe to decimate without causing aliasing
    y_out = y_aligned(1:M:end);
end
