function G = mainFunction(Data,Max_p,Max_q)
% Data is a matrix nxm,each colomn of which represents a time-series,and
% Max_p,Max_q, represent the order of y,x in model y=ay+bx+e,respectivity.

if nargin < 1
    % Rand model y=ay+bx+e
    Data  = rand(100,10);
    Max_p = 3;%Max order of y by autoregressive
    Max_q = 2;%Max order of x by regressive
end

display('**********Start to compute***********')
[n,m] = size(Data);
G     = zeros(m,m);

% Computer granger causality
for i = 1:m
    for j = 1:m
        x = Data(:,i);
        y = Data(:,j);
        
        if i~=j
            % i-->j
            [Fxy,F0,Attribution] = Granger(x,Max_q,y,Max_p);
            if Fxy > F0 %accepet null hypothesis
                fprintf(1,'%2d,----have---->, %2d\n',i,j);
                G(i,j) = 1;
            else
                fprintf(1,'%2d,----no---->, %2d\n',i,j);
                G(i,j) = 0;
            end
        end
    end
end

% Get rid of the false connect
display('-Pause:The following change connection by partial correlation-');
pause;
for i = 1:m
    for j = 1:m
        if i~=j && G(i,j) ~= 0
            for k = setdiff(1:m,[i,j])
                z = Data(:,k);
                [PCorr,qe,pe,qe3,qz3,pe3] = partial_Granger(x,y,Max_p,z,Max_q);
                fprintf(1,'i=%4d  j=%4d  k=%4d  PCorr=%8.4f\n',i,j,k,PCorr);
                if (abs(PCorr) < 0.05) %refuse null hypothesis
                    fprintf(1,'%2d---no----%2d\n',i,j);
                    G(i,j) = 0;
                    break;
                end
            end
        end
    end
end
%%%