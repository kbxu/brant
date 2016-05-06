function ind = brant_mpe_index(s)
% AMPE_index calculates the index of the given signal s.

 N = length(s);
%  sm=smooth(s)';
 
 Fs=fftshift(abs(fft(s)));
 Fs=Fs(N/2+2:N).^2;
 SDF=Fs;
 SDF=(smooth(SDF))';
         
 ind = find(SDF==max(SDF));
%          ind=ind+5;
 imax=ind;
 i0=imax;     
         
 while i0<floor(N/2)-1
      if SDF(i0)>SDF(i0+1)
           i0=i0+1;
      else
           break;
      end
 end

ind=min(i0,floor(N/6));
