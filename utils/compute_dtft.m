function [X_mag, w_axis] = compute_dtft(signal_in, num_points)
    % COMPUTE_DTFT Calculates the Discrete-Time Fourier Transform (DTFT)
    % using the fast matrix multiplication method (Proakis technique).
    %
    % Inputs:
    %   signal_in  - Input discrete signal (vector)
    %   num_points - Number of points to divide the pi interval (resolution)
    %
    % Outputs:
    %   X_mag      - Magnitude of the DTFT
    %   w_axis     - Normalized frequency axis (from -pi to pi)

    % 1. Data preparation
    N = length(signal_in);
    n = 0 : (N-1);
    n = n(:); % Force 'n' to be a column vector

    % 2. Frequency axis configuration (-pi to pi)
    k = -num_points : num_points;
    w_axis = (k / num_points) * pi;

    % 3. DTFT matrix computation
    % The matrix W_matrix contains all complex exponential combinations
    W_matrix = exp(-1j * n * w_axis);

    % Ensure the input signal is a row vector
    signal_row = signal_in(:)'; 
    
    % Vectorized dot product (equivalent to the sum in the DTFT equation)
    X_complex = signal_row * W_matrix;

    % 4. Return the magnitude
    X_mag = abs(X_complex);
end