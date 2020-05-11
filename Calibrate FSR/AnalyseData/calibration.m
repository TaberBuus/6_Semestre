%% Reset and load data
clc 
clear
load('FSR_big_recording3.mat')

weights = RaaData(1,:);             % Mass in kilogram
voltage = (RaaData(2,:)/1000)*5;    % Voltage

%% polynomial fit: (wrong direction)
hold('off'); 
p_orginal = polyfit(weights,voltage, 5);
y_fittet_orginal= polyval(p_orginal,weights); 

hold('on');
plot(weights, y_fittet_orginal); 
scatter(weights,voltage); 
xlabel('weight'); 
ylabel('voltage'); 
ylim([0 5]);
grid('on');
title('polynomial'); 



%% exponentiel fit
hold('off'); 
%[f] = fit(voltage', weights','exp1')
%[f1] = fit(voltage', weights','exp2')


x1 = (0:0.2:5)';
y1 = 5.947e-07*exp(4.285*x1)';
%y2 = (6.652e-13)*exp(7.029*x1') + 20.56*exp(0.4484*x1');

y2 = (1)*exp(7.029*x1') + 20.56*exp(0.4484*x1');


hold('on'); 
plot(x1,y1); 
plot(x1,y2); 
%scatter(voltage,weights);

ylim([0 1000]);
xlim([0 5]);
xlabel('voltage'); 
ylabel('Weight (gram)')




