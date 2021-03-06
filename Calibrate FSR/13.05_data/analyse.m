%% proper clear
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

%% Load signal (Calibrated)
clc;  
clear;
load('straingauge4_60.mat');
load('fsr4_60.mat');
 

%% Load signal (Test against) 
clc;
clear; 
load('fsr_20.mat'); 
load('straingauge_20.mat'); 

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
%% Plot data
cftool

%% Test various poly regression
x = voltage; 
y = movingIntegrel_3voltcliped;
tid =linspace(0,20,length(voltage));


for i = 1:length(voltage)
    i
    %Linear model Poly31:
    %Coefficients (with 95% confidence bounds):
       p00 =     -0.1916;%(-0.2404, -0.1427)
       p10 =       7.075;%(6.855, 7.295)
       p01 =  -1.116e-05;%(-3.722e-05, 1.49e-05)
       p20 =      -7.561;%(-7.844, -7.278)
       p11 =   3.838e-05;%(-1.005e-05, 8.681e-05)
       p30 =       2.462;%(2.367, 2.556)
       p21 =   -6.16e-05;%(-7.942e-05, -4.377e-05)
      Poly31(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p30*x(i)^3 + p21*x(i)^2*y(i);

       
       %Linear model Poly32:
       %Coefficients (with 95% confidence bounds):
       p00 =     -0.2323;%(-0.2814, -0.1832)
       p10 =       7.017;%(6.74, 7.293)
       p01 =   0.0001172;%(6.402e-05, 0.0001703)
       p20 =      -7.633;%(-7.922, -7.343)
       p11 =   5.744e-05;%(8.194e-06, 0.0001067)
       p02 =  -1.639e-08;%(-2.331e-08, -9.476e-09)
       p30 =        2.19;%(2.09, 2.29)
       p21 =   6.987e-05;%(3.779e-05, 0.0001019)
       p12 =  -1.284e-08;%(-1.701e-08, -8.665e-09)
       Poly32(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i) + p12*x(i)*y(i)^2;

    
    %Linear model Poly33:
    %Coefficients ;%(with 95% confidence bounds):
       p00 =     -0.2312;%(-0.2803, -0.1821)
       p10 =         6.8;%(6.508, 7.092)
       p01 =   0.0001843;%(0.0001235, 0.0002451)
       p20 =      -7.696;%(-7.987, -7.406)
       p11 =   0.0002022;%(0.0001216, 0.0002828)
       p02 =  -4.668e-08;%(-6.171e-08, -3.165e-08)
       p30 =       2.135;%(2.032, 2.238)
       p21 =   0.0001073;%(7.127e-05, 0.0001434)
       p12 =  -3.015e-08;%(-3.885e-08, -2.146e-08)
       p03 =   2.555e-12;%(1.429e-12, 3.681e-12)
       Poly33(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i) + p12*x(i)*y(i)^2 + p03*y(i)^3;

    %Linear model Poly34:
    %Coefficients ;%(with 95% confidence bounds):   
      p00 =      0.0256;%(-0.02232, 0.07352)
       p10 =      -1.377;%(-1.877, -0.8771)
       p01 =   0.0002003;%(0.0001021, 0.0002984)
       p20 =       3.198;%(2.505, 3.891)
       p11 =   0.0004332;%(0.0002663, 0.0006001)
       p02 =  -7.891e-08;%(-1.18e-07, -3.987e-08)
       p30 =     -0.9718;%(-1.292, -0.6512)
       p21 =  -0.0008145;%(-0.0009325, -0.0006966)
       p12 =   5.404e-08;%(1.27e-08, 9.538e-08)
       p03 =   7.557e-12;%(1.214e-12, 1.39e-11)
       p31 =   0.0003121;%(0.0002765, 0.0003477)
       p22 =  -2.176e-08;%(-3.528e-08, -8.231e-09)
       p13 =  -1.362e-12;%(-4.435e-12, 1.711e-12)
       p04 =  -2.227e-16;%(-5.674e-16, 1.221e-16)
    Poly34(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i) + p12*x(i)*y(i)^2 + p03*y(i)^3 + p31*x(i)^3*y(i) + p22*x(i)^2*y(i)^2 + p13*x(i)*y(i)^3 + p04*y(i)^4;

    %Linear model Poly41:
    %Coefficients ;%(with 95% confidence bounds):
         p00 =     0.01933;%(-0.02756, 0.06623)
       p10 =     -0.2578;%(-0.6502, 0.1347)
       p01 =   2.877e-05;%(2.632e-06, 5.49e-05)
       p20 =       4.239;%(3.533, 4.945)
       p11 =  -0.0002215;%(-0.0003274, -0.0001155)
       p30 =      -3.975;%(-4.504, -3.446)
       p21 =    0.000259;%(0.0001618, 0.0003562)
       p40 =       1.153;%(1.031, 1.274)
       p31 =  -8.983e-05;%(-0.0001133, -6.64e-05)

    Poly41(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p30*x(i)^3 + p21*x(i)^2*y(i) + p40*x(i)^4 + p31*x(i)^3*y(i);



    %Linear model Poly42:
    %Coefficients ;%(with 95% confidence bounds):   
       p00 =     0.02464;%(-0.02266, 0.07194)
       p10 =      -1.226;%(-1.675, -0.7768)
       p01 =   8.871e-05;%(3.068e-05, 0.0001467)
       p20 =        5.32;%(4.525, 6.115)
       p11 =  -0.0001966;%(-0.0003099, -8.324e-05)
       p02 =  -1.134e-08;%(-1.894e-08, -3.737e-09)
       p30 =      -3.326;%(-3.854, -2.798)
       p21 =  -0.0002263;%(-0.0003403, -0.0001123)
       p12 =   5.541e-08;%(4.197e-08, 6.885e-08)
       p40 =      0.5625;%(0.4322, 0.6928)
       p31 =   0.0002063;%(0.0001647, 0.0002479)
       p22 =  -3.352e-08;%(-3.855e-08, -2.848e-08)

    Poly42(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i) + p12*x(i)*y(i)^2 + p40*x(i)^4 + p31*x(i)^3*y(i) + p22*x(i)^2*y(i)^2;


    %Linear model Poly43:
    %Coefficients ;%(with 95% confidence bounds):
          p00 =     0.01309;%(-0.03467, 0.06084)
       p10 =      -1.614;%(-2.102, -1.125)
       p01 =   0.0002321;%(0.0001376, 0.0003266)
       p20 =       5.243;%(4.445, 6.041)
       p11 =   2.118e-05;%(-0.0001165, 0.0001589)
       p02 =  -6.625e-08;%(-9.38e-08, -3.869e-08)
       p30 =      -3.167;%(-3.696, -2.639)
       p21 =  -0.0004072;%(-0.0005324, -0.0002819)
       p12 =   6.965e-08;%(5.573e-08, 8.357e-08)
       p03 =   4.222e-12;%(2.28e-12, 6.163e-12)
       p40 =      0.6997;%(0.564, 0.8353)
       p31 =   9.722e-05;%(4.567e-05, 0.0001488)
       p22 =   5.294e-09;%(-5.985e-09, 1.657e-08)
       p13 =  -4.639e-12;%(-5.883e-12, -3.395e-12)
    Poly43(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i)  + p12*x(i)*y(i)^2 + p03*y(i)^3 + p40*x(i)^4 + p31*x(i)^3*y(i) + p22*x(i)^2*y(i)^2 + p13*x(i)*y(i)^3;



    %Linear model Poly44:
    %Coefficients ;%(with 95% confidence bounds):
           p00 =     0.01457;%(-0.03319, 0.06233)
       p10 =      -1.759;%(-2.262, -1.256)
       p01 =   0.0002656;%(0.000167, 0.0003641)
       p20 =       5.368;%(4.564, 6.173)
       p11 =   0.0001498;%(-2.494e-05, 0.0003245)
       p02 =  -9.936e-08;%(-1.384e-07, -6.03e-08)
       p30 =      -3.387;%(-3.946, -2.827)
       p21 =  -0.0003031;%(-0.0004556, -0.0001506)
       p12 =    2.28e-08;%(-1.879e-08, 6.439e-08)
       p03 =   1.146e-11;%(5.102e-12, 1.782e-11)
       p40 =      0.7167;%(0.5804, 0.8531)
       p31 =   0.0001089;%(5.647e-05, 0.0001614)
       p22 =  -4.351e-09;%(-1.822e-08, 9.516e-09)
       p13 =  -1.297e-12;%(-4.357e-12, 1.763e-12)     
       p04 =  -4.126e-16;%(-7.578e-16, -6.747e-17)
    Poly44(i) = p00 + p10*x(i) + p01*y(i) + p20*x(i)^2 + p11*x(i)*y(i) + p02*y(i)^2 + p30*x(i)^3 + p21*x(i)^2*y(i) + p12*x(i)*y(i)^2 + p03*y(i)^3 + p40*x(i)^4 + p31*x(i)^3*y(i) + p22*x(i)^2*y(i)^2 + p13*x(i)*y(i)^3 + p04*y(i)^4;
end 
% 
% for i = 1:length(voltage)    
%     PolyregressionSS32(i) = ( force(i) - mean(Poly32) )^2;
%     PolyregressionSS33(i) = ( force(i) - mean(Poly33) )^2;
%     PolyregressionSS34(i) = ( force(i) - mean(Poly34) )^2;
%     PolyregressionSS41(i) = ( force(i) - mean(Poly41) )^2;
%     PolyregressionSS42(i) = ( force(i) - mean(Poly42) )^2;
%     PolyregressionSS43(i) = ( force(i) - mean(Poly43) )^2;
%     PolyregressionSS44(i) = ( force(i) - mean(Poly44) )^2;
%     
%     totalSS31(i) = (Poly31(i) - mean(Poly31))^2;
%     totalSS32(i) = (Poly32(i) - mean(Poly32))^2;
%     totalSS33(i) = (Poly33(i) - mean(Poly33))^2;
%     totalSS34(i) = (Poly34(i) - mean(Poly34))^2;
%     totalSS41(i) = (Poly41(i) - mean(Poly41))^2;
%     totalSS42(i) = (Poly42(i) - mean(Poly42))^2;
%     totalSS43(i) = (Poly43(i) - mean(Poly43))^2;
%     totalSS44(i) = (Poly44(i) - mean(Poly44))^2;
%     
%     Poly33_error(i) = abs(Poly33(i)- force(i));
%     Poly34_error(i) = abs(Poly34(i)- force(i));
%     Poly41_error(i) = abs(Poly41(i)- force(i));
%     Poly42_error(i) = abs(Poly42(i)- force(i));
%     Poly43_error(i) = abs(Poly43(i)- force(i));
%     Poly44_error(i) = abs(Poly44(i)- force(i));     
% end

% r31 =  sum(PolyregressionSS31) / sum(totalSS33);
% r32 =  sum(PolyregressionSS32) / sum(totalSS33);
% r33 =  sum(PolyregressionSS33) / sum(totalSS33);
% r34 =  sum(PolyregressionSS34) / sum(totalSS34);
% r41 =  sum(PolyregressionSS41) / sum(totalSS41);
% r42 =  sum(PolyregressionSS42) / sum(totalSS42);
% r43 =  sum(PolyregressionSS43) / sum(totalSS43);
% r44 =  sum(PolyregressionSS44) / sum(totalSS44);

r31 =  0.983;
r32 =  0.9814;
r33 =  0.9827;
r34 =  0.9862;
r41 =  0.9872;
r42 =  0.9864;
r43 =  0.9867;
r44 =  0.9863;
disp('done'); 


%% Bar chart
X = categorical({'Poly31', 'Poly32', 'Poly33', 'Poly34', 'Poly41', 'Poly42', 'Poly43', 'Poly44'});
Y = [r31 r32 r33 r34 r41 r42 r43 r44];

%X = categorical({'Poly23', 'Poly24','Poly25', 'Poly31', 'Poly32', 'Poly33', 'Poly34', 'Poly35', 'Poly41', 'Poly42', 'Poly43', 'Poly44', 'Poly45','Poly51', 'Poly52', 'Poly53', 'Poly54', 'Poly55'});
%Y = [r23 r24 r25 r31 r32 r33 r34 r35 r41 r42 r43 r44 r45 r51 r52 r53 r54 r55];

%X = categorical({'Poly23', 'Poly24','Poly25', 'Poly31', 'Poly32', 'Poly33', 'Poly34', 'Poly35', 'Poly41', 'Poly42', 'Poly43', 'Poly44', 'Poly45','Poly51', 'Poly52', 'Poly53', 'Poly54', 'Poly55','Exp','Two-Term Exp'});
%Y = [mean(Poly23_error) mean(Poly24_error) mean(Poly25_error) mean(Poly31_error) mean(Poly32_error) mean(Poly33_error) mean(Poly34_error) mean(Poly35_error) mean(Poly41_error) mean(Poly42_error)  mean(Poly43_error) mean(Poly44_error) mean(Poly45_error) mean(Poly51_error) mean(Poly52_error) mean(Poly53_error) mean(Poly54_error) mean(Poly55_error), mean(exponentielt_fit_error), mean(exponentielt2_fit_error)];
bar(X,Y)
grid('on')
labels1 = string(Y);
text(X,Y,labels1,'VerticalAlignment','bottom','HorizontalAlignment','center')
ylim([0.95 1])
ylabel('R-squared [ R^2 ]')
grid('on');
set(gcf,'Position',[300 300 600 250])
set(gca,'FontSize',10)
title('Linearitet af fundne polynomie regressioner'); 




%% plot (standard)
%plot(tid, mass, tid, Poly13, tid,Poly14, tid,Poly15, tid,Poly21, tid,Poly22, tid,Poly23, tid,Poly24, tid,Poly25, tid,Poly31, tid,Poly32, tid,Poly33, tid,Poly34, tid,Poly35, tid,Poly41, tid,Poly42, tid,Poly43, tid,Poly44, tid,Poly45, tid,Poly51, tid,Poly52, tid,Poly53, tid,Poly54, tid,Poly55)
% legend('mass');
% ylim([0 3000]);
% ylabel('weight');

plot(tid, force, tid, Poly41)
legend('strain gauge','poly4*1 fit');
ylabel(' Kraft [ N ]');
xlabel(' Tid [ sec ] '); 
set(gcf,'Position',[300 300 600 350])
set(gca,'FontSize',10)
grid('on'); 
title('Poly4*1 formel i forhold til strain gauge'); 
ylim([0 22]);



%% plot (fancy)
%plot(exponentielt2_fit, force)
plot(Poly41, force,'.' );

hold('on')
plot(force, force); 
legend('poly4*1 vs Faktisk kraft', '1 til 1 linearitet')
grid('on')
ylabel('Faktisk kraft påført FSR sensor [ N ]'); 
xlabel('Kraft output af poly4*1 [ N ]'); 
set(gca,'FontSize',10)
title('Linearitet mellem reelle og estimeret tryk'); 


ylim([0 20])
xlim([0 20])



%% Error plot
%plot(tid, Poly13_error, tid,Poly14_error, tid,Poly15_error, tid,Poly21_error, tid,Poly22_error, tid,Poly23_error, tid,Poly24_error, tid,Poly25_error, tid,Poly31_error, tid,Poly32_error, tid,Poly33_error, tid,Poly34_error, tid,Poly35_error, tid,Poly41_error, tid,Poly42_error, tid,Poly43_error, tid,Poly44_error, tid,Poly45_error, tid,Poly51_error, tid,Poly52_error, tid,Poly53_error, tid,Poly54_error, tid,Poly55_error)

plot(tid, exponentielt2_fit_error)
plot(tid, Poly44_error)


%% remove 0 points (ift sensitivity)

j = 1; 
thresshold = 0.25; 
for i = 1:length(force) 
    if force(i) > thresshold
        ZeroForce(j)   = force(i); 
        ZeroVoltage(j) = voltage(i); 
        j = j + 1; 
    end 
end 

%% Sensitivitet Power ( simple plot )

% General model Power2:
%      f(x) = a*x^b+c
% Coefficients (with 95% confidence bounds):
a =      -3.594  ;%(-3.667, -3.522)
b =     -0.2874  ;%(-0.2955, -0.2793)
c =       4.732  ;%2(4.66, 4.803)

% Goodness of fit:
%   SSE: 27.03
%   R-square: 0.9793
%   Adjusted R-square: 0.9793
%   RMSE: 0.09798

x = linspace(0.3899, max(ZeroForce), length(ZeroForce)); 
y = a*(x).^b+c; 

hold('on'); 
plot(x,y)
plot(ZeroForce, ZeroVoltage, '.'); 
% ylim([0 3.3])
% xlim([0 max(ZeroForce)+1])
xlabel('Kraft induceret på FSR sensor ( N ) ');
ylabel('FSR output ( V )')
legend('Power regression','Målinger');
set(gca,'FontSize',14)
set(gcf,'Position',[300 300 1000 600])
xlim([0 22]);
grid('on');
title('Power regression'); 
hold('off'); 




%% sensitivitet Power( diff plot)
syms X
Y = a*(X).^b+c;


diff(Y)

for i = 1:length(x); 
    y_diff(i) = 2582289/(2500000*x(i)^(1.2874)); 
end

plot(x, y_diff); 
ylabel('ΔSpænding / ΔNewton ');
xlabel('Kraft induceret på FSR sensor ( N )')
set(gca,'FontSize',14)
title('Sensitivitet'); 
grid('on'); 
xlim([0 22]);
set(gcf,'Position',[300 300 1000 600])


% xlabel('Spænding ( v )'); 
% ylabel('d(Force) / D(Spænding)')
% grid('on'); 




