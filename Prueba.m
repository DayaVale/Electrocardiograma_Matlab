%load('ECG1_prueba','-mat')
load('109m','-mat')
Fs = 360;
L = length(val);
%plot(val)
T = L/Fs;        
f_complete = (-L/2:L/2-1)*Fs/L;
t = linspace(0, T, L);
%plot(t,val)

[y_m,y_d] = pan_tompkins(Fs,val,t);
%plot(y_d)
detector_QRS2(y_m,y_d,Fs)
%detectorQRS(y_m,y_d,Fs)











