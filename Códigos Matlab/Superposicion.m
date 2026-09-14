%% ============================================================
%% Superposición de Espectros FFT — Pruebas A a D (M = 128, 256, 512, 1024)
%% ============================================================
clear; clc; close all;

try
    cd(fileparts(mfilename('fullpath')));
catch
    % Continuar si mfilename falla (ej. al ejecutar por selección)
end

% --- 1. Definir los archivos y etiquetas de cada prueba ---
archivos = { ...
    'adc_fft_M128.csv',  ...
    'adc_fft_M256.csv',  ...
    'adc_fft_M512.csv',  ...
    'adc_fft_M1024.csv'  ...
    };

etiquetas = {'M = 128', 'M = 256', 'M = 512', 'M = 1024'};
colores   = {[0, 0.45, 0.74], [0.85, 0.33, 0.10], [0.47, 0.67, 0.19], [0.49, 0.18, 0.56]};

% --- 2. Cargar datos en memoria una sola vez ---
num_archivos = length(archivos);
datos = cell(1, num_archivos);

for k = 1:num_archivos
    datos{k} = readtable(archivos{k});
end

% --- 3. Graficar todos los espectros superpuestos ---
figure('Color', 'w');
hold on;
for k = 1:num_archivos
    plot(datos{k}.frequency_Hz, datos{k}.magnitude_dBFS, ...
        'Color', colores{k}, 'LineWidth', 1.1, ...
        'DisplayName', etiquetas{k});
end
grid on;
xlabel('Frecuencia [Hz]');
ylabel('Magnitud [dBFS]');
title('Superposición de Espectros FFT — Efecto de M sobre el Piso de Ruido');
xlim([0, 1000]);   % Banda de Nyquist (Fs/2 = 1000 Hz)
ylim([-120, 5]);
legend('Location', 'northeast');
hold off;

