%% This scribt is used to calibrate FSR sensor
% 1. Change sampling frequency?: Sampling frequnce must be must be change 
% though the microcontroller program and changed respectively in the 
% 'FFT analyze' section. 
% 2. Change sample size?: The sample size can be changed in the
% readArduioData function. (visible in the folder) 

%% Clear any previous connections
clc
clear all 
if ~isempty(instrfind) % check if any instrument are connected
    fclose(instrfind); % close com if any open 
    delete(instrfind); 
end
clc; 
close all; 
clear all; 
disp('System reset'); 


%% Connect microcontroller and sample data (remember to clear previos connection!)
disp('Setup microcontroller. Wait'); 
%arduinoObj = serialport("COM4",19200);  % Arduino UNO
%arduinoObj = serialport("COM11",19200); % Arduino nano
arduinoObj = serialport("COM13",115200); % M5Stack

configureTerminator(arduinoObj,"CR/LF"); % Set the Terminator property to match the terminator that you specified in the microcontroller code.
flush(arduinoObj);                       % Flush the serialport object to remove any old data.
arduinoObj.UserData = struct("Data",[],"Count",1); %Prepare the UserData property to store the microcontroller data. 

% The callback function opens the MATLAB figure window with a plot of the first 1000 points.
configureCallback(arduinoObj,"terminator",@readArduinoData); % Set the BytesAvailableFcnMode property to "terminator" and the BytesAvailableFcn property to @readArduinoData. The callback function readArduinoData is triggered when a new data (with the terminator) is available to be read from the microcontroller.

%% Store data

straingauge = arduinoObj.UserData.Data(2:2:end); 
fsr = arduinoObj.UserData.Data(3:2:end);


%% data process
Fs = 200;            % Sampling frequency                    
T = 1/Fs;            % Sampling period  

kilogram =  (1.095*straingauge -937.1 - 14);
force = (kilogram/1000)*9.8;
voltage = (fsr/4095)*3.3; 


window = 0.5/T; 
mask3 = linspace(100,0, window); 

movingIntegrel_3fsr = conv(fsr, mask3); % rigtig 
movingIntegrel_3volt = conv(voltage, mask3); % rigtig 

movingIntegrel_3fsrcliped = movingIntegrel_3fsr(1:length(fsr)); 
movingIntegrel_3voltcliped = movingIntegrel_3volt(1:length(voltage)); 

%cftool

% %% Load data, 60 sec
% load('fsr_4_long.mat');     % unit (bit level)      
% load('mass_4_longmat.mat')  % unit (g)
% Fs = 320;                   % Sampling frequency                    
% T = 1/Fs;                   % Sampling period  
% 
% voltage = (fsr/4095)*3.3;   % bit levels to voltage
% 
% window = 0.5/T;             % size of integral filter 
% mask3 = linspace(100,0, window); 
% movingIntegrel_3 = conv(fsr, mask3); 
% movingIntegrel_3cliped = movingIntegrel_3(1:length(fsr)); 
% 
% force = (mass/1000)*9.82; 
% disp('60 sec loaded'); 
% %cftool
% 
% 
% %% Load data, 10 sec
% load('fsr_test.mat');       % unit (bit level)      
% load('mass_test.mat')       % unit (g)
% 
% voltage = (fsr/4095)*3.3;   % bit levels to voltage
% Fs = 320;                   % Sampling frequency                    
% T = 1/Fs;                   % Sampling period  
% 
% window = 0.5/T;             % size of integral filter 
% mask3 = linspace(100,0, window); 
% movingIntegrel_3 = conv(fsr, mask3); 
% movingIntegrel_3cliped = movingIntegrel_3(1:length(fsr)); 
% clear window; clear mask3; clear movingIntegrel_3; clear fsr; 
% 
% % window = 0.5/T; 
% % mask = ones(1,window); 
% % mask2 = linspace(0,100,window); 
% % movingIntegrel_same2 = conv(fsr, mask2, 'same'); 
% 
% force = (mass/1000)*9.82; 
% disp('10 sec loaded'); 
% 
% 
% %% Load data, 5 sec 
% load('mass_2.mat');
% load('fsr_2.mat');
% 
% a = 1373.364; 
% voltage = (fsr/4095)*3.3;   % bit levels to voltage
% Fs = 320;                   % Sampling frequency                    
% T = 1/Fs;                   % Sampling period  
%  
% mass = ((straingauge)/4095)*3.3*a; 
% mass = mass - 1070;
% force = (mass/1000)*9.82; 
% clear a; clear mass; clear straingauge;
% 
% window = 0.5/T;             % size of integral filter 
% mask3 = linspace(100,0, window); 
% movingIntegrel_3 = conv(fsr, mask3); 
% movingIntegrel_3cliped = movingIntegrel_3(1:length(fsr)); 
% clear window; clear mask3; clear movingIntegrel_3; clear fsr; 
% 


%% Test various poly regression
x = voltage; 
y = movingIntegrel_3cliped; 
tid =linspace(0,length(voltage)/320,length(voltage));


