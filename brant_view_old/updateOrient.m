function updateOrient(handle1, handle2, str1, str2, str3, str4, val)
if val < 0.25
    set(handle1, 'String', str1);
    set(handle2, 'String', str2);
elseif val > 0.75
    set(handle1, 'String', str2);
    set(handle2, 'String', str1);
else
    set(handle1, 'String', str3);
    set(handle2, 'String', str4);
end