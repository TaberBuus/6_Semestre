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
arduinoObj = serialport("COM13",115200);   %Arduino M5Stack

configureTerminator(arduinoObj,"CR/LF"); % Set the Terminator property to match the terminator that you specified in the microcontroller code.
flush(arduinoObj);                       % Flush the serialport object to remove any old data.
arduinoObj.UserData = struct("Data",[],"Count",1); %Prepare the UserData property to store the microcontroller data. The Data field of the struct saves the sine wave value and the Count field saves the x-axis value of the sine wave.

% The callback function opens the MATLAB figure window with a plot of the first 1000 points.
configureCallback(arduinoObj,"terminator",@readArduinoData); % Set the BytesAvailableFcnMode property to "terminator" and the BytesAvailableFcn property to @readArduinoData. The callback function readArduinoData is triggered when a new data (with the terminator) is available to be read from the microcontroller.

%%
data = (arduinoObj.UserData.Data(2:end))

