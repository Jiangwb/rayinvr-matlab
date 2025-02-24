function [RMS, CHI] = start_rayinvr(pathIn, pathRin, pathVin, isUseOde)
% [RMS, CHI] = start_rayinvr(pathIn, pathRin, pathVin, isUseOde)
% Rayinvr forward calculating without GUI.

    if nargin < 1
        pathIn = fullfile(pwd, 'data', 'subbarao_s');
    end
    if nargin < 2
        pathRin = fullfile(pathIn, 'r.in');
    end
    if nargin < 3
        pathVin = fullfile(pathIn, 'v.in');
    end
    if nargin < 4
        isUseOde = false;
    end

    % Add functions to path.
    % `genpath` will add all the children path
    addpath(genpath('./functions'));

    obj.pathIn = pathIn;
    obj.pathRinm = fun_trans_rin2m(pathRin);
    % Clear cached r_in.m, or the modification for r.in won't work
    clear(obj.pathRinm);
    obj.pathVin = pathVin;
    obj.isUseOde = isUseOde;

    [RMS, CHI] = main(obj);

    rmpath(genpath('./functions'));
end
