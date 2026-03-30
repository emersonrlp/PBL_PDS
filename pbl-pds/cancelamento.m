%% Script Definitivo - O Laser Cirúrgico Manual (Filtro Rejeita-Faixa)
pkg load signal;
clear; clc;

disp('1. Interpolando a Voz para 30 kHz...');
upsampling_15k; % Mantemos o seu script da voz intacto

% =========================================================================
% ETAPA 2: FILTRO REJEITA-FAIXA DEMOLIDOR (Buraco Largo e Profundo)
% =========================================================================
disp('2. Abrindo um buraco largo no espectro (3.8k a 4.2k)...');
Fs = 30000;

% Alargando a zona de exclusão para não ter erro de alvo
fc1 = 3800;
fc2 = 4200;
wc1 = 2 * pi * fc1 / Fs;
wc2 = 2 * pi * fc2 / Fs;

% Aumentando o tamanho para 501 pontos (Corte ultra-afiado)
N_notch = 501;
M_half = (N_notch - 1) / 2;
n_filt = -M_half:M_half;

hd_notch = zeros(1, N_notch);
for k = 1:N_notch
    if n_filt(k) == 0
        hd_notch(k) = 1 - ((wc2 - wc1) / pi); % Correção da fórmula central
    else
        % Matemática pura: Impulso - (Passa-Banda) = Rejeita-Faixa
        hd_notch(k) = (sin(pi*n_filt(k)) - (sin(wc2*n_filt(k)) - sin(wc1*n_filt(k)))) / (pi*n_filt(k));
    end
end

w_hamming = 0.54 - 0.46 * cos(2 * pi * (n_filt + M_half) / (N_notch - 1));
h_notch = hd_notch .* w_hamming;

% Aplicando com filtragem de fase zero para não dar eco
x_salvo = filtfilt(h_notch, 1, x1_interpolado);
% =========================================================================
% ETAPA 3: A ANIQUILAÇÃO DEFINITIVA
% =========================================================================
disp('3. Aplicando o laser para vaporizar os 4.000 Hz...');
x_salvo = conv(x1_interpolado(:)', h_notch, 'same');

% =========================================================================
% VISUALIZAÇÃO: O VEREDITO NO DOMÍNIO DA FREQUÊNCIA
% =========================================================================
N_pontos_final = 10001;
w_vec_final = linspace(-3*pi, 3*pi, N_pontos_final);
X_salvo_dtft = dtft_pure(x_salvo(:), w_vec_final);

figure('Name', 'O Veredito Final: Voz Salva pelo Notch Manual', 'NumberTitle', 'off', 'Position', [200, 200, 1000, 500]);
plot(w_vec_final, abs(X_salvo_dtft), 'g', 'LineWidth', 2);
title('Espectro Final (\omega) - O apito de 4 kHz foi VAPORIZADO na unha!');
xlabel('Frequência Digital \omega (rad/amostra)');
ylabel('Magnitude');
xlim([-3*pi 3*pi]);
xticks([-3*pi, -2*pi, -pi, 0, pi, 2*pi, 3*pi]);
xticklabels({'-3\pi','-2\pi','-\pi','0','\pi','2\pi','3\pi'});
grid on;

% =========================================================================
% REPRODUÇÃO DO ÁUDIO
% =========================================================================
disp('====================================================');
disp(' Pressione ENTER na Command Window para ouvir a Vitória!');
disp('====================================================');
pause;
soundsc(x_salvo, Fs);
