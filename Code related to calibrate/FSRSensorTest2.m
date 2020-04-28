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


%% Connect MATLAB to arduino 

%Use serialportlist("available")' to find correct comPort
% arduinoObj = serialport("COM4",9600); %Arduino UNO
arduinoObj = serialport("COM11",9600); %Arduino NANO

% Mirrors the arduino acknowledgement routine :
data = 'b'; 

% Read a 8bit precision character until 'a' is read
while (data ~= 'a') 
    data = read(arduinoObj,1,"char");
end

% Character read from arduino
if (data == 'a')
    disp('Arduino succesfuld connected'); 
    write(arduinoObj,"a","char")
end

%% Get date

write(arduinoObj,"F","char"); 
    data = 'b'; 
    j = 1; 
    str ='0';
    while data ~= 'a'
        data = read(arduinoObj,  1, "char"); 
        if (data ~= 'a')
            str(j) = data; 
            j = j+1; 
        end
    end
str2double(str)
