function brant_hm_est(jobman)
%%%% this function was design to estimate the common used head motion measures
% FORMAT function [] = brant_hm_est(jobman)
%                 jobman.src_list --- filelist of fMRI data
%                 jobman.output_dir-- save the result for estimation
% Output 
%     HeadMotion.xyzmove(i) = max(TT(:));
%     HeadMotion.maxmove(i) = max(Motion);
%     HeadMotion.meanmove(i) = mean(Motion);
%     HeadMotion.numbermove(i) = length(find(Motion>0.1));
%     HeadMotion.Rotation
%     HeadMotion.FD
% Written by Yong Liu, Aug,2014
% Brainnetome Center,
% National Laboratory of Pattern Recognition (NLPR),
% Chinese Academy of Sciences (CAS), China.
% E-mail: yliu@nlpr.ia.ac.cn || liuyong.ccm@gmail.com
% Copywrite (c) 2007, & 2014
%%%%
jobman.input_nifti.is_txt = 1;
[HeadMotionList, subj_ids] = brant_get_subjs(jobman.input_nifti);
outdir = jobman.out_dir{1};
if (exist(outdir, 'dir') ~= 7)
    mkdir(outdir)
end

num_subj = numel(subj_ids);

savefilename = fullfile(outdir, 'brant_headmotion_result.csv');

csv_titles = [...
    {'subject-name'},...
    {'max-abstranslation(mm)'},...
    {'max-absrotation(deg)'},...
    {'max-motion-Dijk(mm)'},...
    {'mean-motion-Dijk(mm)'},...
    {'num-movements-Dijk(>0.1mm)'},...
    {'mean-rotation-Dijk(deg)'},...
    {'mean-FD(mm)'},...
    {'num-FD>0.5'}];

csv_data = cell(num_subj, 9);

fprintf('\tStart to estimate the headmotion\n');
for i = 1:num_subj

    HeadMotion(i) = brant_HeadMotionEstimate(HeadMotionList(i)); %#ok<AGROW>
        
        csv_data(i, :) = [subj_ids{i},...
            num2cell([...
            HeadMotion(i).max_abstranslation,...
            HeadMotion(i).max_absrotation,...
            HeadMotion(i).maxmotion_dijk,...
            HeadMotion(i).meanmotion_dijk,...
            HeadMotion(i).numbermove_dijk,...
            HeadMotion(i).rotation_dijk,...
            HeadMotion(i).FD,...
            HeadMotion(i).num_badFD])];
end
fprintf('\tEnd of estimate the headmotion\n\tplease visit %s to check your results.\n',savefilename);

brant_write_csv(savefilename, [csv_titles; csv_data]);

m_n_r = zeros(num_subj, 2); % Motions and Rotations
for i = 1:num_subj
    m_n_r(i, 1) = HeadMotion(i).max_abstranslation;
    m_n_r(i, 2) = HeadMotion(i).max_absrotation;
end

fid = fopen(fullfile(outdir, 'brant_headmotion_exclusions.txt'), 'wt');
for thres = 5:-0.5:0.5
    bad_subjs_m = m_n_r(:, 1) > thres;
    bad_subjs_r = m_n_r(:, 2) > thres;
    bad_subjs = bad_subjs_m | bad_subjs_r;
    
    fprintf(fid, 'Subjects excluded for threshold %2.1f mm or %2.1f degree\n', thres, thres);
    if ~isempty(bad_subjs)
        subj_inds = find(bad_subjs);
        for m = 1:numel(subj_inds)
            fprintf(fid, '%s\n', subj_ids{subj_inds(m)});
        end
    end
    fprintf(fid, '\n');
end
fclose(fid);
