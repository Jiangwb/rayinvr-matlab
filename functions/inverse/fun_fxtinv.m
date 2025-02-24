% inv.f
% [~]
% called by: main;
% call: none.

function [npt] = fun_fxtinv(npt)
% keep track of those rays in the current family which reach the
% surface of the model

    % global file_rayinvr_par file_rayinvr_com;
    % run(file_rayinvr_par);
    % run(file_rayinvr_com);

    global ninv ntt range_ tfinv tt vr xfinv;

    if vr(npt,2) ~= 0.0
        xfinv(ninv) = range_(ntt-1);
        tfinv(ninv) = tt(ntt-1);
    else
        ninv = ninv - 1;
    end
    return;
end % fun_fxtinv end
