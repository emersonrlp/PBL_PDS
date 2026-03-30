%% Script Principal - O Fim do Aliasing (Filtro Passa-Baixas Manual + Downsampling)
pkg load signal;
clear; clc;

% 1. Carregar o Sinal Real
load('x1_e_x2.mat'); % Carrega x1_15k e x2_10k

% 2. Parâmetros do Sistema
Fs_orig = 15000; % Taxa original
M = 3;           % Fator de subamostragem
Fs_down = 5000;  % Nova taxa

% =========================================================================
% ETAPA A: PROJETO DO FILTRO PASSA-BAIXAS MANUAL (Sinc + Hamming)
% =========================================================================
fc = 2200;             % Frequência de corte (Cortando tudo acima de 2.2kHz)
wc = 2 * pi * fc / Fs_orig;
N_filtro = 101;        % Tamanho do filtro (Ímpar)
M_half = (N_filtro - 1) / 2;
n_filt = -M_half:M_half;

hd = zeros(1, N_filtro);
for k = 1:N_filtro
    if n_filt(k) == 0
        hd(k) = wc / pi;
    else
        hd(k) = sin(wc * n_filt(k)) / (pi * n_filt(k));
    end
end
w_hamming = 0.54 - 0.46 * cos(2 * pi * (n_filt + M_half) / (N_filtro - 1));
h = hd .* w_hamming; % Coeficientes finais do Filtro Anti-Aliasing

% =========================================================================
% ETAPA B: PROCESSAMENTO DOS SINAIS
% =========================================================================
% Sinal 1: Original (Já temos o x1_15k)
% Sinal 2: Subamostrado RUIM (Sem Filtro)
x1_sub_ruim = downsampling(x1_15k, M);

% Sinal 3: Filtrado (Original passando pelo Filtro Anti-Aliasing)
% Usamos 'same' para manter o tamanho de 15.000 amostras
x1_filtrado = conv(x1_15k(:)', h, 'same');

% Sinal 4: Subamostrado BOM (Filtrado -> Subamostrado)
x1_sub_bom = downsampling(x1_filtrado, M);

% Vetores de Tempo e Frequência
t1 = (0:length(x1_15k)-1) / Fs_orig;
t_sub = (0:length(x1_sub_ruim)-1) / Fs_down;
N_pontos = 10001; % Resolução excelente e rápida para a DTFT
w_vec = linspace(-3*pi, 3*pi, N_pontos);

% =========================================================================
% ETAPA C: VISUALIZAÇÃO - FIGURA 1 (O PROBLEMA)
% =========================================================================
figure('Name', 'FIGURA 1: O Problema (Aliasing)', 'NumberTitle', 'off');

% Original no Tempo
subplot(2,2,1);
janela = 1000:1100;
stem(t1(janela), x1_15k(janela), 'b', 'filled', 'MarkerSize', 4);
title('1. Original: x1 (Fs=15 kHz)'); ylabel('Amplitude'); grid on;

% Original na Freq
subplot(2,2,2);
X_orig = dtft_pure(x1_15k(:), w_vec);
plot(w_vec, abs(X_orig), 'b', 'LineWidth', 1.5);
title('Espectro Original (\omega)'); xlim([-3*pi 3*pi]); grid on;
xticks([-3*pi, -2*pi, -pi, 0, pi, 2*pi, 3*pi]); xticklabels({'-3\pi', '-2\pi', '-\pi', '0', '\pi', '2\pi', '3\pi'});

% Subamostrado RUIM no Tempo
subplot(2,2,3);
janela_sub = round(1000/M):round(1100/M);
stem(t_sub(janela_sub), x1_sub_ruim(janela_sub), 'r', 'filled', 'MarkerSize', 4);
title('2. Subamostrado SEM Filtro (Fs=5 kHz)'); ylabel('Amplitude'); grid on;

% Subamostrado RUIM na Freq
subplot(2,2,4);
X_sub_ruim = dtft_pure(x1_sub_ruim(:), w_vec);
plot(w_vec, abs(X_sub_ruim), 'r', 'LineWidth', 1.5);
title('Espectro com ALIASING (Ruído invadiu a banda)'); xlim([-3*pi 3*pi]); grid on;
xticks([-3*pi, -2*pi, -pi, 0, pi, 2*pi, 3*pi]); xticklabels({'-3\pi', '-2\pi', '-\pi', '0', '\pi', '2\pi', '3\pi'});

% =========================================================================
% ETAPA D: VISUALIZAÇÃO - FIGURA 2 (A SOLUÇÃO)
% =========================================================================
figure('Name', 'FIGURA 2: A Solução (Anti-Aliasing)', 'NumberTitle', 'off');

% Filtrado no Tempo
subplot(2,2,1);
% Plotamos como linha contínua para ver como o filtro suavizou a onda
plot(t1(janela), x1_15k(janela), 'Color', [0.7 0.7 0.7]); hold on; % Fundo cinza
plot(t1(janela), x1_filtrado(janela), 'g', 'LineWidth', 2);
title('3. Filtrado em 15 kHz (Ruído removido)'); ylabel('Amplitude'); grid on;
legend('Original', 'Filtrado');

% Filtrado na Freq
subplot(2,2,2);
X_filt = dtft_pure(x1_filtrado(:), w_vec);
plot(w_vec, abs(X_filt), 'g', 'LineWidth', 1.5);
title('Espectro Filtrado (\omega) - Adeus 4kHz!'); xlim([-3*pi 3*pi]); grid on;
xticks([-3*pi, -2*pi, -pi, 0, pi, 2*pi, 3*pi]); xticklabels({'-3\pi', '-2\pi', '-\pi', '0', '\pi', '2\pi', '3\pi'});

% Sub

