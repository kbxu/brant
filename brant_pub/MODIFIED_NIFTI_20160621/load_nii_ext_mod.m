%  Load NIFTI header extension after its header is loaded using load_nii_hdr.
%
%  Usage: ext = load_nii_ext(filename)
%
%  filename - NIFTI file name.
%
%  Returned values:
%
%  ext - Structure of NIFTI header extension, which includes num_ext,
%       and all the extended header sections in the header extension.
%       Each extended header section will have its esize, ecode, and
%       edata, where edata can be plain text, xml, or any raw data
%       that was saved in the extended header section.
%
%  NIFTI data format can be found on: http://nifti.nimh.nih.gov
%
%  - Jimmy Shen (jimmy@rotman-baycrest.on.ca)
%
function ext = load_nii_ext_mod(filename)

if ~exist('filename','var'),
    error('Usage: ext = load_nii_ext(filename)');
end


v = version;

%  Check file extension. If .gz, unpack it into temp folder
%
if length(filename) > 2 && strcmp(filename(end-2:end), '.gz')
    
    if ~strcmp(filename(end-6:end), '.img.gz') && ...
            ~strcmp(filename(end-6:end), '.hdr.gz') && ...
            ~strcmp(filename(end-6:end), '.nii.gz')
        
        error('Please check filename.');
    end
    
    if str2num(v(1:3)) < 7.1 || ~usejava('jvm')
        error('Please use MATLAB 7.1 (with java) and above, or run gunzip outside MATLAB.');
    elseif strcmp(filename(end-6:end), '.img.gz')
        filename1 = filename;
        filename2 = filename;
        filename2(end-6:end) = '';
        filename2 = [filename2, '.hdr.gz'];
        
        %         tmpDir = tempname;
        %         mkdir(tmpDir);
        %         gzFileName = filename;
        %
        %         filename1 = gunzip(filename1, tmpDir);
        %         filename2 = gunzip(filename2, tmpDir);
        filename = char(filename1);	% convert from cell to string
    elseif strcmp(filename(end-6:end), '.hdr.gz')
        filename1 = filename;
        filename2 = filename;
        filename2(end-6:end) = '';
        filename2 = [filename2, '.img.gz'];
        
        %         tmpDir = tempname;
        %         mkdir(tmpDir);
        %         gzFileName = filename;
        %
        %         filename1 = gunzip(filename1, tmpDir);
        %         filename2 = gunzip(filename2, tmpDir);
        filename = char(filename1);	% convert from cell to string
    elseif strcmp(filename(end-6:end), '.nii.gz')
        %         tmpDir = tempname;
        %         mkdir(tmpDir);
        %         gzFileName = filename;
        %         filename = gunzip(filename, tmpDir);
        filename = char(filename);	% convert from cell to string
    end
end

machine = 'ieee-le';
new_ext = 0;

if strcmpi(filename(end-3:end), '.nii') || strcmpi(filename(end-6:end), '.nii.gz')
    new_ext = 1;
    %     filename(end-3:end)='';
end

% if findstr('.hdr',filename) && strcmp(filename(end-3:end), '.hdr')
%     filename(end-3:end)='';
% end
%
% if findstr('.img',filename) && strcmp(filename(end-3:end), '.img')
%     filename(end-3:end)='';
% end

% if new_ext
%     fn = sprintf('%s.nii',filename);
%
%     if ~exist(fn)
%         msg = sprintf('Cannot find file "%s.nii".', filename);
%         error(msg);
%     end
% else
%     fn = sprintf('%s.hdr',filename);
%
%     if ~exist(fn)
%         msg = sprintf('Cannot find file "%s.hdr".', filename);
%         error(msg);
%     end
% end

% fid = fopen(fn,'r',machine);
vox_offset = 0;

% if fid < 0,
%     msg = sprintf('Cannot open file %s.',fn);
%     error(msg);
% else
% fseek(fid,0,'bof');

% tmp = foptgz(filename, 'rb', {'int32'}, {uint32(1)}, uint32(0));
% 
% if tmp{1} == 348
    if new_ext
        tmp = foptgz(filename, 'rb', {'float32'}, {uint32(1)}, uint32(108));
        vox_offset = tmp{1};
%         fseek(fid,108,'bof');
%         vox_offset = fread(fid,1,'float32');
    end
    
    ext = read_extension(filename, vox_offset);
%     fclose(fid);
% else
%     fclose(fid);
    
    %  first try reading the opposite endian to 'machine'
    %
%     switch machine,
%         case 'ieee-le', machine = 'ieee-be';
%         case 'ieee-be', machine = 'ieee-le';
%     end
    
%     fid = fopen(fn,'r',machine);
%     
%     if fid < 0,
%         msg = sprintf('Cannot open file %s.',fn);
%         error(msg);
%     else
%     fseek(fid,0,'bof');

%     if fread(fid,1,'int32') ~= 348
% 
%         %  Now throw an error
%         %
%         msg = sprintf('File "%s" is corrupted.',fn);
%         error(msg);
%     end
% 
%     if new_ext
%         fseek(fid,108,'bof');
%         vox_offset = fread(fid,1,'float32');
%     end
% 
%     ext = read_extension(filename, vox_offset);
%         fclose(fid);
%     end
% end
% end


%  Clean up after gunzip
%
% if exist('gzFileName', 'var')
%     rmdir(tmpDir,'s');
% end


% return                                       % load_nii_ext


%---------------------------------------------------------------------
function ext = read_extension(fileprefix, vox_offset)

ext = [];

if vox_offset
    end_of_ext = vox_offset;
else % no voxels, all extension
    if foptgz(fileprefix, 'remain', uint32(348)) > 0
        end_of_ext = 352 + double(foptgz(fileprefix, 'remain', uint32(352)));
    else
        end_of_ext = 348;
    end
%     fseek(fn, 0, 'eof');
%     end_of_ext = ftell(fn);
end

if end_of_ext > 352
    tmp = foptgz(fileprefix, 'rb', {'uint8'}, {uint32(4)}, uint32(348));
    ext.extension = cast(tmp{1}, 'double');
%     fseek(fn, 348, 'bof');
%     ext.extension = fread(fn,4)';
end

if isempty(ext) || ext.extension(1) == 0
    ext = [];
    return;
end

i = 1;
extoff = 352;
next_read_ind = true;
while(next_read_ind)
    tmp = foptgz(fileprefix, 'rb', {'int32', 'int32'}, {uint32(1), uint32(1)}, uint32(extoff));
    
    ext.section(i).esize = cast(tmp{1}, 'double');
    ext.section(i).ecode = cast(tmp{2}, 'double');
    
    tmp = foptgz(fileprefix, 'rb', {'uint8'}, {uint32(ext.section(i).esize-8)}, uint32(extoff+8));
    ext.section(i).edata = cast(tmp{1}, 'char')';
    extoff = extoff + ext.section(i).esize;
    
    i = i + 1;
    
    if vox_offset
        next_read_ind = extoff < end_of_ext;
    else % search to the last byte if there are no voxel (*.hdr)
        next_read_ind = foptgz(fileprefix, 'remain', uint32(extoff)) > 0;
    end
end
    
% while(ftell(fn) < end_of_ext)
%     ext.section(i).esize = fread(fn,1,'int32');
%     ext.section(i).ecode = fread(fn,1,'int32');
%     ext.section(i).edata = char(fread(fn,ext.section(i).esize-8)');
%     i = i + 1;
% end

ext.num_ext = length(ext.section);

return                                               % read_extension