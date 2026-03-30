%% Script Principal - Interpolação de x1 (15k -> 30k)
pkg load signal;
clc;

% 1. Carregar os Sinais
load('x1_e_x2.mat'); % Carrega x1_15k

% =========================================================================
% PROCESSAMENTO DO SINAL x1 (15 kHz -> 30 kHz)
% =========================================================================
Fs1_orig = 15000;
L1 = 2;
Fs_up = 30000; % Taxa final alvo
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

% Vetor comum de frequências digitais para a DTFT
N_pontos = 10001*5;
w_vec = linspace(-3*pi, 3*pi, N_pontos);

% =========================================================================
% VISUALIZAÇÃO: SINAL x1 (15k -> 30k)
% =========================================================================
%figure('Name', 'x1: Superamostragem e Interpolação (15kHz -> 30kHz)', 'NumberTitle', 'off', 'Position', [50, 100, 1200, 800]);

%janela1 = 1000:1100;
%janela1_up = (1000*L1):(1100*L1);

%subplot(3,2,1); stem(t1(janela1), x1_15k(janela1), 'b', 'filled', 'MarkerSize', 4); title('1. Original x1 (15 kHz)'); grid on;
%subplot(3,2,2); plot(w_vec, abs(dtft_pure(x1_15k(:), w_vec)), 'b', 'LineWidth', 1.5); title('1. Espectro Original x1'); xlim([-3*pi 3*pi]); xticks([-3*pi, -2*pi, -pi, 0, pi, 2*pi, 3*pi]); xticklabels({'-3\pi','-2\pi','-\pi','0','\pi','2\pi','3\pi'}); grid on;

%subplot(3,2,3); stem(t1_up(janela1_up), x1_up(janela1_up), 'r', 'filled', 'MarkerSize', 4); title('2. x1 com Zeros (L=2)'); grid on;
%subplot(3,2,4); plot(w_vec, abs(dtft_pure(x1_up(:), w_vec)), 'r', 'LineWidth', 1.5); title('2. Espectro com Imagens'); xlim([-3*pi 3*pi]); xticks([-3*pi, -2*pi, -pi, 0, pi, 2*pi, 3*pi]); xticklabels({'-3\pi','-2\pi','-\pi','0','\pi','2\pi','3\pi'}); grid on;

%subplot(3,2,5); stem(t1_up(janela1_up), x1_interpolado(janela1_up), 'r', 'filled', 'MarkerSize', 4); title('3. x1 Interpolado (30 kHz)'); grid on;
%subplot(3,2,6); plot(w_vec, abs(dtft_pure(x1_interpolado(:), w_vec)), 'g', 'LineWidth', 1.5); title('3. Espectro Interpolado (Limpo)'); xlim([-3*pi 3*pi]); xticks([-3*pi, -2*pi, -pi, 0, pi, 2*pi, 3*pi]); xticklabels({'-3\pi','-2\pi','-\pi','0','\pi','2\pi','3\pi'}); grid on;
