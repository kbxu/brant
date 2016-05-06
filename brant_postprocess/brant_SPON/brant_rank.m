%-------Rank time series---------------%
function Rank = brant_rank(Array)
N = length(Array);
Rank = zeros(N,1);
SortArray = sort(Array);
for Tmp = 1 : N
    Rank(Tmp,1) = mean(find(SortArray == Array(Tmp)));
end
