clear,clc
close all

M=1000;
N=128;
sigma=1;

% H0=0.1:0.1:0.9;
% H0=0.01:0.01:0.09;
 H0=0.91:0.01:0.99;


L=length(H0);

S=zeros(M,N,L);
for i=1:L
    H=H0(i);
    for j=1:M
        s=fGn_Davies(H,sigma,N);
        S(j,:,i)=s;
    end
end

save('E:\MATLAB\fGn_bank\data_fGn_N128_high09.mat', 'S','H0')
% save data_fGn_N400_low01 S H0
% save data_fGn_N400_high09 S H0

