function fname = brant_MeasureRun( handles )
% BNAT - Measures: compute measures of each data.
%-----------------------------------------------
% handles structure
%       - .Flist          | cell
%       - .OutputDir      | string
%       - .netType        | string
%       - .listSelected   | cell
%       - .Measures       | cell
%       - .editTimes      | string -> integer
%       - .ppmMode        | 1-4
%       - .chkConnect     | 0/1
%-----------------------------------------------
% fname     file list of result output, 
%           when stop running, fname = []
% See also branches, brant_MeasureInt

global RUNSTOP1;

InputFile  = handles.Flist;
OutputDir  = handles.OutputDir;
Type       = handles.netType;
Selectedms = get(handles.listSelected,'String'); % measures be selected
Measures   = handles.Measures;

% Set output directory
nameDir = ['brantResOut',datestr(now,'yyyymmdd')];
tmpDir  = dir(fullfile(OutputDir, [nameDir,'*']));
nameDir = genvarname(nameDir,{tmpDir.name});     % generate dir name

% Make a dir
OutputDir = fullfile(OutputDir, nameDir);
if ~isempty(tmpDir)
    fprintf('PROMPT: result will be save in < %s >.\n', nameDir); 
end
mkdir( OutputDir );
% try
%     if(exist(OutputDir,'dir')==7),   rmdir(OutputDir,'s');    end
%     mkdir(OutputDir);
% catch
%     fprintf('WARNING: previous result will be covered.\n');
% end


