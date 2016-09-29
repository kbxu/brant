function [ERN] = brant_simu_symRand(SymMatrix)
% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

% FORMAT function [ERN] = brant_simu_symRand(SymMatrix)
% input symMatrix--- Symmetry binary connect matrix
% Output ERN ---- Rand network has the same degree distribution with Matrix
%       
% Refers: 
% Maslov S, Sneppen K (2002) Specificity and stability in topology of
% protein networks. Science 296:910-913.
% Sporns O, Zwi JD (2004) The small world of the cerebral cortex.
% Neuroinformatics 2:145-162.
% Achard and Bullmore(2007) Efficiency and cost of economical brain
% functional networks. Plos computational biology. 3:174-183

% +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Written by Yong Liu, Oct,2007
% Brainnetome Center 
% National Laboratory of Pattern Recognition (NLPR),
% Institute of Automation,Chinese Academy of Sciences (IACAS), China.

% E-mail: yliu@nlpr.ia.ac.cn 
%         liuyong.81@gmail.com
% based on Matlab 2006a
% Version (1.0)
% Copywrite (c) 2007, 
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% see also  Span_Simu_symRandTime



% % temp = sum(SymMatrix);
% % [I J] = find(temp==1);

[i1,j1]=find(SymMatrix);

[Ne, aux]=size(i1);
clear aux;

Time = 0;
while Time<1
    e1=1+floor(Ne*rand);
    e2=1+floor(Ne*rand);
    v1=i1(e1);
    v2=j1(e1);
    v3=i1(e2);
    v4=j1(e2);
    if (sum(SymMatrix(v1,:))==1) || (sum(SymMatrix(v3,:)) == 1)  || (sum(SymMatrix(:,v2)) == 1)  || (sum(SymMatrix(:,v4))==1)
        %% do nothing
    else
        if (v1<v3)&(v1<v4)&(v2<v4)&(v2>v3)&((v1~=v3))&((v2~=v4))

            if (SymMatrix(v1,v4)==0)&(SymMatrix(v3,v2)==0)
                Time = Time +1;

                SymMatrix(v1,v4)=SymMatrix(v1,v2);
                SymMatrix(v3,v2)=SymMatrix(v3,v4);

                SymMatrix(v1,v2)=0;
                SymMatrix(v3,v4)=0;
                

                i1(e1)=v1;
                j1(e1)=v4;
                i1(e2)=v3;
                j1(e2)=v2;
            end
        end
    end
end

X = triu(SymMatrix,1);
ERN= X + X';
