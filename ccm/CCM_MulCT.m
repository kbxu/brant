function [h, cp] = CCM_MulCT(p, q, Type)
%Correction of Multiple Comparison Test.
% False Discovery Rate(FDR) is a approach to the multiple comparisons problem. 
% Instead of controlling the chance of any false positives(as Bonferroni or 
% random field methods do), FDR controls the expected proportion of false 
% positives among suprathreshold voxels. A FDR threshold is determined from 
% the observed p-value distribution, and hence is adaptive to the amount of 
% signal in your data.
%
% Usage:
%  [h, cp] = CCM_MulCT(p, q, Type);
%
% Required Input:
%   p -	A vector or matrix (two dimensions or more) containing the
%    	p-value of each individual test in a family of tests.
%
% Optional Inputs:
%   q	 - The desired false discovery rate.  {default: 0.05}
%   Type - ['FDR' | 'FDR2' | 'BONF' | 'FWER'].{default: 'FDR'}
%		   'FDR'  - False Discovery ratio, p-value threshold based on 
%					independence or positive dependence.
%          'FDR2' - FDR when nonparametric p-value threshold.
%		   'BONF' - Bonferroni correction.
%          'FWER' - family-wise error.
%
% Outputs:
%   h       - A binary vector or matrix of the same size as the input "p".
%   cp  	- All p-values less than or equal to cp are significant.
%
% References:
%     Benjamini, Y. & Hochberg, Y. (1995) Controlling the false discovery
%     rate: A practical and powerful approach to multiple testing. Journal
%     of the Royal Statistical Society, Series B (Methodological). 57(1),
%     289-300.
%
% Example:
%   [dummy, pnull]  = ttest(randn(12,15)); %15 tests where the null hypothes is true
%   [dummy, peffect]= ttest(randn(12,5)+1);%5 tests where the null hypothesis is false
%   [h, cp] = CCM_MulCT([pnull, peffect], 0.05, 'FDR2');(cp maybe FDR2 >= BONF >= FDR)


% Written by Yong Liu, Oct,2007
% Revised by Hu Yong, Mar,2011
% Center for Computational Medicine (CMC),
% National Laboratory of Pattern Recognition (NLPR),
% Institute of Automation,Chinese Academy of Sciences (IACAS), China.
% E-mail: yliu@nlpr.ia.ac.cn
%         liuyong.81@gmail.com
% based on Matlab 2006a
% Version (1.0) Copywrite (c) 2007,
% See also

% p-value check
if(nargin<1),  error('You need to provide a vector or matrix of p-values.');
else
if(isscalar(p)),    error('Requires vector or matrix as first input.');  end    
if(any(p<0 | p>1)), error('p-values must be in [0,1]');                  end
end

% default setting
if(nargin<2),    q = 0.05;     end
if(nargin<3),    Type = 'FDR'; end
if(~isscalar(q) | q<=0 | q>=1),  error('q-value must be a scalar in (0,1).'); end

% determine if actual significance exceeds the desired value.
num = numel(p);
switch(upper(Type))
case {'FDR', 'FDR2'}%False Discovery Rate
	if(strcmp(Type, 'FDR')),
		de = sum(1./(1:num));%denominator
	else
		de = 1;
	end

    % sort the original p-values
    p_sort = sort(p(:));
    thresh = (1:num)'*q/num/de;
	maxid  = find(p_sort <= thresh, 1, 'last');%find greatest significant p-value
	if(isempty(maxid))
		cp = 0;
		h  = p*0;
		fprintf('*  Corrected p-value does not exist. \n');
	else
		cp = p_sort(maxid);
		h  = double(p <= cp);
	end
	
case 'BONF'%Bonferroni correction
    thresh = q/num;
    I = find(p <= thresh, 1, 'last');
	if(isempty(I))
		cp = 0;
		h  = p*0;
		fprintf('*  Corrected p-value does not exist. \n');
	else
		cp = thresh;
		h  = double(p <= cp);
	end
    
case 'FWER'
    fprintf('*  Still under prepare.\n');
    h = [];cp = [];
	
otherwise
    error('Invald type.');
end