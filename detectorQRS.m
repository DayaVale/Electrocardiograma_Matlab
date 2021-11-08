function detectorQRS(senal_I,senal_F,fs)
    % Datos de la señal integrada
    LI = length(senal_I);
    TI = LI/fs;        
    tI = linspace(0, TI, LI);
    
    %Datos de la señal filtrada (Derivada)
    LF = length(senal_F);
    TF = LF/fs;        
    tF = linspace(0, TF, LF);

    SPKI_list = [];
    %SPKF = [];
    NPKI_list = [];
    %NPKF = [];
    picos_qrs = []; %Arreglo que almacena los tiempos de los complejos QRS
    complejos_qrs = []; % Arreglo de posibles complejos QRS
    indp = 1; %Inicialización
    picos_noise = []; %Arreglo que almacena los tiempos de el ruido
    indn = 1; %Inicialización
    THRESHOLDI1_list = [];
    %THRESHOLDI2 = [];
    %THRESHOLDF1 = [];
    
    [PEAKSI, IDEXTI] = findpeaks(senal_I,'MinPeakDistance',round(0.2*fs)); % Picos locales de la señal Integrada 
    [PEAKSF, IDEXTF] = findpeaks(senal_F,'MinPeakDistance',round(0.2*fs)); % Picos locales de la señal filtrada
   
    
    RR_AVERANGE1 = [];
    RR_AVERANGE2 = [];
    RR_LOW_LIMIT = [];
    RR_HIGH_LIMIT = [];
    RR_MISSED_LIMIT =[];
    
    %-------------------------- Primera Fase ------------------------------
    % Estrategia I se realiza sobre la señal integrada
    %-------------- Detección de los tiempos --------------------
    % Inicialización Estrategia I
    %Fase de inicialización en 2 segundos de la señal
    SPKI = max(senal_I(1:2*fs))/3; %Maximo de las amplitudes de los picos de la señal Integrada en los primeros dos segundos.
    NPKI = mean(senal_I(1:2*fs))/2; %Media de las amplitudes de los picos de la señal Integrada en los primeros dos segundos.
    THRESHOLDI1 = NPKI + (0.25)*(SPKI-NPKI);
    THRESHOLDI2 = (0.5)*THRESHOLDI1;
    
    indes = []
    L1 = length(PEAKSI);
    
    for i = 1:L1
        PEAKI = PEAKSI(i);
        if PEAKI > THRESHOLDI1
            ind = IDEXTI(i);
            indes(indp) = ind;
            picos_qrs(indp) = tI(ind);
            complejos_qrs(indp)= PEAKI; 
            SPKI = (0.125)*PEAKI + (0.875)*SPKI;
            SPKI_list(indp)= SPKI;
            indp = indp + 1;
        else 
            ind = IDEXTI(i);
            picos_noise(indn) = tI(ind);
            NPKI = (0.125)*PEAKI + (0.875)*NPKI;
            NPKI_list(indn)= NPKI;
            indn = indn + 1;
        end
        THRESHOLDI1 = NPKI + (0.25)*(SPKI-NPKI);
        %THRESHOLDI2 = (0.5)*THRESHOLDI1
        THRESHOLDI1_list(i)= THRESHOLDI1;
        
    end
    
    %picos_qrs
    %------ Graficar la primera parte -----------------------------------
    
    
    %plot(tI,senal_I)
    %hold on
    %plot(picos_qrs,complejos_qrs,'*')
    %plot(picos_qrs,SPKI_list,'o')
    %plot(picos_noise,NPKI_list,'-*')
    %plot(tI(IDEXTI),THRESHOLDI1_list,'x')
    %hold off
    
    % Estrategia II sobre la señal filtrada(derivada)
    %-------------------------  Comprobaciones --------------------------
    % Inicialización Estrategia II
    SPKF = max(senal_F(1:2*fs))/3; %Maximo de las amplitudes de los picos de la señal Filtrados en los primeros dos segundos.
    NPKF = mean(senal_F(1:2*fs))/2; %Media de las amplitudes de los picos de la señal Filtrados en los primeros dos segundos.
    THRESHOLDF1 = NPKF + (0.25)*(SPKF-NPKF)
    THRESHOLDF2 = (0.5)* THRESHOLDF1;
    complejosQRS = [];
    indtime_pqrs = [];
    ind3 = 1;
    
    index = 1;
    
   
    L2 = length(picos_qrs);
    while index <= L2
        win = senal_F(indes(index)-round(0.15*fs):indes(index));
        t = tF(indes(index)-round(0.15*fs):indes(index));
        [pic is] = max(win);
        
        if pic > THRESHOLDF1
            complejosQRS(ind3)= pic;
            indtime_pqrs(ind3)= t(is);
            SPKF = (0.125)*pic + (0.875)*SPKF;
            ind3 = ind3 +1;
        else
            NPKF = (0.125)*pic + (0.875)*NPKF;
        end
        THRESHOLDF1 = NPKF + (0.25)*(SPKF-NPKF)
        index = index +1;
    end
    
    
    
    subplot(2,1,1);
    plot(tF,senal_F)
    xlim([0,21])
    hold on
    plot(indtime_pqrs,complejosQRS,'*')
    hold off
    title('\textbf{Filtrada}', 'Interpreter', 'latex')
    xlabel('\textbf{Tiempo}  \textit{[sec]}', 'Interpreter','latex')
    ylabel('\textbf{Amplitud} \textit{[mV]} ', 'Interpreter','latex')
    
    subplot(2,1,2);
    plot(tI,senal_I)
    xlim([0,21])
    hold on
    plot(picos_qrs,complejos_qrs,'*')
    %plot(picos_qrs,SPKI_list,'o')
    %plot(picos_noise,NPKI_list,'-*')
    %plot(tI(IDEXTI),THRESHOLDI1_list,'x')
    hold off
    grid on
    title('\textbf{Integrada}', 'Interpreter', 'latex')
    xlabel('\textbf{Tiempo}  \textit{[sec]}', 'Interpreter','latex')
    ylabel('\textbf{Amplitud} \textit{[mV]} ', 'Interpreter','latex')
    
    
end