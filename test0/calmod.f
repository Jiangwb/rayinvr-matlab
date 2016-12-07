c
c     version 1.3  Aug 1992
c
c     Calmod routine for RAYINVR
c
c     ----------------------------------------------------------------
c
      subroutine calmod(ncont,pois,poisb,poisl,poisbl,invr,iflagm,
     +                  ifrbnd,xmin1d,xmax1d,insmth,xminns,xmaxns)
c
c     calculate model parameters now for use later in program
c
c
      include 'rayinvr.par'
      real xa(2*(ppcntr+ppvel)),pois(player),poisbl(papois),
     +     zsmth(pnsmth)
      integer poisb(papois),poisl(papois),insmth(pncntr)
      include 'rayinvr.com'
      iflagm=0
      idvmax=0
      idsmax=0
c
      do 10 i=1,ncont
         do 20 j=1,ppcntr
            if(abs(xm(i,j)-xmax).lt..0001) go to 30
            nzed(i)=nzed(i)+1
20       continue
30       if(nzed(i).gt.1) then
           do 40 j=1,nzed(i)-1
              if(xm(i,j).ge.xm(i,j+1)) write(0,*) 1,i,j
              if(xm(i,j).ge.xm(i,j+1)) go to 999
40         continue
           if(abs(xm(i,1)-xmin).gt..001.or.
     +        abs(xm(i,nzed(i))-xmax).gt..001) write(0,*) 2,i
           if(abs(xm(i,1)-xmin).gt..001.or.
     +        abs(xm(i,nzed(i))-xmax).gt..001) go to 999
         else
            xm(i,1)=xmax
         end if
10    continue
      do 11 i=1,nlayer
         do 21 j=1,ppvel
            if(abs(xvel(i,j,1)-xmax).lt..0001) go to 31
            nvel(i,1)=nvel(i,1)+1
21       continue
31       if(nvel(i,1).gt.1) then
           do 41 j=1,nvel(i,1)-1
              if(xvel(i,j,1).ge.xvel(i,j+1,1)) write(0,*) 3,i,j
              if(xvel(i,j,1).ge.xvel(i,j+1,1)) go to 999
41         continue
           if(abs(xvel(i,1,1)-xmin).gt..001.or.abs(xvel(i,nvel(i,1),1)-
     +        xmax).gt..001) write(0,*) 4,i
           if(abs(xvel(i,1,1)-xmin).gt..001.or.abs(xvel(i,nvel(i,1),1)-
     +        xmax).gt..001) go to 999
         else
           if(vf(i,1,1).gt.0.) then
             xvel(i,1,1)=xmax
           else
             if(i.eq.1) then
              write(0,*) 5
               go to 999
             else
               nvel(i,1)=0
             end if
           end if
         end if
11    continue
      do 12 i=1,nlayer
         do 22 j=1,ppvel
            if(abs(xvel(i,j,2)-xmax).lt..0001) go to 32
            nvel(i,2)=nvel(i,2)+1
22       continue
32       if(nvel(i,2).gt.1) then
           do 42 j=1,nvel(i,2)-1
              if(xvel(i,j,2).ge.xvel(i,j+1,2)) write(0,*) 6,i,j
              if(xvel(i,j,2).ge.xvel(i,j+1,2)) go to 999
42         continue
           if(abs(xvel(i,1,2)-xmin).gt..001.or.abs(xvel(i,nvel(i,2),2)-
     +        xmax).gt..001) write(0,*) 7,i
           if(abs(xvel(i,1,2)-xmin).gt..001.or.abs(xvel(i,nvel(i,2),2)-
     +        xmax).gt..001) go to 999
         else
           if(vf(i,1,2).gt.0.) then
             xvel(i,1,2)=xmax
           else
             nvel(i,2)=0
           end if
         end if
12    continue
c
      do 50 i=1,nlayer
         xa(1)=xmin
         xa(2)=xmax
         ib=2
         ih=ib
         do 60 j=1,nzed(i)
            do 61 k=1,ih
               if(abs(xm(i,j)-xa(k)).lt..005) go to 60
61          continue
            ib=ib+1
            xa(ib)=xm(i,j)
60       continue
         ih=ib
         do 70 j=1,nzed(i+1)
            do 80 k=1,ih
               if(abs(xm(i+1,j)-xa(k)).lt..005) go to 70
80          continue
            ib=ib+1
            xa(ib)=xm(i+1,j)
70       continue
         ih=ib
         if(nvel(i,1).gt.0) then
           il=i
           is=1
         else
           if(nvel(i-1,2).gt.0) then
             il=i-1
             is=2
           else
             il=i-1
             is=1
           end if
         end if
         do 71 j=1,nvel(il,is)
            do 81 k=1,ih
               if(abs(xvel(il,j,is)-xa(k)).lt..005) go to 71
81          continue
            ib=ib+1
            xa(ib)=xvel(il,j,is)
71       continue
         if(nvel(i,2).gt.0) then
           ih=ib
           do 72 j=1,nvel(i,2)
              do 82 k=1,ih
                 if(abs(xvel(i,j,2)-xa(k)).lt..005) go to 72
82            continue
              ib=ib+1
              xa(ib)=xvel(i,j,2)
72         continue
         end if
c
         if(ib.gt.(ptrap+1)) then
           write(6,5) i
5          format(/'***  maximum number of blocks in layer ',
     +       i2,' exceeded  ***'/)
           iflagm=1
           return
         end if
c
         call sort(xa,ib)
c
         nblk(i)=ib-1
         do 90 j=1,nblk(i)
            xbnd(i,j,1)=xa(j)
            xbnd(i,j,2)=xa(j+1)
