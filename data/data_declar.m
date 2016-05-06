function data_declar
%data_declar is desiged to data declaration

% AAL_ROI_2x2x2.mat		==> AAL(2x2x2,116)	
%   variable name: roi, 
%   fieldname:
%             fname, dim, volsize, volid, areaname, the last two are cell array
%
% AAL_ROI_3x3x3.mat     ==> AAL(3x3x3,116)
%   variable name: roi, 
%   fieldname:
%             fname, dim, volsize, volid, areaname, the last two are cell array

% AAL_116BrainArea      record aal 116 brain area name
%   variable name: AreaName,
%   fieldname:     Name, Name_abbr

% td100.mat
%			size   100x100
% 			edge   2738
%			dense  0.4804
%
% td1000.mat
% 			size   1000x1000
%			edge   45106
%           dense  0.0903
% Code:
%	N = 100;   threshold = 0.7; %N = 1000; threshold = 0.3;
%   td = double(rand(N) < threshold);
%   td = min(td,td');
%   td(1:(N+1):end) = 0;
%   isconnected(td)
%   sum(td(:))/2
%   sum(td(:))/(N*(N-1))
%   td100 = td;   save td100 td100;


% td9.mat
%			size   9x9
%			edge   15
% 			dense  0.4167
% td20.mat
% 			size   20x20
%			edge   41
%			dense  0.2158
% Code:
%	td9  = CCM_TestGraph1();
%	td20 = CCM_TestGraph2();


% PAJEK_td20.mat
%   format1 of pajek data
% PAJEK_td20.net
%   format2 of pajek data
%   Code:
%	g = load('td20.mat');
%	writetoPAJ(g, [], 'PAJEK_td20',0); % 0 for undirected graph


