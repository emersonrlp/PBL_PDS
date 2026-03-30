%% Script Principal - Análise de Subamostragem com Senoide Sintética
pkg load signal;
clear; clc;

% 1. Parâmetros do Sinal e Subamostragem
Fs_orig = 15000; % Taxa original (Hz)
f_seno = 1000;   % Frequência da nossa senoide (Hz)
M = 3;           % Fator de subamostragem (inteiro positivo)
N_gerar = 1500;  % Quantidade de amostras para gerar (0.1 segundos)

% Calcula novas taxas e durações
Fs_down = Fs_orig / M; % Nova taxa de amostragem
t1 = (0:N_gerar-1) / Fs_orig; % Vetor de tempo original

% 2. Gerar a função Seno Sintética
% Amplitude 1, Fase 0
x_sine_orig = sin(2 * pi * f_seno * t1);

% 3. Aplicar a sua função de downsampling
x_sine_sub = downsampling(x_sine_orig, M);

% --- VETOR DE FREQUÊNCIAS DIGITAIS (w) ---
% w varia de -3*pi até 3*pi para mostrar múltiplos períodos
N_pontos = 4096; % Aumentei a resolução para cobrir o intervalo maior
w_vec = linspace(-3*pi, 3*pi, N_pontos);

%% 4. Visualização Comparativa
figure('Name', 'Subamostragem de Senoide: Antes e Depois', 'NumberTitle', 'off');

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
% Plota o eixo X puro, sem dividir por pi
plot(w_vec, abs(X_dtft_orig), 'b', 'LineWidth', 2);
title('Espectro Original (\omega)');
xlabel('Frequência Digital \omega (rad/amostra)');
xlim([-3*pi 3*pi]);
% Configura as marcações exatas em radianos e adiciona os rótulos com o símbolo pi
xticks([-3*pi, -2*pi, -pi, 0, pi, 2*pi, 3*pi]);
xticklabels({'-3\pi', '-2\pi', '-\pi', '0', '\pi', '2\pi', '3\pi'});
grid on;

% --- SINAL SUBAMOSTRADO (5 kHz) ---
% Tempo
subplot(2,2,3);
t_sub = (0:length(x_sine_sub)-1) / Fs_down;
janela_tempo_sub = 1:20; % Mesmo tempo total
stem(t_sub(janela_tempo_sub), x_sine_sub(janela_tempo_sub), 'r', 'filled');
title(['Subamostrado (Fs=', num2str(Fs_down/1000), ' kHz) - Fator M=3']);
ylabel('Amplitude'); grid on;
set(gca, 'FontSize', 12);
xlabel('Tempo (s)');

% Frequência (Usando sua DTFT)
subplot(2,2,4);
X_dtft_sub = dtft_pure(x_sine_sub', w_vec);
% Plota o eixo X puro, sem dividir por pi
plot(w_vec, abs(X_dtft_sub), 'r', 'LineWidth', 2);
title('Espectro Subamostrado (\omega) - EXPANDIDO');
xlabel('Frequência Digital \omega (rad/amostra)');
xlim([-3*pi 3*pi]);
% Configura as marcações exatas em radianos e adiciona os rótulos com o símbolo pi
xticks([-3*pi, -2*pi, -pi, 0, pi, 2*pi, 3*pi]);
xticklabels({'-3\pi', '-2\pi', '-\pi', '0', '\pi', '2\pi', '3\pi'});
grid on;
