clear,clc
close all

H0=0.1:0.1:0.9;

file_number=150;
f1='PE';f2='MPE';
file_in=strcat('E:\MATLAB\fGn_results\',f1,'_N',num2str(file_number));
load(file_in)
H1=H;
Hm1=mean(H1);
mse1=100*sqrt((H0-Hm1).^2+var(H1));

file_in=strcat('E:\MATLAB\fGn_results\',f2,'_N',num2str(file_number));
load(file_in)
H2=H;
Hm2=mean(H2);
mse2=100*sqrt((H0-Hm2).^2+var(H2));

ymin=min(min([H1 H2]));
ymax=max(max([H1 H2]));

ymin=min(ymin,0);
h=H0(2)-H0(1);
Hy1=H0(1):-h:ymin;
Hy1=Hy1(end:-1:1);
Hytick=[Hy1 H0(2:end-1) H0(end):h:ymax];

for i=1:length(H0)
    g{i}=num2str(H0(i));
end
subplot(221),boxplot(H1,'labels',g,'sym','r.')
set(gca,'ytick',Hytick);
grid on,
xlabel('Hurst exponent','fontsize',12)
ylabel('estimated Hurst exponent','fontsize',12)
title('Periodogram estimator','fontsize',12)
ylim([ymin ymax])


subplot(222),boxplot(H2,'labels',g,'sym','r.')
set(gca,'ytick',Hytick);
grid on,
xlabel('Hurst exponent','fontsize',12)
ylabel('estimated Hurst exponent','fontsize',12)
title('Modified periodogram estimator','fontsize',12)
ylim([ymin ymax])

subplot(223),plot(H0,H0,'M',H0,Hm1,'ks:',H0,Hm2,'r^:')
legend('nominal Hurst exponent','PE','MPE')
xlabel('Hurst exponent','fontsize',12)
ylabel('mean','fontsize',12)

subplot(224),plot(H0,mse1,'ks:',H0,mse2,'r^:')
legend('PE','MPE')
xlabel('Hurst exponent','fontsize',12)
ylabel('100¡ÁRMSE','fontsize',12)

