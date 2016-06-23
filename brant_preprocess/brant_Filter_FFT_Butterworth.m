function [TC_filtered] = brant_Filter_FFT_Butterworth(TC, threshold_highpass, threshold_lowpass, SF, type)
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

T = size(TC, 1); % T: the length of time courses; N: the number of time courses
NyquistFreq = SF/2; % Nyquist frequency
TC_mirror = TC(end:-1:1,:); % the mirror of TC
TC_extend = [TC_mirror; TC; TC_mirror]; % extend the time courses in periodical way

if type == 0
    % FFT filter
    % add the length of TC_extend in order to be 2^n
    p = 2^nextpow2(3*T) - 3*T;
    if floor(p/T) == 0
        TC_extend = [TC_extend; TC(1:p,:)];
    elseif floor(p/T) > 0
%         fprintf('\n please check \n');
        for k = 1:floor(p/T)
            if mod(k,2) ~= 0
                TC_extend = [TC_extend; TC];
            else
                TC_extend = [TC_extend; TC_mirror]; %#ok<*AGROW>
            end
        end
        if mod(k,2) == 0
            TC_extend = [TC_extend; TC(1:p-k*T,:)];
        else
            TC_extend = [TC_extend; TC_mirror(1:p-k*T,:)];
        end        
    end
    TC_FFT = fft(TC_extend);
    len_tc_ext = size(TC_extend, 1);
    % high pass filtering
    if threshold_highpass == -1
    elseif threshold_highpass > 0
        N_high = round(len_tc_ext * threshold_highpass / SF);
        TC_FFT(1:N_high,:) = 0;
    end
    % low pass filtering
    if threshold_lowpass == -1
    elseif threshold_lowpass > 0
        cut_tmp = min(NyquistFreq, threshold_lowpass);
        N_low = round(len_tc_ext * cut_tmp / SF);
        TC_FFT(N_low:end,:) = 0;
    end
    % inverse FFT
    Z = ifft(TC_FFT);
    temp = 2*real(Z);
    TC_filtered = temp(T+1:2*T,:);
elseif type > 0
    error('butterworth filter is not available now');
    % % butterworth filter
    % [b a] = butter(4,[0.01/0.25 0.08/0.25]); % 4th butterworth bandpass (0.01Hz - 0.08Hz) filter
    % [y t] = impz(b,a,[]);
    % LP_butter = conv(x,y);
    % % figure; plot(y);
    % % figure; plot(abs(fft(y,256)));
    % % LP_butter = filter(b,a,x);
end