nFile = length(InputFile);
try
    for n = 1 : nFile
        pause(0.0001); % prepare for interrupt
        if RUNSTOP1,	fname = [];     return;     end      
    
        fprintf('*\tBegin to compute file < %s >. \n', InputFile{n});    
        % Loading data to variable "gMatrix"
        tmpData  = load( InputFile{n} ); % note: theData is a struct-arry!!!
        tmpField = fieldnames(tmpData);
        eval(['gMatrix = tmpData.',tmpField{1},';']);
        clear tmp*
    
        % Check connectivity
        sizeMat  = length(gMatrix); % number of nodes
        disnode  = [];              % disconnected node set
        connode  = 1:sizeMat;
        
        % Maybe gMatrix is a logical array
        gMatrix  = double(gMatrix); %% transform to double array
        [num, bset] = branches(gMatrix);
        if(num > 1),
            fprintf('\nWARNING: %d-th data is not connected.\n', n);

            % Find the largest connected component
            tabfre = tabulate(bset);%frequency table
            [I, J] = max(tabfre(:,2));
            connode = find(bset == tabfre(J, 1));%connected nodes
            disnode = setdiff(1:sizeMat,connode);
            gMatrix = gMatrix(connode, connode);
        end
        
        % Weighted network transform
        if ismember(get(handles.ppmType,'Value'),[3 4])
            gMatrix = 1 - gMatrix;
            gMatrix(1:length(gMatrix)+1:end) = 0;
        end
	
        % gMatrix = sparse(gMatrix); %% maybe need using sparse array
    
        for m = 1 : length(Selectedms)
            switch Selectedms{m}
            case Measures{1} % Assortative coefficient
                mRes.assortative = CCM_Assortative(gMatrix);

            case Measures{2} % Avg neighbor degree
                [mRes.neighbordegree.global, ntmp]  = CCM_AvgNeighborDegree(gMatrix);
                
                 mRes.neighbordegree.nodal          = zeros(sizeMat, 1);
                 mRes.neighbordegree.nodal(connode) = ntmp;
                if(num > 1),     mRes.neighbordegree.nodal(disnode) = NaN;  end

           case Measures{3} % Random walk betweenness
                if(strcmpi(Type,'Binary'))%just for binary network
                     ntmp = CCM_RBetweenness(gMatrix);%slowly
                   % ntmp = rwBetweenness(gMatrix);
                    mRes.betweennessrw = zeros(sizeMat,1);
                    mRes.betweennessrw(connode) = ntmp;
                    if(num > 1),    mRes.betweennessrw(disnode) = NaN;      end
                else
                    mRes.betweennessrw = [];
                end

            case Measures{4} % Shortest path betweenness of edge
                if(~strcmpi(Type,'Directed'))%not for directed network
                    ntmp = CCM_SBetweenness(gMatrix, 'Edge', Type);
                    mRes.betweennessspe = zeros(sizeMat,sizeMat);
                    mRes.betweennessspe(connode, connode) = ntmp;
                    %if(num > 1),   mRes.betweennessspe(disnode, disnode) = NaN; end
                else
                    mRes.betweennessspe = [];
                end

            case Measures{5} % Shortest path betweenness of vertex
                if(~strcmpi(Type,'Directed'))%not for directed network
                    ntmp = CCM_SBetweenness(gMatrix, 'Vertex', Type);
                    mRes.betweennessspv = zeros(sizeMat,1);
                    mRes.betweennessspv(connode) = ntmp;
                    if(num > 1),    mRes.betweennessspv(disnode) = NaN;     end
                else
                    mRes.betweennessspv = [];
                end

            case Measures{6} % Clustering coefficient
                [mRes.clusteringcoeff.global, ntmp] = CCM_ClusteringCoef(gMatrix, Type);
                 mRes.clusteringcoeff.nodal = zeros(sizeMat,1);
                 mRes.clusteringcoeff.nodal(connode) = ntmp;
                if(num > 1),    mRes.clusteringcoeff.nodal(disnode) = NaN;  end

            case Measures{7} % Degree
                [mRes.degree.outglobal, ntmp] = CCM_Degree(gMatrix');%out-degree
                 mRes.degree.outnodal = zeros(sizeMat,1);
                 mRes.degree.outnodal(connode) = ntmp;

                [mRes.degree.inglobal,  ntmp] = CCM_Degree(gMatrix);%in-degree
                 mRes.degree.innodal = zeros(sizeMat,1);
                 mRes.degree.innodal(connode) = ntmp;

                if(num > 1),
                    mRes.degree.outnodal(disnode) = NaN;
                    mRes.degree.innodal(disnode)  = NaN;
                end

            case Measures{8} % Fault tolerance
                [mRes.faulttol.global, ntmp] = CCM_FaultTol(gMatrix);
                 mRes.faulttol.nodal = zeros(sizeMat,1);
                 mRes.faulttol.nodal(connode) = ntmp;
                if(num > 1),       mRes.faulttol.nodal(disnode) = NaN;      end

            case Measures{9} % Global efficiency
                [mRes.globalefficiency.global, ntmp] = CCM_GEfficiency(gMatrix);
                 mRes.globalefficiency.nodal = zeros(sizeMat, 1);
                 mRes.globalefficiency.nodal(connode) = ntmp;
                if(num > 1),    mRes.globalefficiency.nodal(disnode) = NaN; end

            case Measures{10} % Local efficiency
                [mRes.localefficiency.global, ntmp] = CCM_LEfficiency(gMatrix);
                 mRes.localefficiency.nodal = zeros(sizeMat, 1);
                 mRes.localefficiency.nodal(connode) = ntmp;
                if(num > 1),    mRes.localefficiency.nodal(disnode) = NaN;  end

            case Measures{11} % Resilience degree distribution
                mRes.resilience.out = CCM_Resilience(gMatrix');% Out-degree
                mRes.resilience.in  = CCM_Resilience(gMatrix); % In-degree

            case Measures{12} % Shortest path length
                [mRes.shortestpathlength.global, ntmp] = CCM_AvgShortestPath(gMatrix);
                 mRes.shortestpathlength.nodal = zeros(sizeMat,1);
                 mRes.shortestpathlength.nodal(connode) = ntmp;
                if(num > 1),  mRes.shortestpathlength.nodal(disnode) = NaN; end

            case Measures{13} % Small worldness
            simT = eval(get(handles.editTimes,'String'));% simulated times
            if(get(handles.chkConnect,'Value'))
                [s, l, g] = CCM_SmallWorldness(gMatrix, simT, Type, 1);
                mRes.smallworldness = [s, l, g];           
            else
                [s, l, g] = CCM_SmallWorldness(gMatrix, simT, Type, 0);
                mRes.smallworldness = [s, l, g];
            end

            case Measures{14} % Transitivity
                mode = get(handles.ppmMode, {'UserData','Value'});

                mRes.transitivity = CCM_Transitivity(gMatrix, Type, mode{1}{mode{2}});

            case Measures{15} % Vulnerability
                [mRes.vulnerability.global, ntmp] = CCM_Vulnerability(gMatrix);
                 mRes.vulnerability.nodal = zeros(sizeMat,1);
                 mRes.vulnerability.nodal(connode) = ntmp;
                 if(num > 1),     mRes.vulnerability.nodal(disnode) = NaN;  end
            end
        end

        % Save to output file
        [filedir, filename] = fileparts( InputFile{n} );
        Outputfile = fullfile(OutputDir, strcat('brantRes_',filename));
        save(Outputfile, 'mRes');
        clear mRes

        % Show waitbar infomation
        progressbar(n/nFile, handles.pgbar, [1 0 0]);
    end
    
    % Output file list
    fname = fullfile(OutputDir, 'fileList.txt');
    s = ['!dir /B/S "', OutputDir, filesep, '*.mat',  '" > "', fname, '"'];
    eval( s );
    fprintf('*\tResult output successfully ...\n\t%s < %s >. \n', ...
        'see filelist in', fname);
    fprintf('*\tDone ...\n');

catch ex
    fprintf('*\tTask doesn''t finish. \n');
    clear global RUNSTOP1
    set(handles.btnRun, 'String', 'Run');
	progressbar(1.0, handles.pgbar);
    
    err = MException('MATLAB:Measure:InvalidArguments',...
        'Improper arguments for Measure');
    err = err.addCause(ex);
    throw(err);
end
