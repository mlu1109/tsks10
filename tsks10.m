clear;

[y, Fs] = audioread('signal-extra012.wav');
T = 1/Fs;       % Sampling period
B = 20000;      % Bandwidth (hearable sound)
N = length(y);  % Number of samples

% 1. Identify fc
absY = abs(fftshift(fft(y)));
faxis = linspace(-0.5, 0.5, N)*Fs;
freqs = (faxis >= 0);
plot(faxis(freqs), absY(freqs));
xlabel('Frekvens {\itf} [Hz]')
ylabel('|Y(f)|')

Fc = [56000, 94000, 151000]; % From the plot

taxis = linspace(0, T*N, N);
[b, a] = butter(10, [Fc(1)-B, Fc(1)+B]/(Fs/2));
y_1 = filter(b, a, y);
[b, a] = butter(10, [Fc(2)-B, Fc(2)+B]/(Fs/2));
y_2 = filter(b, a, y);
[b, a] = butter(10, [Fc(3)-B, Fc(3)+B]/(Fs/2));
y_3 = filter(b, a, y);

figure;
subplot(3, 1, 1);
plot(taxis, y_1);
title('f_{c} = 56 kHz'); % Looks like the sought signal
ylabel('y_{1}(t)');
subplot(3, 1, 2);
plot(taxis, y_2);
title('f_{c} = 94 kHz');
ylabel('y_{2}(t)');
subplot(3, 1, 3);
plot(taxis, y_3);
title('f_{c} = 151 kHz');
ylabel('y_{3}(t)');
xlabel('Tid {\itt} [s]');

% 2. Identify f1 and f2 of w(t)
figure;
freqs = (faxis > 4.64995e4) & (faxis < 4.65013e4);
plot(faxis(freqs), absY(freqs));
ylabel('|Y(f)|');
xlabel('Frekvens {\itf} [Hz]');

% 3. Identify t2-t1
[z, lags] = xcorr(y);
lags = lags/Fs;
time = (lags >= -0.1);
figure;
plot(lags(time), z(time));
ylabel('z(\tau)');
xlabel('Tid {\it\tau} [s]');
tau = 0.430; % From the plot

% 4. Remove echo from y1
N_tau = uint32(tau / T); % Number of samples in time period tau
for i = N_tau + 1 : N
    y_1(i) = y_1(i) - 0.9 * y_1(i - N_tau);
end

% 5. Demodulate y1
[b, a] = butter(10, B/(Fs/2), 'low');
d = 1.1; % Deduced by trial and error listening to the sounds
I = 2*cos(2*pi*Fc(1)*taxis + d)';
Q = 2*sin(2*pi*Fc(1)*taxis + d)';
x_1I = filter(b, a, y_1.*I); 
x_1Q = -1*filter(b, a, y_1.*Q);
x_1I = decimate(x_1I, 10);
x_1Q = decimate(x_1Q, 10);

pause;
close all;

% 6. Play each sound using the commands below
% soundsc(x_1I, Fs/10);
% soundsc(x_1Q, Fs/10);
