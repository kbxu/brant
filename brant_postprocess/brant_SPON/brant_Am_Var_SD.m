function [Amplitude, Variance, SD] = brant_Am_Var_SD(TimeSeries)
%%
%%%%%%%%% *************************
% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Estimate the matrix of M in entropy maximum

% FORMAT function [amplitude, Variance, SD] = brant_Am_Var_SD(timeSeries)
%                 amplitude -- meam amplitude of the time series
%                 Variance --  amplitude variance of the time series
%                 SD --  amplitude std of the time series
%                 T -- the point length of time series
%
%
% Written by Yong Liu, Oct,2007
% Center for Computational Medicine (CMC),
% National Laboratory of Pattern Recognition (NLPR),
% Institute of Automation,Chinese Academy of Sciences (IACAS), China.

% E-mail: yliu@nlpr.ia.ac.cn
%         liuyong.81@gmail.com
% based on Matlab 2006a
% Version (1.0)
% Copywrite (c) 2007,
%%%% reference :
%%%% reference :ALzherimer Diease: evaluation of fMRI index as a marker
%%%%
%%%%%%%%% *************************
%%
if nargin < 1
    error('two arguments are required.');
elseif nargin == 1
    T = length(TimeSeries);
elseif nargin == 2
    %% do nothing
else
    error('pls check your input');
end

if T > length(TimeSeries);
    fprintf('you have input a wrong T');
    T = length(TimeSeries);
else
    timeSeries = TimeSeries(1:T);
end

Amplitude = mean(abs(detrend(timeSeries,'constant')));
Variance = var(abs(detrend(timeSeries,'constant')));
SD = std(abs(detrend(timeSeries,'constant')));
