function brant_config_figure(h_fig, conf_type, varargin)
% h_fig: handle of main figure
% conf_type: type of ui elements' uints
% varargin: handle of text with sroll bars

set(h_fig, 'resize', 'on');
set(findall(h_fig, '-property', 'Units' ), 'Units', conf_type);
set(findall(h_fig, '-property', 'FontUnits' ), 'FontUnits', conf_type);

if nargin > 2
    if verLessThan('matlab','8.5')
        set(h_fig, 'ResizeFcn', {@brant_size_change, varargin{1}});
    else
        set(h_fig, 'SizeChangedFcn', {@brant_size_change, varargin{1}});
    end
end

function brant_size_change(obj, evd, h_text) %#ok<INUSL>
try
%     h_text = varargin{1};
    jEdit1 = findjobj(h_text);
    jEditbox1 = jEdit1.getViewport().getComponent(0);
    jEditbox1.setWrapping(false);                % turn off word-wrapping
    jEditbox1.setEditable(false);                % non-editable
    set(jEdit1, 'HorizontalScrollBarPolicy', 30);  % HORIZONTAL_SCROLLBAR_AS_NEEDED
catch
end