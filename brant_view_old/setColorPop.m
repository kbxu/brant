function data_type = setColorPop(data_type_val, color_pop_handle)
switch data_type_val
    case 1
        set(color_pop_handle, 'String', {'-select color-'});
        data_type = 'no data type';
    case 2
        set(color_pop_handle, 'String', {'-select color-'; 'yellow'; 'magenta'; 'cyan'; 'red'; 'green'; 'blue'});
        data_type = 'binary values';
    case 3 
        set(color_pop_handle, 'String', {'-select color-'; 'autumn'; 'hot'; 'HSV'; 'lines'});
        data_type = 'discrete positive values';
    case 4 
        set(color_pop_handle, 'String', {'-select color-'; 'autumn'; 'hot'; 'HSV'; 'lines'});
        data_type = 'continuous positive values';
    case 5
        set(color_pop_handle, 'String', {'-select color-';'winter - autumn'});
        data_type = 'positive and negative values';
end
