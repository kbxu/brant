function [phi, pcoh] = norm_pmi(y, r)
% NORMPMI computes normal partial mutual information.
%       y       each column represents a discrete time series
%       r       parameter that modulates the smoothness of filter
%       phi     normal partial mutual information
%       pcoh    partial coherence
% Note:
%       1) linear filter,used by Bach & Jordan(2004),to reduce variance of
%       cross-spectral density: 
%           W(q) = (r * sqrt(2 * pi) / N) * exp(-Lambada(q)^2 * r^2 / 2)
%       where need R <= N^(-1/5)
%       2) stable estimate of the spectral density:
%       f_ij(Lambada(k)) = sum(W(q) * [Di(i)*conj(Di(j))](Lambada(K+q)) 
%       	for q = -inf : inf and Lambada(K) = 2*pi*K/N
%           where Di is the discrete Fourier coefficients (unit as column)
%           of Yi. there, f_ij is a M x M x length(K) matrix. each vector
%           f(i,j,Lambada) represents a estimate cross-spectral density
%           between i and j at a given frequency Lambada.
% Example:
%       y = rand(100, 4);
%       phi = norm_pmi(y);
% Ref:
%       Raymond Salvador etc. Undirected graphs of frequency-dependent
%       functional connectivity in whole brain network. 
% See also partialMutInfo, pcoh

% Write by: Hu Yong, 2010
% Revised:  2011-07-01

error(nargchk(1,2,nargin,'struct'));
[N, M] = size( y );
if nargin < 2,  r = N^(-1/5);   end
if r > N^(-1/5),    error('Wrong input ''r'' value: %f\n', r);  end

y = y - ones(N, 1)*mean(y); % null expectation
% d = disFour(y);           % discrete fourier coeeficients
d = fft(y, N)./N;
r=10;
% hermitian matrix
sh = zeros(M, M, N);
for n = 1:N,    sh(:,:,n) = d(n,:).'*conj(d(n,:));      end

% % liner filter --- non-periodic
% emat = zeros(M, M, N);      % estimate of the spectral density
% for n = 1:M
%     for m = 1:M
%         tmp = squeeze(sh(n, m, :));
%         wq  = zeros(N, N);
%         for k = 0:N-1
%             q = -k:(N-1-k);
%             wq(k+1,:) = r*sqrt(2*pi)*exp(-(2*pi*q/N).^2*r^2)/N;
%         end
%         emat(n,m,:) = wq*tmp;
%     end
% end

% % liner filter 2 --- periodic
% emat = zeros(M, M, N);      % estimate of the spectral density
%    q = -N:N;
%   wq = r*sqrt(2*pi)*exp(-(2*pi*q/N).^2*r^2)/N;
% for n = 1:M
%   for m = 1:M
%       tmp = zeros(2*N+1, N);
%       for k = 0:N-1
%           tmp(:,k+1) = sh(n,m,mod(k+q,N)+1);
%       end
%       emat(n,m,:) = wq*tmp;
%   end
% end

% liner filter 3 
   Q = 101; %  Q-point smoothing, Q must be a odd
emat = zeros(M, M, N);      % estimate of the spectral density
   q = -(Q-1)/2:(Q-1)/2;
  wq = r*sqrt(2*pi)*exp(-(2*pi*q/N).^2*r^2)/N;
for n = 1:M
    for m = 1:M
        emat(n, m, :) = myConv(squeeze(sh(n,m,:)),wq);
%         emat(n, m, :) = ifft(fft(squeeze(sh(n,m,:))).*wq');
%         emat(n, m, :) = convn(squeeze(sh(n,m,:)), wq, 'same');
%         emat(n, m, :) = smooth(squeeze(sh(n,m,:)),10);
    end
end


% partial coherence
pcoh = zeros(M, M, N);
for n = 1:N
    inv_emat = inv(emat(:,:,n)); % intermediate variable
    r_lambda = -diag(diag(inv_emat))^(-1/2)*inv_emat*...
        diag(diag(inv_emat))^(-1/2);
    pcoh(:,:,n) = abs(r_lambda).^2;
end

% partial mutual information
delta = zeros(M, M);
for n = 1:N
    delta = delta - log(1-pcoh(:,:,n))/N;
end

phi = (1-exp(-2*delta)).^(1/2);


% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
function d = disFour( y )
% DISFOUR computes the discrete fourier coefficients of time series
% d(k) = sum(y(t)*exp(-i*k*t))/N, for t = 0:(N-1) and k = 0:(N-1)

y = y(:);   % transform to a column
n = length(y);
wn = 0:n-1;
wn = wn'*wn;
d  = exp(-i*wn)*y/n;

function y = myConv(x, wq)
% periodogram conv
N = length(x);  M = length(wq);
y = zeros(1,N);
for n = 1 : N
    id = mod(n + (-(M-1)/2:(M-1)/2), N);
    id(~logical(id)) = N;
    y(n) = sum(x(id).*wq')/M;
end