90       continue
c
50    continue
c
C       if(invr.eq.1) then
C         do 310 i=1,nlayer
C            ivlyr=0
C            do 320 j=1,nzed(i)
C               if(ivarz(i,j).ne.1.and.ivarz(i,j).ne.-1) ivarz(i,j)=0
C               if(ivarz(i,j).eq.-1) ivlyr=1
C 320        continue
C            if(ivlyr.eq.1) then
C              if(i.eq.1) write(0,*) 8
C              if(i.eq.1) go to 999
C              if(nzed(i).ne.nzed(i-1)) write(0,*) 9,i
C              if(nzed(i).ne.nzed(i-1)) go to 999
C              do 327 j=1,nzed(i)
C                 if(xm(i,j).ne.xm(i-1,j)) write(0,*) 10,i,j
C                 if(xm(i,j).ne.xm(i-1,j)) go to 999
C                 if(zm(i,j).lt.zm(i-1,j)) write(0,*) 11,i,j
C                 if(zm(i,j).lt.zm(i-1,j)) go to 999
C                 if(ivarz(i-1,j).eq.0.and.ivarz(i,j).eq.-1) ivarz(i,j)=0
C 327          continue
C            end if
C            do 321 j=1,nvel(i,1)
C               if(ivarv(i,j,1).ne.1) ivarv(i,j,1)=0
C 321        continue
C            ivgrad=0
C            if(nvel(i,2).gt.0) then
C              do 322 j=1,nvel(i,2)
C                 if(ivarv(i,j,2).ne.1.and.ivarv(i,j,2).ne.-1)
C      +             ivarv(i,j,2)=0
C                 if(ivarv(i,j,2).eq.-1) ivgrad=1
C 322          continue
C              if(ivgrad.eq.1) then
C                iflag=0
C                if(nvel(i,1).gt.0) then
C                  iflag=1
C                  ig=i
C                  jg=1
C                  go to 326
C                end if
C                if(i.gt.1.and.nvel(i,1).eq.0) then
C                  do 324 j=i-1,1,-1
C                    if(nvel(j,2).gt.0) then
C                      iflag=1
C                      ig=j
C                      jg=2
C                      go to 326
C                    end if
C                    if(nvel(j,1).gt.0) then
C                      iflag=1
C                      ig=j
C                      jg=1
C                      go to 326
C                    end if
C 324              continue
C                end if
C 326            if(iflag.eq.1.and.nvel(ig,jg).eq.nvel(i,2)) then
C                  do 323 j=1,nvel(ig,jg)
C           if(xvel(ig,j,jg).ne.xvel(i,j,2)) write(0,*) 12,i,j,ig,jg
C                     if(xvel(ig,j,jg).ne.xvel(i,j,2)) go to 999
C                     if(ivarv(ig,j,jg).eq.0.and.ivarv(i,j,2).eq.-1)
C      +                 ivarv(i,j,2)=0
C 323              continue
C                else
C           write(0,*) 13,i,ig,jg
C                  go to 999
C                end if
C              end if
C            end if
C 310     continue
C c
C         nvar=0
C         do 410 i=1,nlayer
C            do 420 j=1,nzed(i)
C c
C c             check for layer pinchouts
C c
C               iflag=0
C               if(i.gt.1) then
C                 do 427 k=1,i-1
C                    do 428 l=1,nzed(k)
C                       if(abs(xm(i,j)-xm(k,l)).lt..005.and.
C      +                   abs(zm(i,j)-zm(k,l)).lt..005) then
C                          iflag=1
C                          iv=ivarz(k,l)
C                          go to 429
C                       end if
C 428                continue
C 427             continue
C               end if
C 429           if(ivarz(i,j).eq.1.and.iflag.eq.0) then
C                 nvar=nvar+1
C                 ivarz(i,j)=nvar
C                 partyp(nvar)=1
C                 parorg(nvar)=zm(i,j)
C               else
C                 if(iflag.eq.1) then
C                   ivarz(i,j)=iv
C                 else
C                   if(ivarz(i,j).ne.-1) ivarz(i,j)=0
C                 end if
C               end if
C 420        continue
C c
C            do 421 j=1,nvel(i,1)
C               if(ivarv(i,j,1).eq.1) then
C                 nvar=nvar+1
C                 ivarv(i,j,1)=nvar
C                 partyp(nvar)=2
C                 parorg(nvar)=vf(i,j,1)
C               else
C                 ivarv(i,j,1)=0
C               end if
C 421        continue
C            if(nvel(i,2).gt.0) then
C              do 422 j=1,nvel(i,2)
C                 if(ivarv(i,j,2).eq.1) then
C                   nvar=nvar+1
C                   ivarv(i,j,2)=nvar
C                   partyp(nvar)=2
C                   parorg(nvar)=vf(i,j,2)
C                 end if
C 422          continue
C            end if
C 410     continue
C c
C c       check for inverting floating reflectors
C c
C         do 426 i=1,nfrefl
C            do 431 j=1,npfref(i)
C               if(ivarf(i,j).eq.1) then
C                 nvar=nvar+1
C                 ivarf(i,j)=nvar
C                 partyp(nvar)=3
C                 parorg(nvar)=zfrefl(i,j)
C               end if
C 431        continue
C 426     continue
C c
C         if(nvar.eq.0) then
C           write(6,445)
C 445       format(/'***  no parameters varied for inversion  ***'/)
C           invr=0
C         end if
C c
C         if(nvar.gt.pnvar) then
C           write(6,455)
C 455       format(/'***  too many parameters varied for inversion  ***'/)
C           iflagm=1
C           return
C         end if
C c
C       end if
C c
C c     calculate slopes and intercepts of each block boundary
C c
C       do 100 i=1,nlayer
C          do 110 j=1,nblk(i)
C             xbndc=xbnd(i,j,1)+.001
C             if(nzed(i).gt.1) then
C               do 120 k=1,nzed(i)-1
C                  if(xbndc.ge.xm(i,k).and.xbndc.le.xm(i,k+1)) then
C                    dx=xm(i,k+1)-xm(i,k)
C                    c1=(xm(i,k+1)-xbnd(i,j,1))/dx
C                    c2=(xbnd(i,j,1)-xm(i,k))/dx
C                    z1=c1*zm(i,k)+c2*zm(i,k+1)
C                    if(ivarz(i,k).ge.0) then
C                      iv=ivarz(i,k)
C                    else
C                      iv=ivarz(i-1,k)
C                    end if
C                    izv(i,j,1)=iv
C                    if(iv.gt.0) then
C                      cz(i,j,1,1)=xm(i,k+1)
C                      cz(i,j,1,2)=xm(i,k+1)-xm(i,k)
C                    end if
C                    c1=(xm(i,k+1)-xbnd(i,j,2))/dx
C                    c2=(xbnd(i,j,2)-xm(i,k))/dx
C                    z2=c1*zm(i,k)+c2*zm(i,k+1)
C                    if(ivarz(i,k+1).ge.0) then
C                      iv=ivarz(i,k+1)
C                    else
C                      iv=ivarz(i-1,k+1)
C                    end if
C                    izv(i,j,2)=iv
C                    if(iv.gt.0) then
C                      cz(i,j,2,1)=xm(i,k)
C                      cz(i,j,2,2)=xm(i,k+1)-xm(i,k)
C                    end if
C                    go to 130
C                  end if
C   120         continue
C             else
C               z1=zm(i,1)
C               if(ivarz(i,1).ge.0) then
C                 iv=ivarz(i,1)
C               else
C                 iv=ivarz(i-1,1)
C               end if
C               izv(i,j,1)=iv
C               if(iv.gt.0) then
C                 cz(i,j,1,1)=0.
C                 cz(i,j,1,2)=0.
C               end if
C               z2=zm(i,1)
C               izv(i,j,2)=0
C             end if
C 130         s(i,j,1)=(z2-z1)/(xbnd(i,j,2)-xbnd(i,j,1))
C             b(i,j,1)=z1-s(i,j,1)*xbnd(i,j,1)
C             if(nzed(i+1).gt.1) then
C               do 140 k=1,nzed(i+1)-1
C                  if(xbndc.ge.xm(i+1,k).and.xbndc.le.
C      +             xm(i+1,k+1)) then
C                    dx=xm(i+1,k+1)-xm(i+1,k)
C                    c1=(xm(i+1,k+1)-xbnd(i,j,1))/dx
C                    c2=(xbnd(i,j,1)-xm(i+1,k))/dx
C                    z3=c1*zm(i+1,k)+c2*zm(i+1,k+1)
C                    if(i.eq.nlayer) then
C                      izv(i,j,3)=0
C                    else
C                      if(ivarz(i+1,k).ge.0) then
C                        iv=ivarz(i+1,k)
C                      else
C                        iv=ivarz(i,k)
C                      end if
C                      izv(i,j,3)=iv
C                      if(iv.gt.0) then
C                        cz(i,j,3,1)=xm(i+1,k+1)
C                        cz(i,j,3,2)=xm(i+1,k+1)-xm(i+1,k)
C                      end if
C                    end if
C                    c1=(xm(i+1,k+1)-xbnd(i,j,2))/dx
C                    c2=(xbnd(i,j,2)-xm(i+1,k))/dx
C                    z4=c1*zm(i+1,k)+c2*zm(i+1,k+1)
C                    if(i.eq.nlayer) then
C                      izv(i,j,4)=0
C                    else
C                      if(ivarz(i+1,k+1).ge.0) then
C                        iv=ivarz(i+1,k+1)
C                      else
C                        iv=ivarz(i,k+1)
C                      end if
C                      izv(i,j,4)=iv
C                      if(iv.gt.0) then
C                        cz(i,j,4,1)=xm(i+1,k)
C                        cz(i,j,4,2)=xm(i+1,k+1)-xm(i+1,k)
C                      end if
C                    end if
C                    go to 150
C                  end if
C 140           continue
C             else
C               z3=zm(i+1,1)
C               if(i.eq.nlayer) then
C                 izv(i,j,3)=0
C               else
C                 if(ivarz(i+1,1).ge.0) then
C                   iv=ivarz(i+1,1)
C                 else
C                   iv=ivarz(i,1)
C                 end if
C                 izv(i,j,3)=iv
C                 if(iv.gt.0) then
C                   cz(i,j,3,1)=0.
C                   cz(i,j,3,2)=0.
C                 end if
C               end if
C               z4=zm(i+1,1)
C               izv(i,j,4)=0
C             end if
C 150         s(i,j,2)=(z4-z3)/(xbnd(i,j,2)-xbnd(i,j,1))
C             b(i,j,2)=z3-s(i,j,2)*xbnd(i,j,1)
C c
C c           check for layer pinchouts
C c
C             ivg(i,j)=1
C             if(abs(z3-z1).lt..0005) ivg(i,j)=2
C             if(abs(z4-z2).lt..0005) ivg(i,j)=3
C             if(abs(z3-z1).lt..0005.and.abs(z4-z2).lt..0005) ivg(i,j)=-1
C c
C 110      continue
C 100   continue
C c
C c     assign velocities to each model block
C c
C C       do 160 i=1,nlayer
C C c
C C          if(nvel(i,1).eq.0) then
C C            do 161 j=i-1,1,-1
C C               if(nvel(j,2).gt.0) then
C C                 ig=j
C C                 jg=2
C C                 n1g=nvel(j,2)
C C                 go to 162
C C               end if
C C               if(nvel(j,1).gt.0) then
C C                 ig=j
C C                 jg=1
C C                 n1g=nvel(j,1)
C C                 go to 162
C C               end if
C C 161        continue
C C          else
C C            ig=i
C C            jg=1
C C            n1g=nvel(i,1)
C C          end if
C C c
C C 162      if(n1g.gt.1.and.nvel(i,2).gt.1) ivcase=1
C C          if(n1g.gt.1.and.nvel(i,2).eq.1) ivcase=2
C C          if(n1g.eq.1.and.nvel(i,2).gt.1) ivcase=3
C C          if(n1g.eq.1.and.nvel(i,2).eq.1) ivcase=4
C C          if(n1g.gt.1.and.nvel(i,2).eq.0) ivcase=5
C C          if(n1g.eq.1.and.nvel(i,2).eq.0) ivcase=6
C C c
C C          do 170 j=1,nblk(i)
C C c
C C             if(ivg(i,j).eq.-1) go to 170
C C c
C C             xbndcl=xbnd(i,j,1)+.001
C C             xbndcr=xbnd(i,j,2)-.001
C C c
C C             go to (1001,1002,1003,1004,1005,1006), ivcase
C C c
C C 1001        do 180 k=1,n1g-1
C C                if(xbndcl.ge.xvel(ig,k,jg).and.xbndcl.le.xvel(ig,k+1,jg))
C C      +           then
C C                  dxx=xvel(ig,k+1,jg)-xvel(ig,k,jg)
C C                  c1=xvel(ig,k+1,jg)-xbnd(i,j,1)
C C                  c2=xbnd(i,j,1)-xvel(ig,k,jg)
C C                  vm(i,j,1)=(c1*vf(ig,k,jg)+c2*vf(ig,k+1,jg))/dxx
C C                  if(ig.ne.i) vm(i,j,1)=vm(i,j,1)+.001
C C                  if(invr.eq.1) then
C C                    iv=ivarv(ig,k,jg)
C C                    ivv(i,j,1)=iv
C C                    if(iv.gt.0) then
C C                      cf=c1/dxx
C C                      call cvcalc(i,j,1,1,cf)
C C                      if(ivg(i,j).eq.2) call cvcalc(i,j,1,3,cf)
C C                    end if
C C                    if(c2.gt..001) then
C C                      iv=ivarv(ig,k+1,jg)
C C                      ivv(i,j,2)=iv
C C                      if(iv.gt.0) then
C C                        cf=c2/dxx
C C                        call cvcalc(i,j,2,1,cf)
C C                        if(ivg(i,j).eq.2) call cvcalc(i,j,2,3,cf)
C C                      end if
C C                    end if
C C                  end if
C C                  go to 1811
C C                end if
C C 180         continue
C C c
C C 1811        do 1812 k=1,n1g-1
C C                if(xbndcr.ge.xvel(ig,k,jg).and.xbndcr.le.xvel(ig,k+1,jg))
C C      +           then
C C                  dxx=xvel(ig,k+1,jg)-xvel(ig,k,jg)
C C                  c1=xvel(ig,k+1,jg)-xbnd(i,j,2)
C C                  c2=xbnd(i,j,2)-xvel(ig,k,jg)
C C                  vm(i,j,2)=(c1*vf(ig,k,jg)+c2*vf(ig,k+1,jg))/dxx
C C                  if(ig.ne.i) vm(i,j,2)=vm(i,j,2)+.001
C C                  if(invr.eq.1) then
C C                    iv=ivarv(ig,k+1,jg)
C C                    ivv(i,j,2)=iv
C C                    if(iv.gt.0) then
C C                      cf=c2/dxx
C C                      call cvcalc(i,j,2,2,cf)
C C                      if(ivg(i,j).eq.3) call cvcalc(i,j,2,4,cf)
C C                    end if
C C                    if(c1.gt..001) then
C C                      iv=ivarv(ig,k,jg)
C C                      ivv(i,j,1)=iv
C C                      if(iv.gt.0) then
C C                        cf=c1/dxx
C C                        call cvcalc(i,j,1,2,cf)
C C                        if(ivg(i,j).eq.3) call cvcalc(i,j,1,4,cf)
C C                      end if
C C                    end if
C C                  end if
C C                  go to 181
C C                end if
C C 1812        continue
C C c
C C 181         do 182 k=1,nvel(i,2)-1
C C                if(xbndcl.ge.xvel(i,k,2).and.xbndcl.le.xvel(i,k+1,2))
C C      +           then
C C                  dxx=xvel(i,k+1,2)-xvel(i,k,2)
C C                  c1=xvel(i,k+1,2)-xbnd(i,j,1)
C C                  c2=xbnd(i,j,1)-xvel(i,k,2)
C C                  if(ivg(i,j).ne.2) then
C C                    vm(i,j,3)=(c1*vf(i,k,2)+c2*vf(i,k+1,2))/dxx
C C                  else
C C                    vm(i,j,3)=vm(i,j,1)
C C                  end if
C C                  if(invr.eq.1) then
C C                    if(ivg(i,j).eq.2) then
C C                      ivv(i,j,3)=0
C C                      icorn=0
C C                    else
C C                      iv=ivarv(i,k,2)
C C                      if(iv.gt.0) then
C C                        ivv(i,j,3)=iv
C C                        icorn=3
C C                      else
C C                        ivv(i,j,3)=0
C C                        if(iv.lt.0) then
C C                          icorn=1
C C                        else
C C                          icorn=0
C C                        end if
C C                      end if
C C                    end if
C C                    if(icorn.gt.0) then
C C                      cf=c1/dxx
C C                      call cvcalc(i,j,icorn,3,cf)
C C                    end if
C C c
C C                    if(c2.gt..001) then
C C                      if(ivg(i,j).eq.2) then
C C                        ivv(i,j,4)=0
C C                        icorn=0
C C                      else
C C                        iv=ivarv(i,k+1,2)
C C                        if(iv.gt.0) then
C C                          ivv(i,j,4)=iv
C C                          icorn=4
C C                        else
C C                          ivv(i,j,4)=0
C C                          if(iv.lt.0) then
C C                            icorn=2
C C                          else
C C                            icorn=0
C C                          end if
C C                        end if
C C                      end if
C C                      if(icorn.gt.0) then
C C                        cf=c2/dxx
C C                        call cvcalc(i,j,icorn,3,cf)
C C                      end if
C C                    end if
C C                  end if
C C                  go to 187
C C                end if
C C 182         continue
C C c
C C 187         do 1822 k=1,nvel(i,2)-1
C C                if(xbndcr.ge.xvel(i,k,2).and.xbndcr.le.xvel(i,k+1,2))
C C      +           then
C C                  dxx=xvel(i,k+1,2)-xvel(i,k,2)
C C                  c1=xvel(i,k+1,2)-xbnd(i,j,2)
C C                  c2=xbnd(i,j,2)-xvel(i,k,2)
C C                  if(ivg(i,j).ne.3) then
C C                    vm(i,j,4)=(c1*vf(i,k,2)+c2*vf(i,k+1,2))/dxx
C C                  else
C C                    vm(i,j,4)=vm(i,j,2)
C C                  end if
C C                  if(invr.eq.1) then
C C                    if(ivg(i,j).eq.3) then
C C                      ivv(i,j,4)=0
C C                      icorn=0
C C                    else
C C                      iv=ivarv(i,k+1,2)
C C                      if(iv.gt.0) then
C C                        ivv(i,j,4)=iv
C C                        icorn=4
C C                      else
C C                        ivv(i,j,4)=0
C C                        if(iv.lt.0) then
C C                          icorn=2
C C                        else
C C                          icorn=0
C C                        end if
C C                      end if
C C                    end if
C C                    if(icorn.gt.0) then
C C                      cf=c2/dxx
C C                      call cvcalc(i,j,icorn,4,cf)
C C                    end if
C C c
C C                    if(c1.gt..001) then
C C                      if(ivg(i,j).eq.3) then
C C                        ivv(i,j,3)=0
C C                        icorn=0
C C                      else
C C                        iv=ivarv(i,k,2)
C C                        if(iv.gt.0) then
C C                          ivv(i,j,3)=iv
C C                          icorn=3
C C                        else
C C                          ivv(i,j,3)=0
C C                          if(iv.lt.0) then
C C                            icorn=1
C C                          else
C C                            icorn=0
C C                          end if
C C                        end if
C C                      end if
C C                      if(icorn.gt.0) then
C C                        cf=c1/dxx
C C                        call cvcalc(i,j,icorn,4,cf)
C C                      end if
C C                    end if
C C                  end if
C C                  go to 171
C C                end if
C C 1822        continue
C C c
C C 1002        do 183 k=1,n1g-1
C C                if(xbndcl.ge.xvel(ig,k,jg).and.xbndcl.le.xvel(ig,k+1,jg))
C C      +           then
C C                  dxx=xvel(ig,k+1,jg)-xvel(ig,k,jg)
C C                  c1=xvel(ig,k+1,jg)-xbnd(i,j,1)
C C                  c2=xbnd(i,j,1)-xvel(ig,k,jg)
C C                  vm(i,j,1)=(c1*vf(ig,k,jg)+c2*vf(ig,k+1,jg))/dxx
C C                  if(ig.ne.i) vm(i,j,1)=vm(i,j,1)+.001
C C                  if(invr.eq.1) then
C C                    iv=ivarv(ig,k,jg)
C C                    ivv(i,j,1)=iv
C C                    if(iv.gt.0) then
C C                      cf=c1/dxx
C C                      call cvcalc(i,j,1,1,cf)
C C                    end if
C C                    if(c2.gt..001) then
C C                      iv=ivarv(ig,k+1,jg)
C C                      ivv(i,j,2)=iv
C C                      if(iv.gt.0) then
C C                        cf=c2/dxx
C C                        call cvcalc(i,j,2,1,cf)
C C                      end if
C C                    end if
C C                  end if
C C                  go to 1833
C C                end if
C C 183         continue
C C c
C C 1833        do 1832 k=1,n1g-1
C C                if(xbndcr.ge.xvel(ig,k,jg).and.xbndcr.le.xvel(ig,k+1,jg))
C C      +           then
C C                  dxx=xvel(ig,k+1,jg)-xvel(ig,k,jg)
C C                  c1=xvel(ig,k+1,jg)-xbnd(i,j,2)
C C                  c2=xbnd(i,j,2)-xvel(ig,k,jg)
C C                  vm(i,j,2)=(c1*vf(ig,k,jg)+c2*vf(ig,k+1,jg))/dxx
C C                  if(ig.ne.i) vm(i,j,2)=vm(i,j,2)+.001
C C                  if(invr.eq.1) then
C C                    iv=ivarv(ig,k+1,jg)
C C                    ivv(i,j,2)=iv
C C                    if(iv.gt.0) then
C C                      cf=c2/dxx
C C                      call cvcalc(i,j,2,2,cf)
C C                    end if
C C                    if(c1.gt..001) then
C C                      iv=ivarv(ig,k,jg)
C C                      ivv(i,j,1)=iv
C C                      if(iv.gt.0) then
C C                        cf=c1/dxx
C C                        call cvcalc(i,j,1,2,cf)
C C                      end if
C C                    end if
C C                  end if
C C                  go to 184
C C                end if
C C 1832        continue
C C c
C C 184         vm(i,j,3)=vf(i,1,2)
C C             if(ivg(i,j).eq.2) vm(i,j,3)=vm(i,j,1)
C C             vm(i,j,4)=vf(i,1,2)
C C             if(ivg(i,j).eq.3) vm(i,j,4)=vm(i,j,2)
C C             if(invr.eq.1) then
C C               iv=ivarv(i,1,2)
C C               ivv(i,j,3)=iv
C C               ivv(i,j,4)=0
C C               if(iv.gt.0) then
C C                 if(ivg(i,j).ne.2) call cvcalc(i,j,3,3,1.)
C C                 if(ivg(i,j).ne.3) call cvcalc(i,j,3,4,1.)
C C               end if
C C             end if
C C             go to 171
C C c
C C 1003        vm(i,j,1)=vf(ig,1,jg)
C C             vm(i,j,2)=vf(ig,1,jg)
C C             if(ig.ne.i) then
C C               vm(i,j,1)=vm(i,j,1)+.001
C C               vm(i,j,2)=vm(i,j,2)+.001
C C             end if
C C             if(invr.eq.1) then
C C               iv=ivarv(ig,1,jg)
C C               ivv(i,j,1)=iv
C C               ivv(i,j,2)=0
C C               if(iv.gt.0) then
C C                 call cvcalc(i,j,1,1,1.)
C C                 call cvcalc(i,j,1,2,1.)
C C               end if
C C             end if
C C c
C C             do 185 k=1,nvel(i,2)-1
C C                if(xbndcl.ge.xvel(i,k,2).and.xbndcl.le.xvel(i,k+1,2))
C C      +           then
C C                  dxx=xvel(i,k+1,2)-xvel(i,k,2)
C C                  c1=xvel(i,k+1,2)-xbnd(i,j,1)
C C                  c2=xbnd(i,j,1)-xvel(i,k,2)
C C                  if(ivg(i,j).ne.2) then
C C                    vm(i,j,3)=(c1*vf(i,k,2)+c2*vf(i,k+1,2))/dxx
C C                  else
C C                    vm(i,j,3)=vm(i,j,1)
C C                  end if
C C                  if(invr.eq.1) then
C C                    if(ivg(i,j).eq.2) then
C C                      ivv(i,j,3)=0
C C                      icorn=1
C C                    else
C C                      iv=ivarv(i,k,2)
C C                      if(iv.gt.0) then
C C                        ivv(i,j,3)=iv
C C                        icorn=3
C C                      else
C C                        ivv(i,j,3)=0
C C                        icorn=0
C C                      end if
C C                    end if
C C                    if(icorn.gt.0) then
C C                      cf=c1/dxx
C C                      call cvcalc(i,j,icorn,3,cf)
C C                    end if
C C c
C C                    if(c2.gt..001) then
C C                      if(ivg(i,j).eq.2) then
C C                        ivv(i,j,3)=0
C C                        icorn=2
C C                      else
C C                        iv=ivarv(i,k+1,2)
C C                        if(iv.gt.0) then
C C                          ivv(i,j,4)=iv
C C                          icorn=4
C C                        else
C C                          ivv(i,j,4)=0
C C                          icorn=0
C C                        end if
C C                      end if
C C                      if(icorn.gt.0) then
C C                        cf=c2/dxx
C C                        call cvcalc(i,j,icorn,3,cf)
C C                      end if
C C                    end if
C C                  end if
C C                  go to 188
C C                end if
C C 185         continue
C C c
C C 188         do 1851 k=1,nvel(i,2)-1
C C                if(xbndcr.ge.xvel(i,k,2).and.xbndcr.le.xvel(i,k+1,2))
C C      +           then
C C                  dxx=xvel(i,k+1,2)-xvel(i,k,2)
C C                  c1=xvel(i,k+1,2)-xbnd(i,j,2)
C C                  c2=xbnd(i,j,2)-xvel(i,k,2)
C C                  if(ivg(i,j).ne.3) then
C C                    vm(i,j,4)=(c1*vf(i,k,2)+c2*vf(i,k+1,2))/dxx
C C                  else
C C                    vm(i,j,4)=vm(i,j,2)
C C                  end if
C C                  if(invr.eq.1) then
C C                    if(ivg(i,j).eq.3) then
C C                      ivv(i,j,4)=0
C C                      icorn=2
C C                    else
C C                      iv=ivarv(i,k+1,2)
C C                      if(iv.gt.0) then
C C                        ivv(i,j,4)=iv
C C                        icorn=4
C C                      else
C C                        ivv(i,j,4)=0
C C                        icorn=0
C C                      end if
C C                    end if
C C                    if(icorn.gt.0) then
C C                      cf=c2/dxx
C C                      call cvcalc(i,j,icorn,4,cf)
C C                    end if
C C c
C C                    if(c1.gt..001) then
C C                      if(ivg(i,j).eq.3) then
C C                        ivv(i,j,4)=0
C C                        icorn=1
C C                      else
C C                        iv=ivarv(i,k,2)
C C                        if(iv.gt.0) then
C C                          ivv(i,j,3)=iv
C C                          icorn=3
C C                        else
C C                          ivv(i,j,3)=0
C C                          icorn=0
C C                        end if
C C                      end if
C C                      if(icorn.gt.0) then
C C                        cf=c1/dxx
C C                        call cvcalc(i,j,icorn,4,cf)
C C                      end if
C C                    end if
C C                  end if
C C                  go to 171
C C                end if
C C 1851        continue
C C c
C C 1004        vm(i,j,1)=vf(ig,1,jg)
C C             vm(i,j,2)=vf(ig,1,jg)
C C             if(ig.ne.i) then
C C               vm(i,j,1)=vm(i,j,1)+.001
C C               vm(i,j,2)=vm(i,j,2)+.001
C C             end if
C C             if(invr.eq.1) then
C C               iv=ivarv(ig,1,jg)
C C               ivv(i,j,1)=iv
C C               ivv(i,j,2)=0
C C               if(iv.gt.0) then
C C                 call cvcalc(i,j,1,1,1.)
C C                 call cvcalc(i,j,1,2,1.)
C C               end if
C C             end if
C C c
C C             vm(i,j,3)=vf(i,1,2)
C C             if(ivg(i,j).eq.2) vm(i,j,3)=vm(i,j,1)
C C             vm(i,j,4)=vf(i,1,2)
C C             if(ivg(i,j).eq.3) vm(i,j,4)=vm(i,j,2)
C C             if(invr.eq.1) then
C C               iv=ivarv(i,1,2)
C C               if(iv.gt.0) then
C C                 ivv(i,j,3)=iv
C C                 icorn=3
C C               else
C C                 ivv(i,j,3)=0
C C                 if(iv.lt.0) then
C C                   icorn=1
C C                 else
C C                   icorn=0
C C                 end if
C C               end if
C C               ivv(i,j,4)=0
C C               if(icorn.gt.0) then
C C                 if(ivg(i,j).ne.2) call cvcalc(i,j,icorn,3,1.)
C C                 if(ivg(i,j).ne.3) call cvcalc(i,j,icorn,4,1.)
C C               end if
C C             end if
C C             go to 171
C C c
C C 1005        do 186 k=1,n1g-1
C C                if(xbndcl.ge.xvel(ig,k,jg).and.xbndcl.le.xvel(ig,k+1,jg))
C C      +           then
C C                  dxx=xvel(ig,k+1,jg)-xvel(ig,k,jg)
C C                  c1=xvel(ig,k+1,jg)-xbnd(i,j,1)
C C                  c2=xbnd(i,j,1)-xvel(ig,k,jg)
C C                  vm(i,j,1)=(c1*vf(ig,k,jg)+c2*vf(ig,k+1,jg))/dxx
C C                  if(ig.ne.i) vm(i,j,1)=vm(i,j,1)+.001
C C                  vm(i,j,3)=vm(i,j,1)
C C                  if(invr.eq.1) then
C C                    iv=ivarv(ig,k,jg)
C C                    ivv(i,j,1)=iv
C C                    if(iv.gt.0) then
C C                      cf=c1/dxx
C C                      call cvcalc(i,j,1,1,cf)
C C                      if(ivg(i,j).ne.2) call cvcalc(i,j,1,3,cf)
C C                    end if
C C                    if(c2.gt..001) then
C C                      iv=ivarv(ig,k+1,jg)
C C                      ivv(i,j,2)=iv
C C                      if(iv.gt.0) then
C C                        cf=c2/dxx
C C                        call cvcalc(i,j,2,1,cf)
C C                        if(ivg(i,j).ne.2) call cvcalc(i,j,2,3,cf)
C C                      end if
C C                    end if
C C                  end if
C C                  go to 1861
C C                end if
C C 186         continue
C C c
C C 1861        do 1862 k=1,n1g-1
C C                if(xbndcr.ge.xvel(ig,k,jg).and.xbndcr.le.xvel(ig,k+1,jg))
C C      +           then
C C                  dxx=xvel(ig,k+1,jg)-xvel(ig,k,jg)
C C                  c1=xvel(ig,k+1,jg)-xbnd(i,j,2)
C C                  c2=xbnd(i,j,2)-xvel(ig,k,jg)
C C                  vm(i,j,2)=(c1*vf(ig,k,jg)+c2*vf(ig,k+1,jg))/dxx
C C                  if(ig.ne.i) vm(i,j,2)=vm(i,j,2)+.001
C C                  vm(i,j,4)=vm(i,j,2)
C C                  if(invr.eq.1) then
C C                    iv=ivarv(ig,k+1,jg)
C C                    ivv(i,j,2)=iv
C C                    if(iv.gt.0) then
C C                      cf=c2/dxx
C C                      call cvcalc(i,j,2,2,cf)
C C                      if(ivg(i,j).ne.3) call cvcalc(i,j,2,4,cf)
C C                    end if
C C                    if(c1.gt..001) then
C C                      iv=ivarv(ig,k,jg)
C C                      ivv(i,j,1)=iv
C C                      if(iv.gt.0) then
C C                        cf=c1/dxx
C C                        call cvcalc(i,j,1,2,cf)
C C                        if(ivg(i,j).ne.3) call cvcalc(i,j,1,4,cf)
C C                      end if
C C                    end if
C C                    ivv(i,j,3)=0
C C                    ivv(i,j,4)=0
C C                  end if
C C                  go to 171
C C                end if
C C 1862        continue
C C c
C C 1006        vm(i,j,1)=vf(ig,1,jg)
C C             if(ig.ne.i) vm(i,j,1)=vm(i,j,1)+.001
C C             vm(i,j,2)=vm(i,j,1)
C C             vm(i,j,3)=vm(i,j,1)
C C             vm(i,j,4)=vm(i,j,1)
C C             if(invr.eq.1) then
C C               iv=ivarv(ig,1,jg)
C C               ivv(i,j,1)=iv
C C               ivv(i,j,2)=0
C C               ivv(i,j,3)=0
C C               ivv(i,j,4)=0
C C               if(iv.gt.0) then
C C                 call cvcalc(i,j,1,1,1.)
C C                 call cvcalc(i,j,1,2,1.)
C C                 call cvcalc(i,j,1,3,1.)
C C                 call cvcalc(i,j,1,4,1.)
C C               end if
C C             end if
C C c
C C c
C C c           calculate velocity coefficients
C C c
C C 171         s1=s(i,j,1)
C C             s2=s(i,j,2)
C C             b1=b(i,j,1)
C C             b2=b(i,j,2)
C C             xb1=xbnd(i,j,1)
C C             xb2=xbnd(i,j,2)
C C             if(ivg(i,j).eq.2) then
C C               z3=s(i,j,2)*xb1+b(i,j,2)+.001
C C               z4=s(i,j,2)*xb2+b(i,j,2)
C C               s2=(z4-z3)/(xb2-xb1)
C C               b2=z3-s2*xb1
C C             end if
C C             if(ivg(i,j).eq.3) then
C C               z3=s(i,j,2)*xb1+b(i,j,2)
C C               z4=s(i,j,2)*xb2+b(i,j,2)+.001
C C               s2=(z4-z3)/(xb2-xb1)
C C               b2=z3-s2*xb1
C C             end if
C C             v1=vm(i,j,1)
C C             v2=vm(i,j,2)
C C             v3=vm(i,j,3)
C C             v4=vm(i,j,4)
C C c
C C             c(i,j,1)=s2*(xb2*v1-xb1*v2)+b2*(v2-v1)-
C C      +               s1*(xb2*v3-xb1*v4)-b1*(v4-v3)
C C             c(i,j,2)=s2*(v2-v1)-s1*(v4-v3)
C C             c(i,j,3)=-xb2*v1+xb1*v2+xb2*v3-xb1*v4
C C             c(i,j,4)=-v2+v1+v4-v3
C C             c(i,j,5)=b2*(xb2*v1-xb1*v2)-b1*(xb2*v3-xb1*v4)
C C             c(i,j,6)=(s2-s1)*(xb2-xb1)
C C             c(i,j,7)=(b2-b1)*(xb2-xb1)
C C             c(i,j,8)=2.*c(i,j,2)*c(i,j,7)
C C             c(i,j,9)=c(i,j,2)*c(i,j,6)
C C             c(i,j,10)=c(i,j,4)*c(i,j,7)-c(i,j,3)*c(i,j,6)
C C             c(i,j,11)=c(i,j,1)*c(i,j,7)-c(i,j,5)*c(i,j,6)
C C c
C C             if(ivg(i,j).eq.-1) then
C C               vm(i,j,1)=0.
C C               vm(i,j,2)=0.
C C               vm(i,j,3)=0.
C C               vm(i,j,4)=0.
C C               do 172 k=1,11
C C                  c(i,j,1)=0.
C C 172           continue
C C             end if
C C             if(abs(vm(i,j,1)-vm(i,j,2)).le..001.and.abs(vm(i,j,2)-
C C      +        vm(i,j,3)).le..001.and.abs(vm(i,j,3)-vm(i,j,4)).le..001.
C C      +        and.ivg(i,j).ne.-1) ivg(i,j)=0
C C c
C C 170      continue
C C 160   continue
C c
C c     assign values to array vsvp
C c
C       if(pois(1).lt.-10.) then
C         do 190 i=1,nlayer
C            do 200 j=1,nblk(i)
C               vsvp(i,j)=0.57735
C 200        continue
C 190     continue
C       else
C         if(nlayer.gt.1) then
C           if(pois(2).lt.-10.) then
C             do 210 j=1,nblk(1)
C                vsvp(1,j)=sqrt((1.-2.*pois(1))/(2.*(1.-pois(1))))
C 210         continue
C             do 220 i=2,nlayer
C                do 230 j=1,nblk(i)
C                   vsvp(i,j)=vsvp(1,1)
C 230            continue
C 220         continue
C           else
C             do 240 i=1,nlayer
C                if(pois(i).lt.-10.) then
C                  do 250 j=1,nblk(i)
C                     vsvp(i,j)=0.57735
C 250              continue
C                else
C                  do 260 j=1,nblk(i)
C                     vsvp(i,j)=sqrt((1.-2.*pois(i))/(2.*(1.-pois(i))))
C 260              continue
C                end if
C 240         continue
C           end if
C         end if
C       end if
C c
C c     calculate velocity ratios for specific model blocks specified
C c     through the arrays poisbl, poisl and poisb
C c
C       i=1
C 270   if(poisbl(i).lt.-10.) go to 400
C       vsvp(poisl(i),poisb(i))=
C      +  sqrt((1.-2.*poisbl(i))/(2.*(1.-poisbl(i))))
C       i=i+1
C       if(i.le.papois) go to 270
C c
C c     calculation of smooth layer boundaries
C c
C 400   if(ibsmth.gt.0) then
C         xsinc=(xmax-xmin)/float(npbnd-1)
C         do 600 i=1,nlayer+1
C            if(i.lt.(nlayer+1)) then
C              il=i
C              ib=1
C            else
C              il=i-1
C              ib=2
C            end if
C            iblk=1
C            do 610 j=1,npbnd
C               x=xmin+float(j-1)*xsinc
C               if(x.lt.xmin) x=xmin+.001
C               if(x.gt.xmax) x=xmax-.001
C 620           if(x.ge.xbnd(il,iblk,1).and.x.le.xbnd(il,iblk,2)) then
C                 cosmth(i,j)=s(il,iblk,ib)*x+b(il,iblk,ib)
C                 go to 610
C               else
C                 iblk=iblk+1
C                 go to 620
C               end if
C 610        continue
C 600     continue
C         n1ns=nint(xminns/xsinc)+1
C         n2ns=nint(xmaxns/xsinc)+1
C         iflag12=0
C C         if(n1ns.ge.1.and.n1ns.le.npbnd.and.n2ns.ge.1.and.
C C      +  n2ns.le.npbnd.and.n1ns.lt.n2ns) iflag12=1
C C         if(nbsmth.gt.0) then
C C           do 630 i=1,nlayer+1
C C              if(xminns.lt.xmin.and.xmaxns.lt.xmin) then
C C                do 6630 j=1,pncntr
C C                   if(insmth(j).eq.i) go to 630
C C 6630           continue
C C              end if
C C              iflagns=0
C C              do 6640 j=1,pncntr
C C                 if(insmth(j).eq.i) iflagns=1
C C 6640         continue
C C              do 640 j=1,npbnd
C C                 zsmth(j)=cosmth(i,j)
C C 640          continue
C C              do 650 j=1,nbsmth
C C                 if(iflag12.eq.1.and.iflagns.eq.1) then
C C                   call smooth2(zsmth,npbnd,n1ns,n2ns)
C C                 else
C C                   call smooth(zsmth,npbnd)
C C                 end if
C C 650          continue
C C              do 660 j=1,npbnd
C C                 cosmth(i,j)=zsmth(j)
C C 660          continue
C C              if(idump.eq.2) then
C C                do 670 j=1,npbnd
C C                   x=xmin+float(j-1)*xsinc
C C                   write(12,635) x,zsmth(j)
C C 635               format(2f7.2)
C C 670            continue
C C              end if
C C 630       continue
C C         end if
C       end if
C c
C       if(idump.eq.1) then
C         write(12,15) nlayer
C 15      format('***  velocity model:  ***'//'number of layers=',i2)
C         do 510 i=1,nlayer
C            write(12,25) i,nblk(i)
C 25         format(/'layer#',i2,'  nblk=',i4,
C      +     ' (ivg,x1,x2,z11,z12,z21,z22,s1,b1,s2,b2,vp1,vs1,vp2,vs2,
C      +     vp3,vs3,vp4,vs4,c1,c2,...,c11)')
C            write(12,35) (ivg(i,j),j=1,nblk(i))
C            write(12,45) (xbnd(i,j,1),j=1,nblk(i))
C            write(12,45) (xbnd(i,j,2),j=1,nblk(i))
C            write(12,45) (s(i,j,1)*xbnd(i,j,1)+b(i,j,1),j=1,nblk(i))
C            write(12,45) (s(i,j,1)*xbnd(i,j,2)+b(i,j,1),j=1,nblk(i))
C            write(12,45) (s(i,j,2)*xbnd(i,j,1)+b(i,j,2),j=1,nblk(i))
C            write(12,45) (s(i,j,2)*xbnd(i,j,2)+b(i,j,2),j=1,nblk(i))
C            write(12,45) (s(i,j,1),j=1,nblk(i))
C            write(12,45) (b(i,j,1),j=1,nblk(i))
C            write(12,45) (s(i,j,2),j=1,nblk(i))
C            write(12,45) (b(i,j,2),j=1,nblk(i))
C            write(12,45) (vm(i,j,1),j=1,nblk(i))
C            write(12,45) (vm(i,j,1)*vsvp(i,j),j=1,nblk(i))
C            write(12,45) (vm(i,j,2),j=1,nblk(i))
C            write(12,45) (vm(i,j,2)*vsvp(i,j),j=1,nblk(i))
C            write(12,45) (vm(i,j,3),j=1,nblk(i))
C            write(12,45) (vm(i,j,3)*vsvp(i,j),j=1,nblk(i))
C            write(12,45) (vm(i,j,4),j=1,nblk(i))
C            write(12,45) (vm(i,j,4)*vsvp(i,j),j=1,nblk(i))
C            write(12,55) (c(i,j,1),j=1,nblk(i))
C            write(12,55) (c(i,j,2),j=1,nblk(i))
C            write(12,55) (c(i,j,3),j=1,nblk(i))
C            write(12,55) (c(i,j,4),j=1,nblk(i))
C            write(12,55) (c(i,j,5),j=1,nblk(i))
C            write(12,55) (c(i,j,6),j=1,nblk(i))
C            write(12,55) (c(i,j,7),j=1,nblk(i))
C            write(12,55) (c(i,j,8),j=1,nblk(i))
C            write(12,55) (c(i,j,9),j=1,nblk(i))
C            write(12,55) (c(i,j,10),j=1,nblk(i))
C            write(12,55) (c(i,j,11),j=1,nblk(i))
C 35         format(100i10)
C 45         format(100f10.4)
C 55         format(100e10.3)
C 510     continue
C c
C         xmod=xmax-xmin
C         write(12,65)
C 65      format(/'equivalent 1-dimensional velocity model:'/)
C         do 520 i=1,nlayer
C            z1sum=0.
C            z2sum=0.
C            vp1=0.
C            vp2=0.
C            vs1=0.
C            vs2=0.
C            vp1sum=0.
C            vp2sum=0.
C            vs1sum=0.
C            vs2sum=0.
C            xvmod=0.
C            do 530 j=1,nblk(i)
C               xblk=xbnd(i,j,2)-xbnd(i,j,1)
C               z11=s(i,j,1)*xbnd(i,j,1)+b(i,j,1)
C               z12=s(i,j,1)*xbnd(i,j,2)+b(i,j,1)
C               z21=s(i,j,2)*xbnd(i,j,1)+b(i,j,2)
C               z22=s(i,j,2)*xbnd(i,j,2)+b(i,j,2)
C               z1sum=z1sum+xblk*(z11+z12)/2.
C               z2sum=z2sum+xblk*(z21+z22)/2.
C               if(vm(i,j,1).gt..001) then
C                 vp1sum=vp1sum+xblk*(vm(i,j,1)+vm(i,j,2))/2.
C                 vs1sum=vs1sum+xblk*(vm(i,j,1)+vm(i,j,2))*vsvp(i,j)/2.
C                 vp2sum=vp2sum+xblk*(vm(i,j,3)+vm(i,j,4))/2.
C                 vs2sum=vs2sum+xblk*(vm(i,j,3)+vm(i,j,4))*vsvp(i,j)/2.
C                 xvmod=xvmod+xblk
C               end if
C 530        continue
C            z1=z1sum/xmod
C            z2=z2sum/xmod
C            if(xvmod.gt..000001) then
C              vp1=vp1sum/xvmod
C              vp2=vp2sum/xvmod
C              vs1=vs1sum/xvmod
C              vs2=vs2sum/xvmod
C            end if
C            write(12,75) i,z1,z2,vp1,vp2,vs1,vs2
C 75         format('layer# ',i2,'   z1=',f7.2,'   z2=',f7.2,
C      +            ' km'/9x,'  vp1=',f7.2,'  vp2=',f7.2,' km/s'/
C      +                  9x,'  vs1=',f7.2,'  vs2=',f7.2,' km/s')
C 520     continue
C c
C         if(xmin1d.lt.-999998.) xmin1d=xmin
C         if(xmax1d.lt.-999998.) xmax1d=xmax
C         write(12,175) xmin1d,xmax1d
C 175     format(/'1-dimensional P-wave velocity model between ',
C      +          f7.2,' and ',f7.2,' km:'/)
C         xmod=xmax1d-xmin1d
C         do 720 i=1,nlayer
C            z1sum=0.
C            z2sum=0.
C            vp1=0.
C            vp2=0.
C            vs1=0.
C            vs2=0.
C            vp1sum=0.
C            vp2sum=0.
C            vs1sum=0.
C            vs2sum=0.
C            xvmod=0.
C            do 730 j=1,nblk(i)
C               if(xbnd(i,j,1).ge.xmax1d) go to 730
C               if(xbnd(i,j,2).le.xmin1d) go to 730
C               if(xbnd(i,j,1).lt.xmin1d) then
C                 xb1=xmin1d
C               else
C                 xb1=xbnd(i,j,1)
C               end if
C               if(xbnd(i,j,2).gt.xmax1d) then
C                 xb2=xmax1d
C               else
C                 xb2=xbnd(i,j,2)
C               end if
C               xblk=xb2-xb1
C               z11=s(i,j,1)*xb1+b(i,j,1)
C               z12=s(i,j,1)*xb2+b(i,j,1)
C               z21=s(i,j,2)*xb1+b(i,j,2)
C               z22=s(i,j,2)*xb2+b(i,j,2)
C               z1sum=z1sum+xblk*(z11+z12)/2.
C               z2sum=z2sum+xblk*(z21+z22)/2.
C               if(vm(i,j,1).gt..001) then
C                 layer=i
C                 iblk=j
C                 v11=vel(xb1,z11)
C                 v12=vel(xb2,z12)
C                 v21=vel(xb1,z21)
C                 v22=vel(xb2,z22)
C                 vp1sum=vp1sum+xblk*(v11+v12)/2.
C                 vs1sum=vs1sum+xblk*(v11+v12)*vsvp(i,j)/2.
C                 vp2sum=vp2sum+xblk*(v21+v22)/2.
C                 vs2sum=vs2sum+xblk*(v21+v22)*vsvp(i,j)/2.
C                 xvmod=xvmod+xblk
C               end if
C 730        continue
C            z1=z1sum/xmod
C            z2=z2sum/xmod
C            if(xvmod.gt..000001) then
C              vp1=vp1sum/xvmod
C              vp2=vp2sum/xvmod
C              vs1=vs1sum/xvmod
C              vs2=vs2sum/xvmod
C            end if
C            write(12,155) i,xmax,0,z1,0
C 155        format(i2,1x,f7.2/i2,1x,f7.2/3x,i7)
C            write(12,155) i,xmax,0,vp1,0
C            write(12,155) i,xmax,0,vp2,0
C            if(i.eq.nlayer) write(12,165) i+1,xmax,0,z2
C 165        format(i2,1x,f7.2/i2,1x,f7.2)
C 720     continue
C       end if
C c
C       if(idump.eq.1) write(12,85)
C 85    format(/'layer   max. gradient (km/s/km)   block')
C c
C       do 910 i=1,nlayer
C          delv=0.
C          ibd=0
C          do 920 j=1,nblk(i)
C             if(ivg(i,j).lt.1) go to 920
C             if(ivg(i,j).eq.2) then
C               delv1=0.
C               delv3=0.
C             else
C               x1=xbnd(i,j,1)
C               z1=s(i,j,1)*x1+b(i,j,1)
C               denom=c(i,j,6)*x1+c(i,j,7)
C               vx=(c(i,j,8)*x1+c(i,j,9)*x1**2+c(i,j,10)*z1+
C      +            c(i,j,11))/denom**2
C               vz=(c(i,j,3)+c(i,j,4)*x1)/denom
C               delv1=(vx**2+vz**2)**.5
C               z3=s(i,j,2)*x1+b(i,j,2)
C               vx=(c(i,j,8)*x1+c(i,j,9)*x1**2+c(i,j,10)*z3+
C      +            c(i,j,11))/denom**2
C               vz=(c(i,j,3)+c(i,j,4)*x1)/denom
C               delv3=(vx**2+vz**2)**.5
C             end if
C             if(ivg(i,j).eq.3) then
C               delv2=0.
C               delv4=0.
C             else
C               x2=xbnd(i,j,2)
C               z2=s(i,j,1)*x2+b(i,j,1)
C               denom=c(i,j,6)*x2+c(i,j,7)
C               vx=(c(i,j,8)*x2+c(i,j,9)*x2**2+c(i,j,10)*z2+
C      +            c(i,j,11))/denom**2
C               vz=(c(i,j,3)+c(i,j,4)*x2)/denom
C               delv2=(vx**2+vz**2)**.5
C               z4=s(i,j,2)*x2+b(i,j,2)
C               vx=(c(i,j,8)*x2+c(i,j,9)*x2**2+c(i,j,10)*z4+
C      +            c(i,j,11))/denom**2
C               vz=(c(i,j,3)+c(i,j,4)*x2)/denom
C               delv4=(vx**2+vz**2)**.5
C             end if
C             delm=amax1(delv1,delv2,delv3,delv4)
C             if(delm.gt.delv) then
C               delv=delm
C               ibd=j
C             end if
C 920      continue
C          if(idump.eq.1) write(12,95) i,delv,ibd
C 95       format(i4,f17.4,i17)
C          if(delv.gt.dvmax) then
C            idvmax=idvmax+1
C            ldvmax(idvmax)=i
C          end if
C 910   continue
C c
C       if(idump.eq.1) write(12,105)
C 105   format(/'boundary   slope change (degrees)   between points')
C c
C       do 930 i=1,ncont
C          dslope=0.
C          ips1=0
C          ips2=0
C          if(nzed(i).gt.2) then
C            do 940 j=1,nzed(i)-2
C               slope1=(zm(i,j+1)-zm(i,j))/(xm(i,j+1)-xm(i,j))
C               slope2=(zm(i,j+2)-zm(i,j+1))/(xm(i,j+2)-xm(i,j+1))
C               ds1=atan(slope1)*pi18
C               ds2=atan(slope2)*pi18
C               if(abs(ds2-ds1).gt.dslope) then
C                 dslope=abs(ds2-ds1)
C                 ips1=j
C                 ips2=j+2
C               end if
C 940        continue
C          end if
C          if(idump.eq.1) write(12,115) i,dslope,ips1,ips2
C 115      format(i4,f19.4,12x,2i7)
C          if(dslope.gt.dsmax) then
C            idsmax=idsmax+1
C            ldsmax(idsmax)=i
C          end if
C 930   continue
c
      return
c
999   write(6,900)
900   format(/'***  error in velocity model 2 ***'/)
      iflagm=1
      return
      end
