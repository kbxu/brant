function brant_ConstructRun( handles )
% BNAT - Construct: construct network for each {*.img,*.hdr} file.
%-----------------------------------------------
% handles structure( part )
%       - .pgbar        | handle
%       - .Flist        | cell
%       - .OutputDir    | string
%       - .Mask         | string
%       - .ROI          | string
%       - .netType      | string {'CorrNetwork',  'PartialCorr',...
%                                 'CausalNetwork','PartialCausal',...
%                                 'CohereNetwork','PartialCohere'}
%
%       - ppmValue      | options {'Threshold','Proportion'}
%       - editValue     | string --> [0,1],interval
%       - chkSymmetry   | value  --> 0/1
%       - chkRelation   | value  --> 0/1
%       - chkSpan       | value  --> 0/1
%       - editPrefix    | string
%-----------------------------------------------
% See also spm_vol, spm_read_vols, (spm_write_vol), progressbar

global RUNSTOP;

InputDir  = handles.Flist;
OutputDir = handles.OutputDir;
roi       = handles.ROI;
mask      = handles.Mask;
type      = handles.netType;
prefix    = get(handles.editPrefix,'String');

% % load mask file and determine voxel size
if(~isempty(mask)),
    v = spm_vol( mask );
    volsize  = abs(v.mat([1,6,11]));
    maskData = spm_read_vols( v );
else
% % load a img file to determine voxel size at random
    tmpFile  = dir(fullfile(InputDir{1},[prefix,'*.hdr']));
    tmpFile  = tmpFile(1).name;
    v = spm_vol( fullfile(InputDir{1},tmpFile) );
    
    volsize  = abs(v.mat([1,6,11]));
    maskData = ones(v.dim);
end
    
% % get roi data
load( roi );    VoxelID = roi.volid;

nDir  = length(InputDir);    % number of directory
pcorr = cell(nDir, 1);       % predefine for relational matrix
% % begin to compute
try % {*.hdr,*.img} --> *.mat(relation matrix)
    for n = 1 : nDir
        pause(0.0001); % prepare for interrupt
        if(RUNSTOP),	return;     end           

        theDir = InputDir{n};
        fprintf('*\tBegin to compute dir < %s >. \n', theDir);        
        Flist  = dir(fullfile(theDir,[prefix,'*.hdr']));%list hdr-file
        T = size(Flist, 1); %length of time points    
        P = {Flist.name};
        P = strcat([theDir, filesep], P);
        V = spm_vol( P );

        % Construct to 4D-matrix 
        %              (Maybe show warn information -- Out of memory)
        to4Dmat = zeros([size(maskData), T], 'single');
        for t   = 1:T
            Vt  = spm_vol( V{t} );
            if isequal(volsize, abs(Vt.mat([1,6,11])))
                to4Dmat(:,:,:,t) = maskData.*spm_read_vols( Vt );
            else
                fprintf('WRONG: Voxel size isn''t matching:\n\t%s.\n',P{t});
                uiwait(errordlg('Voxel size isn''t matching.','Error','modal'));
                return
            end
        end

        % Construct time series
        N = length( VoxelID ); % number of brain area
        tMatrix = zeros(T, N); % each column is time series of a area
        for k = 1:N
            roiVox   = VoxelID{k};
            n_roiVox = size(roiVox, 1);
            if(n_roiVox == 0), 
                fprintf('WARNING: number of voxels in area %3d is 0.\n',n);
                continue;
            end

            % Note: function MEAN/SUM has size limit!
            for m = 1:n_roiVox
                tMatrix(:,k) = tMatrix(:,k) + ...
                    squeeze(to4Dmat(roiVox(m,1),roiVox(m,2),roiVox(m,3),:));
            end
            tMatrix(:,k) = tMatrix(:,k)/n_roiVox;
        end
        clear to4Dmat


        pcorr{n} = zeros(N, N);
        % Calculate relation matrix
        switch(upper(type))        
        case 'CORRNETWORK',  % correlation network
            pcorr{n}  = fastcorr(tMatrix);    % the same as corr(tMatrix);
