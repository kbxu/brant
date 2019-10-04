function [p_thres, sts] = brant_MulCC(p_vector, alpha, mulcc_type)
% correction of Multiple comparison test
% input:
% p_vector: a vector or matrix of p value
% alpha: level of FWER or FDR
% mulcc_type: can be fdrN, bonf and fdrID
% output:
% p_thres: threshold of p for the controled level, p values <= p_thres are
% considered survive the multiple comparison correction.
% sts: -1 for no survival, 1 for there exist lucky ones


if nargin ~= 3
    error('Requires 3 input arguments');
end

if (numel(alpha) > 1)
    error('ALPHA must be a scalar.');
end

if ((alpha <= 0) || (alpha >= 1))
    error('ALPHA must be between 0 and 1.');
end

% number of input elements
num_comp = numel(p_vector);
p_vector = reshape(p_vector, [num_comp, 1]);
switch mulcc_type
    case {'fdrN', 'fdrID'} 
        % fdrN -- false discovery rate for not independent input
        % fdrID -- false discovery rate for independent input
        if strcmp(mulcc_type, 'fdrN')
            denominator = sum(1 ./ (1:num_comp));
        else
            denominator = 1;
        end

        % sort the original p values with ascending order
        p_vector = sort(p_vector, 'ascend');
        p_ref = (1:num_comp) * alpha / num_comp / denominator;
        
        idx = p_vector > p_ref;
        if all(idx)
            % all p values are greater than the threshold
            p_thres = -1;
            sts = -1;
        else
            p_thres_idx = find(idx, 1, 'first');
            if p_thres_idx == 1
                % the minimum p is greater than the threshold
                % while some p larger passed the threshold
                p_thres = -1;
                sts = -1;
            else
                p_thres = p_ref(p_thres_idx - 1);
                sts = 1;
            end
        end
    case 'bonf'
        p_ref = alpha / num_comp;
        idx = p_vector <= p_ref;

        if any(idx)
            p_thres = p_ref;
            sts = 1;
        else
            p_thres = -1;
            sts = -1;
        end
    otherwise
        error('there is no such correction type');
end