for i = 1:length(voltage)
    i
     %Linear model Poly23:
    %Coefficients ;%(with 95% confidence bounds):   
       p00 =      0.3491  ;%(0.3399, 0.3583)
       p10 =       1.972  ;%(1.909, 2.034)
       p01 =   6.152e-09  ;%(-7.039e-10, 1.301e-08)
       p20 =     -0.8493  ;%(-0.8966, -0.802)
       p11 =  -1.096e-07  ;%(-1.172e-07, -1.02e-07)
       p02 =  -8.352e-16  ;%(-1.773e-15, 1.02e-16)
       p21 =   1.501e-07  ;%(1.469e-07, 1.533e-07)
       p12 =  -1.118e-14  ;%(-1.17e-14, -1.066e-14)
       p03 =   3.643e-22  ;%(3.265e-22, 4.022e-22)
    Poly23(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p21*x(i)^2*y(i) + p12*x(i)*y(i)^2 + p03*y(i)^3;

    %Linear model Poly24:
    %Coefficients ;%(with 95% confidence bounds):
        p00 =        0.36  ;%(0.3513, 0.3687)
       p10 =     -0.1007  ;%(-0.1943, -0.007115)
       p01 =   3.003e-08  ;%(1.826e-08, 4.181e-08)
       p20 =       1.144  ;%(1.058, 1.229)
       p11 =  -8.524e-09  ;%(-2.541e-08, 8.362e-09)
       p02 =   4.118e-15  ;%(1.516e-15, 6.72e-15)
       p21 =  -1.931e-07  ;%(-2.06e-07, -1.803e-07)
       p12 =   1.934e-14  ;%(1.715e-14, 2.154e-14)
       p03 =  -1.256e-21  ;%(-1.465e-21, -1.046e-21)
       p22 =   1.278e-14  ;%(1.231e-14, 1.325e-14)
       p13 =  -1.643e-21  ;%(-1.727e-21, -1.559e-21)
       p04 =   7.182e-29  ;%(6.606e-29, 7.757e-29)

    Poly24(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p21*x(i)^2*y(i) + p12*x(i)*y(i)^2 + p03*y(i)^3 + p22*x(i)^2*y(i)^2 + p13*x(i)*y(i)^3 + p04*y(i)^4;


    %Linear model Poly25:
    %Coefficients ;%(with 95% confidence bounds):
       p00 =      0.3503  ;%(0.3423, 0.3583)
       p10 =       2.487  ;%(2.371, 2.603)
       p01 =  -3.041e-08  ;%(-4.772e-08, -1.311e-08)
       p20 =      -1.471  ;%(-1.591, -1.35)
       p11 =   -5.69e-07  ;%(-6.02e-07, -5.359e-07)
       p02 =   1.557e-14  ;%(1.002e-14, 2.112e-14)
       p21 =   6.748e-07  ;%(6.434e-07, 7.062e-07)
       p12 =  -1.058e-14  ;%(-1.649e-14, -4.68e-15)
       p03 =   5.984e-22  ;%(-9.5e-23, 1.292e-21)
       p22 =   -6.29e-14  ;%(-6.547e-14, -6.032e-14)
       p13 =   5.882e-21  ;%(5.411e-21, 6.352e-21)
       p04 =  -2.388e-28  ;%(-2.776e-28, -1.999e-28)
       p23 =    1.92e-21  ;%(1.854e-21, 1.985e-21)
       p14 =  -2.446e-28  ;%(-2.568e-28, -2.325e-28)
       p05 =   9.804e-36  ;%(8.999e-36, 1.061e-35)

    Poly25(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p21*x(i)^2*y(i) + p12*x(i)*y(i)^2 + p03*y(i)^3 + p22*x(i)^2*y(i)^2 + p13*x(i)*y(i)^3 + p04*y(i)^4 + p23*x(i)^2*y(i)^3 + p14*x(i)*y(i)^4 + p05*y(i)^5;

    %Linear model Poly31:
    %Coefficients ;%(with 95% confidence bounds):
          
        p00 =      0.3501  ;%(0.3431, 0.357)
       p10 =       2.995  ;%(2.946, 3.043)
       p01 =    1.45e-08  ;%(1.275e-08, 1.624e-08)
       p20 =      -3.068  ;%(-3.119, -3.017)
       p11 =   -1.52e-08  ;%(-1.871e-08, -1.168e-08)
       p30 =       1.121  ;%(1.105, 1.137)
       p21 =   -8.17e-09  ;%(-9.583e-09, -6.756e-09)
    Poly31(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p30*x(i)^3 + p21*x(i)^2*y(i);


    %Linear model Poly32:
    %Coefficients ;%(with 95% confidence bounds):  
        p00 =      0.3486  ;%(0.3417, 0.3556)
       p10 =       3.094  ;%(3.043, 3.146)
       p01 =   1.373e-08  ;%(9.356e-09, 1.809e-08)
       p20 =      -3.148  ;%(-3.199, -3.096)
       p11 =  -1.212e-08  ;%(-1.588e-08, -8.367e-09)
       p02 =    1.57e-16  ;%(-1.74e-16, 4.88e-16)
       p30 =       1.068  ;%(1.051, 1.086)
       p21 =   9.631e-09  ;%(6.85e-09, 1.241e-08)
       p12 =  -1.275e-15  ;%(-1.48e-15, -1.071e-15)

    Poly32(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i) + p12*x(i)*y(i)^2;

    %Linear model Poly33:
    %Coefficients ;%(with 95% confidence bounds):
          p00 =      0.3494  ;%(0.3425, 0.3564)
       p10 =       3.111  ;%(3.059, 3.162)
       p01 =   1.794e-09  ;%(-3.413e-09, 7.002e-09)
       p20 =      -3.111  ;%(-3.163, -3.059)
       p11 =  -3.139e-08  ;%(-3.732e-08, -2.546e-08)
       p02 =   2.813e-15  ;%(2.098e-15, 3.527e-15)
       p30 =       1.089  ;%(1.071, 1.107)
       p21 =   1.094e-09  ;%(-2.349e-09, 4.536e-09)
       p12 =   3.573e-16  ;%(-8.239e-17, 7.969e-16)
       p03 =  -1.252e-22  ;%(-1.55e-22, -9.534e-23)
    Poly33(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i) + p12*x(i)*y(i)^2 + p03*y(i)^3;

    %Linear model Poly34:
    %Coefficients ;%(with 95% confidence bounds):   
        p00 =      0.3549  ;%(0.3483, 0.3614)
       p10 =      0.6231  ;%(0.5253, 0.7209)
       p01 =   2.362e-08  ;%(1.471e-08, 3.253e-08)
       p20 =      0.6964  ;%(0.556, 0.8368)
       p11 =  -3.505e-08  ;%(-4.801e-08, -2.209e-08)
       p02 =   1.504e-15  ;%(-4.622e-16, 3.471e-15)
       p30 =     -0.2249  ;%(-0.2809, -0.1689)
       p21 =  -1.433e-07  ;%(-1.531e-07, -1.336e-07)
       p12 =   9.189e-15  ;%(7.505e-15, 1.087e-14)
       p03 =  -1.215e-22  ;%(-2.82e-22, 3.901e-23)
       p31 =   8.157e-08  ;%(7.8e-08, 8.514e-08)
       p22 =  -6.107e-15  ;%(-6.784e-15, -5.431e-15)
       p13 =   1.385e-22  ;%(5.985e-23, 2.172e-22)
       p04 =  -3.539e-30  ;%(-8.238e-30, 1.161e-30)
    Poly34(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i) + p12*x(i)*y(i)^2 + p03*y(i)^3 + p31*x(i)^3*y(i) + p22*x(i)^2*y(i)^2 + p13*x(i)*y(i)^3 + p04*y(i)^4;

    %Linear model Poly35:
    %Coefficients ;%(with 95% confidence bounds):        
          p00 =      0.3415  ;%(0.3353, 0.3477)
       p10 =       3.897  ;%(3.75, 4.043)
       p01 =   6.202e-08  ;%(4.845e-08, 7.559e-08)
       p20 =      -5.013  ;%(-5.265, -4.76)
       p11 =  -2.794e-07  ;%(-3.055e-07, -2.534e-07)
       p02 =   -1.07e-14  ;%(-1.503e-14, -6.363e-15)
       p30 =       2.004  ;%(1.893, 2.114)
       p21 =   5.304e-07  ;%(5.022e-07, 5.585e-07)
       p12 =  -6.101e-15  ;%(-1.068e-14, -1.523e-15)
       p03 =    8.65e-22  ;%(3.268e-22, 1.403e-21)
       p31 =  -2.674e-07  ;%(-2.836e-07, -2.511e-07)
       p22 =  -7.409e-16  ;%(-3.546e-15, 2.064e-15)
       p13 =  -1.469e-22  ;%(-5.6e-22, 2.663e-22)
       p04 =   2.787e-30  ;%(-2.879e-29, 3.437e-29)
       p32 =   1.202e-14  ;%(1.143e-14, 1.26e-14)
       p23 =  -1.298e-21  ;%(-1.421e-21, -1.175e-21)
       p14 =    6.94e-29  ;%(5.574e-29, 8.307e-29)
       p05 =  -1.701e-36  ;%(-2.429e-36, -9.722e-37)
    Poly35(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i) + p12*x(i)*y(i)^2 + p03*y(i)^3 + p31*x(i)^3*y(i) + p22*x(i)^2*y(i)^2 + p13*x(i)*y(i)^3 + p04*y(i)^4 + p32*x(i)^3*y(i)^2 + p23*x(i)^2*y(i)^3 + p14*x(i)*y(i)^4 +p05*y(i)^5;


    %Linear model Poly41:
    %Coefficients ;%(with 95% confidence bounds):
          p00 =      0.3542  ;%(0.3481, 0.3604)
       p10 =       0.311  ;%(0.2156, 0.4065)
       p01 =   2.607e-08  ;%(2.444e-08, 2.769e-08)
       p20 =       2.326  ;%(2.173, 2.479)
       p11 =  -8.483e-08  ;%(-9.242e-08, -7.724e-08)
       p30 =      -2.242  ;%(-2.337, -2.148)
       p21 =   6.835e-08  ;%(6.096e-08, 7.574e-08)
       p40 =      0.6579  ;%(0.6377, 0.678)
       p31 =  -2.104e-08  ;%(-2.29e-08, -1.918e-08)
    Poly41(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p30*x(i)^3 + p21*x(i)^2*y(i) + p40*x(i)^4 + p31*x(i)^3*y(i);



    %Linear model Poly42:
    %Coefficients ;%(with 95% confidence bounds):   
        p00 =       0.354  ;%(0.3478, 0.3601)
       p10 =     0.03212  ;%(-0.06383, 0.1281)
       p01 =   3.138e-08  ;%(2.688e-08, 3.588e-08)
       p20 =       2.725  ;%(2.571, 2.88)
       p11 =  -9.404e-08  ;%(-1.024e-07, -8.565e-08)
       p02 =  -5.395e-16  ;%(-8.904e-16, -1.886e-16)
       p30 =      -2.175  ;%(-2.268, -2.082)
       p21 =   1.515e-08  ;%(6.255e-09, 2.405e-08)
       p12 =   3.935e-15  ;%(3.322e-15, 4.547e-15)
       p40 =      0.5297  ;%(0.5078, 0.5517)
       p31 =   1.611e-08  ;%(1.258e-08, 1.964e-08)
       p22 =  -2.412e-15  ;%(-2.651e-15, -2.174e-15)

    Poly42(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i) + p12*x(i)*y(i)^2 + p40*x(i)^4 + p31*x(i)^3*y(i) + p22*x(i)^2*y(i)^2;


    %Linear model Poly43:
    %Coefficients ;%(with 95% confidence bounds):
        p00 =      0.3532  ;%(0.347, 0.3594)
       p10 =   -0.004312  ;%(-0.09985, 0.09123)
       p01 =   4.256e-08  ;%(3.476e-08, 5.036e-08)
       p20 =       2.687  ;%(2.533, 2.842)
       p11 =  -7.654e-08  ;%(-8.664e-08, -6.645e-08)
       p02 =  -3.178e-15  ;%(-4.52e-15, -1.836e-15)
       p30 =      -2.156  ;%(-2.248, -2.063)
       p21 =   -1.11e-09  ;%(-1.022e-08, 8.001e-09)
       p12 =   4.895e-15  ;%(4.256e-15, 5.535e-15)
       p03 =   1.301e-22  ;%(7.19e-23, 1.883e-22)
       p40 =      0.5757  ;%(0.5527, 0.5987)
       p31 =  -1.574e-09  ;%(-6.122e-09, 2.973e-09)
       p22 =   5.478e-16  ;%(2.845e-19, 1.095e-15)
       p13 =  -1.826e-22  ;%(-2.166e-22, -1.486e-22)
    Poly43(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i)  + p12*x(i)*y(i)^2 + p03*y(i)^3 + p40*x(i)^4 + p31*x(i)^3*y(i) + p22*x(i)^2*y(i)^2 + p13*x(i)*y(i)^3;



    %Linear model Poly44:
    %Coefficients ;%(with 95% confidence bounds):
       p00 =      0.3532  ;%(0.347, 0.3594)
       p10 =   -0.004405  ;%(-0.09996, 0.09115)
       p01 =   4.276e-08  ;%(3.432e-08, 5.12e-08)
       p20 =       2.687  ;%(2.533, 2.841)
       p11 =   -7.61e-08  ;%(-8.843e-08, -6.378e-08)
       p02 =  -3.258e-15  ;%(-5.122e-15, -1.395e-15)
       p30 =      -2.157  ;%(-2.25, -2.063)
       p21 =   -7.48e-10  ;%(-1.156e-08, 1.007e-08)
       p12 =   4.805e-15  ;%(3.207e-15, 6.402e-15)
       p03 =   1.388e-22  ;%(-1.285e-23, 2.905e-22)
       p40 =      0.5757  ;%(0.5526, 0.5987)
       p31 =  -1.494e-09  ;%(-6.221e-09, 3.233e-09)
       p22 =   5.216e-16  ;%(-1.69e-16, 1.212e-15)
       p13 =  -1.784e-22  ;%(-2.537e-22, -1.032e-22)
       p04 =  -2.754e-31  ;%(-4.708e-30, 4.157e-30)
    Poly44(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i) + p12*x(i)*y(i)^2 + p03*y(i)^3 + p40*x(i)^4 + p31*x(i)^3*y(i) + p22*x(i)^2*y(i)^2 + p13*x(i)*y(i)^3 + p04*y(i)^4;


    %Linear model Poly45:
    %Coefficients (with 95% confidence bounds):     
       p00 =       0.344  ;%(0.3381, 0.3499)
       p10 =        3.48  ;%(3.311, 3.648)
       p01 =   3.991e-08  ;%(2.677e-08, 5.305e-08)
       p20 =      -4.407  ;%(-4.777, -4.037)
       p11 =  -2.821e-07  ;%(-3.071e-07, -2.572e-07)
       p02 =  -2.995e-15  ;%(-7.199e-15, 1.209e-15)
       p30 =        2.11  ;%(1.821, 2.4)
       p21 =   4.821e-07  ;%(4.541e-07, 5.1e-07)
       p12 =  -5.663e-15  ;%(-1.006e-14, -1.269e-15)
       p03 =   3.721e-22  ;%(-1.456e-22, 8.898e-22)
       p40 =     -0.2346  ;%(-0.3175, -0.1517)
       p31 =  -2.563e-07  ;%(-2.719e-07, -2.407e-07)
       p22 =  -3.338e-15  ;%(-6.023e-15, -6.537e-16)
       p13 =   7.192e-22  ;%(3.209e-22, 1.117e-21)
       p04 =  -2.806e-29  ;%(-5.829e-29, 2.179e-30)
       p41 =   4.434e-08  ;%(3.916e-08, 4.952e-08)
       p32 =   6.889e-16  ;%(-4.378e-16, 1.816e-15)
       p23 =   2.876e-23  ;%(-1.253e-22, 1.828e-22)
       p14 =  -2.034e-29  ;%(-3.475e-29, -5.927e-30)
       p05 =   8.193e-37  ;%(1.057e-37, 1.533e-36)
       
%        p00 =        1.11  ;%(1.083, 1.136)
%        p10 =       6.027  ;%(5.595, 6.459)
%        p01 =  -1.696e-07  ;%(-2.095e-07, -1.298e-07)
%        p20 =      -9.404  ;%(-10.25, -8.555)
%        p11 =  -6.669e-07  ;%(-7.348e-07, -5.99e-07)
%        p02 =    6.25e-14  ;%(5.171e-14, 7.329e-14)
%        p30 =       5.716  ;%(5.108, 6.323)
%        p21 =   7.869e-07  ;%(7.296e-07, 8.442e-07)
%        p12 =    2.52e-14  ;%(1.588e-14, 3.452e-14)
%        p03 =   -6.74e-21  ;%(-7.92e-21, -5.561e-21)
%        p40 =     -0.9813  ;%(-1.131, -0.8316)
%        p31 =  -5.068e-07  ;%(-5.343e-07, -4.794e-07)
%        p22 =   5.852e-15  ;%(1.124e-15, 1.058e-14)
%        p13 =  -1.209e-21  ;%(-1.917e-21, -5.006e-22)
%        p04 =   2.865e-28  ;%(2.278e-28, 3.452e-28)
%        p41 =   1.098e-07  ;%(1.021e-07, 1.174e-07)
%        p32 =  -3.843e-15  ;%(-5.309e-15, -2.377e-15)
%        p23 =   1.714e-22  ;%(-1.76e-23, 3.605e-22)
%        p14 =   1.023e-29  ;%(-8.752e-30, 2.921e-29)
%        p05 =  -4.094e-36  ;%(-5.184e-36, -3.004e-36)
  
       
    Poly45(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i)  + p12*x(i)*y(i)^2 + p03*y(i)^3 + p40*x(i)^4 + p31*x(i)^3*y(i) + p22*x(i)^2*y(i)^2 + p13*x(i)*y(i)^3 + p04*y(i)^4 + p41*x(i)^4*y(i) + p32*x(i)^3*y(i)^2 + p23*x(i)^2*y(i)^3 + p14*x(i)*y(i)^4 + p05*y(i)^5;


    %Linear model Poly51:
    %Coefficients (with 95% confidence bounds):   
         p00 =      0.3487  ;%(0.3428, 0.3546)
       p10 =       3.549  ;%(3.374, 3.724)
       p01 =   2.371e-08  ;%(2.212e-08, 2.529e-08)
       p20 =      -5.991  ;%(-6.39, -5.592)
       p11 =  -1.441e-07  ;%(-1.587e-07, -1.295e-07)
       p30 =       5.079  ;%(4.705, 5.452)
       p21 =   1.722e-07  ;%(1.472e-07, 1.972e-07)
       p40 =      -2.037  ;%(-2.201, -1.873)
       p31 =   -7.45e-08  ;%(-8.869e-08, -6.031e-08)
       p50 =      0.3559  ;%(0.3291, 0.3827)
       p41 =   8.528e-09  ;%(5.948e-09, 1.111e-08)
    Poly51(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p30*x(i)^3 + p21*x(i)^2*y(i) + p40*x(i)^4 + p31*x(i)^3*y(i) + p50*x(i)^5 + p41*x(i)^4*y(i);


    %Linear model Poly52:
    %Coefficients (with 95% confidence bounds): 
          p00 =      0.3452  ;%(0.3393, 0.351)
       p10 =       3.735  ;%(3.564, 3.906)
       p01 =   3.319e-08  ;%(2.872e-08, 3.767e-08)
       p20 =      -6.112  ;%(-6.512, -5.712)
       p11 =  -2.252e-07  ;%(-2.445e-07, -2.06e-07)
       p02 =   -7.48e-16  ;%(-1.101e-15, -3.944e-16)
       p30 =       4.861  ;%(4.496, 5.226)
       p21 =   2.583e-07  ;%(2.334e-07, 2.832e-07)
       p12 =   3.561e-15  ;%(2.226e-15, 4.897e-15)
       p40 =      -1.676  ;%(-1.837, -1.515)
       p31 =   -1.42e-07  ;%(-1.603e-07, -1.236e-07)
       p22 =  -6.603e-16  ;%(-1.914e-15, 5.938e-16)
       p50 =      0.2218  ;%(0.193, 0.2506)
       p41 =   3.405e-08  ;%(2.935e-08, 3.875e-08)
       p32 =  -7.225e-16  ;%(-1.039e-15, -4.059e-16)

     Poly52(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i) + p12*x(i)*y(i)^2 + p40*x(i)^4 + p31*x(i)^3*y(i) + p22*x(i)^2*y(i)^2 + p50*x(i)^5 + p41*x(i)^4*y(i) + p32*x(i)^3*y(i)^2;


    %Linear model Poly53:
    %Coefficients (with 95% confidence bounds):         
       p00 =      0.3446  ;%(0.3388, 0.3505)
       p10 =       3.792  ;%(3.623, 3.961)
       p01 =    3.14e-08  ;%(2.284e-08, 3.996e-08)
       p20 =      -5.919  ;%(-6.314, -5.524)
       p11 =  -2.525e-07  ;%(-2.72e-07, -2.329e-07)
       p02 =   6.907e-17  ;%(-1.465e-15, 1.604e-15)
       p30 =       4.436  ;%(4.074, 4.798)
       p21 =   3.546e-07  ;%(3.269e-07, 3.824e-07)
       p12 =  -1.922e-15  ;%(-3.972e-15, 1.273e-16)
       p03 =  -5.072e-23  ;%(-1.182e-22, 1.676e-23)
       p40 =      -1.649  ;%(-1.808, -1.491)
       p31 =  -1.291e-07  ;%(-1.475e-07, -1.107e-07)
       p22 =  -6.866e-15  ;%(-8.378e-15, -5.354e-15)
       p13 =    5.14e-22  ;%(4.037e-22, 6.242e-22)
       p50 =      0.3093  ;%(0.2796, 0.339)
       p41 =  -4.058e-09  ;%(-1.009e-08, 1.978e-09)
       p32 =   5.243e-15  ;%(4.514e-15, 5.971e-15)
       p23 =  -3.137e-22  ;%(-3.556e-22, -2.718e-22)
    Poly53(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i)  + p12*x(i)*y(i)^2 + p03*y(i)^3 + p40*x(i)^4 + p31*x(i)^3*y(i) + p22*x(i)^2*y(i)^2 + p13*x(i)*y(i)^3 + p50*x(i)^5 + p41*x(i)^4*y(i) + p32*x(i)^3*y(i)^2 + p23*x(i)^2*y(i)^3;

    %Linear model Poly54:
    %Coefficients (with 95% confidence bounds):      
          p00 =      0.3443  ;%(0.3384, 0.3501)
       p10 =       3.794  ;%(3.625, 3.963)
       p01 =   3.657e-08  ;%(2.375e-08, 4.939e-08)
       p20 =      -5.932  ;%(-6.327, -5.536)
       p11 =  -2.464e-07  ;%(-2.698e-07, -2.23e-07)
       p02 =  -1.743e-15  ;%(-5.522e-15, 2.035e-15)
       p30 =       4.428  ;%(4.063, 4.792)
       p21 =   3.586e-07  ;%(3.299e-07, 3.873e-07)
       p12 =  -2.938e-15  ;%(-5.799e-15, -7.654e-17)
       p03 =   1.307e-22  ;%(-2.305e-22, 4.918e-22)
       p40 =      -1.646  ;%(-1.806, -1.486)
       p31 =  -1.298e-07  ;%(-1.49e-07, -1.107e-07)
       p22 =  -6.796e-15  ;%(-8.624e-15, -4.969e-15)
       p13 =   5.275e-22  ;%(4.09e-22, 6.459e-22)
       p04 =  -5.441e-30  ;%(-1.633e-29, 5.443e-30)
       p50 =      0.3095  ;%(0.2796, 0.3395)
       p41 =  -4.446e-09  ;%(-1.127e-08, 2.373e-09)
       p32 =   5.377e-15  ;%(4.286e-15, 6.468e-15)
       p23 =  -3.362e-22  ;%(-4.522e-22, -2.202e-22)
       p14 =   1.744e-30  ;%(-4.527e-30, 8.016e-30)
    Poly54(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i)  + p12*x(i)*y(i)^2 + p03*y(i)^3 + p40*x(i)^4 + p31*x(i)^3*y(i) + p22*x(i)^2*y(i)^2 + p13*x(i)*y(i)^3 + p04*y(i)^4 + p50*x(i)^5 + p41*x(i)^4*y(i) + p32*x(i)^3*y(i)^2 + p23*x(i)^2*y(i)^3 + p14*x(i)*y(i)^4;


    %Linear model Poly55:
    %Coefficients (with 95% confidence bounds):
    p00 =      0.3443  ;%(0.3384, 0.3501)
       p10 =       3.795  ;%(3.625, 3.964)
       p01 =   3.615e-08  ;%(2.313e-08, 4.916e-08)
       p20 =      -5.932  ;%(-6.328, -5.537)
       p11 =   -2.48e-07  ;%(-2.729e-07, -2.231e-07)
       p02 =  -1.408e-15  ;%(-5.571e-15, 2.755e-15)
       p30 =       4.433  ;%(4.067, 4.798)
       p21 =   3.568e-07  ;%(3.266e-07, 3.87e-07)
       p12 =  -2.306e-15  ;%(-6.666e-15, 2.054e-15)
       p03 =   6.065e-23  ;%(-4.526e-22, 5.739e-22)
       p40 =      -1.647  ;%(-1.807, -1.487)
       p31 =  -1.307e-07  ;%(-1.504e-07, -1.111e-07)
       p22 =  -6.422e-15  ;%(-9.095e-15, -3.748e-15)
       p13 =   4.551e-22  ;%(6.013e-23, 8.501e-22)
       p04 =  -6.483e-32  ;%(-3.011e-29, 2.998e-29)
       p50 =      0.3103  ;%(0.2801, 0.3405)
       p41 =  -4.758e-09  ;%(-1.177e-08, 2.252e-09)
       p32 =   5.476e-15  ;%(4.268e-15, 6.685e-15)
       p23 =  -3.565e-22  ;%(-5.135e-22, -1.995e-22)
       p14 =   4.246e-30  ;%(-1.021e-29, 1.871e-29)
       p05 =  -1.367e-37  ;%(-8.49e-37, 5.756e-37)     
    Poly55(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i) + p12*x(i)*y(i)^2 + p03*y(i)^3 + p40*x(i)^4 + p31*x(i)^3*y(i) + p22*x(i)^2*y(i)^2 + p13*x(i)*y(i)^3 + p04*y(i)^4 + p50*x(i)^5 + p41*x(i)^4*y(i) + p32*x(i)^3*y(i)^2 + p23*x(i)^2*y(i)^3 + p14*x(i)*y(i)^4 + p05*y(i)^5;
    
    %fit(voltage',force','exp1')
    %General model Exp1:     
    exponentielt_fit(i) = 0.2144*exp(1.225*x(i));
    
    %fit(voltage',force','exp2')
    %General model Exp2:
    exponentielt2_fit(i) = 0.4416*exp(0.8126*x(i)) + 4.678e-05*exp(3.938*x(i));
    
    totalSS(i) = (force(i) - mean(force))^2;
    Poly23regressionSS(i) = (Poly23(i) - mean(force))^2; 
    Poly24regressionSS(i) = (Poly24(i) - mean(force))^2; 
    Poly25regressionSS(i) = (Poly25(i) - mean(force))^2; 
    Poly31regressionSS(i) = (Poly31(i) - mean(force))^2; 
    Poly32regressionSS(i) = (Poly32(i) - mean(force))^2; 
    Poly33regressionSS(i) = (Poly33(i) - mean(force))^2; 
    Poly34regressionSS(i) = (Poly34(i) - mean(force))^2; 
    Poly35regressionSS(i) = (Poly35(i) - mean(force))^2; 
    Poly41regressionSS(i) = (Poly41(i) - mean(force))^2; 
    Poly42regressionSS(i) = (Poly42(i) - mean(force))^2; 
    Poly43regressionSS(i) = (Poly43(i) - mean(force))^2; 
    Poly44regressionSS(i) = (Poly44(i) - mean(force))^2; 
    Poly45regressionSS(i) = (Poly45(i) - mean(force))^2; 
    Poly51regressionSS(i) = (Poly51(i) - mean(force))^2; 
    Poly52regressionSS(i) = (Poly52(i) - mean(force))^2; 
    Poly53regressionSS(i) = (Poly53(i) - mean(force))^2; 
    Poly54regressionSS(i) = (Poly54(i) - mean(force))^2; 
    Poly55regressionSS(i) = (Poly55(i) - mean(force))^2; 
    
    exp1regressionSS(i) = (exponentielt_fit(i) - mean(force))^2; 
    exp2regressionSS(i) = (exponentielt2_fit(i) - mean(force))^2; 


    Poly23_error(i) = abs(Poly23(i)- force(i));
    Poly24_error(i) = abs(Poly24(i)- force(i));
    Poly25_error(i) = abs(Poly25(i)- force(i));
    Poly31_error(i) = abs(Poly31(i)- force(i));
    Poly32_error(i) = abs(Poly32(i)- force(i));
    Poly33_error(i) = abs(Poly33(i)- force(i));
    Poly34_error(i) = abs(Poly34(i)- force(i));
    Poly35_error(i) = abs(Poly35(i)- force(i));
    Poly41_error(i) = abs(Poly41(i)- force(i));
    Poly42_error(i) = abs(Poly42(i)- force(i));
    Poly43_error(i) = abs(Poly43(i)- force(i));
    Poly44_error(i) = abs(Poly44(i)- force(i));
    Poly45_error(i) = abs(Poly45(i)- force(i));
    Poly51_error(i) = abs(Poly51(i)- force(i));
    Poly52_error(i) = abs(Poly52(i)- force(i));
    Poly53_error(i) = abs(Poly53(i)- force(i));
    Poly54_error(i) = abs(Poly54(i)- force(i));
    Poly55_error(i) = abs(Poly55(i)- force(i));
    exponentielt_fit_error(i) = abs(exponentielt_fit(i)- force(i));
    exponentielt2_fit_error(i)= abs(exponentielt2_fit(i)- force(i));
      
end

r23 =  sum(Poly23regressionSS) / sum(totalSS);
r24 =  sum(Poly24regressionSS) / sum(totalSS);
r25 =  sum(Poly25regressionSS) / sum(totalSS);
r31 =  sum(Poly31regressionSS) / sum(totalSS);
r32 =  sum(Poly32regressionSS) / sum(totalSS);
r33 =  sum(Poly33regressionSS) / sum(totalSS);
r34 =  sum(Poly34regressionSS) / sum(totalSS);
r35 =  sum(Poly35regressionSS) / sum(totalSS);
r41 =  sum(Poly41regressionSS) / sum(totalSS);
r42 =  sum(Poly42regressionSS) / sum(totalSS);
r43 =  sum(Poly43regressionSS) / sum(totalSS);
r44 =  sum(Poly44regressionSS) / sum(totalSS);
r45 =  sum(Poly45regressionSS) / sum(totalSS);
r51 =  sum(Poly51regressionSS) / sum(totalSS);
r52 =  sum(Poly52regressionSS) / sum(totalSS);
r53 =  sum(Poly53regressionSS) / sum(totalSS);
r54 =  sum(Poly54regressionSS) / sum(totalSS);
r55 =  sum(Poly55regressionSS) / sum(totalSS);

rexp1 =  sum(exp1regressionSS) / sum(totalSS);
rexp2 =  sum(exp2regressionSS) / sum(totalSS);


disp('done'); 

%% plot (standard)
%plot(tid, mass, tid, Poly13, tid,Poly14, tid,Poly15, tid,Poly21, tid,Poly22, tid,Poly23, tid,Poly24, tid,Poly25, tid,Poly31, tid,Poly32, tid,Poly33, tid,Poly34, tid,Poly35, tid,Poly41, tid,Poly42, tid,Poly43, tid,Poly44, tid,Poly45, tid,Poly51, tid,Poly52, tid,Poly53, tid,Poly54, tid,Poly55)
% legend('mass');
% ylim([0 3000]);
% ylabel('weight');

plot(tid, force, tid, Poly45, tid, exponentielt_fit)
legend('strain gauge','45poly fit', 'exponentielt2_fit');
ylabel(' Force ( N )');
xlabel(' Time ( sec ) '); 


%% plot (fancy)
%plot(exponentielt2_fit, force)
plot(Poly55, force);
grid('on')
ylabel('force ( N )'); 
xlabel('regression ( N )'); 

ylim([0 20])
xlim([0 20])



%% Error plot
%plot(tid, Poly13_error, tid,Poly14_error, tid,Poly15_error, tid,Poly21_error, tid,Poly22_error, tid,Poly23_error, tid,Poly24_error, tid,Poly25_error, tid,Poly31_error, tid,Poly32_error, tid,Poly33_error, tid,Poly34_error, tid,Poly35_error, tid,Poly41_error, tid,Poly42_error, tid,Poly43_error, tid,Poly44_error, tid,Poly45_error, tid,Poly51_error, tid,Poly52_error, tid,Poly53_error, tid,Poly54_error, tid,Poly55_error)
ylim([0 200]);

plot(tid, exponentielt2_fit_error)
plot(tid, Poly44_error)


%% Bar chart

X = categorical({'Poly23', 'Poly24','Poly25', 'Poly31', 'Poly32', 'Poly33', 'Poly34', 'Poly35', 'Poly41', 'Poly42', 'Poly43', 'Poly44', 'Poly45','Poly51', 'Poly52', 'Poly53', 'Poly54', 'Poly55'});
Y = [r23 r24 r25 r31 r32 r33 r34 r35 r41 r42 r43 r44 r45 r51 r52 r53 r54 r55];
%X = categorical({'Poly23', 'Poly24','Poly25', 'Poly31', 'Poly32', 'Poly33', 'Poly34', 'Poly35', 'Poly41', 'Poly42', 'Poly43', 'Poly44', 'Poly45','Poly51', 'Poly52', 'Poly53', 'Poly54', 'Poly55','Exp','Two-Term Exp'});
%Y = [mean(Poly23_error) mean(Poly24_error) mean(Poly25_error) mean(Poly31_error) mean(Poly32_error) mean(Poly33_error) mean(Poly34_error) mean(Poly35_error) mean(Poly41_error) mean(Poly42_error)  mean(Poly43_error) mean(Poly44_error) mean(Poly45_error) mean(Poly51_error) mean(Poly52_error) mean(Poly53_error) mean(Poly54_error) mean(Poly55_error), mean(exponentielt_fit_error), mean(exponentielt2_fit_error)];
bar(X,Y)
grid('on')
labels1 = string(Y);
text(X,Y,labels1,'VerticalAlignment','bottom','HorizontalAlignment','center')



%% 
