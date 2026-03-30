%% Script Principal - Subamostragem de x1 (15k -> 5k)
pkg load signal;
clear; clc;

% 1. Carregar o Sinal
load('x1_e_x2.mat'); % Carrega x1_15k

% =========================================================================
% PROCESSAMENTO DO SINAL x1 (15 kHz -> 5 kHz)
% =========================================================================
Fs1_orig = 15000;
M1 = 3;
Fs_down = Fs1_orig / M1; % 5000 Hz

% Filtro Anti-Aliasing para x1 (Corta tudo acima de 2.200 Hz)
fc1 = 2200;
wc1 = 2 * pi * fc1 / Fs1_orig;
N_filtro = 101;
M_half = (N_filtro - 1) / 2;
n_filt = -M_half:M_half;

hd1 = zeros(1, N_filtro);
for k = 1:N_filtro
    if n_filt(k) == 0
        hd1(k) = wc1 / pi;
    else
        hd1(k) = sin(wc1 * n_filt(k)) / (pi * n_filt(k));
    end
end
w_hamming = 0.54 - 0.46 * cos(2 * pi * (n_filt + M_half) / (N_filtro - 1));
h1 = hd1 .* w_hamming; % Sem multiplicar por M, pois não queremos ganho de energia aqui

% Aplicação das Técnicas
x1_sub_ruim = downsampling(x1_15k, M1); % Subamostragem DIRETA (Aliasing)
x1_filtrado = conv(x1_15k(:)', h1, 'same'); % Passa pelo filtro primeiro
x1_sub_bom  = downsampling(x1_filtrado, M1); % Subamostragem SEGURA

t1 = (0:length(x1_15k)-1) / Fs1_orig;
t1_sub = (0:length(x1_sub_bom)-1) / Fs_down;

% Vetor comum de frequências digitais
N_pontos = 10001;
w_vec = linspace(-3*pi, 3*pi, N_pontos);

% =========================================================================
% VISUALIZAÇÃO: SINAL x1 (15k -> 5k)
% =========================================================================
figure('Name', 'x1: Subamostragem (15kHz -> 5kHz)', 'NumberTitle', 'off', 'Position', [50, 100, 1200, 800]);

janela1 = 1000:1100;
janela1_sub = round(1000/M1):round(1100/M1);

subplot(3,2,1); stem(t1(janela1), x1_15k(janela1), 'b', 'filled', 'MarkerSize', 4); title('1. Original x1 (15 kHz)'); grid on;
subplot(3,2,2); plot(w_vec, abs(dtft_pure(x1_15k(:), w_vec)), 'b', 'LineWidth', 1.5); title('1. Espectro Original x1 (Agulha em 4kHz)'); xlim([-3*pi 3*pi]); xticks([-3*pi:pi:3*pi]); xticklabels({'-3\pi','-2\pi','-\pi','0','\pi','2\pi','3\pi'}); grid on;

subplot(3,2,3); stem(t1_sub(janela1_sub), x1_sub_ruim(janela1_sub), 'r', 'filled', 'MarkerSize', 4); title('2. x1 Subamostrado SEM Filtro (M=3)'); grid on;
subplot(3,2,4); plot(w_vec, abs(dtft_pure(x1_sub_ruim(:), w_vec)), 'r', 'LineWidth', 1.5); title('2. Espectro com ALIASING'); xlim([-3*pi 3*pi]); xticks([-3*pi:pi:3*pi]); xticklabels({'-3\pi','-2\pi','-\pi','0','\pi','2\pi','3\pi'}); grid on;

subplot(3,2,5); stem(t1_sub(janela1_sub), x1_sub_bom(janela1_sub), 'g', 'filled', 'MarkerSize', 4); title('3. x1 Subamostrado COM Filtro (5 kHz)'); grid on;
subplot(3,2,6); plot(w_vec, abs(dtft_pure(x1_sub_bom(:), w_vec)), 'g', 'LineWidth', 1.5); title('3. Espectro Limpo (Sem Aliasing)'); xlim([-3*pi 3*pi]); xticks([-3*pi:pi:3*pi]); xticklabels({'-3\pi','-2\pi','-\pi','0','\pi','2\pi','3\pi'}); grid on;
