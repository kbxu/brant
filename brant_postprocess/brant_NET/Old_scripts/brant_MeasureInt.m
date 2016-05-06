function brant_MeasureInt( theFile , theDir)
% Integration result to text file
%   theFile     a text file including the name want to integrate
%   theDir      output dir
% See also brant_Measure

Flist = textread(theFile, '%s', 'delimiter', '\n'); % file list
load( Flist{1} ); % load a file

% there a variable "mRes"
   ms = fieldnames( mRes );
allms = {'assortative', 'neighbordegree',  'betweennessrw',...
    'betweennessspe',   'betweennessspv',  'clusteringcoeff',...
    'degree',           'faulttol',        'globalefficiency',...
    'localefficiency',  'resilience',      'shortestpathlength',...
    'smallworldness',   'transitivity',    'vulnerability'};

% - begin -
fprintf('\n*\tStart to integrate result ...\n');

% dir-make
theDir = strcat(theDir, filesep, 'integrate_res');
mkdir(theDir);

N = length(Flist);  % number of *.mat files
% creat file
for n = 1:length(ms)
    if ~strcmpi(ms{n}, 'betweennessspe')
    fid1(n) = fopen(fullfile(theDir,[ms{n},'_nodal.txt']),  'wt'); % nodal
    fid2(n) = fopen(fullfile(theDir,[ms{n},'_global.txt']), 'wt'); % global
    end
end

for n = N:-1:1
    load( Flist{n} ); % there a variable "mRes"
    for m = 1:length(ms)
        switch ms{m}
        case allms{1}  % assortative
            fprintf(fid1(m), '%g\t', mRes.assortative);
        case allms{2}  % neighbordegree
            fprintf(fid1(m), '%g\t', mRes.neighbordegree.nodal);
            fprintf(fid2(m), '%g\t', mRes.neighbordegree.global);
        case allms{3}  % betweennessrw
            fprintf(fid1(m), '%g\t', mRes.betweennessrw);
        case allms{4}  % betweennessspe
            % do nothing
        case allms{5}  % betweennessspv
            fprintf(fid1(m), '%g\t', mRes.betweennessspv);
        case allms{6}  % clusteringcoeff
            fprintf(fid1(m), '%g\t', mRes.clusteringcoeff.nodal);
            fprintf(fid2(m), '%g\t', mRes.clusteringcoeff.global);
        case allms{7}  % degree
            fprintf(fid1(m), '%g\t', mRes.degree.innodal);
            fprintf(fid2(m), '%g\t', mRes.degree.inglobal);
        case allms{8}  % faulttol
            fprintf(fid1(m), '%g\t', mRes.faulttol.nodal);
            fprintf(fid2(m), '%g\t', mRes.faulttol.global);
        case allms{9}  % globalefficiency
            fprintf(fid1(m), '%g\t', mRes.globalefficiency.nodal);
            fprintf(fid2(m), '%g\t', mRes.globalefficiency.global);
        case allms{10} % localefficiency
            fprintf(fid1(m), '%g\t', mRes.localefficiency.nodal);
            fprintf(fid2(m), '%g\t', mRes.localefficiency.global);
        case allms{11} % resilience
            fprintf(fid1(m), '%g\t', mRes.resilience.in);
            fprintf(fid2(m), '%g\t', mRes.resilience.out);
        case allms{12} % shortestpathlength
            fprintf(fid1(m), '%g\t', mRes.shortestpathlength.nodal);
            fprintf(fid2(m), '%g\t', mRes.shortestpathlength.global);
        case allms{13} % smallworldness
            fprintf(fid1(m), '%g\t', mRes.smallworldness);
        case allms{14} % transitivity
            fprintf(fid1(m), '%g\t', mRes.transitivity);
        case allms{15} % vulnerability
            fprintf(fid1(m), '%g\t', mRes.vulnerability.nodal);
            fprintf(fid2(m), '%g\t', mRes.vulnerability.global);
        end
        
        % new line
        fprintf(fid1(m), '\n');
        fprintf(fid2(m), '\n');
    end
end

% close file
for n = 1:length(ms)
    fclose(fid1(n));
    fclose(fid2(n));
end
fprintf('*\tDone ...\n\n');
