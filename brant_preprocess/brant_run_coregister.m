function coreg_prefix = brant_run_coregister(coreg_infos, data_files, is4d_ind, par)

file_dirs = brant_get_dirs_from_data(data_files, is4d_ind);

file_ref = brant_get_subjs2(file_dirs, 1, coreg_infos.subj.filetype_ref);
file_src = brant_get_subjs2(file_dirs, 1, coreg_infos.subj.filetype_src);

% 1 for segment and bet, 2 for bet only, 0 and others do nothing
if (coreg_infos.subj.seg_bet_ind == 1) || (coreg_infos.subj.seg_bet_ind == 2)
    if coreg_infos.subj.seg_bet_ind == 1
        % do segment
        fprintf('\n*\tRunning Segment*\n');
        if (par == 0)
            for m = 1:numel(file_src)
                brant_run_segment(file_src{m}, [0, 0]);
            end
        else
            parfor m = 1:numel(file_src)
                brant_run_segment(file_src{m}, [0, 0]);
            end
        end
    end
    
    % do bet
    fprintf('\n*\tRunning Bet*\n');
    file_c1 = brant_get_subjs2(file_dirs, 1, 'c1*.nii');
    file_c2 = brant_get_subjs2(file_dirs, 1, 'c2*.nii');
    file_c3 = brant_get_subjs2(file_dirs, 1, 'c3*.nii');
    if (par == 0)
        for m = 1:numel(file_src)
            brant_image_calc([file_c1(m); file_c2(m); file_c3(m)], 'wholebrain', file_dirs(m), '(i1+i2+i3)', 0);
            brant_image_calc([file_src(m); file_c1(m); file_c2(m); file_c3(m)], 'betStructImg', file_dirs(m), 'i1.*((i2+i3+i4)>0.5)', 0);
        end
    else
        parfor m = 1:numel(file_src)
            brant_image_calc([file_c1(m); file_c2(m); file_c3(m)], 'wholebrain', file_dirs(m), '(i1+i2+i3)', 0);
            brant_image_calc([file_src(m); file_c1(m); file_c2(m); file_c3(m)], 'betStructImg', file_dirs(m), 'i1.*((i2+i3+i4)>0.5)', 0);
        end
    end
    
    if isequal(spm('ver'), 'SPM8')
        file_src_bet = brant_get_subjs2(file_dirs, 1, 'betStructImg*.img');
    else
        file_src_bet = brant_get_subjs2(file_dirs, 1, 'betStructImg*.nii');
    end
    file_src_cog = file_src;
else
    file_src_bet = file_src;
    file_c1 = cell(numel(file_src_bet), 1);
    file_c2 = cell(numel(file_src_bet), 1);
    file_c3 = cell(numel(file_src_bet), 1);
    file_src_cog = cell(numel(file_src_bet), 1);
end
%

% do coregister
fprintf('\n*\tRunning coregister*\n');
if (par == 0)
    for m = 1:numel(file_src_bet)
        loop_coregister(file_src_bet(m), file_ref(m), [file_src_cog(m);file_c1(m);file_c2(m);file_c3(m)], coreg_infos, file_dirs{m});
    end
else
    parfor m = 1:numel(file_src_bet)
        loop_coregister(file_src_bet(m), file_ref(m), [file_src_cog(m);file_c1(m);file_c2(m);file_c3(m)], coreg_infos, file_dirs{m});
    end
end

coreg_prefix = [];%coreg_infos.roptions.prefix;
fprintf('\n*\tCoregister finished!*\n');

function loop_coregister(file_src, file_ref, file_other, coreg_infos, file_dirs)
fprintf('\n*\tRunning coregister for data in %s.\t*\n', file_dirs);
coreg_infos = rmfield(coreg_infos, 'subj');
coreg_infos.source = file_src;
coreg_infos.ref = file_ref;

oth_ept_ind = cellfun(@isempty, file_other);
if all(oth_ept_ind)
    coreg_infos.other = {''};
else
    coreg_infos.other = file_other(~oth_ept_ind);
end

spm_v = spm('ver');
if strcmpi(spm_v, 'SPM12')
    spm_run_coreg(coreg_infos);
else
    spm_run_coreg_estimate(coreg_infos);
end
