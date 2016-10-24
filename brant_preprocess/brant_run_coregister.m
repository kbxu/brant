function coreg_prefix = brant_run_coregister(coreg_infos, data_files, is4d_ind, par)

file_dirs = brant_get_dirs_from_data(data_files, is4d_ind);

file_ref = brant_get_subjs2(file_dirs, 1, coreg_infos.subj.filetype_ref);
file_src = brant_get_subjs2(file_dirs, 1, coreg_infos.subj.filetype_src);

% 1 for segment and bet, 2 for bet only, 0 and others do nothing
if (coreg_infos.subj.seg_bet_ind == 1) || (coreg_infos.subj.seg_bet_ind == 2)
    if coreg_infos.subj.seg_bet_ind == 1
        % do segment
        fprintf('\n*\tDoing Segment*\n');
        if (par == 0)
            for m = 1:numel(file_src)
                brant_run_segment(file_src{m});
            end
        else
            parfor m = 1:numel(file_src)
                brant_run_segment(file_src{m});
            end
        end
    end
    
    % do bet
    fprintf('\n*\tDoing Bet*\n');
    file_c1 = brant_get_subjs2(file_dirs, 1, 'c1*.nii');
    file_c2 = brant_get_subjs2(file_dirs, 1, 'c2*.nii');
    file_c3 = brant_get_subjs2(file_dirs, 1, 'c3*.nii');
    if (par == 0)
        for m = 1:numel(file_src)
            brant_image_calc([file_src(m); file_c1(m); file_c2(m); file_c3(m)], 'betStructImg', file_dirs(m), 'i1.*((i2+i3+i4)>0.5)');
        end
    else
        parfor m = 1:numel(file_src)
            brant_image_calc([file_src(m); file_c1(m); file_c2(m); file_c3(m)], 'betStructImg', file_dirs(m), 'i1.*((i2+i3+i4)>0.5)');
        end
    end
    
    file_src_bet = brant_get_subjs2(file_dirs, 1, 'betStructImg*.nii');
    file_src_cog = file_src;
else
    file_src_bet = file_src;
    file_src_cog = cell(numel(file_src_bet), 1);
end
%

% do coregister
fprintf('\n*\tDoing coregister*\n');
if (par == 0)
    for m = 1:numel(file_src_bet)
        loop_coregister(file_src_bet(m), file_ref(m), file_src_cog(m), coreg_infos, file_dirs{m});
    end
else
    parfor m = 1:numel(file_src_bet)
        loop_coregister(file_src_bet(m), file_ref(m), file_src_cog(m), coreg_infos, file_dirs{m});
    end
end

coreg_prefix = [];%coreg_infos.roptions.prefix;
fprintf('\n*\tCoregister finished!*\n');

function loop_coregister(file_src, file_ref, file_other, coreg_infos, file_dirs)
fprintf('\n*\tDoing coregister for data in %s.\t*\n', file_dirs);
coreg_infos = rmfield(coreg_infos, 'subj');
coreg_infos.source = file_src;
coreg_infos.ref = file_ref;
coreg_infos.other = file_other;


spm_v = spm('ver');
if strcmpi(spm_v, 'SPM12')
    spm_run_coreg(coreg_infos);
else
    spm_run_coreg_estwrite(coreg_infos);
end
