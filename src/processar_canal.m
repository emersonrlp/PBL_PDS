function y_out = processar_canal(sinal_data, fs_in, cfg, fig_id, nome)
    I = cfg.Fs_comum / fs_in;
    figure(fig_id); clf;

    % 1. Filtragem de Limpeza (3kHz)
    Wn = cfg.Fc_alvo / (fs_in/2);
    h_lp = fir1(cfg.N_ordem, Wn);
    x_filt = filter(h_lp, 1, sinal_data);
    x_filt = x_filt(cfg.N_ordem/2 + 1 : end);

    % 2. Upsampling
    x_up = zeros(length(x_filt)*I, 1);
    x_up(1:I:end) = x_filt;

    % 3. Interpolação
    h_int = I * fir1(cfg.N_ordem, 1/I);
    y_out = filter(h_int, 1, x_up);
    y_out = y_out(cfg.N_ordem/2 + 1 : end);

    % Plotar as 4 etapas (Grade 4x2)
    rows = 4; cols = 2;
    plot_estagio(sinal_data, [nome ' Original'],    rows, cols, 1, cfg.n_view);
    plot_estagio(x_filt,     [nome ' Filtrado'],    rows, cols, 3, cfg.n_view);
    plot_estagio(x_up,       [nome ' c/ Zeros'],    rows, cols, 5, cfg.n_view*I);
    plot_estagio(y_out,      [nome ' Reamostrado'], rows, cols, 7, cfg.n_view*I);
end
