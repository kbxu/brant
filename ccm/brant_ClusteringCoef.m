function [Cp_Global, Cp_Nodal] = brant_ClusteringCoef(gMatrix)


N = size(gMatrix, 1);
gMatrix(1:(N+1):end) = 0;

Cp_Nodal = zeros(N, 1);
gBin = gMatrix > 0;%Ensure binary network
for m = 1:N
    temp = gBin(gBin(m, :), gBin(m, :));
    Num = size(temp, 1);
    if(Num > 1),
        Cp_Nodal(m) = sum(temp(:)) / (Num * (Num - 1));
    end
end

Cp_Global = mean(Cp_Nodal);
