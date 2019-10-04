function [corrected_p_val, sts] = brant_MulCC(p_vector,alpha,Type)
% correction of Multiple comparison test
% FORMAT [corrected_p_val] = brant_MulCC(P_Values,Type,alpha)
%   performs a
%   set of corrected  to determine the Minimum P values which is
%   significant in the multiple compration

% input P_Values --- the P_values of the hypothesis test
%       alpha ---- the threshold of significance, Default value = 0.05
%       Type --- the method for Multiple comparison test correction
%                there are three multiple method can be selected {'False
%                Discovery ratio','Bonferroni correction','family-wise error '}
%                the default one is 'FDR'
% Output corrected_p_val ---- the corrected P_values
%
% Refers:

% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Written by Yong Liu, Oct,2007
% Center for Computational Medicine (CMC),
% National Laboratory of Pattern Recognition (NLPR),
% Institute of Automation,Chinese Academy of Sciences (IACAS), China.

% E-mail: yliu@nlpr.ia.ac.cn
%         liuyong.81@gmail.com
% based on Matlab 2006a
% Version (1.0)
% Copywrite (c) 2007,
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% see also


if nargin < 1,
    error('Requires at least one input arguments');
end

[I, J] = size(p_vector);
if ((I == 1) && (J == 1))
    error('Requires matrix first  inputs.');
end

if nargin < 2
    alpha = 0.05;
end

if nargin < 3
    Type = 'fdrID';
end

if (numel(alpha) > 1)
    error('ALPHA must be a scalar.');
end

if ((alpha <= 0) || (alpha >= 1))
    error('ALPHA must be between 0 and 1.');
end

% Determine if the actual significance exceeds the desired significance
Num_comparison = length(p_vector);
switch Type
    case 'fdrN' %% false discovery rate not independent
        denominator = sum(1 ./ (1:Num_comparison));

        % sort the original p values
        p_vector = sort(p_vector);
        if size(p_vector,1)~=1
            p_vector = p_vector';
        end
        P_reference = [1:Num_comparison] * alpha / Num_comparison / denominator;
        i = find(p_vector <= P_reference, 1, 'last');

        if ~isempty(i)
            corrected_p_val = p_vector(i);
            sts = 1;
        else
            corrected_p_val = -1;
            sts = -1;
        end

    case 'bonf'
        P_reference = alpha / Num_comparison;
        i = p_vector <= P_reference;

        if any(i)
            corrected_p_val = P_reference;
            sts = 1;
        else
            corrected_p_val = -1;
            sts = -1;
%             fprintf('\n\tCorrected P value does not exist. \n');
        end
    case 'fdrID'    % independent    
        denominator = 1;

        % sort the original p values
        p_vector = sort(p_vector);
        if size(p_vector,1)~=1
            p_vector = p_vector';
        end
        P_reference = [1:Num_comparison] * alpha / Num_comparison / denominator; %#ok<*NBRAK>
        i = find(p_vector <= P_reference, 1, 'last');
        
        if ~isempty(i)
            sts = 1;
            corrected_p_val = p_vector(i);
        else
            sts = -1;
            corrected_p_val = -1;
        end
%     case 'FWE'
%         fprintf('still under prepare');
    otherwise
        error('there is no such correction type');
end

if (nargout > 2),
    error('The max nargout is one P value after Multiple comparison test correction')
end
