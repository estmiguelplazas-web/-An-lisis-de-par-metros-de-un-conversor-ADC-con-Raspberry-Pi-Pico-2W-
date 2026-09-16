# Práctica 4 - Explorando la Conversión Análoga a Digital (ADC)

## Autores

- Daniel Mateo Alegría Bernate
- Miguel Ángel Plazas Llanes
  
Ingeniería de Telecomunicaciones  
Universidad Militar Nueva Granada

---

## Explorando la Conversión Análoga a Digital (ADC) con Raspberry Pi Pico 2W

Este repositorio contiene el desarrollo de la Práctica 4 de Comunicaciones Digitales de la carrera de Ingeniería de Telecomunicaciones en la Universidad Militar Nueva Granada.

En esta práctica se analizó experimentalmente el proceso de Conversión Análoga a Digital (ADC) utilizando el periférico interno de 12 bits de la Raspberry Pi Pico 2W, MicroPython, un generador de señales, un multímetro digital y un osciloscopio Tektronix.

Se estudió la resolución teórica y práctica del convertidor, el voltaje del bit menos significativo ($LSB$), el cálculo de error de cuantización, el análisis de linealidad mediante barridos de voltaje DC y el comportamiento estático/dinámico frente a señales senoidales. Además, se realizó el procesamiento de $10.000$ muestras continuas utilizando herramientas en Python para caracterizar el ruido y la distribución estadística del convertidor.

---

## Objetivos

### Objetivo general

Analizar experimentalmente el comportamiento y las características del periférico de conversión análoga a digital (ADC) de la Raspberry Pi Pico 2W, evaluando la resolución, el error de cuantización, la linealidad y la distribución estadística del ruido en señales continuas e ininterrumpidas.

### Objetivos específicos

- Caracterizar el voltaje de referencia ($V_{ref}$) y determinar el valor del $LSB$ teórico y experimental.
- Evaluar el error de cuantización a lo largo de un barrido de voltaje de corriente continua (DC).
- Medir la respuesta del ADC ante señales variables en el tiempo (senoidales) para verificar la tasa de muestreo y la fidelidad de reconstrucción.
- Adquirir y procesar un lote de $10.000$ muestras en formato de punto flotante y valores discretos para su análisis estadístico (media, desviación estándar, histogramas).
- Desarrollar scripts de adquisición en MicroPython y de análisis de datos en Python (`matplotlib`, `numpy`, `scipy`).

---

## Parámetros de la práctica

| Parámetro | Valor |
|---|---|
| Microcontrolador | Raspberry Pi Pico 2W (RP2350) |
| Periférico ADC | ADC0 (Pin GP26 / Canal 0) |
| Resolución nativa | 12 bits ($0 - 4095$) |
| Resolución en MicroPython | 16 bits emulados (`read_u16`, $0 - 65535$) |
| Voltaje de Referencia ($V_{ref}$) | $3.3\text{ V}$ (Pin 36 `3V3_OUT` / ADC_VREF) |
| Frecuencia de Muestreo | Configurable / $1\text{ kHz} - 10\text{ kHz}$ |
| Tamaño de Lote Estadístico | $10.000$ muestras DC |
| Instrumentos de Medición | Osciloscopio Tektronix, Multímetro Digital, Generador de Funciones |
| Lenguajes de Programación | MicroPython (Target) y Python (Procesamiento/Plots) |

---

## Metodología

### 1. Configuración de hardware y medición de $V_{ref}$

Se configuró el canal ADC0 (GP26) de la Raspberry Pi Pico 2W. Se midió el voltaje real del riel de alimentación $V_{ref}$ con el multímetro digital para calibrar los cálculos.

La conexión utilizada fue:

- **Entrada ADC0:** GP26 (Pin 31).
- **GND:** Pin 3 o Pin 38 (GND analógico).
- **VREF:** Pin 36 (`3V3_OUT`).

El cálculo del voltaje de bit menos significativo ($LSB$) se obtuvo mediante:

$$LSB = \frac{V_{ref}}{2^N} = \frac{3.3\text{ V}}{2^{12}} = \frac{3.3\text{ V}}{4096} \approx 0.8056\text{ mV}$$

donde $N = 12$ bits de resolución nativa del ADC.

### 2. Barrido DC y Error de Cuantización

Se aplicó un voltaje DC variable en pasos discretos desde $0\text{ V}$ hasta $3.3\text{ V}$ utilizando una fuente regulada / potenciómetro calibrado. Para cada escalón de voltaje se registraron:
1. Voltaje real medido con multímetro ($V_{in}$).
2. Valor digitalizado obtenido por la Pico 2W ($D_{out}$).
3. Voltaje reconstruido ($V_{calc} = D_{out} \times LSB$).

El error absoluto y el error de cuantización $e_q$ se evaluaron teóricamente dentro del rango:

$$-\frac{LSB}{2} \le e_q \le \frac{LSB}{2}$$

### 3. Muestreo de Señales Senoidales (Modo Dinámico)

Se inyectó una señal senoidal con amplitud dentro del rango de $0\text{ V}$ a $3.3\text{ V}$ (offset de $1.65\text{ V}$) proveniente del generador de funciones. Se adquirieron las muestras en intervalos periódicos de tiempo para analizar la reconstrucción de la forma de onda en el dominio del tiempo y verificar el cumplimiento del Teorema de Muestreo de Nyquist-Shannon.

### 4. Adquisición y Análisis Estadístico ($10.000$ Muestras)

Con una señal de entrada DC fija y stable, se capturó un bloque continuo de $10.000$ muestras directas. Las muestras fueron exportadas a un archivo `.csv` para su posterior procesamiento en Python.

Se calcularon los siguientes métricos estadísticos:
- **Media ($\mu$):** Indicador del valor medio medido.
- **Desviación Estándar ($\sigma$):** Medida del ruido térmico y de cuantización presente en la lectura.
- **Histograma de Distribución:** Evaluación de la distribución gaussiana del ruido.

---

## Resultados y Análisis

### Tabla de Resolución y Niveles Discretos

| Resolución ($N$) | Combinaciones ($2^N$) | Valor LSB ($V_{ref} = 3.3\text{ V}$) | Rango Dinámico |
|---:|---:|---:|---:|
| 8 bits | 256 | $12.89\text{ mV}$ | $48.16\text{ dB}$ |
| 10 bits | 1024 | $3.22\text{ mV}$ | $60.20\text{ dB}$ |
| **12 bits (Pico 2W)** | **4096** | **$0.8056\text{ mV}$** | **$72.25\text{ dB}$** |
| 16 bits (Emulado) | 65536 | $0.0503\text{ mV}$ | $96.32\text{ dB}$ |

### Análisis de la Toma de $10.000$ Muestras DC

| Parámetro Estadístico | Valor Obtenido |
|---|---:|
| Cantidad de Muestras | $10.000$ |
| Voltaje Nominal Entrada | $1.650\text{ V}$ |
| Promedio Medido ($\mu$) | $1.6482\text{ V}$ |
| Desviación Estándar ($\sigma$) | $1.82\text{ mV}$ |
| Error Máximo Registrado | $3.21\text{ mV}$ |
| Distribución | Normal |

---

## Desarrollo

- [X] Capturas MicroPython  
- [X] Capturas Montaje  
- [X] Capturas Osciloscopio  
- [X] Códigos  
- [X] Informe
