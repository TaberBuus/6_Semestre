%% This scribt can frequency analyze a signal from a microcontroller
% 1. Change sampling frequency?: Sampling frequnce must be must be change 
% though the microcontroller program and changed respectively in the 
% 'FFT analyze' section. 
% 2. Change sample size?: The sample size can be changed in the
% readArduioData function. (visible in the folder) 

%% Clear any previous connections

clc
clear all 
if ~isempty(instrfind) %check if any instrument are connected
    fclose(instrfind); %close com if any open 
    delete(instrfind); 
end
clc; 
close all; 
clear all; 

%% Connect microcontroller and sample data (remember to clear previos connection!)

disp('Sampling started. Wait'); 
% Connect to the microcontroller Due by creating a serialport object using the port and baud rate specified in the microcontroller code.
microcontrollerObj = serialport("COM13",115200);    % m5stack
% microcontrollerObj = serialport("COM5",19200);    % DOIT esp32 devkit
% kode linje 25 fik mig til at græde btw. 
% microcontrollerObj = serialport("COM4",19200);    % arduino UNO
% microcontrollerObj = serialport("COM11",19200);   % arduino Nano

configureTerminator(microcontrollerObj,"CR/LF"); % Set the Terminator property to match the terminator that you specified in the microcontroller code.
flush(microcontrollerObj);                       % Flush the serialport object to remove any old data.
microcontrollerObj.UserData = struct("Data",[],"Count",1); %Prepare the UserData property to store the microcontroller data. The Data field of the struct saves the sine wave value and the Count field saves the x-axis value of the sine wave.

% The callback function opens the MATLAB figure window with a plot of the first 1000 points.
configureCallback(microcontrollerObj,"terminator",@readData); % Set the BytesAvailableFcnMode property to "terminator" and the BytesAvailableFcn property to @readArduinoData. The callback function readArduinoData is triggered when a new data (with the terminator) is available to be read from the microcontroller.

%configureCallback(microcontrollerObj,"terminator",@readMicrocontrollerData); % Set the BytesAvailableFcnMode property to "terminator" and the BytesAvailableFcn property to @readArduinoData. The callback function readArduinoData is triggered when a new data (with the terminator) is available to be read from the microcontroller.

 %% FFT (Cut data)
data = (microcontrollerObj.UserData.Data(2:end)/4095)*3.3;
dataPointFound = 0; 
for i = 2:length(data) +1
    if microcontrollerObj.UserData.Data(i) ~= 0 && dataPointFound == 0
        StartSlopeValue = i; 
        dataPointFound = 1; 
    end
end 
clear i; clear dataPointFound; 

Fs = 320;            % Sampling frequency                    
T = 1/Fs;            % Sampling period       
L = length(microcontrollerObj.UserData.Data(StartSlopeValue-320:StartSlopeValue+1600));    % Length of signal

data = (microcontrollerObj.UserData.Data(StartSlopeValue-320:StartSlopeValue+1600)/4095)*3.3;

Y = fft(data);       % Compute the Fourier transform of the signal. 

% Compute the two-sided spectrum P2. Then compute the single-sided spectrum P1 based on P2 and the even-valued signal length L.
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

%Define the frequency domain f and plot the single-sided amplitude spectrum P1.
f = Fs*(0:(L/2))/L;
plot(f,P1) 
title('Frequency domain of FSR sensor recording (static load, Fc = 5 Hz)')
xlabel('f (Hz)')
ylabel('|P1(f)|')
xlim([0 20]);

%% Frequency analysis (uden cut)

data = (microcontrollerObj.UserData.Data(2:end)/4095)*3.3;

Fs = 320;            % Sampling frequency                    
T = 1/Fs;            % Sampling period       
L = length(microcontrollerObj.UserData.Data(2:end));    % Length of signal

data = (data/4095)*3.3;
%data = data - min(data);

Y = fft(data);       % Compute the Fourier transform of the signal. 

% Compute the two-sided spectrum P2. Then compute the single-sided spectrum P1 based on P2 and the even-valued signal length L.
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

%Define the frequency domain f and plot the single-sided amplitude spectrum P1.
f = Fs*(0:(L/2))/L;
plot(f,P1) 
title('Frequency domain of FSR sensor recording (static load, 10Hz filter)')
xlabel('f (Hz)')
ylabel('|P1(f)|')
xlim([1 20])


%% Plot normal values 
x = linspace(0,L/Fs,length(data));
plot(x, data);
title('FSR sensor')
xlabel('time (t)')
ylabel('voltage (v)')

%% understand FFT
Fs = 1000;            % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = 1500;             % Length of signal
t = (0:L-1)*T;        % Time vector

%Form a signal containing a 50 Hz sinusoid of amplitude 0.7 and a 120 Hz sinusoid of amplitude 1.
S = 0.7*sin(2*pi*50*t) + sin(2*pi*120*t);

%Corrupt the signal with zero-mean white noise with a variance of 4.
X = S + 2*randn(size(t));

%Plot the noisy signal in the time domain. It is difficult to identify the frequency components by looking at the signal X(t).
plot(1000*t(1:50),X(1:50))
title('Signal Corrupted with Zero-Mean Random Noise')
xlabel('t (milliseconds)')
ylabel('X(t)')

%%
%Compute the Fourier transform of the signal.
Y = fft(X);

%Compute the two-sided spectrum P2. Then compute the single-sided spectrum P1 based on P2 and the even-valued signal length L.
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

%Define the frequency domain f and plot the single-sided amplitude spectrum P1. The amplitudes are not exactly at 0.7 and 1, as expected, because of the added noise. On average, longer signals produce better frequency approximations.
f = Fs*(0:(L/2))/L;
plot(f,P1) 
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')

%% Sampling frequency test 

% clock has a precision of 1ms
data = microcontrollerObj.UserData.Data(2:end); 


j = 1; 
for i = 10:2009
    diff(j) = data(i+1) - data(i); 
    j = j + 1; 
end 


plot(diff); 
title('Test af sampling frekvens'); 
ylabel('Difference mellem foregående sample ( micro sec )');
xlabel('Sample nummer')
set(gcf,'Position',[300 300 1000 600])
set(gca,'FontSize',14)
grid('on'); 


%% plot

(data(179)- data(100))/80


plot(data(80:180))