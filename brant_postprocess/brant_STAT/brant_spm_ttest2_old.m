function brant_spm_ttest2(jobman)

num_gps = numel(jobman.subj_infos.paths);

if num_gps < 2
    error('\tNumber of input groups should be at lease 2!\n');
else
    fprintf('\tNumber of groups is %d\n', num_gps);
end

gp_ind_up = triu(ones(num_gps), 1);

[group_up_1, group_up_2] = find(gp_ind_up);

job.des.t2.dept = 0;
job.des.t2.variance = 1;
job.des.t2.gmsca = 0;
job.des.t2.ancova = 0;
job.masking.tm.tm_none = 1;
job.masking.im = 1;
job.masking.em = {jobman.mask_fn};
job.globalc.g_omit = 1;
job.globalm.gmsca.gmsca_no = 1;
job.globalm.glonorm = 1;
job.cov = '';

% parse covariates from jobman.covs
if ~isempty(jobman.covs.inputfile)
    cov_pos_tmp = strfind(jobman.covs.subjs, 'cov_name');
    cov_pos = zeros(numel(cov_pos_tmp), 1);
    for m = 1:numel(cov_pos_tmp)
        if ~isempty(cov_pos_tmp{m})
            cov_pos(m) = 1;
        end
    end
    cov_pos_loc = find(cov_pos == 1);
    for m = 1:numel(cov_pos_loc)
        cov_name = regexpi(jobman.covs.subjs{cov_pos_loc(m)},'cov_name:(\w+)','tokens','once');
        if cov_pos_loc(m) ~= cov_pos_loc(end)
            m_int = cov_pos_loc(m) + 1:cov_pos_loc(m + 1) - 1;
        else
            m_int = cov_pos_loc(m) + 1:numel(cov_pos);
        end
        for mm = m_int
            for n = 1:numel(jobman.subj_infos.subjnames)
                cov_vec = regexpi(jobman.covs.subjs{mm}, [jobman.subj_infos.subjnames{n}, ':([[0-9]+[\s\.]+]+)'], 'tokens', 'once');
                if ~isempty(cov_vec)
                    vec_tmp = str2num(cov_vec{1});
                    covs.(cov_name{1}).(jobman.subj_infos.subjnames{n}) = reshape(vec_tmp, [numel(vec_tmp), 1]);
                end
            end
        end
    end
    
    cov_names = fields(covs);
    for m = 1:numel(cov_names)
        job.cov(m).cname = cov_names{m};
        job.cov(m).iCFI = 1;
        job.cov(m).iCC = 1;
    end
end


for m = 1:numel(group_up_1)
    
    gp_cmp = [jobman.subj_infos.subjnames{group_up_1(m)}, '_gt_', jobman.subj_infos.subjnames{group_up_2(m)}];
    if ~isempty(jobman.covs.inputfile)
        for n = 1:numel(cov_names)
            job.cov(n).c = [covs.(cov_names{n}).(jobman.subj_infos.subjnames{group_up_1(m)});...
                            covs.(cov_names{n}).(jobman.subj_infos.subjnames{group_up_2(m)})];
        end
    end
    fprintf('\tRunning spm t-test2 for %s\n', gp_cmp);
    job.des.t2.scans1 = jobman.subj_infos.subjs{group_up_1(m)};
    job.des.t2.scans2 = jobman.subj_infos.subjs{group_up_2(m)};
    
    job.dir = {fullfile(jobman.out_dir, gp_cmp)};
    
    if exist(job.dir{1}, 'dir') ~= 7
        mkdir(job.dir{1});
    end
    out = brant_spm_run_factorial_design(job);
    brant_spm_getSPM(out.spmmat{1});
end

fprintf('\n\tspm t-test2 finished!\n');
