function [pos_fp, pos_cb] = brant_interface_pos(h_size)

screensize = get(0,'screensize');
mainfig_pos = get(findobj(0,'Tag','figBRANT'),'Position');

upper_bounds = 30;   % title
side_bounds = 8;
lower_bounds = 9;

real_width = h_size(1) + side_bounds * 2;
real_height = h_size(2) + upper_bounds + lower_bounds;
real_width_m = 310 + side_bounds * 2;
real_height_m = 270 + upper_bounds + lower_bounds;

if((screensize(4) > (real_height + real_height_m)) && (mainfig_pos(2) > real_height))
    pos_fp = [mainfig_pos(1), mainfig_pos(2) - real_height];
    if(screensize(3) - real_width_m + side_bounds - mainfig_pos(1) > real_width)
        pos_cb = [mainfig_pos(1) + real_width, mainfig_pos(2) - real_height];
    else
        pos_cb = [mainfig_pos(1) - real_width, mainfig_pos(2) - real_height];
    end
else
    if ((screensize(3) - real_width_m + side_bounds - mainfig_pos(1)) < real_width)
        pos_fp(1) = mainfig_pos(1) - real_width;
        pos_cb(1) = mainfig_pos(1) - real_width*2;
    elseif (((screensize(3) - real_width_m + side_bounds - mainfig_pos(1)) >= real_width) && ((screensize(3) - real_width_m + side_bounds- mainfig_pos(1)) < real_width*2))
        pos_fp(1) = mainfig_pos(1) - real_width;
        pos_cb(1) = mainfig_pos(1) + real_width_m;
    else
        pos_fp(1) = mainfig_pos(1) + real_width_m;
        pos_cb(1) = mainfig_pos(1) + real_width_m + real_width;
    end
    if (mainfig_pos(2) + real_height_m - lower_bounds > real_height)
        pos_fp(2) = mainfig_pos(2) + real_height_m - real_height;
        pos_cb(2) = mainfig_pos(2) + real_height_m - real_height;
    else
        pos_fp(2) = lower_bounds;
        pos_cb(2) = lower_bounds;
    end
end
pos_fp(3:4) = h_size;
pos_cb(3:4) = h_size;
% 
%         if (screensize(3) - real_width_m - mainfig_pos(1) < real_width)
%             pos_fp(1) = mainfig_pos(1) - real_width*2;
%             pos_cb(1) = mainfig_pos(1) - real_width;
%         elseif(screensize(3) - 310 - mainfig_pos(1) >= real_width && (screensize(3) - real_width_m - mainfig_pos(1) < real_width*2))
%             pos_fp(1) = mainfig_pos(1) - real_width;
%             pos_cb(1) = mainfig_pos(1) + real_width_m;
%         else
%             pos_fp(1) = mainfig_pos(1) + real_width_m;
%             pos_cb(1) = mainfig_pos(1) + real_width_m + real_width;
%         end
%         if (mainfig_pos(2) + real_height_m - lower_bounds> real_height)
%             pos_fp(2) = mainfig_pos(2) + real_height_m - real_height;
%             pos_cb(2) = mainfig_pos(2) + real_height_m - real_height;
%         else
%             pos_fp(2) = lower_bounds;
%             pos_cb(2) = lower_bounds;
%         end


        
        
        
        
        
