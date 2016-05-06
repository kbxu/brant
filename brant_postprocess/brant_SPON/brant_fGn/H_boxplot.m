clear,clc
close all

H0=0.1:0.1:0.9;

file_number=128;
f1='Whittle';f2='WLS';f3='fBm';f4='MPE';
file_in=strcat('E:\MATLAB\fGn_results\',f1,'_N',num2str(file_number));
load(file_in)
H1=H(1:1000,:);
Hm1=mean(H1);
mse1=100*sqrt((H0-Hm1).^2+var(H1));

file_in=strcat('E:\MATLAB\fGn_results\',f2,'_N',num2str(file_number));
load(file_in)
H2=H;
Hm2=mean(H2);
mse2=100*sqrt((H0-Hm2).^2+var(H2));

file_in=strcat('E:\MATLAB\fGn_results\',f3,'_N',num2str(file_number));
load(file_in)
H3=H(1:1000,:);
Hm3=mean(H3);
mse3=100*sqrt((H0-Hm3).^2+var(H3));

file_in=strcat('E:\MATLAB\fGn_results\',f4,'_N',num2str(file_number));
load(file_in)
H4=H;
Hm4=mean(H4);
mse4=100*sqrt((H0-Hm4).^2+var(H4));

ymin=min(min([H1 H2 H3 H4]));
ymax=max(max([H1 H2 H3 H4]));

ymin=min(ymin,0);
h=H0(2)-H0(1);
Hy1=H0(1):-h:ymin;
Hy1=Hy1(end:-1:1);
Hytick=[Hy1 H0(2:end-1) H0(end):h:ymax];

for i=1:length(H0)
    g{i}=num2str(H0(i));
end
subplot(321),boxplot(H1,'labels',g,'sym','r.')
set(gca,'ytick',Hytick);
grid on,
xlabel('Hurst exponent','fontsize',12)
ylabel('estimated Hurst exponent','fontsize',12)
title('Whittle''s estimator','fontsize',12)
ylim([ymin ymax])


subplot(322),boxplot(H2,'labels',g,'sym','r.')
set(gca,'ytick',Hytick);
grid on,
xlabel('Hurst exponent','fontsize',12)
ylabel('estimated Hurst exponent','fontsize',12)
title('Wavelet-ML estimator','fontsize',12)
ylim([ymin ymax])



subplot(323),boxplot(H3,'labels',g,'sym','r.')
set(gca,'ytick',Hytick);
grid on,
xlabel('Hurst exponent','fontsize',12)
ylabel('estimated Hurst exponent','fontsize',12)
title('fBm estimator','fontsize',12)
ylim([ymin ymax])

subplot(324),boxplot(H4,'labels',g,'sym','r.')
set(gca,'ytick',Hytick);
grid on,
xlabel('Hurst exponent','fontsize',12)
ylabel('estimated Hurst exponent','fontsize',12)
title('Modified Periodogram estimator','fontsize',12)
ylim([ymin ymax])

subplot(325),plot(H0,H0,'M',H0,Hm1,'bo:',H0,Hm2,'gs:',H0,Hm3,'kd:',H0,Hm4,'r^:')
legend('nominal Hurst exponent','Whittle','WLS','fBm','MPE')
xlabel('Hurst exponent','fontsize',12)
ylabel('mean','fontsize',12)

subplot(326),plot(H0,mse1,'bo:',H0,mse2,'gs:',H0,mse3,'kd:',H0,mse4,'r^:')
legend('Whittle','WLS','fBm','MPE')
xlabel('Hurst exponent','fontsize',12)
ylabel('100¡ÁRMSE','fontsize',12)

