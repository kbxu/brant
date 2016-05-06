function [ROI, Num_ROI]  = brant_findneigbor(ROI_seed,Radius,type)

%%% select the voxel according to the ROI_seed
%%% you can select ''BOX' or 'Sphere' to get the ROI
% FORMAT
%function [ROI, Num_ROI] =  brant_findneigbor(ROI_seed,Radius,Mask,vargin)
% input  ROI_seed ---  the coordidate of seed regions
%           Radius -- the Radius, it is a value of voxel size * a integer
%            Mask -- a 0 or 1 binary matrix
%            vargin --- 'Box' or 'Sphere'
% Output ROI ---  the regions of interest
%             Num_ROI -- the number of voxels in the ROI
% Refers:
%  +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Written by Yong Liu, Oct,2007
% Brainnetome Center,
% http://www.brainnetome.org/yongliu
% National Laboratory of Pattern Recognition (NLPR),
% Institute of Automation,Chinese Academy of Sciences (CASIA), China.

% E-mail: yliu@nlpr.ia.ac.cn
%         liuyong.81@gmail.com
% based on Matlab 2006a
% Version (1.0)
% Copywrite (c) 2007,
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% see also



ROI=[];

x = ROI_seed(1);
y = ROI_seed(2);
z = ROI_seed(3);
TP = ceil(1.2*Radius);
M = 10*x;
N = 10*y;
P = 10*z;
if Radius < sqrt(2)
    ROI = [x y z;x-1 y z; x y-1 z;x y z-1;x+1 y z; x y+1 z; x y z+1];
elseif Radius >= sqrt(2) && Radius < sqrt(3)
    
    ROI = [x y z;x-1 y z; x y-1 z;x y z-1;x+1 y z; x y+1 z; x y z+1];
    ROI = [ROI;x-1 y-1 z;x-1 y+1 z; x-1 y z-1;x-1 y z+1;...
        x+1 y-1 z;x+1 y+1 z; x+1 y z-1;x+1 y z+1;...
        x y-1 z-1;x y-1 z+1; x y+1 z-1;x y+1 z-1];
    
elseif Radius >= sqrt(3) && Radius < 2
    
    ROI = [x y z;x-1 y z; x y-1 z;x y z-1;x+1 y z; x y+1 z; x y z+1];
    ROI = [ROI;x-1 y-1 z;x-1 y+1 z; x-1 y z-1;x-1 y z+1;...
        x+1 y-1 z;x+1 y+1 z; x+1 y z-1;x+1 y z+1;...
        x y-1 z-1;x y-1 z+1; x y+1 z-1;x y+1 z-1];
    ROI = [ROI;x-1 y-1 z-1;x-1 y-1 z+1; x-1 y+1 z-1;x-1 y+1 z+1;...
        x+1 y-1 z-1;x+1 y-1 z+1; x+1 y+1 z-1;x+1 y+1 z+1];
else
    switch type
        case 'box'
            for i=x-TP:x+TP
                if(i>0 && i<=M)
                    for j= y-TP:y+TP
                        if(j>0 && j<=N)
                            for k=z-TP:z+TP
                                if (k>0 && k<=P)
                                    temp=[i j k];
                                    if abs(i-x)+ abs(j-y)+abs(k-z)<=Radius
                                        ROI=[ROI; temp];
                                    end
                                end
                            end
                        end
                    end
                end
            end
            
        case 'sphere'
            
            for i=x-TP:x+TP
                if(i>0&&i<=M)
                    for j= y-TP:y+TP
                        if(j>0&&j<=N)
                            for k=z-TP:z+TP
                                if (k>0&&k<=P)
                                    temp=[i j k];
                                    
                                    if norm(temp-ROI_seed)<= Radius
                                        ROI=[ROI; temp]; %#ok<*AGROW>
                                    end
                                    
                                end
                            end
                        end
                    end
                end
            end
            
        otherwise
            disp('Plese enter the right repression');
            return;
    end
end
Num_ROI = size(ROI,1);
