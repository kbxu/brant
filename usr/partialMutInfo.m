function phi = partialMutInfo(y, sr, lambmin, lambmax)
%PARTIALMUTINFO gets the partial mutual information "phi".
%       y       a matrix (each column represents a variable, size: L x M)
%       ======  varargin: sr, lambmin, lambmax  ======
%       sr      sampling rate in Hz. (default 1)
%       lambmin the frequency min boundary in Hz. (default 0)
%       lambmax the frequency max boundary in Hz. (default 1/2)
% Note:
%       The analysis operates IN BETWEEN these boundaries, lambmin=0, and
%       The maximum lambdamax is half the sampling rate (Nyquest frequency) 
%       The default (if sr, lambdamin, lambdamax are not specified) is to
%       use the whole frequency range.
% Example:
%       y   = rand(100,5);
%       phi = partialMutInfo(y);
%       phi = partialMutInfo(y, 0.6, 0, 1);
% Ref : 
%       1) Raymond Salvador etc. Undirected graphs of frequency-dependent
%          functional connectivity in whole brain network. 2005-May.
%       2) Dongli Zhou etc. MATLAB toolbox for functional connectivity.
% Write by: Dongli Zhou
% Revised : Hu Yong, 2011-06-29

error(nargchk(1, 4, nargin), 'struct');

% default-define-value
if nargin < 4,  lambmax = 1/2;      end
if nargin < 3,  lambmin = 0;        end
if nargin < 2,       sr = 1;        end
lambmin = lambmin/(sr/2);
lambmax = lambmax/(sr/2);

[L, M] = size(y); % M is the number of variables
T  = fix(L/2)+1;  % time points

% estimate of spectral density     
f_lamb = zeros(M, M, T);  
for p = 1:M
    for q = 1:M
        f_lamb(p,q,:) = cpsd(y(:,p), y(:,q), [], [], L)/2/pi;
    end
end
f_lamb = cat(3, conj(f_lamb(:,:,end:-1:2)), f_lamb);

% partial coherence
pcoh = zeros(M, M, 2*T-1);
for lamb = 1:(2*T-1)
   f_inv = inv(f_lamb(:, :, lamb));
  r_lamb = diag(diag(f_inv))^(-1/2)*f_inv*diag(diag(f_inv))^(-1/2);
    pcoh(:, :, lamb) = abs(r_lamb).^2;
end

% specify the frequency band
[tmp, w] = cpsd(y(:,1), y(:,2), [], [], L, sr);
lambf    = zeros(2*T-1, 1);
lambf(T:end) = w;
lambf(1:T-1) = -w(end:-1:2);

lw = sum(lambf(T:end)<lambmin);
up = sum(lambf(T:end)>lambmax);

if lw==0
    pcoh_fb = pcoh(:,:,up+1:(2*T-1-up));
else
    pcoh_fb = pcoh(:,:,[up+1:(T-lw), (T+lw):(2*T-1-up)]);
end

% partial mutual information
delta = zeros(M, M);
for p = 2:M
    for q = 1:p-1
        delta(p,q) = -mean(log(1-pcoh_fb(p,q,:)))/2/pi;
    end
end
delta = delta + delta';
% % the same as ==>
% for p = 1:size(pcoh_fb,3)
%     delta = delta - log(1-pcoh_fb(:,:,p));
% end
% delta = delta./(2*pi*size(pcoh_fb,3));

% normalized
phi   = (1-exp(-2*delta)).^(1/2);
% pcoh  = pcoh(:,:,T:end); % interception a half ==> partial coherence