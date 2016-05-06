function [AmplitudeF,PowerSpectrum,ALFF]  = brant_meanPowerSpectrum(TS,FS,BP);
%%
%%%%%%%%% *************************
% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Estimate the power spectrum of a time series

% FORMAT function [AmplitudeF,PowerSpectrum,ALFF]  =
%                                           Span_meanPowerSpectrum(TS,FS,BP);
%                 
%                 AmplitudeF --- meam Amplitude of the time series
%                 PowerSpectrum -- meam PowerSpectrum of the time series
%                 ALFF  --  mean sqrt of PowerSpectrum of the time series
%                 at BP.
%%%         Input
%                 TS --- time series
%                   FS --- 1/TR, the sample frequency
%                   Bp = [Low Hig] frequency
% input parameters
% the columns of TC is the time courses which need to be filtered
% threshold_highpass is the cut threshold of high-pass filter.
% threshold_highpass = -1 for no high-pass filtering
% threshold_lowpass is the cut threshold of low-pass filter.
% threshold_lowpass = -1 for no low-pass filtering
% both specified means the band-pass filter
% SF: sample frequency in Hz
% type: the type of filter. type = 0 : FFT; type = n (n>0) : nth Butterworth
% output parameters
% TC_filtered: the filtered time courses (columns of matrix)

% Written by Yong Liu, Sep,2007 revised on April, 2010
% Brain Imaging and Cognitive Disorders (BICD),
% National Laboratory of Pattern Recognition (NLPR),
% Chinese Academy of Sciences (CAS), China.
% E-mail: yliu@nlpr.ia.ac.cn || yliugmj@gmail.com
% Copywrite (c) 2007,
%%%% reference :
%%%% see Zang YF et al.
% Altered baseline brain activity in children with ADHD revealed by resting-state functional MRI.
% Brain Dev. 2007 Mar;29(2):83-91. Epub 2006 Aug 17

err = 1e-10;
if nargin < 3
    error('two arguments are required by PIMF.');
elseif nargin == 2
   BP = [0.01, 0.08];
end

% % if size(TS,4)~=T
% %     error('pls check you files');
% % end

%     Y = fft(TS,N);
% %     Y = Span_Filtered_Bandpass(TS,Mask,Low_F,High_F,Sample_F)
%     Pyy = Y.* conj(Y) / N;
%
%     Low = floor(BP(1)/FS*N);
%     Hig = ceil(BP(2)/FS*N);
%     Pyy = Pyy(Low:Hig);

threshold_lowpass = BP(2);
threshold_highpass = BP(1);

if size(TS,1) == 1
    TS = TS';
end
TS = detrend(TS);
[T] = length(TS); % T: the length of time courses; N: the number of time courses
NyquistFreq = FS/2; % Nyquist frequency
TS_mirror = TS(end:-1:1,:); % the mirror of TC

TS_extend = [TS_mirror; TS; TS_mirror];

% extend the time courses in periodical way


% FFT filter
% add the length of TC_extend in order to be 2^n
p = 2^(ceil(log2(3*T))) - 3*T;
if floor(p/T) == 0
    TS_extend = [TS_extend; TS(1:p,:)];
elseif floor(p/T) > 0
    %         fprintf('\n please check \n');
    for k = 1:floor(p/T)
        if mod(k,2) ~= 0
            TS_extend = [TS_extend; TS];
        else
            TS_extend = [TS_extend; TS_mirror];
        end
    end
    if mod(k,2) == 0
        TS_extend = [TS_extend; TS(1:p-k*T,:)];
    else
        TS_extend = [TS_extend; TS_mirror(1:p-k*T,:)];
    end
end
TS_FFT = fft(TS_extend);

% high pass filtering
if threshold_highpass == -1
elseif threshold_highpass > 0
    N_high = round(length(TS_extend) * threshold_highpass / FS);
    TS_FFT(1:N_high,:) = 0;
end
% low pass filtering
if threshold_lowpass == -1
elseif threshold_lowpass > 0
    N_low = round(length(TS_extend) * threshold_lowpass / FS);
    TS_FFT(N_low:end,:) = 0;
end
%Get the amplitude only in one of the symmetric sides after FFT
Temp = abs(TS_FFT);
AmplitudeF = mean(Temp(N_high:N_low));
%Get the Power Spectrum, double it because single-sided amplitude
%spectrum
Temp = 2*(Temp.*Temp)/T;
PowerSpectrum = mean(Temp(N_high:N_low));
% get the ALFF 

Temp = sqrt(Temp);
ALFF = sum(Temp)/(N_low-N_high+1);
