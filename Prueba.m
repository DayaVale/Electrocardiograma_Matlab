load('ECG1_prueba','-mat')
%Fs = 250;
%L = 5120;
%plot(val)
T = L/Fs;        
f_complete = (-L/2:L/2-1)*Fs/L;
t = linspace(0, T, L);
%plot(t,val)

[y_m,y_d] = pan_tompkins(Fs,val,t);
%plot(y_m)
detectorQRS(y_m,y_d,Fs)










