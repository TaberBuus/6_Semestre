load('fsr_3.mat')
load('mass_3.mat')

a = 1373.364; 
voltage = (fsr/4095)*3.3; 
mass = ((straingauge)/4095)*3.3*a; 
mass = ((mass - 1070)/1000)*9.8;


plot(voltage,mass,'k.');
xlabel('FSR voltage (v)');
ylabel('Force (N)');
grid('on'); 
ylim([0 22]);
