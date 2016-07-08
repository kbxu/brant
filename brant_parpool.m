function brant_parpool(ctr_str, varargin)
% ctr_srt: open or close
% varargin: number of workders

num_dft = 2;

if nargin == 0
    ctr_str = 'open';
    num_workers = num_dft;
end

if nargin > 2
    error('Too many inputs!');
end

if ~any(strcmpi(ctr_str, {'open', 'close'}))
    error('Unknown input!Use open or close as first input!');
end

if nargin == 1
    if strcmpi(ctr_str, 'open')
        fprintf('No input of number workers are detected!\nUse 2 as default!');
        num_workers = num_dft;
    end
elseif nargin == 2
    num_workers = varargin{1};
end

if strcmpi(ctr_str, 'open')
    if verLessThan('matlab','8.3')
        try
            matlabpool('close'); %#ok<DPOOL>
        catch
        end
        matlabpool(num_workers); %#ok<DPOOL>
    else
        poolobj = gcp('nocreate'); % If no pool, do not create new one.
        new_pool_ind = 0;
        if isempty(poolobj)
            new_pool_ind = 1;
        else
            poolsize = poolobj.NumWorkers;
            if (poolsize ~= num_workers)
                delete(gcp);
                new_pool_ind = 1;
            end
        end

        if new_pool_ind == 1
            parpool(num_workers);
        end
    end
elseif strcmpi(ctr_str, 'close')
    if verLessThan('matlab','8.3')
        try
            matlabpool('close'); %#ok<DPOOL>
        catch
        end
    else
        poolobj = gcp('nocreate'); % If no pool, do not create new one.
        if ~isempty(poolobj)
            delete(gcp);
        end
    end
end
