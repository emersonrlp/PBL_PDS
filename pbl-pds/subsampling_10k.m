%% Script Principal - Subamostragem de x2 (10k -> 5k)
pkg load signal;
clear; clc;

% 1. Carregar o Sinal
load('x1_e_x2.mat'); % Carrega x2_10k

% =========================================================================
% PROCESSAMENTO DO SINAL x2 (10 kHz -> 5 kHz)
% =========================================================================
Fs2_orig = 10000;
M2 = 2;
Fs_down = Fs2_orig / M2; % 5000 Hz

% Filtro Anti-Aliasing para x2 (Corta tudo acima de 2.200 Hz)
fc2 = 2200;
wc2 = 2 * pi * fc2 / Fs2_orig;
N_filtro = 101;
M_half = (N_filtro - 1) / 2;
n_filt = -M_half:M_half;

hd2 = zeros(1, N_filtro);
for k = 1:N_filtro
    if n_filt(k) == 0
        hd2(k) = wc2 / pi;
    else
        hd2(k) = sin(wc2 * n_filt(k)) / (pi * n_filt(k));
    end
end
w_hamming = 0.54 - 0.46 * cos(2 * pi * (n_filt + M_half) / (N_filtro - 1));
h2 = hd2 .* w_hamming;

% Aplicação das Técnicas
x2_sub_ruim = downsampling(x2_10k, M2); % Subamostragem DIRETA (Aliasing)
x2_filtrado = conv(x2_10k(:)', h2, 'same'); % Passa pelo filtro primeiro
x2_sub_bom  = downsampling(x2_filtrado, M2); % Subamostragem SEGURA

t2 = (0:length(x2_10k)-1) / Fs2_orig;
t2_sub = (0:length(x2_sub_bom)-1) / Fs_down;

% Vetor comum de frequências digitais
N_pontos = 10001;
w_vec = linspace(-3*pi, 3*pi, N_pontos);

% =========================================================================
% VISUALIZAÇÃO: SINAL x2 (10k -> 5k)
% =========================================================================
figure('Name', 'x2: Subamostragem (10kHz -> 5kHz)', 'NumberTitle', 'off', 'Position', [100, 150, 1200, 800]);

janela2 = 1000:1100;
janela2_sub = round(1000/M2):round(1100/M2);

subplot(3,2,1); stem(t2(janela2), x2_10k(janela2), 'b', 'filled', 'MarkerSize', 4); title('1. Original x2 (10 kHz)'); grid on;
subplot(3,2,2); plot(w_vec, abs(dtft_pure(x2_10k(:), w_vec)), 'b', 'LineWidth', 1.5); title('1. Espectro Original x2 (Pinos em 4kHz)'); xlim([-3*pi 3*pi]); xticks([-3*pi:pi:3*pi]); xticklabels({'-3\pi','-2\pi','-\pi','0','\pi','2\pi','3\pi'}); grid on;

subplot(3,2,3); stem(t2_sub(janela2_sub), x2_sub_ruim(janela2_sub), 'r', 'filled', 'MarkerSize', 4); title('2. x2 Subamostrado SEM Filtro (M=2)'); grid on;
subplot(3,2,4); plot(w_vec, abs(dtft_pure(x2_sub_ruim(:), w_vec)), 'r', 'LineWidth', 1.5); title('2. Espectro com ALIASING'); xlim([-3*pi 3*pi]); xticks([-3*pi:pi:3*pi]); xticklabels({'-3\pi','-2\pi','-\pi','0','\pi','2\pi','3\pi'}); grid on;

subplot(3,2,5); stem(t2_sub(janela2_sub), x2_sub_bom(janela2_sub), 'g', 'filled', 'MarkerSize', 4); title('3. x2 Subamostrado COM Filtro (5 kHz)'); grid on;
subplot(3,2,6); plot(w_vec, abs(dtft_pure(x2_sub_bom(:), w_vec)), 'g', 'LineWidth', 1.5); title('3. Espectro Limpo (Filtro Decepou o Sinal)'); xlim([-3*pi 3*pi]); xticks([-3*pi:pi:3*pi]); xticklabels({'-3\pi','-2\pi','-\pi','0','\pi','2\pi','3\pi'}); grid on;
