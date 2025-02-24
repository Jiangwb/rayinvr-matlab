% hdw.f
% old: [~,~,n,~,~,iflag,i1ray,~] = fun_hdwave(ifam,ir,n,invr,xsmax,iflag,i1ray,modout)
% [n,iflag,i1ray]
% called by: fun_trace;
% call: fun_block; fun_velprt; fun_bndprt; fun_vel; done.

function [n,iflag,i1ray] = fun_hdwave(ifam,ir,n,invr,xsmax,iflag,i1ray,modout)
% ray now travels along a layer boundary as a head wave.
% do not need to use runge kutta routine. after ray has
% traveled a distance hws further than previous ray, it
% is directed upward into the model.

    global fID_11 fID_12;
    global ar_ b cosmth dhw fid hws iblk ihdwf ivg iwave id idray iccbnd ...
        ihdw ihdwf icbnd idump ibsmth idiff layer nlayer nccbnd nbnd npskp ...
        nhskip nbnda nblk pi2 pi18 ppray piray ray s tdhw vr vp vs vsvp ...
        vm xr xsinc xbnd xmin zr;

    global c iblk layer; % for fun_vel

    dhw = 0.0;

    % 10 % -------------------- cycle10 begin
    cycle10 = true;
    while cycle10
        l1 = layer + 1;
        [ib] = fun_block(xr(n),l1 ,nblk,xbnd);
        if ivg(l1,ib)~=-1, break; end % go to 20
        layer = layer + 1;
        if layer == nlayer
            [vr,~,iflag,ihdwf] = fun_goto999(vr,n,iflag,ihdwf);
            return; % go to 999
        end
        continue; % go to 10
        break; % go to nothing
    end % -------------------- cycle10 end

    % 20
    layer = l1;
    iblk = ib;
    idray(2) = 3;
    hwsl = hws;
    ilr = (id+3) ./ 2;
    irl = (3-id) ./ 2;
    alpha_ = atan(s(layer,iblk,1));

    % 1000 % -------------------- cycle1000 begin
    cycle1000 = true;
    while cycle1000
        isGoto1000 = false;

        if dhw >= (tdhw-0.001)
            lstart = layer;
            istart = iblk;
            ihdw = 0;
            tdhw = tdhw + hws;
            if dhw == 0.0
                vh = fun_vel(xr(n),zr(n), c,iblk,layer);
                if iwave==-1, vh=vh.*vsvp(layer,iblk); end
            end

            % 30 % -------------------- cycle30 begin
            cycle30 = true;
            while cycle30
                l1 = layer - 1;
                [ib] = fun_block(xr(n),l1 ,nblk,xbnd);
                if ivg(l1,ib)~=-1, break; end % go to 40
                layer = layer - 1;
                if layer == 1
                    [vr,~,iflag,ihdwf] = fun_goto999(vr,n,iflag,ihdwf);
                    return; % go to 999
                end
                continue; % go to 30
                break; % go to nothing
            end % -------------------- cycle30 end

            % 40
            layer = l1;
            iblk = ib;
            vp(n,2) = fun_vel(xr(n),zr(n), c,iblk,layer);
            vs(n,2) = vp(n,2) .* vsvp(layer,iblk);
            nccbnd = nccbnd + 1;
            if icbnd(iccbnd) == nccbnd
                iconvt = 1;
                iwave = -iwave;
                iccbnd = iccbnd + 1;
            end
            if iwave == 1
                vr(n,2) = vp(n,2);
            else
                vr(n,2) = vs(n,2);
            end
            if iwave==-1 & vr(n,2)<=0.001
                vr(n,2) = 0.0;
                iflag = 1;
                if ir ~= 0
                    % 15
                    fprintf(fID_11, '***  ray stopped - s-wave cannot propagate  ***\n');
                end
                return;
            end
            if ibsmth == 0
                alpha_ = atan(s(layer,iblk,2));
            else
                npl = fix((xr(n)-xmin-0.001)./xsinc) + 1; % ifix -> fix
                npr = npl + 1;
                xpl = xmin + (npl-1) .* xsinc; % float
                alpha_ = (cosmth(layer+1,npr)-cosmth(layer+1,npl)) .* (xr(n)-xpl) ./ xsinc + cosmth(layer+1,npl);
            end
            if i1ray == 1
                nhskip = 0;
                i1ray = 0;
            else
                nhskip = n - 1;
            end
            if dhw ~= 0, vh = vr(n,1); end
            vratio = vr(n,2) ./ vh;
            if vratio >= 1
                if idiff == 0
                    vr(n,2) = 0.0;
                    iflag = 1;
                    return;
                else
                    a2 = 0.99999 .* pi2;
                end
            else
                a2 = asin(vratio);
            end
            ar_(n,2) = fid .* (pi-a2) - alpha_;
            if invr==1 & ir> 0
                [~,~,~,~,~,~,~,~,~] = fun_bndprt(lstart,istart,vr(n,1),vr(n,2),pi2,a2,alpha_,n,-1);
            end
            iflag = 0;
            return;
        else
            if idump == 1
                % 5
                fprintf(fID_12, '%2d%3d%4d%8.3f%8.3f%8.2f%8.2f%7.2f%7.2f%3d%3d%3d%3d\n', ...
                    ifam,ir,n,xr(n),zr(n),ar_(n,1).*pi18,ar_(n,2).*pi18,vr(n,1),vr(n,2),layer,iblk,id,iwave);
            end
        end

        % 500 % -------------------- cycle500 begin
        cycle500 = true;
        while cycle500
            isGoto1000 = false;

            xrp = xr(n) + fid.*hwsl.*cos(alpha_);
            if fid.*xrp > fid.*xbnd(layer,iblk,ilr)
                hl = abs(xbnd(layer,iblk,ilr)-xr(n)) ./ cos(alpha_);
                hwsl = hwsl - hl;
                if n == ppray
                    [~,vr,~,iflag,ihdwf] = fun_goto900(fID_11,vr,n,iflag,ihdwf)
                    return; % go to 900
                end
                n = n + 1;
                nbnd = nbnd + 1;
                if nbnd==piray, npskp=1; end
                if npskp~=1, nbnda(nbnd)=n; end
                xr(n) = xbnd(layer,iblk,ilr);
                zr(n) = s(layer,iblk,1) .* xr(n) + b(layer,iblk,1);
                if xsmax > 0.0 & abs(xr(n)-xr(1)) > xsmax
                    vr(n,2) = 0.0;
                    iflag = 1;
                    ihdwf = 0;
                    return;
                end
                vp(n,1) = vm(layer,iblk,ilr);
                vs(n,1) = vp(n,1) .* vsvp(layer,iblk);
                if iwave == 1
                    vr(n,1) = vp(n,1);
                else
                    vr(n,1) = vs(n,1);
                end
                ar_(n,1) = ar_(n-1,2);
                iblk = iblk + id;
                if iblk < 1 | iblk > nblk(layer)
                    [vr,~,iflag,ihdwf] = fun_goto999(vr,n,iflag,ihdwf);
                    return; % go to 999
                end

                % 50 % -------------------- cycle50 begin
                cycle50 = true;
                while cycle50
                    vp(n,2) = vm(layer,iblk,irl);
                    if vp(n,2) > 0.0, break; end % go to 60
                    l1 = layer + 1;
                    if l1 > nlayer
                        [vr,~,iflag,ihdwf] = fun_goto999(vr,n,iflag,ihdwf);
                        return; % go to 999
                    end
                    [ib] = fun_block(xr(n)+fid.*0.001,l1 ,nblk,xbnd);
                    layer = l1;
                    iblk = ib;
                    continue; % go to 50
                    break; % go to nothing
                end % -------------------- cycle50 end

                % 60
                vs(n,2) = vp(n,1) .* vsvp(layer,iblk);
                if iwave == 1
                    vr(n,2) = vp(n,2);
                else
                    vr(n,2) = vs(n,2);
                end
                alpha_ = atan(s(layer,iblk,1));
                ar_(n,2) = fid .* pi2 - alpha_;
                if invr == 1 & ir > 0
                    fun_velprt(layer,iblk,n);
                end

                if idump == 1
                    fprintf(fID_12, '%2d%3d%4d%8.3f%8.3f%8.2f%8.2f%7.2f%7.2f%3d%3d%3d%3d\n', ...
                        ifam,ir,n,xr(n),zr(n),ar_(n,1)*pi18,ar_(n,2)*pi18,vr(n,1),vr(n,2),layer,iblk,id,iwave);
                end

                continue; % go to 500
            else
                hwsl = hws;
                if n == ppray
                    [~,vr,~,iflag,ihdwf] = fun_goto900(fID_11,vr,n,iflag,ihdwf)
                    return; % go to 900
                end
                n = n + 1;
                nbnd = nbnd + 1;
                if nbnd==piray, npskp=1; end
                if npskp~=1, nbnda(nbnd)=n; end
                xr(n) = xrp;
                zr(n) = s(layer,iblk,1) .* xr(n) + b(layer,iblk,1);
                if xsmax > 0.0 & abs(xr(n)-xr(1)) > xsmax
                    vr(n,2) = 0.0;
                    iflag = 1;
                    ihdwf = 0;
                    return;
                end
                vp(n,1) = fun_vel(xr(n),zr(n), c,iblk,layer);
                vs(n,1) = vp(n,1) .* vsvp(layer,iblk);
                if iwave == 1
                    vr(n,1) = vp(n,1);
                else
                    vr(n,1) = vs(n,1);
                end
                ar_(n,1) = ar_(n-1,2);
                vp(n,2) = vp(n,1);
                vs(n,2) = vs(n,1);
                vr(n,2) = vr(n,1);
                ar_(n,2) = ar_(n,1);
                if invr == 1 & ir > 0
                    fun_velprt(layer,iblk,n);
                end
                dhw = dhw + hws;
                isGoto1000 = true; break; % go to 1000 step1
            end
            break; % go to nothing
        end % -------------------- cycle500 end
        if isGoto1000, continue; end % go to 1000 step2
        break; % go to nothing
    end % -------------------- cycle1000 end
    return;

end % fun_hdwave end


% ------------------------------------------------------------
% [vr,~,iflag,ihdwf]
function [vr,n,iflag,ihdwf] = fun_goto999(vr,n,iflag,ihdwf)
    vr(n,2) = 0.0;
    iflag = 1;
    ihdwf = 0;
    return;
end % fun_goto999 end

% ------------------------------------------------------------
% [~,vr,~,iflag,ihdwf]
function [fID_11,vr,n,iflag,ihdwf] = fun_goto900(fID_11,vr,n,iflag,ihdwf)
    % 25
    fprintf(fID_11, '***  ray stopped - consists of too many points  ***\n');
    vr(n,2) = 0.0;
    iflag = 1;
    ihdwf = 0;
    return;
end % fun_goto900 end
