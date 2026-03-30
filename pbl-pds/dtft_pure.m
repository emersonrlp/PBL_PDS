function X_dtft = dtft_pure(x, w)
    % Calcula a DTFT por definição: X(w) = sum( x[n] * exp(-jwn) )
    % Otimizado com janelamento de 1000 amostras para visualização rápida.
    limite = min(20000, length(x));
    x_curto = x(1:limite);
    n = (0:limite-1)';

    X_dtft = zeros(size(w));
    for k = 1:length(w)
        X_dtft(k) = sum(x_curto .* exp(-1j * w(k) * n));
    end
end
