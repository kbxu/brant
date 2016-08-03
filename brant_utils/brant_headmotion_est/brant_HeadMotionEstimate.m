function [HeadMotion] = brant_HeadMotionEstimate(HeadMotionList)
%%%%%%%%% *************************
% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Estimate the matrix of M in entropy maximum

% FORMAT function [headMotion] = CCM_HeadMotionEstimate(HeadMotionList)
%                 HeadMotionList --- the rp_*.txt from the SPM
%                 HeadMotion ---- the HeadMotion result
%
% Written by Yong Liu, May,2012
% Center for Computational Medicine (CCM),
% National Laboratory of Pattern Recognition (NLPR),
% Chinese Academy of Sciences (CAS), China.
% E-mail: yliu@nlpr.ia.ac.cn || liuyong.ccm@gmail.com
% Copywrite (c) 2007, & 2012
%%%%
%%%%%%%%% *************************
SubjNum = length(HeadMotionList);
% HeadMotion = zeros(SubjNum,6);
for i = 1:SubjNum
%     [head_motion] = brant_ReadHeadMotionTxt(HeadMotionList{i}); %% time length*6
    head_motion = load(HeadMotionList{i});
    xyz_abs = abs(head_motion(:, 1:3));
    rot_abs = abs(head_motion(:, 4:6)) * 180 / pi;
    HeadMotion.max_absmotion(i) = max(xyz_abs(:));
    HeadMotion.max_absrotation(i) = max(rot_abs(:));
    
    %%  refer van Dijk et al., Neuroimage 2012
    
    for j = 1:size(head_motion, 1)
        Motion(j) = norm(head_motion(j, 1:3)); %#ok<AGROW>
    end
    HeadMotion.maxmotion_dijk(i) = max(Motion);
    HeadMotion.meanmotion_dijk(i) = mean(Motion);
    HeadMotion.numbermove_dijk(i) = sum(Motion > 0.1);
    phi = head_motion(:, 4);
    theta = head_motion(:, 5);
    psi = head_motion(:, 6);
    EularAngle = acosd((cos(phi) .* cos(theta) + cos(phi) .* cos(psi) + cos(theta) .* cos(psi) + sin(phi) .* sin(theta) .* sin(psi) - 1) / 2);
    HeadMotion.rotation_dijk(i) = mean(abs(EularAngle)); % in degree
    
    %%  refer Power et al., Neuroimage 2012

    FD = sum([abs(head_motion(:, 1:3)), 50 * abs(head_motion(:, 4:6))], 2);
    HeadMotion.FD(i) = mean(FD);
    HeadMotion.num_badFD(i) = sum(FD >= 0.5);
end
