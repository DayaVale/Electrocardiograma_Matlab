function[tI,tF,picostime_qrs,complejos_qrs,PEAKQRS,PEAKtime] = detector_QRS2 (senal_I,senal_F,fs)
    % Datos de la señal integrada
    LI = length(senal_I);
    TI = LI/fs;        
    tI = linspace(0, TI, LI);
    
    %Datos de la señal filtrada (Derivada)
    LF = length(senal_F);
    TF = LF/fs;        
    tF = linspace(0, TF, LF);

    SPKI_list = [];
    SPKF_list = [];
    NPKI_list = [];
    NPKF_list = [];
    picostime_qrs = []; %Arreglo que almacena los tiempos de los complejos QRS
    complejos_qrs = []; % Arreglo de posibles complejos QRS
    PEAKQRS = [];
    PEAKtime =[];
    indp = 1; %Inicialización
    picos_noise = []; %Arreglo que almacena los tiempos de el ruido
    indn = 1; %Inicialización
    THRESHOLDI1_list = [];
    %THRESHOLDI2 = [];
    %THRESHOLDF1 = [];
    
    [PEAKSI, IDEXTI] = findpeaks(senal_I,'MinPeakDistance',round(0.2*fs)); % Picos locales de la señal Integrada 
    
    %-------------- Detección de los tiempos --------------------
    % Inicialización Estrategia I
    %Fase de inicialización en 2 segundos de la señal
    SPKI = max(senal_I(1:2*fs))/3; %Maximo de las amplitudes de los picos de la señal Integrada en los primeros dos segundos.
    NPKI = mean(senal_I(1:2*fs))/2; %Media de las amplitudes de los picos de la señal Integrada en los primeros dos segundos.
    THRESHOLDI1 = NPKI + (0.25)*(SPKI-NPKI);
    THRESHOLDI2 = (0.5)*THRESHOLDI1;
    % Inicialización Estrategia II
    SPKF = max(senal_F(1:2*fs))/3; %Maximo de las amplitudes de los picos de la señal Filtrados en los primeros dos segundos.
    NPKF = mean(senal_F(1:2*fs))/2; %Media de las amplitudes de los picos de la señal Filtrados en los primeros dos segundos.
    THRESHOLDF1 = NPKF + (0.25)*(SPKF-NPKF);
    THRESHOLDF2 = (0.5)*THRESHOLDF1;
    % Inicialización Fase 3
    RRn = 0;
    RRn_prima = 0;
    RR_missed = 0;
    RR_AVERAGE1 = [];
    RR_AVERAGE2 = 0.4; % Se inicializa en 400 ms
    RR_LOW = 0.92 * RR_AVERAGE2;
    RR_HIGH = 1.16 * RR_AVERAGE2;
    RR_MISSED = 1.66 * RR_AVERAGE2;
    %Varibles booleanas
    conti = 0; % Parte 1 ventana 
    test = 0;
    reanalis = 0;
    
    
    
    
    L1 = length(PEAKSI);
    
    for i = 1:L1
        PEAKI = PEAKSI(i);
        if PEAKI > THRESHOLDI1 
            if (IDEXTI(i)-round(0.15*fs)>= 1)&& (IDEXTI(i) <= length(senal_F))
                win = senal_F(IDEXTI(i)-round(0.15*fs):IDEXTI(i));
                t = tF(IDEXTI(i)-round(0.15*fs):IDEXTI(i));
                conti = 1;
            else
                if i == 1
                    win = senal_F(1:IDEXTI(i)); 
                    t = tF(1:IDEXTI(i));
                    if IDEXTI(i)-1 == round(0.15*fs)
                       conti = 1;
                    else
                       conti = 0; 
                    end 
                elseif IDEXTI(i) >= length(senal_F)
                    win = senal_F(IDEXTI(i)-round(0.15*fs):end);
                    t = tF(IDEXTI(i)-round(0.15*fs):end);
                    if lenght(senal_F)-(IDEXTI(i)-round(0.15*fs)) == round(0.15*fs)
                        conti = 1;
                    else
                       conti = 0; 
                    end
                end
            end
            
        end
        if PEAKI > THRESHOLDI1 
            if conti
                [pico , idx] = max(win);
                if pico > THRESHOLDF1
                    complejos_qrs(indp) = pico; %Complejos qrs
                    picostime_qrs(indp) = t(idx); % tiempo de los complejos qrs
                    PEAKQRS(indp) = PEAKI; % Posibles complejos qrs
                    PEAKtime(indp)= tI(IDEXTI(i)); % el tiempo de los posibles complejos qrs
                    SPKI = (0.125)*PEAKI + (0.875)*SPKI;
                    SPKI_list(indp)= SPKI;
                    SPKF = (0.125)*pico + (0.875)*SPKF;
                    SPKF_list(indp) = SPKF;
                    indp = indp + 1;
              
                else
                    test = 1;
                end    
            end  
            
            
           if test
                t2 = tI(IDEXTI(i))-picostime_qrs(end);
                if t2 > RR_MISSED
                    THRESHOLDI2 = (0.5)*THRESHOLDI1;
                    THRESHOLDF2 = (0.5)*THRESHOLDF1;
                    reanalis = 1;
                else
                    NPKI = (0.125)*PEAKI + (0.875)*NPKI;
                    NPKI_list(indn)= NPKI; 
                    NPKF = (0.125)*pico + (0.875)*NPKF;
                    NPKF_list(indn)= NPKF; 
                    indn = indn + 1; 
                end  
           end
           
           if reanalis
             if PEAKI > THRESHOLDI2
                win2 = senal_F(IDEXT(i)-round(0.15*fs):IDEXT(i));
                t2 = tF(IDEXTI(i)-round(0.15*fs):IDEXTI(i));
                [pico2, is2] = max(win2);
                if pico2 > THRESHOLDF2
                    complejos_qrs(indp) = pico2; %Complejos qrs
                    picostime_qrs(indp) = t2(is2); % tiempo de los complejos qrs
                    PEAKQRS(indp) = PEAKI; % Posibles complejos qrs
                    PEAKtime(indp)= tI(IDEXTI(i)); % el tiempo de los posibles complejos qrs
                    SPKI = (0.125)*PEAKI + (0.875)*SPKI;
                    SPKI_list(indp)= SPKI;
                    SPKF = (0.125)*pico + (0.875)*SPKF;
                    SPKF_list(indp) = SPKF;
                    indp = indp + 1;
                end    
             end
           end   
           if length(complejos_qrs) > 8
               RRn = picostime_qrs(end-8:end); %Tomo los 8 ultimos intervalos
               RR_AVERAGE1 = (0.125)*(sum(RRn));
               RR_prima1 = RRn(RRn >= RR_LOW);
               RR_prima = RR_prima1(RRn <= RR_HIGH);
               if length(RR_prima) > 8
                   RR_AVERAGE2 = (0.125)*(sum(RR_prima));
               end  
           end  
        end   
        
        THRESHOLDI1 = NPKI + (0.25)*(SPKI-NPKI);
        THRESHOLDF1 = NPKF + (0.25)*(SPKF-NPKF);
        RR_LOW = 0.92 * RR_AVERAGE2;
        RR_HIGH = 1.16 * RR_AVERAGE2;
        RR_MISSED = 1.66 * RR_AVERAGE2;
        conti = 0; % Parte 1 ventana 
        test = 0;
        reanalis = 0;
    end
    
   
end