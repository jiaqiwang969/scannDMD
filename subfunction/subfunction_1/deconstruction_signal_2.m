function deconstruction_signal_2(signal,fs,object)
% fs=12000;
%data=resample(signal(:,object(1)),fs,fk);%qian
data=signal(:,object(1));%qian
data1=signal(:,object(1)+1);%qian
data2=signal(:,object(1)+2);
data3=signal(:,object(1)+3);
data4=signal(:,object(2));
data5=signal(:,object(3));
data6=signal(:,object(4));

f=[4*10/fs 6*20/fs 2*1000/fs 2*1020/fs];
A=[0 1 0];
rp=0.153;
rs=16.92;
devp=1-10^(-rp/20);
devs=10^(-rs/20);
dev=[devp devs devp];
[n,f0,A0,w]=remezord(f,A,dev);
if rem(n,2)
   n=n+1;
end
b=remez(n,f0,A0,w);
freqz(b,1,length(b),1);
data_filter = filter(b,1,data);
data_filter1 = filter(b,1,data1);
data_filter2 = filter(b,1,data2);
data_filter3 = filter(b,1,data3);
data_filter4 = filter(b,1,data4);
data_filter5 = filter(b,1,data5);
data_filter6 = filter(b,1,data6);


N = length(data_filter);
x = (data_filter - mean(data_filter))/std(data_filter);
x1 = (data_filter1 - mean(data_filter1))/std(data_filter1)+4;
x2 = (data_filter2 - mean(data_filter2))/std(data_filter2)+8;
x3 = (data_filter3 - mean(data_filter3))/std(data_filter3)+12;
x4 = (data_filter4 - mean(data_filter4))/std(data_filter4)+16;
x5 = (data_filter5 - mean(data_filter5))/std(data_filter5)+20;
x6 = (data_filter6 - mean(data_filter6))/std(data_filter6)+24;

[row,col] = size(x);
if row<col
    x = x';
end

t = [0:N-1]'/fs;
figure
subplot(211)
plot(t,x)
hold on
plot(t,x1)
plot(t,x2)
plot(t,x3)
plot(t,x4)
plot(t,x5)
plot(t,x6)


subplot(212)
[psd_x,f] = pwelch(x,[],[],round(N/4),fs);
[psd_x1,f1] = pwelch(x1,[],[],round(N/4),fs);
[psd_x2,f2] = pwelch(x2,[],[],round(N/4),fs);
[psd_x3,f3] = pwelch(x3,[],[],round(N/4),fs);
[psd_x4,f4] = pwelch(x4,[],[],round(N/4),fs);
[psd_x5,f5] = pwelch(x5,[],[],round(N/4),fs);
[psd_x6,f6] = pwelch(x6,[],[],round(N/4),fs);
plot(f,psd_x)
hold on
plot(f1,psd_x1)
plot(f2,psd_x2)
plot(f3,psd_x3)
plot(f4,psd_x4)
plot(f5,psd_x5)
plot(f6,psd_x6)
%cyclic analysis for x
Ana_data = hilbert(x);
Nw = 256;           % window length
window = hanning(Nw);0
Nv = fix(2/3*Nw);	% block overlap
nfft = 2*Nw;  		% FFT length
d_afa = fs/N;

% 指定区域和分辨率
afa = [1:1:1000];
alpha = fix(afa/d_afa)/N;  	% cyclic frequencies to scan
Cyc_Coh = zeros(nfft,length(afa));
Cyc_Spec = zeros(nfft,length(afa));
h = waitbar(0,'CALCULATION IN PROGRESS...');
for k = 1:length(afa)
    Cyc_Coh(:,k) = cyclic_coherence_Welch(Ana_data,Ana_data,alpha(k),nfft,Nv,window);
    Cyc_Spec(:,k) = cyclic_spectrum_density_Welch(Ana_data,Ana_data,alpha(k),nfft,Nv,window);
    waitbar(k/length(afa))
end
close(h)

figure
plot(afa,sum(abs(Cyc_Coh(1:nfft/2,:))))
xlabel('\alpha')
title('Cyclic Coherence')

figure
plot(afa,sum(abs(Cyc_Spec(1:nfft/2,:))))
xlabel('\alpha')
title('Cyclic Spectrum')

TFPlane = abs(Cyc_Coh(1:nfft/2,:));
TFMax = max(max(TFPlane));
TFPlane = TFPlane .* (512./TFMax);
figure
colormap(1 - gray(256))
f = (0:nfft/2-1)*fs/nfft;
image(afa,f,TFPlane);
axis('xy')
title('Cyclic Coherence'),xlabel('\alpha'),ylabel('f')

