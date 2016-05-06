clear,clc
close all

file_number=128;
f1='PE';f2='MPE';
file_in=strcat('E:\MATLAB\fGn_results\',f1,'_N',num2str(file_number),'_low01');
load(file_in)
H0=0.01:0.01:0.09;
H1=H;
Hm1=mean(H1);
mse1=100*sqrt((H0-Hm1).^2+var(H1));

file_in=strcat('E:\MATLAB\fGn_results\',f2,'_N',num2str(file_number),'_low01');
load(file_in)
H0=0.01:0.01:0.09;
H2=H;
Hm2=mean(H2);
mse2=100*sqrt((H0-Hm2).^2+var(H2));

for i=1:length(H0)
    g{i}=num2str(H0(i));
end

subplot(221),plot(H0,H0,'M',H0,Hm1,'ks:',H0,Hm2,'r^:')
legend('nominal Hurst exponent','PE','MPE')
xlabel('Hurst exponent','fontsize',12)
ylabel('mean','fontsize',12)

subplot(222),plot(H0,mse1,'ks:',H0,mse2,'r^:')
legend('PE','MPE')
xlabel('Hurst exponent','fontsize',12)
ylabel('100¡ÁRMSE','fontsize',12)

%===================================================================


file_in=strcat('E:\MATLAB\fGn_results\',f1,'_N',num2str(file_number),'_high09');
load(file_in)
H0=0.91:0.01:0.99;
H1=H;
Hm1=mean(H1);
mse1=100*sqrt((H0-Hm1).^2+var(H1));

file_in=strcat('E:\MATLAB\fGn_results\',f2,'_N',num2str(file_number),'_high09');
load(file_in)
H0=0.91:0.01:0.99;
H2=H;
Hm2=mean(H2);
mse2=100*sqrt((H0-Hm2).^2+var(H2));


for i=1:length(H0)
    g{i}=num2str(H0(i));
end

subplot(223),plot(H0,H0,'M',H0,Hm1,'ks:',H0,Hm2,'r^:')
legend('nominal Hurst exponent','PE','MPE')
xlabel('Hurst exponent','fontsize',12)
ylabel('mean','fontsize',12)

subplot(224),plot(H0,mse1,'ks:',H0,mse2,'r^:')
legend('PE','MPE')
xlabel('Hurst exponent','fontsize',12)
ylabel('100¡ÁRMSE','fontsize',12)

