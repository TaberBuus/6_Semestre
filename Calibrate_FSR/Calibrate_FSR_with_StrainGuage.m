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
disp('Initiating sampling. Wait'); 
%arduinoObj = serialport("COM4",19200);  % Arduino UNO
%arduinoObj = serialport("COM11",19200); % Arduino nano
arduinoObj = serialport("COM13",115200); % M5Stack

configureTerminator(arduinoObj,"CR/LF"); % Set the Terminator property to match the terminator that you specified in the microcontroller code.
flush(arduinoObj);                       % Flush the serialport object to remove any old data.
arduinoObj.UserData = struct("Data",[],"Count",1); %Prepare the UserData property to store the microcontroller data. The Data field of the struct saves the sine wave value and the Count field saves the x-axis value of the sine wave.

% The callback function opens the MATLAB figure window with a plot of the first 1000 points.
configureCallback(arduinoObj,"terminator",@readArduinoData); % Set the BytesAvailableFcnMode property to "terminator" and the BytesAvailableFcn property to @readArduinoData. The callback function readArduinoData is triggered when a new data (with the terminator) is available to be read from the microcontroller.

%% Store data

fsr = arduinoObj.UserData.Data(2:2:end); 
straingauge = arduinoObj.UserData.Data(3:2:end);

%% Load data 

load('fsr_2.mat')
FSR = fsr; 
load('fsr_3.mat')
FSR = [FSR'; fsr']; 

load('mass_2.mat')
mass = straingauge; 
load('mass_3.mat')
mass = [mass'; straingauge']; 
clear fsr; clear straingauge; 

fsr = FSR; 
straingauge = mass; 

clear FSR; clear mass; 

%% data process
Fs = 320;            % Sampling frequency                    
T = 1/Fs;            % Sampling period  
a = 1373.364; 

% mass = ((straingauge)/4095)*3.3*a; 
% mass = mass - 1070;
clear a; 

voltage = (fsr/4095)*3.3; 

window = 0.5/T; 
mask = ones(1,window); 
mask2 = linspace(0,100,window); 
mask3 = linspace(100,0, window); 

movingIntegrel_same = conv(fsr, mask, 'same'); 
movingIntegrel_same2 = conv(fsr, mask2, 'same'); 

movingIntegrel_1 = conv(fsr, mask); 
movingIntegrel_2 = conv(fsr, mask2); 
movingIntegrel_3 = conv(fsr, mask3); 

movingIntegrel_3cliped = movingIntegrel_3(1:length(fsr)); 





% 
%  
% 
% clip = 160; 
% massCliped = mass(clip:end-clip); 
% voltageCliped = voltage(clip:end-clip); 
% movingIntegrelCliped = movingIntegrel(clip:end-clip); 
% movingIntegrel2Cliped = movingIntegrel2(clip:end-clip); 
% clear clip; 


%scatter(voltage,mass)
plot(voltage,mass,'k.');


%scatter3(voltageCliped,massCliped,movingIntegrelCliped)
%patch(voltageCliped,massCliped,movingIntegrelCliped, 'm') % doent work7
%mesh(voltageCliped,massCliped,movingIntegrelCliped)
xlabel('FSR voltage (v)');
ylabel('Weight (g)');
grid('on'); 
ylim([0 2500]); 
%zlabel('Intergrel (I)');

massCliped = mass(400:1400); 
voltageCliped = voltage(400:1400); 
movingIntegrelCliped = movingIntegrel(400:1400); 
movingIntegrel2Cliped = movingIntegrel2(400:1400); 

%cftool
% a + a1*x + a2*x^2 + a3*x^3 + a4*(x^4) + a5*(y) + a6*(y^2) + a7*(y^3) + a8*(y^4)


%% calibrated kode

x = voltage; 
y = movingIntegrel2; 
tid =linspace(0,length(voltage)/320,length(voltage));


