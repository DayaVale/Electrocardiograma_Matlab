load('12431_02m.mat','-mat')
Fs = 250;
plot(val)

%% ----------------- Algoritmo de Pan-Toskin -----------------------------------------------
% Primer paso Filtrado
% Filto paso bajo corte en 15 Hz
Wn1 = 15/(Fs/2);
n = 3; %Orden 
[b,a] = butter(n,Wn1,"low");
y = filter(b,a,val);
y = y/max(abs(y));
plot(y)

% Filtro pasa altos corte en 5 Hz

Wn2 = 5/(Fs/2); 
[b,a] = butter(n,Wn2,"High");
y1 = filter(b,a,y);
y1 = y1/max(abs(y1));
plot(y1)

% Derivación  
int_c = 4/(Fs*1/40);
b1 = interp1(1:5,[1 2 0 -2 -1].*(1/8)*Fs,1:int_c:5);
y_d = filter(b1,1,y1);
y_d = y_d/max(abs(y_d));
plot(y_d)

%Square 

y_s = y_d.^2;
plot(y_s)

% Integración 
m = round(0.150*Fs);
y_m = conv(y_s ,ones(1 ,m)/m);
plot(y_m)