figure
colormap(gray(256))
hh = mesh(afa,f,TFPlane);
axis('xy')
title('Cyclic Coherence'),xlabel('\alpha'),ylabel('f')
set(hh,'meshstyle','column')

%
TFPlane = abs(Cyc_Spec(1:nfft/2,:));
TFMax = max(max(TFPlane));
TFPlane = TFPlane .* (512./TFMax);
figure
colormap(1 - gray(256))
f = (0:nfft/2-1)*fs/nfft;
image(afa,f,TFPlane);
axis('xy')
title('Cyclic Spectrum'),xlabel('\alpha'),ylabel('f')

figure
colormap(gray(256))
hh = mesh(afa,f,TFPlane);
axis('xy')
title('Cyclic Spectrum'),xlabel('\alpha'),ylabel('f')
set(hh,'meshstyle','column')


% % calculate AR_error using lpc function -- it is very fast compared with ar function
% AR_order = 6000;  %order
% [AR_model,error] = lpc(x,AR_order);
% y = fftfilt(AR_model,x);
% AR_error = y(AR_order+1:end);
% N_AR = length(AR_error);
% t = [0:N_AR-1]'/fs;
% figure
% subplot(211)
% plot(t,AR_error)
% subplot(212)
% [psd_AR_error,f] = pwelch(AR_error,[],[],round(N_AR/4),fs);
% plot(f,psd_AR_error)
% 
% %cyclic analysis for AR error
% Ana_data = hilbert(AR_error);
% Nw = 256;           % window length
% window = hanning(Nw);
% Nv = fix(2/3*Nw);	% block overlap
% nfft = 2*Nw;  		% FFT length
% d_afa = fs/N_AR;
% 
% % 指定区域和分辨率
% afa = [1:1:1000];
% alpha = fix(afa/d_afa)/N_AR;  	% cyclic frequencies to scan
% Cyc_Coh = zeros(nfft,length(afa));
% Cyc_Spec = zeros(nfft,length(afa));
% h = waitbar(0,'CALCULATION IN PROGRESS...');
% for k = 1:length(afa)
%     Cyc_Coh(:,k) = cyclic_coherence_Welch(Ana_data,Ana_data,alpha(k),nfft,Nv,window);
%     Cyc_Spec(:,k) = cyclic_spectrum_density_Welch(Ana_data,Ana_data,alpha(k),nfft,Nv,window);
%     waitbar(k/length(afa))
% end
% close(h)
% 
% figure
% plot(afa,sum(abs(Cyc_Coh(1:nfft/2,:))))
% xlabel('\alpha')
% title('Cyclic Coherence AR error')
% 
% figure
% plot(afa,sum(abs(Cyc_Spec(1:nfft/2,:))))
% xlabel('\alpha')
% title('Cyclic Spectrum AR error')
% 
% TFPlane = abs(Cyc_Coh(1:nfft/2,:));
% TFMax = max(max(TFPlane));
% TFPlane = TFPlane .* (512./TFMax);
% figure
% colormap(1 - gray(256))
% f = (0:nfft/2-1)*fs/nfft;
% image(afa,f,TFPlane);
% axis('xy')
% title('Cyclic Coherence AR error'),xlabel('\alpha'),ylabel('f')
% 
% figure
% colormap(gray(256))
% hh = mesh(afa,f,TFPlane);
% axis('xy')
% title('Cyclic Coherence AR error'),xlabel('\alpha'),ylabel('f')
% set(hh,'meshstyle','column')
% 
% %
% TFPlane = abs(Cyc_Spec(1:nfft/2,:));
% TFMax = max(max(TFPlane));
% TFPlane = TFPlane .* (512./TFMax);
% figure
% colormap(1 - gray(256))
% f = (0:nfft/2-1)*fs/nfft;
% image(afa,f,TFPlane);
% axis('xy')
% title('Cyclic Spectrum AR error'),xlabel('\alpha'),ylabel('f')
% 
% figure
% colormap(gray(256))
% hh = mesh(afa,f,TFPlane);
% axis('xy')
% title('Cyclic Spectrum AR error'),xlabel('\alpha'),ylabel('f')
% set(hh,'meshstyle','column')
% 
% % for i = 1:1:1024
% %     AR_order = i;  %order
% %     [AR_model,error] = lpc(x,AR_order);
% %     AR_error = fftfilt(AR_model,x);
% %     y = AR_error(AR_order+1:end);
% %     LPC_ERROR(i) = std(y);
% % end
% % 
% % figure
% % plot(LPC_ERROR)
% 
% % calculate AR_error using ar function
% % AR_error = zeros(N,1);
% % Data_AR = iddata(x,[],1.0/fs);
% % AR_order = 200;
% % AR_model = ar(Data_AR,AR_order);
% % A = AR_model.a;
% % for it = 1:1:N
% %      if it < AR_order+1
% %          for j = 1:1:it
% %              AR_error(it,1) = AR_error(it,1)+A(1,j)*x(it-j+1,1);
% %          end
% %      else
% %          for j = 1:1:AR_order+1
% %              AR_error(it,1) = AR_error(it,1)+A(1,j)*x(it-j+1,1);
% %          end
% %      end
% % end
% % y = AR_error(AR_order+1:end);
% % N = length(y);
% % t = [0:N-1]'/fs;
% % figure
% % subplot(211)
% % plot(t,y)
% % subplot(212)
% % [psd_AR_error,f] = pwelch(y,[],[],round(N/4),fs);
% % plot(f,psd_AR_error)
% 
% % wiener filter using LMS algorithm
% LMS_order = 6000;
% delay = 0;
% Nwind = N;
% x_input = x(1 : Nwind);                             % 输入信号
% x_ref = x_input;	                                % 参考信号
% mu = 0.0001;                                      % Sign-data step size.
% ha =  dsp.LMSFilter(LMS_order,mu);
% [LMS_filter,e] = filter(ha,x_input,x_ref);
% LMS_error = x_ref - LMS_filter;  
% 
% N_LMS = length(LMS_error);
% t = [0:N_LMS-1]'/fs;
% figure
% subplot(211)
% plot(t,LMS_error)
% subplot(212)
% [psd_LMS_error,f] = pwelch(LMS_error,[],[],round(N_LMS/4),fs);
% plot(f,psd_LMS_error)
% 
% 
% % for i = 1:1:1024
% %     LMS_order = i;                       %order
% %     delay = 0;
% %     Nwind = N;
% %     x_input = x(1 : Nwind);                          
% %     x_ref = x_input;
% %     mu = 0.0001;                        % Sign-data step size
% %     ha = adaptfilt.lms(LMS_order,mu);
% %     [LMS_filter,e] = filter(ha,x_input,x_ref);
% %     y = x_ref - LMS_filter; 
% %     LMS_error(i) = std(y);
% % end
% % 
% % figure
% % plot(LMS_error)
% 
% %cyclic analysis for LMS error
% Ana_data = hilbert(LMS_error);
% Nw = 256;           % window length
% window = hanning(Nw);
% Nv = fix(2/3*Nw);	% block overlap
% nfft = 2*Nw;  		% FFT length
% d_afa = fs/N_LMS;
% 
% % 指定区域和分辨率
% afa = [1:1:1000];
% alpha = fix(afa/d_afa)/N_LMS;  	% cyclic frequencies to scan
% Cyc_Coh = zeros(nfft,length(afa));
% Cyc_Spec = zeros(nfft,length(afa));
% h = waitbar(0,'CALCULATION IN PROGRESS...');
% for k = 1:length(afa)
%     Cyc_Coh(:,k) = cyclic_coherence_Welch(Ana_data,Ana_data,alpha(k),nfft,Nv,window);
%     Cyc_Spec(:,k) = cyclic_spectrum_density_Welch(Ana_data,Ana_data,alpha(k),nfft,Nv,window);
%     waitbar(k/length(afa))
% end
% close(h)
% 
% figure
% plot(afa,sum(abs(Cyc_Coh(1:nfft/2,:))))
% xlabel('\alpha')
% title('Cyclic Coherence LMS error')
% 
% figure
% plot(afa,sum(abs(Cyc_Spec(1:nfft/2,:))))
% xlabel('\alpha')
% title('Cyclic Spectrum LMS error')
% 
% TFPlane = abs(Cyc_Coh(1:nfft/2,:));
% TFMax = max(max(TFPlane));
% TFPlane = TFPlane .* (512./TFMax);
% figure
% colormap(1 - gray(256))
% f = (0:nfft/2-1)*fs/nfft;
% image(afa,f,TFPlane);
% axis('xy')
% title('Cyclic Coherence LMS error'),xlabel('\alpha'),ylabel('f')
% 
% figure
% colormap(gray(256))
% hh = mesh(afa,f,TFPlane);
% axis('xy')
% title('Cyclic Coherence LMS error'),xlabel('\alpha'),ylabel('f')
% set(hh,'meshstyle','column')
% 
% %
% TFPlane = abs(Cyc_Spec(1:nfft/2,:));
% TFMax = max(max(TFPlane));
% TFPlane = TFPlane .* (512./TFMax);
% figure
% colormap(1 - gray(256))
% f = (0:nfft/2-1)*fs/nfft;
% image(afa,f,TFPlane);
% axis('xy')
% title('Cyclic Spectrum LMS error'),xlabel('\alpha'),ylabel('f')
% 
% figure
% colormap(gray(256))
% hh = mesh(afa,f,TFPlane);
% axis('xy')
% title('Cyclic Spectrum LMS error'),xlabel('\alpha'),ylabel('f')
% set(hh,'meshstyle','column')
% 
% 
% 
% % wiener filter using algorithm in frequency domain
% delay = 100;
% Nwind = fs;
% NFFT = 2*Nwind;
% 
% % version with absolute magnitude TF
% G = STFT_LE(x,Nwind+delay,Nwind,round(2*Nwind/3),NFFT,1,'parzenwin');
% G1 = abs(G);
% [y,g] = Filt_STFT(x,G1.');    %复数转置G1.'; 复数共轭转置G1';
% ALE_error = x - y;
% 
% N_ALE = length(ALE_error);
% t = [0:N_ALE-1]'/fs;
% figure
% subplot(211)
% plot(t,ALE_error)
% subplot(212)
% [psd_ALE_error,f] = pwelch(ALE_error,[],[],round(N_ALE/4),fs);
% plot(f,psd_ALE_error)
% 
% %cyclic analysis for ALE error
% Ana_data = hilbert(ALE_error);
% Nw = 256;           % window length
% window = hanning(Nw);
% Nv = fix(2/3*Nw);	% block overlap
% nfft = 2*Nw;  		% FFT length
% d_afa = fs/N_ALE;
% 
% % 指定区域和分辨率
% afa = [1:1:1000];
% alpha = fix(afa/d_afa)/N_ALE;  	% cyclic frequencies to scan
% Cyc_Coh = zeros(nfft,length(afa));
% Cyc_Spec = zeros(nfft,length(afa));
% h = waitbar(0,'CALCULATION IN PROGRESS...');
% for k = 1:length(afa)
%     Cyc_Coh(:,k) = cyclic_coherence_Welch(Ana_data,Ana_data,alpha(k),nfft,Nv,window);
%     Cyc_Spec(:,k) = cyclic_spectrum_density_Welch(Ana_data,Ana_data,alpha(k),nfft,Nv,window);
%     waitbar(k/length(afa))
% end
% close(h)
% 
% figure
% plot(afa,sum(abs(Cyc_Coh(1:nfft/2,:))))
% xlabel('\alpha')
% title('Cyclic Coherence ALE error')
% 
% figure
% plot(afa,sum(abs(Cyc_Spec(1:nfft/2,:))))
% xlabel('\alpha')
% title('Cyclic Spectrum ALE error')
% 
% TFPlane = abs(Cyc_Coh(1:nfft/2,:));
% TFMax = max(max(TFPlane));
% TFPlane = TFPlane .* (512./TFMax);
% figure
% colormap(1 - gray(256))
% f = (0:nfft/2-1)*fs/nfft;
% image(afa,f,TFPlane);
% axis('xy')
% title('Cyclic Coherence ALE error'),xlabel('\alpha'),ylabel('f')
% 
% figure
% colormap(gray(256))
% hh = mesh(afa,f,TFPlane);
% axis('xy')
% title('Cyclic Coherence ALE error'),xlabel('\alpha'),ylabel('f')
% set(hh,'meshstyle','column')
% 
% %
% TFPlane = abs(Cyc_Spec(1:nfft/2,:));
% TFMax = max(max(TFPlane));
% TFPlane = TFPlane .* (512./TFMax);
% figure
% colormap(1 - gray(256))
% f = (0:nfft/2-1)*fs/nfft;
% image(afa,f,TFPlane);
% axis('xy')
% title('Cyclic Spectrum ALE error'),xlabel('\alpha'),ylabel('f')
% 
% figure
% colormap(gray(256))
% hh = mesh(afa,f,TFPlane);
% axis('xy')
% title('Cyclic Spectrum ALE error'),xlabel('\alpha'),ylabel('f')
% set(hh,'meshstyle','column')

end
 
      


   
