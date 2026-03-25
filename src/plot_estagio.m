function plot_estagio(sig, titulo, rows, cols, sub_pos, n_amostras)
    % Gera o par de gráficos (Stem e DTFT) em radianos
    w_eixo = linspace(-pi, pi, 512);
    S_mag = abs(dtft_pure(sig, w_eixo));

    % Gráfico de Amostras (n) - Esquerda
    subplot(rows, cols, sub_pos);
    stem(0:n_amostras-1, sig(1:n_amostras), 'filled', 'MarkerSize', 3);
    title(['n: ' titulo]); grid on;

    % Gráfico de Frequência (rad) - Direita
    subplot(rows, cols, sub_pos + 1);
    plot(w_eixo, S_mag); xlim([-pi pi]);
    title(['DTFT: ' titulo]); xlabel('\omega (rad)'); grid on;
end
