%% Load data 
clc 
clear
load('StrainGaugeData.mat')

%% Linear regression 

% Data found though SPSS
b = -1249.458; 
a = 1373.364; 
r_square = 1.00; %100pct of data is reprecented by the coefficent

% Plot data
weight = StrainGaugeData(1,:); 
voltage  = StrainGaugeData(2,:); 

x = 1:1:100; 
weight_reg = x*a + b; 

scatter(voltage,weight); 
hold('on'); 
plot(x, weight_reg); 

title('Strain Gauge Sensor'); 
ylabel('weight (g)'); 
xlabel('voltage (V)');
ylim([0 1200]); 
xlim([0.9 1.8]);
legend('Data','Linear Regression','Location','best');
grid on


