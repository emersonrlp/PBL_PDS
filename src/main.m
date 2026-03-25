%% Script Principal Modularizado
pkg load signal;
clear; clc;

config.Fs_comum = 30000;
config.Fc_alvo  = 3000;
config.N_ordem  = 150;
config.n_view   = 60;

% Carregar Sinais
load('x1_e_x2.mat'); % Se o arquivo está no path, ele carregará x1_15k e x2_10k

% Processamento
y1 = processar_canal(x1_15k(:), 15000, config, 1, 'x1');
y2 = processar_canal(x2_10k(:), 10000, config, 2, 'x2');

% Combinação
L = min(length(y1), length(y2));
y_final = y1(1:L) + y2(1:L);

% Visualização Final
figure(3); clf;
subplot(2,1,1);
stem(0:199, y_final(1:200), 'b', 'filled', 'MarkerSize', 2);
title('Sinal Final Somado y[n]'); grid on;

subplot(2,1,2);
w_f = linspace(-pi, pi, 512);
plot(w_f, abs(dtft_pure(y_final, w_f))); xlim([-pi pi]);
title('DTFT Final (Radianos)'); xlabel('\omega (rad)'); grid on;

soundsc(y_final(1:min(end, config.Fs_comum*15)), config.Fs_comum);
