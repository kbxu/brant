function stats = brant_ttest2_permutation(data,group_ID,niter)
%%% this function is revised from Enrico Glerean - enrico.glerean@aalto.fi - 2014-01-13
%%% for more info see https://git.becs.aalto.fi/eglerean/bramila.git
%% let's do some input validation first
measure_num = size(data,2);   % number of measures
if(size(group_ID,2) ~= measure_num)
    error('Mismatched number of measures: the number of columns of data variable  should match the number of columns of the design variable')
end
if(size(group_ID,2) ~= 1)
    error('The design variable should only contain 1 row')
end
%  group IDs
g1 = find(group_ID==1);
g2 = find(group_ID==2);
subj_num = size(data,1);
if((length(g1)+length(g2))~=subj_num)
    error('The measure variable should only contain numbers 1 and 2; also pls check if the subject number = length(group_ID)')
end

if(niter<=0)
    disp('The variable niter should be a positive integer, function will continue assuming niter=5000')
    niter=5000;
end
stats.tvals=permutaion_T(data,g1,g2);
% computing pvalues

pvals=zeros(measure_num,2);
for n=1:measure_num % we treat each comparison independently
%     fprintf('Start to perform permutation test\n');
    pvals(n,:) = permutaion_pval(data(:,n),g1,g2,niter,stats.tvals(n));
end
stats.pvals=pvals;
end

function tval= permutaion_T(data,g1,g2)
    % helper function similar to matlab function ttest2.m for the case of
    % groups with difference variance
    xnans = isnan(data(g1,:));
    if any(xnans(:))
        nx = sum(~xnans,1);
    else
        nx = size(data(g1,:),1); 
    end
    ynans = isnan(data(g2,:));
    if any(ynans(:))
        ny = sum(~ynans,1);
    else
        ny = size(data(g2,:),1); % a scalar, => a scalar call to tinv
    end

    difference = nanmean(data(g1,:),1) - nanmean(data(g2,:),1);
    
    s2x = nanvar(data(g1,:),[],1);
    s2y = nanvar(data(g2,:),[],1);
    s2xbar = s2x ./ nx;
    s2ybar = s2y ./ ny;
    se = sqrt(s2xbar + s2ybar);
    if(any(se == 0) || any(isnan(se)))
        error('Group variance seems to be null or NaN, please check your data')
    end
    tval = difference ./ se;

end

function pval = permutaion_pval(data,g1,g2,niter,tval)
    iter_res=zeros(niter,1);
    data_len = length(data);
    for iter=1:niter
        perm=randperm(data_len);
        % one could add a test to see that they are indeed permuted
        temp=data(perm);
        iter_res(iter)=permutaion_T(temp,g1,g2);
    end
    cdf_len =1000;
    if(niter>5000)
        cdf_len = round(1000*niter/5000);
    end
    [fi xi]=ksdensity(iter_res,'function','cdf','npoints',cdf_len);
    
    % trick to avoid NaNs, we approximate the domain of the CDF between
    % -Inf and Inf using the atanh function and the eps matlab precision
    % variable
    
    pval_left=interp1([atanh(-1+eps) xi atanh(1-eps)],[0 fi 1],tval); 
    pval_right=1-pval_left;
    pval=[pval_right pval_left];
end
