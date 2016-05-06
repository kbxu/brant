clear,clc
close all

file_number=512;
f1='Whittle';f2='WLS';f3='fBm';f4='MPE';
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

file_in=strcat('E:\MATLAB\fGn_results\',f3,'_N',num2str(file_number),'_low01');
load(file_in)
H0=0.01:0.01:0.09;
I=H<0;
H(I)=0;
H3=H;
Hm3=mean(H3);
mse3=100*sqrt((H0-Hm3).^2+var(H3));

file_in=strcat('E:\MATLAB\fGn_results\',f4,'_N',num2str(file_number),'_low01');
load(file_in)
H0=0.01:0.01:0.09;
I=H<0;
H(I)=0;
H4=H;
Hm4=mean(H4);
mse4=100*sqrt((H0-Hm4).^2+var(H4));

subplot(221),plot(H0,H0,'M',H0,Hm1,'bo:',H0,Hm2,'gs:',H0,Hm3,'kd:',H0,Hm4,'r^:')
legend('nominal Hurst exponent','Whittle','WLS','fBm','MPE')
xlabel('Hurst exponent','fontsize',12)
ylabel('mean','fontsize',12)

subplot(222),plot(H0,mse1,'bo:',H0,mse2,'gs:',H0,mse3,'kd:',H0,mse4,'r^:')
legend('Whittle','WLS','fBm','MPE')
xlabel('Hurst exponent','fontsize',12)
ylabel('100¡ÁRMSE','fontsize',12)

%=====================================================================

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

file_in=strcat('E:\MATLAB\fGn_results\',f3,'_N',num2str(file_number),'_high09');
load(file_in)
H0=0.91:0.01:0.99;
I=H>1;
H(I)=1;
H3=H;
Hm3=mean(H3);
mse3=100*sqrt((H0-Hm3).^2+var(H3));

file_in=strcat('E:\MATLAB\fGn_results\',f4,'_N',num2str(file_number),'_high09');
load(file_in)
H0=0.91:0.01:0.99;
I=H>1;
H(I)=1;
H4=H;
Hm4=mean(H4);
mse4=100*sqrt((H0-Hm4).^2+var(H4));

subplot(223),plot(H0,H0,'M',H0,Hm1,'bo:',H0,Hm2,'gs:',H0,Hm3,'kd:',H0,Hm4,'r^:')
legend('nominal Hurst exponent','Whittle','WLS','fBm','MPE')
xlabel('Hurst exponent','fontsize',12)
ylabel('mean','fontsize',12)

subplot(224),plot(H0,mse1,'bo:',H0,mse2,'gs:',H0,mse3,'kd:',H0,mse4,'r^:')
legend('Whittle','WLS','fBm','MPE')
xlabel('Hurst exponent','fontsize',12)
ylabel('100¡ÁRMSE','fontsize',12)
