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
arduinoObj = serialport("COM4",19200); %Arduino UNO

% arduinoObj = serialport("COM11",9600);   % Connect to the microcontroller Due by creating a serialport object using the port and baud rate specified in the microcontroller code.
configureTerminator(arduinoObj,"CR/LF"); % Set the Terminator property to match the terminator that you specified in the microcontroller code.
flush(arduinoObj);                       % Flush the serialport object to remove any old data.
arduinoObj.UserData = struct("Data",[],"Count",1); %Prepare the UserData property to store the microcontroller data. The Data field of the struct saves the sine wave value and the Count field saves the x-axis value of the sine wave.

% The callback function opens the MATLAB figure window with a plot of the first 1000 points.
configureCallback(arduinoObj,"terminator",@readArduinoData); % Set the BytesAvailableFcnMode property to "terminator" and the BytesAvailableFcn property to @readArduinoData. The callback function readArduinoData is triggered when a new data (with the terminator) is available to be read from the microcontroller.

%% Frequency analysis 

Fs = 320;            % Sampling frequency                    
T = 1/Fs;            % Sampling period       
L = length(arduinoObj.UserData.Data(2:end));    % Length of signal

data = (arduinoObj.UserData.Data(2:end)/1023)*5;
Y = fft(data);       % Compute the Fourier transform of the signal. 

% Compute the two-sided spectrum P2. Then compute the single-sided spectrum P1 based on P2 and the even-valued signal length L.
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

%Define the frequency domain f and plot the single-sided amplitude spectrum P1.
f = Fs*(0:(L/2))/L;
plot(f,P1) 
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')
