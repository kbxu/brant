function [newQ,newPartion] = fine_tune(Q,qMatrix,Partion)
% fine_tune is fine-tuning a partition of graph
% Input:
%    Q      	old modularity
%   qMatrix     
% Record

                                        %-- subgraph uncheck(1) is divisible
        % Fine-tuning
    	subQ2        = subQ;            %perpare
        submm(1:(subnum+1):end) = 0;    %modify to enable fine-tuning
        indg         = sparse(subnum,1);%array of unmoved indices
        iiter        = subind;          %index of iteration
        
        while(any(indg))                %start iteration
            qiter    = subQ2 - 4*iiter.*(submm*iiter);%it equivalent to:
                                        %for i = 1:subnum
                                        %    iiter(i)=-iiter(i);qiter(i)=iiter'*submm*iiter;iiter(i)=-iiter(i);
                                        %end
            subQ2    = max(qiter.*indg);
            Imax     = (qiter == subQ2);
            iiter(Imax) = -iiter(Imax);
            indg(Imax)  = NaN;
            % success after fine-tunig
            if subQ2 > subQ
                subQ    = subQ2;
                subind  = iiter;
            end
        end
        
        % Determine
        if abs(sum(subQ)) == subnum     %fail to split uncheck(1)
            uncheck(1)  = [];
        else
            num         = num +1;
            C(subg(subind == 1)) = uncheck(1);
            C(subg(subind == -1)) = num;
            uncheck     = [num,uncheck];
        end
    else
        uncheck(1)  = [];               %negative contribution
    end