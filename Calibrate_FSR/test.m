clc
clear 

tdata = 0:0.1:10;
ydata = 40*exp(-0.5*tdata) + randn(size(tdata));

plot(tdata, ydata)
