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

disp('System reset'); 


%% Connect microcontroller and sample data (remember to clear previos connection!)
disp('Sampling started. Wait'); 
%arduinoObj = serialport("COM4",19200); %Arduino UNO
arduinoObj = serialport("COM5",9600); %Arduino UNO


% arduinoObj = serialport("COM11",9600);   % Connect to the microcontroller Due by creating a serialport object using the port and baud rate specified in the microcontroller code.
configureTerminator(arduinoObj,"CR/LF"); % Set the Terminator property to match the terminator that you specified in the microcontroller code.
flush(arduinoObj);                       % Flush the serialport object to remove any old data.
arduinoObj.UserData = struct("Data",[],"Count",1); %Prepare the UserData property to store the microcontroller data. The Data field of the struct saves the sine wave value and the Count field saves the x-axis value of the sine wave.

% The callback function opens the MATLAB figure window with a plot of the first 1000 points.
configureCallback(arduinoObj,"terminator",@readArduinoData); % Set the BytesAvailableFcnMode property to "terminator" and the BytesAvailableFcn property to @readArduinoData. The callback function readArduinoData is triggered when a new data (with the terminator) is available to be read from the microcontroller.

%%
data = (arduinoObj.UserData.Data(2:end)/1023)*5;

sum(data)/length(arduinoObj.UserData.Data(2:end))


% Analyse the recorded data in another scipbt

