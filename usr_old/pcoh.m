function [ph, lamb_ph] = pcoh(y, T, sr)
% PCOH does cross coherence across all frequencies.
% 	y       a matrix (each column represents a variable, size: L x M)
%   T       number of time points(default L)
%   sr      sampling rate in Hz. (default 1)
%	ph      the partial cross coherence 
%   lamb_ph the corresponding frequency
% see also partialMutInfo

[L, M] = size(y);
if nargin<3,        sr = 1;     end
if nargin<2,        T  = L;     end

L = 2*T - (2-mod(T,2)); % check length

% estimate of spectral density     
f_lamb = zeros(M, M, T);  
for p = 1:M
    for q = 1:M
        f_lamb(p,q,:) = cpsd(y(:,p), y(:,q), [], [], L)/2/pi;
    end
end
[tmp, lamb_ph] = cpsd(y(:,1), y(:,2), [], [], L, sr);

% partial coherence
ph = zeros(M, M, T);
for lamb = 1:T
   f_inv = inv(f_lamb(:, :, lamb));
  r_lamb = diag(diag(f_inv))^(-1/2)*f_inv*diag(diag(f_inv))^(-1/2);
    ph(:, :, lamb) = abs(r_lamb).^2;
end