for i = 1:length(voltage)
    i
    %Linear model Poly13:
    %Coefficients (with 95% confidence bounds):
       p00 =       31.64  ;%(30.59, 32.69)
       p10 =       270.4  ;%(259.9, 280.9)
       p01 =    4.92e-06  ;%(3.736e-06, 6.104e-06)
       p11 =  -4.778e-05  ;%(-4.95e-05, -4.606e-05)
       p02 =   1.874e-12  ;%(1.695e-12, 2.052e-12)
       p12 =    2.81e-12  ;%(2.744e-12, 2.876e-12)
       p03 =  -1.893e-19  ;%(-1.96e-19, -1.826e-19)
    Poly13(i) = p00 + p10*x(i) + p01*y(i) + p11*x(i)*y(i) + p02*y(i)^2 + p12*x(i)*y(i)^2 + p03*y(i)^3;


    %Linear model Poly14:
    %Coefficients (with 95% confidence bounds):
               p00 =       32.92;%(31.98, 33.86)
       p10 =      -198.5;%(-215.4, -181.6)
       p01 =   2.497e-05;%(2.324e-05, 2.671e-05)
       p11 =   8.591e-05;%(8.147e-05, 9.034e-05)
       p02 =   -6.42e-12;%(-6.854e-12, -5.987e-12)
       p12 =  -8.259e-12;%(-8.616e-12, -7.902e-12)
       p03 =    6.28e-19;%(5.931e-19, 6.629e-19)
       p13 =   2.739e-19;%(2.651e-19, 2.827e-19)
       p04 =  -2.227e-26;%(-2.314e-26, -2.141e-26)

    Poly14(i) = p00 + p10*x(i) + p01*y(i) + p11*x(i)*y(i) + p02*y(i)^2 + p12*x(i)*y(i)^2 + p03*y(i)^3 + p13*x(i)*y(i)^3 + p04*y(i)^4;

    %Linear model Poly15:
    %Coefficients (with 95% confidence bounds):
           p00 =       32.34;%(31.42, 33.27)
           p10 =         140;%(111.8, 168.2)
           p01 =   1.679e-05;%(1.428e-05, 1.93e-05)
           p11 =  -4.527e-05;%(-5.578e-05, -3.476e-05)
           p02 =  -8.205e-13;%(-1.772e-12, 1.306e-13)
           p12 =   8.732e-12;%(7.378e-12, 1.008e-11)
           p03 =  -3.362e-19;%(-4.625e-19, -2.099e-19)
           p13 =  -6.135e-19;%(-6.847e-19, -5.423e-19)
           p04 =   3.717e-26;%(3.038e-26, 4.396e-26)
           p14 =     1.6e-26;%(1.47e-26, 1.73e-26)
           p05 =   -1.19e-33;%(-1.316e-33, -1.064e-33)

     Poly15(i) = p00 + p10*x(i) + p01*y(i) + p11*x(i)*y(i) + p02*y(i)^2 + p12*x(i)*y(i)^2 + p03*y(i)^3 + p13*x(i)*y(i)^3 + p04*y(i)^4 + p14*x(i)*y(i)^4 + p05*y(i)^5;

    %Linear model Poly21:
    %Coefficients (with 95% confidence bounds):
           p00 =        42.1;%(40.89, 43.3)
       p10 =      -167.6;%(-172.1, -163)
       p01 =   5.694e-06;%(5.301e-06, 6.087e-06)
       p20 =       157.8;%(155, 160.6)
       p11 =  -4.587e-06;%(-4.849e-06, -4.324e-06)

    Poly21(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i);


    %Linear model Poly22:
    %Coefficients (with 95% confidence bounds):
            p00 =        42.4;%(41.18, 43.61)
       p10 =      -158.2;%(-164.4, -152)
       p01 =   4.389e-06;%(3.685e-06, 5.093e-06)
       p20 =         162;%(158.6, 165.3)
       p11 =  -6.239e-06;%(-7.023e-06, -5.454e-06)
       p02 =   1.389e-13;%(7.674e-14, 2.011e-13)
    Poly22(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2;


    %Linear model Poly23:
    %Coefficients (with 95% confidence bounds):
              p00 =       32.66;%(31.94, 33.39)
       p10 =      -162.3;%(-175.6, -149)
       p01 =   2.282e-05;%(2.137e-05, 2.426e-05)
       p20 =       205.7;%(185.5, 225.9)
       p11 =   2.902e-05;%(2.39e-05, 3.413e-05)
       p02 =  -3.737e-12;%(-4.182e-12, -3.291e-12)
       p21 =  -4.144e-05;%(-4.463e-05, -3.824e-05)
       p12 =   1.828e-12;%(1.131e-12, 2.524e-12)
       p03 =   9.527e-20;%(4.894e-20, 1.416e-19)
       p22 =   2.491e-12;%(2.366e-12, 2.616e-12)
       p13 =  -2.819e-19;%(-3.083e-19, -2.555e-19)
       p04 =   7.355e-27;%(5.815e-27, 8.894e-27)

    Poly23(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p21*x(i)^2*y(i) + p12*x(i)*y(i)^2 + p03*y(i)^3;

    %Linear model Poly24:
    %Coefficients (with 95% confidence bounds):
            p00 =       32.66;%(31.94, 33.39)
       p10 =      -162.3;%(-175.6, -149)
       p01 =   2.282e-05;%(2.137e-05, 2.426e-05)
       p20 =       205.7;%(185.5, 225.9)
       p11 =   2.902e-05;%(2.39e-05, 3.413e-05)
       p02 =  -3.737e-12;%(-4.182e-12, -3.291e-12)
       p21 =  -4.144e-05;%(-4.463e-05, -3.824e-05)
       p12 =   1.828e-12;%(1.131e-12, 2.524e-12)
       p03 =   9.527e-20;%(4.894e-20, 1.416e-19)
       p22 =   2.491e-12;%(2.366e-12, 2.616e-12)
       p13 =  -2.819e-19;%(-3.083e-19, -2.555e-19)
       p04 =   7.355e-27;%(5.815e-27, 8.894e-27)

    Poly24(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p21*x(i)^2*y(i) + p12*x(i)*y(i)^2 + p03*y(i)^3 + p22*x(i)^2*y(i)^2 + p13*x(i)*y(i)^3 + p04*y(i)^4;


    %Linear model Poly25:
    %Coefficients (with 95% confidence bounds):
            p00 =       32.19;%(31.51, 32.86)
       p10 =       281.8;%(260.8, 302.8)
       p01 =   2.109e-05;%(1.903e-05, 2.314e-05)
       p20 =      -448.5;%(-491.6, -405.5)
       p11 =  -1.219e-05;%(-2.332e-05, -1.067e-06)
       p02 =  -4.946e-12;%(-5.898e-12, -3.995e-12)
       p21 =   0.0001226;%(0.0001123, 0.000133)
       p12 =  -8.772e-12;%(-1.105e-11, -6.497e-12)
       p03 =     6.3e-19;%(4.754e-19, 7.845e-19)
       p22 =  -1.004e-11;%(-1.085e-11, -9.227e-12)
       p13 =   1.071e-18;%(9e-19, 1.242e-18)
       p04 =  -4.579e-26;%(-5.604e-26, -3.554e-26)
       p23 =   2.973e-19;%(2.769e-19, 3.178e-19)
       p14 =   -3.89e-26;%(-4.315e-26, -3.466e-26)
       p05 =   1.507e-33;%(1.269e-33, 1.745e-33)

    Poly25(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p21*x(i)^2*y(i) + p12*x(i)*y(i)^2 + p03*y(i)^3 + p22*x(i)^2*y(i)^2 + p13*x(i)*y(i)^3 + p04*y(i)^4 + p23*x(i)^2*y(i)^3 + p14*x(i)*y(i)^4 + p05*y(i)^5;

    %Linear model Poly31:
    %Coefficients (with 95% confidence bounds):
           p00 =       34.93;%(34.21, 35.66)
       p10 =       290.2;%(284.8, 295.7)
       p01 =   2.958e-06;%(2.696e-06, 3.22e-06)
       p20 =      -282.6;%(-289.2, -276)
       p11 =  -4.634e-06;%(-5.196e-06, -4.072e-06)
       p30 =       108.2;%(105.8, 110.5)
       p21 =  -1.701e-07;%(-3.995e-07, 5.935e-08)
    Poly31(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p30*x(i)^3 + p21*x(i)^2*y(i);


    %Linear model Poly32:
    %Coefficients (with 95% confidence bounds):
            p00 =       33.53;%(32.79, 34.26)
       p10 =       272.5;%(265.6, 279.4)
       p01 =   7.226e-06;%(6.545e-06, 7.907e-06)
       p20 =      -297.2;%(-303.8, -290.6)
       p11 =  -6.836e-07;%(-1.442e-06, 7.516e-08)
       p02 =  -4.245e-13;%(-4.91e-13, -3.581e-13)
       p30 =       102.1;%(99.23, 105)
       p21 =   1.435e-06;%(8.402e-07, 2.031e-06)
       p12 =  -7.107e-14;%(-1.118e-13, -3.028e-14)

    Poly32(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i) + p12*x(i)*y(i)^2;

    %Linear model Poly33:
    %Coefficients (with 95% confidence bounds):
           p00 =       33.73;%(32.99, 34.46)
       p10 =       284.8;%(277.1, 292.5)
       p01 =   5.326e-06;%(4.457e-06, 6.194e-06)
       p20 =        -283;%(-290.7, -275.2)
       p11 =  -6.814e-06;%(-8.715e-06, -4.914e-06)
       p02 =   1.187e-13;%(-4.938e-14, 2.867e-13)
       p30 =       107.9;%(104.6, 111.3)
       p21 =  -1.506e-06;%(-2.532e-06, -4.801e-07)
       p12 =   4.773e-13;%(3.162e-13, 6.384e-13)
       p03 =  -3.312e-20;%(-4.254e-20, -2.371e-20)
    Poly33(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i) + p12*x(i)*y(i)^2 + p03*y(i)^3;

    %Linear model Poly34:
    %Coefficients (with 95% confidence bounds):
           p00 =       33.09;%(32.42, 33.76)
       p10 =      -114.5;%(-128.2, -100.8)
       p01 =   2.053e-05;%(1.917e-05, 2.19e-05)
       p20 =         154;%(133.7, 174.4)
       p11 =   3.772e-05;%(3.282e-05, 4.262e-05)
       p02 =  -4.565e-12;%(-5.006e-12, -4.123e-12)
       p30 =        -116;%(-129, -102.9)
       p21 =    1.94e-06;%(-2.375e-06, 6.255e-06)
       p12 =  -4.527e-12;%(-5.329e-12, -3.726e-12)
       p03 =   4.405e-19;%(3.894e-19, 4.916e-19)
       p31 =   1.501e-05;%(1.402e-05, 1.6e-05)
       p22 =  -2.294e-12;%(-2.596e-12, -1.993e-12)
       p13 =   2.726e-19;%(2.326e-19, 3.126e-19)
       p04 =  -1.576e-26;%(-1.772e-26, -1.379e-26)
    Poly34(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i) + p12*x(i)*y(i)^2 + p03*y(i)^3 + p31*x(i)^3*y(i) + p22*x(i)^2*y(i)^2 + p13*x(i)*y(i)^3 + p04*y(i)^4;

    %Linear model Poly35:
    %Coefficients (with 95% confidence bounds):
           p00 =       31.92;%(31.29, 32.56)
       p10 =       252.9;%(229.6, 276.1)
       p01 =   2.491e-05;%(2.288e-05, 2.694e-05)
       p20 =      -416.7;%(-460.7, -372.7)
       p11 =  -4.732e-07;%(-1.159e-05, 1.065e-05)
       p02 =  -6.473e-12;%(-7.465e-12, -5.481e-12)
       p30 =       109.6;%(71.42, 147.7)
       p21 =   6.921e-05;%(5.578e-05, 8.263e-05)
       p12 =  -5.124e-12;%(-7.798e-12, -2.451e-12)
       p03 =   6.802e-19;%(5.022e-19, 8.581e-19)
       p31 =  -1.662e-05;%(-2.26e-05, -1.065e-05)
       p22 =  -2.583e-12;%(-4.438e-12, -7.274e-13)
       p13 =    2.89e-19;%(2.689e-20, 5.511e-19)
       p04 =  -2.475e-26;%(-3.84e-26, -1.11e-26)
       p32 =   1.029e-12;%(7.96e-13, 1.262e-12)
       p23 =  -8.924e-20;%(-1.61e-19, -1.752e-20)
       p14 =   4.072e-27;%(-4.566e-27, 1.271e-26)
       p05 =   3.123e-35;%(-3.486e-34, 4.111e-34)

    Poly35(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i) + p12*x(i)*y(i)^2 + p03*y(i)^3 + p31*x(i)^3*y(i) + p22*x(i)^2*y(i)^2 + p13*x(i)*y(i)^3 + p04*y(i)^4 + p32*x(i)^3*y(i)^2 + p23*x(i)^2*y(i)^3 + p14*x(i)*y(i)^4 +p05*y(i)^5;


    %Linear model Poly41:
    %Coefficients (with 95% confidence bounds):
           p00 =       35.43;%(34.78, 36.09)
       p10 =       8.779;%(-1.783, 19.34)
       p01 =     4.6e-06;%(4.352e-06, 4.848e-06)
       p20 =       285.2;%(267.6, 302.7)
       p11 =  -1.305e-05;%(-1.43e-05, -1.181e-05)
       p30 =      -258.3;%(-271, -245.5)
       p21 =   9.774e-06;%(8.553e-06, 1.1e-05)
       p40 =       74.76;%(71.72, 77.81)
       p31 =  -2.883e-06;%(-3.193e-06, -2.573e-06)

    Poly41(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p30*x(i)^3 + p21*x(i)^2*y(i) + p40*x(i)^4 + p31*x(i)^3*y(i);



    %Linear model Poly42:
    %Coefficients (with 95% confidence bounds):
            p00 =       33.99;%(33.34, 34.65)
       p10 =      -50.92;%(-62.23, -39.61)
       p01 =   1.032e-05;%(9.642e-06, 1.101e-05)
       p20 =         321;%(302.3, 339.7)
       p11 =  -9.797e-06;%(-1.127e-05, -8.326e-06)
       p02 =  -6.369e-13;%(-7.058e-13, -5.68e-13)
       p30 =      -204.2;%(-217.1, -191.4)
       p21 =  -7.375e-06;%(-9.191e-06, -5.56e-06)
       p12 =   1.165e-12;%(1.035e-12, 1.295e-12)
       p40 =        39.7;%(35.97, 43.44)
       p31 =   5.984e-06;%(5.226e-06, 6.741e-06)
       p22 =  -5.388e-13;%(-5.895e-13, -4.882e-13)
    Poly42(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i) + p12*x(i)*y(i)^2 + p40*x(i)^4 + p31*x(i)^3*y(i) + p22*x(i)^2*y(i)^2;


    %Linear model Poly43:
    %Coefficients (with 95% confidence bounds):
          p00 =       33.02;%(32.36, 33.68)
       p10 =      -106.3;%(-119, -93.59)
       p01 =   1.879e-05;%(1.761e-05, 1.998e-05)
       p20 =       275.4;%(256.5, 294.3)
       p11 =   1.481e-05;%(1.187e-05, 1.775e-05)
       p02 =  -3.051e-12;%(-3.327e-12, -2.776e-12)
       p30 =      -182.9;%(-195.7, -170.1)
       p21 =  -1.237e-05;%(-1.425e-05, -1.049e-05)
       p12 =   1.793e-13;%(-1.389e-14, 3.726e-13)
       p03 =   1.482e-19;%(1.323e-19, 1.641e-19)
       p40 =        69.4;%(65.08, 73.72)
       p31 =  -7.544e-06;%(-8.822e-06, -6.266e-06)
       p22 =   1.672e-12;%(1.494e-12, 1.85e-12)
       p13 =  -1.192e-19;%(-1.285e-19, -1.099e-19)
    Poly43(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i)  + p12*x(i)*y(i)^2 + p03*y(i)^3 + p40*x(i)^4 + p31*x(i)^3*y(i) + p22*x(i)^2*y(i)^2 + p13*x(i)*y(i)^3;



    %Linear model Poly44:
    %Coefficients (with 95% confidence bounds):
    
    p00 =       32.92;%(32.26, 33.58)
       p10 =      -121.8;%(-135.3, -108.4)
       p01 =   2.094e-05;%(1.96e-05, 2.228e-05)
       p20 =       244.1;%(223.2, 265.1)
       p11 =    2.82e-05;%(2.335e-05, 3.305e-05)
       p02 =  -4.215e-12;%(-4.649e-12, -3.782e-12)
       p30 =      -204.1;%(-218.2, -189.9)
       p21 =   7.903e-07;%(-3.44e-06, 5.02e-06)
       p12 =  -2.512e-12;%(-3.311e-12, -1.713e-12)
       p03 =   3.158e-19;%(2.65e-19, 3.667e-19)
       p40 =       64.64;%(60.12, 69.17)
       p31 =  -3.946e-06;%(-5.59e-06, -2.302e-06)
       p22 =   5.915e-13;%(2.334e-13, 9.497e-13)
       p13 =   2.608e-20;%(-1.678e-20, 6.893e-20)
       p04 =  -7.024e-27;%(-9.047e-27, -5.002e-27)


    Poly44(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i) + p12*x(i)*y(i)^2 + p03*y(i)^3 + p40*x(i)^4 + p31*x(i)^3*y(i) + p22*x(i)^2*y(i)^2 + p13*x(i)*y(i)^3 + p04*y(i)^4;


    %Linear model Poly45:
    %Coefficients ;%(with 95% confidence bounds):
          p00 =       31.99;%(31.36, 32.62)
       p10 =       222.4;%(198.8, 246.1)
       p01 =   2.462e-05;%(2.261e-05, 2.663e-05)
       p20 =      -366.6;%(-417.2, -316)
       p11 =   5.318e-06;%(-5.837e-06, 1.647e-05)
       p02 =  -6.763e-12;%(-7.748e-12, -5.778e-12)
       p30 =       56.83;%(9.004, 104.7)
       p21 =   8.565e-05;%(7.225e-05, 9.906e-05)
       p12 =  -9.043e-12;%(-1.177e-11, -6.319e-12)
       p03 =    9.04e-19;%(7.232e-19, 1.085e-18)
       p40 =      -53.32;%(-74.91, -31.72)
       p31 =   1.155e-05;%(3.567e-06, 1.953e-05)
       p22 =  -9.201e-12;%(-1.134e-11, -7.062e-12)
       p13 =   1.095e-18;%(8.051e-19, 1.385e-18)
       p04 =  -6.044e-26;%(-7.511e-26, -4.578e-26)
       p41 =    7.19e-06;%(5.579e-06, 8.801e-06)
       p32 =   -2.01e-12;%(-2.601e-12, -1.419e-12)
       p23 =   4.457e-19;%(3.346e-19, 5.568e-19)
       p14 =  -4.249e-26;%(-5.355e-26, -3.143e-26)
       p05 =   1.644e-33;%(1.2e-33, 2.089e-33)
    Poly45(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i)  + p12*x(i)*y(i)^2 + p03*y(i)^3 + p40*x(i)^4 + p31*x(i)^3*y(i) + p22*x(i)^2*y(i)^2 + p13*x(i)*y(i)^3 + p04*y(i)^4 + p41*x(i)^4*y(i) + p32*x(i)^3*y(i)^2 + p23*x(i)^2*y(i)^3 + p14*x(i)*y(i)^4 + p05*y(i)^5;


    %Linear model Poly51:
    %Coefficients ;%(with 95% confidence bounds):
           p00 =       34.94;%(34.31, 35.57)
       p10 =       341.7;%(322, 361.3)
       p01 =   4.209e-06;%(3.965e-06, 4.453e-06)
       p20 =      -522.6;%(-566, -479.3)
       p11 =  -2.264e-05;%(-2.501e-05, -2.026e-05)
       p30 =       428.3;%(382.7, 474)
       p21 =   2.543e-05;%(2.134e-05, 2.951e-05)
       p40 =      -174.3;%(-197.1, -151.4)
       p31 =  -1.042e-05;%(-1.275e-05, -8.096e-06)
       p50 =       32.97;%(28.9, 37.04)
       p41 =   1.121e-06;%(6.948e-07, 1.546e-06)
    Poly51(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p30*x(i)^3 + p21*x(i)^2*y(i) + p40*x(i)^4 + p31*x(i)^3*y(i) + p50*x(i)^5 + p41*x(i)^4*y(i);


    %Linear model Poly52:
    %Coefficients ;%(with 95% confidence bounds):
           p00 =       33.25;%(32.62, 33.87)
       p10 =       318.2;%(298.4, 338)
       p01 =   1.061e-05;%(9.932e-06, 1.129e-05)
       p20 =      -378.6;%(-425.3, -331.8)
       p11 =  -4.336e-05;%(-4.7e-05, -3.971e-05)
       p02 =  -6.903e-13;%(-7.6e-13, -6.206e-13)
       p30 =       309.8;%(263.4, 356.3)
       p21 =   2.544e-05;%(2.107e-05, 2.981e-05)
       p12 =   2.513e-12;%(2.212e-12, 2.814e-12)
       p40 =      -128.5;%(-152, -105)
       p31 =  -3.807e-06;%(-7.565e-06, -4.818e-08)
       p22 =  -1.648e-12;%(-1.93e-12, -1.366e-12)
       p50 =       19.77;%(14.81, 24.73)
       p41 =   9.635e-07;%(-4.884e-08, 1.976e-06)
       p32 =   2.203e-13;%(1.506e-13, 2.899e-13)

     Poly52(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i) + p12*x(i)*y(i)^2 + p40*x(i)^4 + p31*x(i)^3*y(i) + p22*x(i)^2*y(i)^2 + p50*x(i)^5 + p41*x(i)^4*y(i) + p32*x(i)^3*y(i)^2;


    %Linear model Poly53:
    %Coefficients ;%(with 95% confidence bounds):
             p00 =       32.39;%(31.77, 33.02)
       p10 =       270.9;%(250.3, 291.4)
       p01 =   1.725e-05;%(1.602e-05, 1.847e-05)
       p20 =      -312.1;%(-358.5, -265.7)
       p11 =  -3.657e-05;%(-4.1e-05, -3.214e-05)
       p02 =  -2.423e-12;%(-2.716e-12, -2.129e-12)
       p30 =         220;%(173.1, 266.9)
       p21 =   3.046e-05;%(2.423e-05, 3.669e-05)
       p12 =   2.249e-12;%(1.774e-12, 2.724e-12)
       p03 =   9.997e-20;%(8.269e-20, 1.173e-19)
       p40 =        -118;%(-141.1, -94.9)
       p31 =   1.247e-06;%(-2.728e-06, 5.222e-06)
       p22 =   -2.26e-12;%(-2.758e-12, -1.763e-12)
       p13 =  -1.202e-20;%(-4.486e-20, 2.082e-20)
       p50 =       45.08;%(39.3, 50.86)
       p41 =  -9.685e-06;%(-1.146e-05, -7.912e-06)
       p32 =   1.542e-12;%(1.295e-12, 1.789e-12)
       p23 =  -4.956e-20;%(-6.235e-20, -3.676e-20)
    Poly53(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i)  + p12*x(i)*y(i)^2 + p03*y(i)^3 + p40*x(i)^4 + p31*x(i)^3*y(i) + p22*x(i)^2*y(i)^2 + p13*x(i)*y(i)^3 + p50*x(i)^5 + p41*x(i)^4*y(i) + p32*x(i)^3*y(i)^2 + p23*x(i)^2*y(i)^3;

    %Linear model Poly54:
    %Coefficients ;%(with 95% confidence bounds):
           p00 =       31.99;%(31.36, 32.62)
       p10 =       227.8;%(204.9, 250.7)
       p01 =    2.37e-05;%(2.182e-05, 2.558e-05)
       p20 =      -375.3;%(-423.6, -327)
       p11 =  -4.154e-06;%(-1.296e-05, 4.654e-06)
       p02 =  -5.628e-12;%(-6.409e-12, -4.847e-12)
       p30 =       203.4;%(156.4, 250.4)
       p21 =   4.875e-05;%(4.126e-05, 5.623e-05)
       p12 =  -3.253e-12;%(-4.626e-12, -1.879e-12)
       p03 =   5.373e-19;%(4.351e-19, 6.394e-19)
       p40 =      -118.7;%(-142.3, -95.08)
       p31 =   8.159e-07;%(-3.828e-06, 5.46e-06)
       p22 =  -2.722e-12;%(-3.308e-12, -2.135e-12)
       p13 =   1.961e-19;%(1.436e-19, 2.486e-19)
       p04 =  -1.763e-26;%(-2.176e-26, -1.35e-26)
       p50 =       47.19;%(40.78, 53.61)
       p41 =  -1.126e-05;%(-1.376e-05, -8.749e-06)
       p32 =   2.099e-12;%(1.585e-12, 2.612e-12)
       p23 =  -1.385e-19;%(-1.931e-19, -8.393e-20)
       p14 =   4.935e-27;%(2.603e-27, 7.266e-27)
    Poly54(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i)  + p12*x(i)*y(i)^2 + p03*y(i)^3 + p40*x(i)^4 + p31*x(i)^3*y(i) + p22*x(i)^2*y(i)^2 + p13*x(i)*y(i)^3 + p04*y(i)^4 + p50*x(i)^5 + p41*x(i)^4*y(i) + p32*x(i)^3*y(i)^2 + p23*x(i)^2*y(i)^3 + p14*x(i)*y(i)^4;


    %Linear model Poly55:
    %Coefficients ;%(with 95% confidence bounds):
             p00 =       31.96;%(31.33, 32.58)
       p10 =       216.8;%(193.2, 240.3)
       p01 =   2.509e-05;%(2.309e-05, 2.709e-05)
       p20 =      -406.2;%(-456.9, -355.4)
       p11 =   9.428e-06;%(-1.696e-06, 2.055e-05)
       p02 =  -6.814e-12;%(-7.795e-12, -5.833e-12)
       p30 =       166.9;%(116.5, 217.3)
       p21 =   7.124e-05;%(5.772e-05, 8.476e-05)
       p12 =  -7.938e-12;%(-1.065e-11, -5.22e-12)
       p03 =   8.341e-19;%(6.538e-19, 1.014e-18)
       p40 =      -132.4;%(-157, -107.8)
       p31 =   1.371e-05;%(5.762e-06, 2.166e-05)
       p22 =  -6.872e-12;%(-9.03e-12, -4.714e-12)
       p13 =   7.713e-19;%(4.787e-19, 1.064e-18)
       p04 =  -4.595e-26;%(-6.072e-26, -3.119e-26)
       p50 =          44;%(37.39, 50.61)
       p41 =  -8.529e-06;%(-1.138e-05, -5.674e-06)
       p32 =   1.023e-12;%(2.787e-13, 1.767e-12)
       p23 =   8.256e-20;%(-4.08e-20, 2.059e-19)
       p14 =  -1.781e-26;%(-2.943e-26, -6.19e-27)
       p05 =    9.11e-34;%(4.551e-34, 1.367e-33)
    Poly55(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i) + p12*x(i)*y(i)^2 + p03*y(i)^3 + p40*x(i)^4 + p31*x(i)^3*y(i) + p22*x(i)^2*y(i)^2 + p13*x(i)*y(i)^3 + p04*y(i)^4 + p50*x(i)^5 + p41*x(i)^4*y(i) + p32*x(i)^3*y(i)^2 + p23*x(i)^2*y(i)^3 + p14*x(i)*y(i)^4 + p05*y(i)^5;
    
    %General model Exp1:     
    exponentielt_fit(i) = 1.478*exp(2.321*x(i));
    
    %General model Exp2:
    exponentielt2_fit(i) = 25.68*exp(1.127*x(i)) + 0.003885*exp(4.058*x(i));
    
    
    Poly13_error(i) = abs(Poly13(i)- mass(i)); 
    Poly14_error(i) = abs(Poly14(i)- mass(i));
    Poly15_error(i) = abs(Poly15(i)- mass(i));
    Poly21_error(i) = abs(Poly21(i)- mass(i));
    Poly22_error(i) = abs(Poly22(i)- mass(i));
    Poly23_error(i) = abs(Poly23(i)- mass(i));
    Poly24_error(i) = abs(Poly24(i)- mass(i));
    Poly25_error(i) = abs(Poly25(i)- mass(i));
    Poly31_error(i) = abs(Poly31(i)- mass(i));
    Poly32_error(i) = abs(Poly32(i)- mass(i));
    Poly33_error(i) = abs(Poly33(i)- mass(i));
    Poly34_error(i) = abs(Poly34(i)- mass(i));
    Poly35_error(i) = abs(Poly35(i)- mass(i));
    Poly41_error(i) = abs(Poly41(i)- mass(i));
    Poly42_error(i) = abs(Poly42(i)- mass(i));
    Poly43_error(i) = abs(Poly43(i)- mass(i));
    Poly44_error(i) = abs(Poly44(i)- mass(i));
    Poly45_error(i) = abs(Poly45(i)- mass(i));
    Poly51_error(i) = abs(Poly51(i)- mass(i));
    Poly52_error(i) = abs(Poly52(i)- mass(i));
    Poly53_error(i) = abs(Poly53(i)- mass(i));
    Poly54_error(i) = abs(Poly54(i)- mass(i));
    Poly55_error(i) = abs(Poly55(i)- mass(i));
    exponentielt_fit_error(i) = abs(exponentielt_fit(i)- mass(i));
    exponentielt2_fit_error(i)= abs(exponentielt2_fit(i)- mass(i));
      
end

%% plot (standard)
%plot(tid, mass, tid, Poly13, tid,Poly14, tid,Poly15, tid,Poly21, tid,Poly22, tid,Poly23, tid,Poly24, tid,Poly25, tid,Poly31, tid,Poly32, tid,Poly33, tid,Poly34, tid,Poly35, tid,Poly41, tid,Poly42, tid,Poly43, tid,Poly44, tid,Poly45, tid,Poly51, tid,Poly52, tid,Poly53, tid,Poly54, tid,Poly55)
% legend('mass');
% ylim([0 3000]);
% ylabel('weight');

plot(tid, mass, tid,Poly45, tid,exponentielt_fit)
legend('strain gauge','45poly fit', 'exponentielt_fit');
ylabel('weight (g)');


%% plot (fancy)
plot(Poly45, mass);
grid('on')
ylabel('weight ( g )'); 
xlabel('Poly 45 ( g )'); 
xlim([0 1250]);
ylim([0 1250]);



%% Error plot
%plot(tid, Poly13_error, tid,Poly14_error, tid,Poly15_error, tid,Poly21_error, tid,Poly22_error, tid,Poly23_error, tid,Poly24_error, tid,Poly25_error, tid,Poly31_error, tid,Poly32_error, tid,Poly33_error, tid,Poly34_error, tid,Poly35_error, tid,Poly41_error, tid,Poly42_error, tid,Poly43_error, tid,Poly44_error, tid,Poly45_error, tid,Poly51_error, tid,Poly52_error, tid,Poly53_error, tid,Poly54_error, tid,Poly55_error)
ylim([0 200]);

%plot(tid, exponentielt2_fit_error)
plot(tid, Poly44_error)


%% Bar chart
X = categorical({'Poly13','Poly14','Poly15','Poly21','Poly22', 'Poly23', 'Poly24','Poly25', 'Poly31', 'Poly32', 'Poly33', 'Poly34', 'Poly35', 'Poly41', 'Poly42', 'Poly43', 'Poly44', 'Poly45','Poly51', 'Poly52', 'Poly53', 'Poly54', 'Poly55','Exp','Two-Term Exp'});
Y = [mean(Poly13_error) mean(Poly14_error) mean(Poly15_error) mean(Poly21_error) mean(Poly22_error) mean(Poly23_error) mean(Poly24_error) mean(Poly25_error) mean(Poly31_error) mean(Poly32_error) mean(Poly33_error) mean(Poly34_error) mean(Poly35_error) mean(Poly41_error) mean(Poly42_error)  mean(Poly43_error) mean(Poly44_error) mean(Poly45_error) mean(Poly51_error) mean(Poly52_error) mean(Poly53_error) mean(Poly54_error) mean(Poly55_error), mean(exponentielt_fit_error), mean(exponentielt2_fit_error)];
bar(X,Y)
grid('on')
labels1 = string(fix(Y));
text(X,Y,labels1,'VerticalAlignment','bottom','HorizontalAlignment','center')



%% 
