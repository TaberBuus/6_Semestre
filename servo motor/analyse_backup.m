clc 
clear

%% Load data
load('servo motor kalibrerings data.mat');
grader  = value(:,1); 
gram1   = value(:,2); 
force1  = (gram1/1000)*9.8; 

gram2   = value(:,3); 
force2  = (gram2/1000)*9.8; 

gram3   = value(:,4); 
force3  = (gram3/1000)*9.8; 

gram4   = value(:,5); 
force4  = (gram4/1000)*9.8; 

gram5   = value(:,6); 
force5  = (gram5/1000)*9.8; 

gram6   = value(:,7); 
force6  = (gram6/1000)*9.8; 

gram7   = value(:,8); 
force7  = (gram7/1000)*9.8; 

gram8   = value(:,9); 
force8  = (gram8/1000)*9.8; 

gram9   = value(:,10); 
force9  = (gram9/1000)*9.8; 

gram10  = value(:,11); 
force10 = (gram10/1000)*9.8; 


gramSammenLagt = [gram1' gram2' gram2' gram3' gram4' gram5' gram6' gram7' gram8' gram9' gram10'];
forceSammenLagt = (gramSammenLagt/1000)*9.8; 
graderSammenLagt = [grader' grader' grader' grader' grader' grader' grader' grader' grader' grader' grader'];

%% Simple plot (med 180 grader)
hold('on'); 
plot( forceSammenLagt,graderSammenLagt, '.'); 
xlabel('Output Servo ( N ) '); 
ylabel('Input Servo ( grader ) ');
x = linspace(0, 6, 1000);
y = 1453*exp(0.6281*x) +  (-1450)*exp(0.628*x); 
plot (x,y);

% fit(forceSammenLagt',graderSammenLagt','exp2')
%  General model Exp2:
%      ans(x) = a*exp(b*x) + c*exp(d*x)
%      Coefficients (with 95% confidence bounds):
%        a =        1453  (-1.18e+12, 1.18e+12)
%        b =      0.6281  (-4.295e+04, 4.295e+04)
%        c =       -1450  (-1.18e+12, 1.18e+12)
%        d =       0.628  (-4.305e+04, 4.305e+04)

%% Simple plot (med 100 grader)
gramSammenLagt100 = [gram1(1:36)' gram2(1:36)' gram2(1:36)' gram3(1:36)' gram4(1:36)' gram5(1:36)' gram6(1:36)' gram7(1:36)' gram8(1:36)' gram9(1:36)' gram10(1:36)'];
forceSammenLagt100 = (gramSammenLagt100/1000)*9.8; 
graderSammenLagt100 = [grader(1:36)' grader(1:36)' grader(1:36)' grader(1:36)' grader(1:36)' grader(1:36)' grader(1:36)' grader(1:36)' grader(1:36)' grader(1:36)' grader(1:36)'];

x100 = linspace(0, 5.6, 1000);
y100 =  5.346*exp(0.4224*x100) +  (0.006816)*exp(1.572*x100); 

hold('on'); 
plot( forceSammenLagt100,graderSammenLagt100, '.'); 
xlabel('Input Servo ( N ) '); 
ylabel('Output Servo ( grader ) ');
plot (x100,y100);
ylim([0 100]);
grid('on'); 


%fit(forceSammenLagt100',graderSammenLagt100','exp2')
% General model Exp2:
%      ans(x) = a*exp(b*x) + c*exp(d*x)
%      Coefficients (with 95% confidence bounds):
%        a =       5.346  (4.092, 6.6)
%        b =      0.4224  (0.3083, 0.5365)
%        c =    0.006816  (-0.0294, 0.04303)
%        d =       1.572  (0.6952, 2.449)

%% plot 
hold('on'); 
plot(force1, grader, force2, grader, force3, grader, force4, grader, force5, grader, force6, grader, force7, grader, force8, grader,force9, grader,force10, grader); 
legend('nr 1','nr 2','nr 3','nr 4','nr 5','nr 6','nr 7','nr 8','nr 9','nr 10')
xlabel('Input Servo ( N ) '); 
ylabel('Output Servo ( grader ) '); 
grid('on');


%% exponentiel regression

