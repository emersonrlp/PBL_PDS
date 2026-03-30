%% Script Principal - Interpolação de x1 (15k->30k) e x2 (10k->30k)
pkg load signal;
clear; clc;

% 1. Carregar os Sinais
load('x1_e_x2.mat'); % Carrega x1_15k e x2_10k

% =========================================================================
% PARTE 1: PROCESSAMENTO DO SINAL x1 (15 kHz -> 30 kHz)
% =========================================================================
Fs1_orig = 15000;
L1 = 2;
Fs_up = 30000; % Taxa final alvo comum para ambos
x1_up = upsampling(x1_15k, L1);

% Filtro Interpolador para x1 (Corta em 7.500 Hz)
fc1 = 7500;
wc1 = 2 * pi * fc1 / Fs_up;
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
h1 = (hd1 .* w_hamming) * L1; % Multiplica por L=2 para recuperar energia

x1_interpolado = conv(x1_up(:)', h1, 'same');
t1 = (0:length(x1_15k)-1) / Fs1_orig;
t1_up = (0:length(x1_up)-1) / Fs_up;

% =========================================================================
% PARTE 2: PROCESSAMENTO DO SINAL x2 (10 kHz -> 30 kHz)
% =========================================================================
Fs2_orig = 10000;
L2 = 3;           % Fator L=3 para levar 10k até 30k
x2_up = upsampling(x2_10k, L2);

% Filtro Interpolador para x2 (Corta em 5.000 Hz)
fc2 = 5000;
wc2 = 2 * pi * fc2 / Fs_up;

hd2 = zeros(1, N_filtro);
for k = 1:N_filtro
    if n_filt(k) == 0
        hd2(k) = wc2 / pi;
    else
        hd2(k) = sin(wc2 * n_filt(k)) / (pi * n_filt(k));
    end
end
h2 = (hd2 .* w_hamming) * L2; % Multiplica por L=3 para recuperar energia!

x2_interpolado = conv(x2_up(:)', h2, 'same');
t2 = (0:length(x2_10k)-1) / Fs2_orig;
t2_up = (0:length(x2_up)-1) / Fs_up;

% Vetor comum de frequências digitais para as DTFTs
N_pontos = 10001*5;
w_vec = linspace(-3*pi, 3*pi, N_pontos);

% =========================================================================
% VISUALIZAÇÃO 1: SINAL x1 (15k -> 30k)
% =========================================================================
figure('Name', 'x1: Superamostragem e Interpolação (15kHz -> 30kHz)', 'NumberTitle', 'off', 'Position', [50, 100, 1200, 800]);

janela1 = 1000:1100;
janela1_up = (1000*L1):(1100*L1);

subplot(3,2,1); stem(t1(janela1), x1_15k(janela1), 'b', 'filled', 'MarkerSize', 4); title('1. Original x1 (15 kHz)'); grid on;
subplot(3,2,2); plot(w_vec, abs(dtft_pure(x1_15k(:), w_vec)), 'b', 'LineWidth', 1.5); title('1. Espectro Original x1'); xlim([-3*pi 3*pi]); xticks([-3*pi, -2*pi, -pi, 0, pi, 2*pi, 3*pi]); xticklabels({'-3\pi','-2\pi','-\pi','0','\pi','2\pi','3\pi'}); grid on;

subplot(3,2,3); stem(t1_up(janela1_up), x1_up(janela1_up), 'r', 'filled', 'MarkerSize', 4); title('2. x1 com Zeros (L=2)'); grid on;
subplot(3,2,4); plot(w_vec, abs(dtft_pure(x1_up(:), w_vec)), 'r', 'LineWidth', 1.5); title('2. Espectro com Imagens'); xlim([-3*pi 3*pi]); xticks([-3*pi, -2*pi, -pi, 0, pi, 2*pi, 3*pi]); xticklabels({'-3\pi','-2\pi','-\pi','0','\pi','2\pi','3\pi'}); grid on;

subplot(3,2,5); stem(t1_up(janela1_up), x1_interpolado(janela1_up), 'r', 'filled', 'MarkerSize', 4); title('3. x1 Interpolado (30 kHz)'); grid on;
subplot(3,2,6); plot(w_vec, abs(dtft_pure(x1_interpolado(:), w_vec)), 'g', 'LineWidth', 1.5); title('3. Espectro Interpolado (Limpo)'); xlim([-3*pi 3*pi]); xticks([-3*pi, -2*pi, -pi, 0, pi, 2*pi, 3*pi]); xticklabels({'-3\pi','-2\pi','-\pi','0','\pi','2\pi','3\pi'}); grid on;

% =========================================================================
% VISUALIZAÇÃO 2: SINAL x2 (10k -> 30k)
% =========================================================================
figure('Name', 'x2: Superamostragem e Interpolação (10kHz -> 30kHz)', 'NumberTitle', 'off', 'Position', [100, 150, 1200, 800]);

janela2 = 1000:1100;
janela2_up = (1000*L2):(1100*L2);

subplot(3,2,1); stem(t2(janela2), x2_10k(janela2), 'b', 'filled', 'MarkerSize', 4); title('1. Original x2 (10 kHz)'); grid on;
subplot(3,2,2); plot(w_vec, abs(dtft_pure(x2_10k(:), w_vec)), 'b', 'LineWidth', 1.5); title('1. Espectro Original x2'); xlim([-3*pi 3*pi]); xticks([-3*pi, -2*pi, -pi, 0, pi, 2*pi, 3*pi]); xticklabels({'-3\pi','-2\pi','-\pi','0','\pi','2\pi','3\pi'}); grid on;

subplot(3,2,3); stem(t2_up(janela2_up), x2_up(janela2_up), 'r', 'filled', 'MarkerSize', 4); title('2. x2 com Zeros (L=3)'); grid on;
subplot(3,2,4); plot(w_vec, abs(dtft_pure(x2_up(:), w_vec)), 'r', 'LineWidth', 1.5); title('2. Espectro com Imagens (2 Cópias!)'); xlim([-3*pi 3*pi]); xticks([-3*pi, -2*pi, -pi, 0, pi, 2*pi, 3*pi]); xticklabels({'-3\pi','-2\pi','-\pi','0','\pi','2\pi','3\pi'}); grid on;

subplot(3,2,5); stem(t2_up(janela2_up), x2_interpolado(janela2_up), 'r', 'filled', 'MarkerSize', 4); title('3. x2 Interpolado (30 kHz)'); grid on;
subplot(3,2,6); plot(w_vec, abs(dtft_pure(x2_interpolado(:), w_vec)), 'g', 'LineWidth', 1.5); title('3. Espectro Interpolado (Limpo)'); xlim([-3*pi 3*pi]); xticks([-3*pi, -2*pi, -pi, 0, pi, 2*pi, 3*pi]); xticklabels({'-3\pi','-2\pi','-\pi','0','\pi','2\pi','3\pi'}); grid on;
