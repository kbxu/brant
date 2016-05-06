% calculate kcc for a time series
%---------------------------------------------------------------------------
function ReHo = brant_f_reho(Array)

[N, K]= size(Array);
SR = sum(Array, 2); 
SRBAR = mean(SR);
S = sum(SR .^ 2) - N * SRBAR ^ 2;
ReHo = 12 * S / K ^ 2 / (N ^ 3 - N);
