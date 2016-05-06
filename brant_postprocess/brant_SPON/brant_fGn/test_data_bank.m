clear,clc
close all

file_number=150;
fn='PE';

file_out=strcat('E:\MATLAB\fGn_results\',fn,'_N',num2str(file_number));
%data_number=input('Pls input a index (1,2,or3)>');
data_number=input('Pls input a number(1,2,or 3)>');
switch data_number
    case 1
         file_in=strcat('E:\MATLAB\fGn_bank\data_fGn','_N',num2str(file_number));
         load(file_in)
    case 2
         file_in=strcat('E:\MATLAB\fGn_bank\data_fGn','_N',num2str(file_number),'_low01');
         load(file_in)
    case 3
         file_in=strcat('E:\MATLAB\fGn_bank\data_fGn','_N',num2str(file_number),'_high09');
         load(file_in)
end

%  load data_fGn_N256_high09.mat;
[M,N,L]=size(S);

H=zeros(M,L);
sigma=H;

wname='db4';
J=wmaxlev(N,wname);

% [b1,b2]  =  Truncated_Alpha(N);
for i=1:L
    for j=1:M
        s=S(j,:,i);
        s=squeeze(s);

%      [H(j,i),sigma(j,i)]=fBm_based(s);

%      [H(j,i),sigma(j,i)]=MPE0(s,N,b1,b2);

%       H(j,i)=periodogram_SF(s,N);

%      [H(j,i),sigma(j,i)]=wls_exact(s,J,wname);

%      [H(j,i),sigma(j,i)]=Whittle_estimator0(s,N);


      
          H(j,i) = periodogram_SF(s,N);

    end
end
% subplot(121),boxplot(H),grid on
% subplot(122),boxplot(H1),grid on
% 
% m=mean(H);s=std(H);
% % m1=mean(H1);s1=std(H1);
% 
% mse=var(H)+(m-(0.1:0.1:0.9)).^2
% mse1=var(H1)+(m1-(0.1:0.1:0.9)).^2

% 
% H0=0.1:0.1:0.9;
g=cell(1,L);
for i=1:L
    g{i}= num2str(H0(i));
end
        
boxplot(H,'labels',g,'sym','r.'),grid on
xlabel('Hurst exponent')
ylabel('estimated Hurst exponent')
% title('MPE')

%  save Whittle_N256 H sigma
%  save MPE_N256_high09 H sigma
% save fBm_N256_high09 H sigma

% save('E:\MATLAB\fGn_results\MPE_N400.mat' ,'H', 'sigma')
% save('E:\MATLAB\fGn_results\MPE_N400_low01.mat' ,'H', 'sigma')
% save('E:\MATLAB\fGn_results\MPE_N400_high09.mat' ,'H', 'sigma')
 
 switch data_number
    case 1
         save(file_out ,'H')
    case 2
         save(strcat(file_out,'_low01') ,'H')
    case 3
         save(strcat(file_out,'_high09') ,'H')
end

