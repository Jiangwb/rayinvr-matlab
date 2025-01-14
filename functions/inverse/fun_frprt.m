% inv.f
% []
% called by: fun_frefl;
% call: none.

function fun_frprt(vfr,afr,alpha_,npt,ifrpt)
% calculate partial derivatives for floating reflectors

    global fpart ifcbnd ivarf ninv xfrefl xr;

    x1 = xfrefl(ifcbnd,ifrpt);
    x2 = xfrefl(ifcbnd,ifrpt+1);

    for ii = ifrpt:ifrpt+1 % 10
        if ivarf(ifcbnd,ii) > 0
            jv = ivarf(ifcbnd,ii);
            if x2-x1 ~= 0.0
                if ii == ifrpt
                    ind = ifrpt + 1;
                else
                    ind = ifrpt;
                end
                slptrm = cos(alpha_) .* abs(xfrefl(ifcbnd,ind)-xr(npt)) ./ (x2-x1);
            else
                slptrm = 1.0;
            end
            fpart(ninv,jv) = fpart(ninv,jv) + 2.0.*(cos(afr)./vfr).*slptrm;
        end
    end % 10
    return;

end % fun_frprt end
