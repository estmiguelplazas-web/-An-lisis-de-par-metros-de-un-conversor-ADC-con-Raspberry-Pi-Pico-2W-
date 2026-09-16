%% Superposición en el Dominio de la Frecuencia y del Tiempo
%% Pruebas A a D (M = 128, 256, 512, 1024)
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

% Dominio del tiempo
archivos_tiempo = { ...
    'adc_time_M128.csv',  ...
    'adc_time_M256.csv',  ...
    'adc_time_M512.csv',  ...
    'adc_time_M1024.csv'  ...
    };
datos_tiempo = cell(1, num_archivos);
for k = 1:num_archivos
    datos_tiempo{k} = readtable(archivos_tiempo{k});
end

% --- 3. Graficar todos los espectros superpuestos (Dominio de Frecuencia) ---
figure('Color', 'w', 'Name', 'Superposición Espectros FFT');
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

% --- 4. Graficar señales superpuestas (Dominio del Tiempo Alineadas) ---
figure('Color', 'w', 'Name', 'Superposición Dominio del Tiempo');
hold on;
etiqueta_y = 'Amplitud';

% Graficamos en orden inverso (de mayor a menor M) para que M=128 quede encima
for k = num_archivos:-1:1
    df = datos_tiempo{k}; 
    if ismember('voltage_V', df.Properties.VariableNames)
        eje_y = df.voltage_V;
        etiqueta_y = 'Voltaje [V]';
    elseif ismember('sample_val', df.Properties.VariableNames)
        eje_y = df.sample_val;
        etiqueta_y = 'Muestra Digital [LSB]';
    else
        eje_y = df{:, 2}; 
        etiqueta_y = 'Amplitud';
    end
    
    % --- ALINEACIÓN DE FASE EN T = 0 ---
    y_ac = eje_y - mean(eje_y); % Eliminar offset DC para encontrar el punto medio
    
    % Buscar el primer cruce por cero de subida (pendiente positiva)
    idx_cruce = find(y_ac(1:end-1) <= 0 & y_ac(2:end) > 0, 1, 'first');
    
    if ~isempty(idx_cruce)
        t_ref = df.time_s(idx_cruce);
    else
        t_ref = df.time_s(1); % Respaldo por si no detecta el cruce
    end
    
    % Desplazar el vector de tiempo para que el inicio de fase coincida en t = 0
    t_alineado = df.time_s - t_ref;
    
    plot(t_alineado, eje_y, ...
        'Color', colores{k}, 'LineWidth', 1.2, ...
        'DisplayName', etiquetas{k});
end

grid on;
xlabel('Tiempo [s]');
ylabel(etiqueta_y);
title('Superposición de Señales en el Dominio del Tiempo (Alineadas en Fase)');
legend('Location', 'northeast');

% Ajuste de límites para ver claramente los ciclos desde t = 0
xlim([0, 0.015]); % 15 ms
hold off;
