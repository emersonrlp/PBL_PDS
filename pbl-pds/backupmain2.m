%% Script Principal - Análise de Superamostragem (Upsampling) com Senoide Sintética
pkg load signal;
clear; clc;

% 1. Parâmetros do Sinal e Superamostragem
Fs_orig = 15000; % Taxa original (Hz)
f_seno = 1000;   % Frequência da nossa senoide (Hz)
L = 3;           % Fator de superamostragem (inteiro positivo)
N_gerar = 1500;  % Quantidade de amostras para gerar



% Calcula novas taxas
% ---> CORREÇÃO: Upsampling MULTIPLICA a taxa <---
Fs_up = Fs_orig * L;
t1 = (0:N_gerar-1) / Fs_orig; % Vetor de tempo original

% 2. Gerar a função Seno Sintética
% Amplitude 1, Fase 0
x_sine_orig = sin(2 * pi * f_seno * t1);

% 3. Aplicar a sua função de upsampling (inserir zeros)
x_sine_up = upsampling(x_sine_orig, L);

% --- VETOR DE FREQUÊNCIAS DIGITAIS (w) ---
N_pontos = 4096;
w_vec = linspace(-3*pi, 3*pi, N_pontos);

%% 4. Visualização Comparativa
figure('Name', 'Superamostragem de Senoide: Antes e Depois', 'NumberTitle', 'off');

% --- SINAL ORIGINAL (15 kHz) ---
% Tempo
subplot(2,2,1);
janela_tempo = 1:60; % Mostrando um pouco mais de 3 ciclos
stem(t1(janela_tempo), x_sine_orig(janela_tempo), 'b', 'filled');
title(['Original: Senoide 1 kHz (Fs=15 kHz)']);
ylabel('Amplitude'); grid on;
set(gca, 'FontSize', 12);
xlabel('Tempo (s)');

% Frequência (Usando sua DTFT)
subplot(2,2,2);
X_dtft_orig = dtft_pure(x_sine_orig', w_vec);
plot(w_vec, abs(X_dtft_orig), 'b', 'LineWidth', 2);
title('Espectro Original (\omega)');
xlabel('Frequência Digital \omega (rad/amostra)');
xlim([-3*pi 3*pi]);
xticks([-3*pi, -2*pi, -pi, 0, pi, 2*pi, 3*pi]);
xticklabels({'-3\pi', '-2\pi', '-\pi', '0', '\pi', '2\pi', '3\pi'});
grid on;

% --- SINAL SUPERAMOSTRADO (45 kHz) ---
% Tempo
subplot(2,2,3);
t_up = (0:length(x_sine_up)-1) / Fs_up;
% Multiplicamos a janela de amostras por L para ver a mesma porção de tempo
janela_tempo_up = 1:(60*L);
stem(t_up(janela_tempo_up), x_sine_up(janela_tempo_up), 'r', 'filled');
title(['Superamostrado (Fs=', num2str(Fs_up/1000), ' kHz) - Fator L=', num2str(L)]);
ylabel('Amplitude'); grid on;
set(gca, 'FontSize', 12);
xlabel('Tempo (s)');

% Frequência (Usando sua DTFT)
subplot(2,2,4);
X_dtft_up = dtft_pure(x_sine_up', w_vec);
plot(w_vec, abs(X_dtft_up), 'r', 'LineWidth', 2);
title('Espectro Superamostrado (\omega) - COMPRIMIDO (Imagens)');
xlabel('Frequência Digital \omega (rad/amostra)');
xlim([-3*pi 3*pi]);
xticks([-3*pi, -2*pi, -pi, 0, pi, 2*pi, 3*pi]);
xticklabels({'-3\pi', '-2\pi', '-\pi', '0', '\pi', '2\pi', '3\pi'});
grid on;