%           zScore = log((1+pcorr)./(1-pcorr))/2;%Fisher's Z transformation     

        case 'PARTIALCORR',  % partial correlation network
            for ColI = 1:N-1
                for ColJ = ColI:N
                    tmp = setdiff(1:N, [ColI,ColJ]);
                    pcorr{n}(ColI, ColJ) = ...
                        partialcorr(tMatrix(:,ColI),tMatrix(:,ColJ),tMatrix(:,tmp));
                    pcorr{n}(ColJ, COlI) = pcorr{n}(ColI, ColJ);
                end
            end

        case 'CAUSALNETWORK',% causal network
    %         Max_q = 3;
    %         Max_p = 3;
    %         for coli = 1:N-1
    %             for colj = coli:N
    %                 [Fxy, F0, Attribution] = ...
    %                     Granger(tMatrix(:,coli),Max_q,tMatrix(:,colj),Max_p);
    %                 if(Fxy > F0),
    %                     pcorr(coli, colj) = 1;
    %                 else
    %                     pcorr(coli, colj) = 0;
    %                 end
    %                 pcorr(colj, coli) = pcorr(coli, colj);
    %             end
    %         end

        case 'PARTIALCAUSAL',% partial causal network
    %         Max_p = 3;
    %         Max_q = 3;
    %         warning off;
    %         for coli = 1:N-1
    %             for colj = coli:N
    %                 pcorr(coli,colj) = partial_Granger(x,y,Max_p,z,Max_q);
    %             end
    %         end
    %         warning on;     

        case 'COHERENETWORK',% coherence network
            %developing

        case 'PARTIALCOHERE',% partial coherence network
            pcorr{n}  = partialMutInfo( tMatrix );%developing

        otherwise,%do nothing
        end
        clear tMatrix
        pcorr{n}(1:(N+1):end) = 0; % values on diagonal line are 0

        % show waitbar infomation
        progressbar(n/nDir, handles.pgbar, [1 0 0]);
    end

    fprintf('*\tTask finished, starting output... \n');
    % Set output directory
    nameDir = ['brantResOut',datestr(now,'yyyymmdd')];
    tmpDir  = dir(fullfile(OutputDir, [nameDir,'*']));
    nameDir = genvarname(nameDir,{tmpDir.name}); % generate dir name

    % Make a dir
    OutputDir = fullfile(OutputDir, nameDir);
    if ~isempty(tmpDir)
        fprintf('PROMPT: result will be save in < %s >.\n', nameDir); 
    end
    mkdir( OutputDir );

    % Set relational matrix dir and output
    if(get(handles.chkRelation,'Value')),
        relDir = fullfile(OutputDir, 'relmat');
        mkdir( relDir );  

        for m = 1:length(pcorr)
            tmpf  = findstr(InputDir{m},filesep); % get file name
            tmpf  = InputDir{m}(tmpf(end)+1:end);
            fname = fullfile(relDir, tmpf);
            p     = pcorr{m};
            save(fname,'p');
        end
    end

    % Set network matrix dir
    val = get(handles.editValue, 'String');
    if isempty(val),        
        val = 0;
    else
        val = eval( val );
    end
    
    str = {'th','pr'};
    str = str{get(handles.ppmValue,'Value')};
    for n = 1:length(val)
        % when proportion value is zeros! 
        if(val(n) == 0),    continue;      end
        
        theDir = [str, sprintf('%02d', 100*val(n))];
        theDir = fullfile(OutputDir, theDir);
        mkdir( theDir );
        for m = 1:length(pcorr)
            tmpg = abs(pcorr{m});
            if strcmp(str,'th') % threshold
                g = double(tmpg >= val(n));
            else                % proportion                
                ind = find(tmpg);
                if get(handles.chkSpan, 'Value') % minium span tree
                    tree = graphminspantree(sparse(tmpg)); % must be sparse
                    tree = tree + tree';         % for "tree" is a tril matrix!!!
                    tmpg(logical(tree)) = 1;
                end

                ep = sortrows([ind, tmpg(ind)], -2); % sort by magnitude
                % number of links to be preserved
                eg = round((length(tmpg)^2-length(tmpg))*val(n));
                if(rem(eg,2) && isequal(tmpg, tmpg.')),   eg = eg + 1;  end

                g = zeros(size(tmpg));
                g( ep(1:eg) ) = 1;
            end
            
            % Output weight matrix
            if( any(~val) ),	g = g.*abs(pcorr{m});       end

            tmpf  = findstr(InputDir{m}, filesep);
            tmpf  = [str,sprintf('%02d_',100*val(n)),InputDir{m}(tmpf(end)+1:end)];
            fname = fullfile(theDir, tmpf);
            save(fname, 'g');
        end
        
        % Output filelist
        fname = fullfile(theDir,sprintf('%s%02d_filelist.txt', str, 100*val(n)));
        filelist( theDir, fname ); 
    end
    
    filelist( OutputDir, fullfile(OutputDir, 'filelist.txt'));        
    fprintf('*\tDone... \n\n');

catch ex
    fprintf('*\tTask doesn''t finish. \n');
    clear global RUNSTOP
    set(handles.btnRun, 'String', 'Run');
	progressbar(1.0, handles.pgbar);
    
    err = MException('MATLAB:Construct:InvalidArguments',...
        'Improper arguments for Construct');
    err = err.addCause(ex);
    throw(err);
end

function filelist( theDir, fname)
% Output *.mat to filelist.txt
try
    s = ['!dir /B/S "', theDir, filesep, '*.mat',  '" > "', fname, '"'];
    eval( s );
end




% function vox = findVoxel(data)
% %findVoxel finds the index of non-zeros
% % data is a 3-D data
% % vox  is a  Nx3 array
% 
% N   = nnz(data);
% vox = zeros(N,3);   pt  = 0;
% for i = 1:size(data,3)
% 	[I,J] = find(data(:,:,i));   ptadd = size(I,1);%Increment of pt
%     vox(pt+1 : pt+ptadd,:) = cat(2,I,J,i*ones(ptadd,1));
%     pt = pt + ptadd;
% end 
