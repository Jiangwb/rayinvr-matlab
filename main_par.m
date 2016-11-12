%% all parameters initialized in main.f

%real
amin = ones(1,prayt) * 181.0;
amax = ones(1,prayt) * 181.0;
xshot = zeros(1,pshot);
space = zeros(1,prayf);
zshot = ones(1,pshot) * -9999.0;
pois = ones(1,player) * -99.0;
poisbl = ones(1,papois) * -99.0;
parunc = zeros(1,3);
zsmth = zeros(1,pnsmth);
xshota = zeros(1,pshot2);
zshota = zeros(1,pshot2);
ta2pt = zeros(1,pr2pt);
ra2pt = zeros(1,pr2pt);
tt2pt = zeros(1,pr2pt);
xo2pt = zeros(1,pnobsf);
ho2pt = zeros(1,pr2pt);
tatan = zeros(1,pitan2);
angtan = zeros(1,pitan2);

%integer
idr = zeros(1,pshot2);
nray = ones(1,prayf) * -1;
itt = zeros(1,ptrayf);
ibrka = zeros(1,ptrayf);
ishot = zeros(1,pshot);
ncbnd = ones(1,prayf) * -1;
ivraya = zeros(1,ptrayf);
ishotr = zeros(1,pshot2);
nrbnd = zeros(1,prayf);
rbnd = zeros(1,preflt);
nsmax = ones(1,prayf) * -1;
ishotw = zeros(1,pshot2);
iturn = ones(1,prayf) * 1;
cbnd = ones(1,pconvt) * -99;
irayt = ones(1,prayt) * 1;
ihead = zeros(1,player);
poisl = zeros(1,papois);
poisb = zeros(1,papois);
ibreak = ones(1,prayf) * 1;
frbnd = zeros(1,prayf);
ifo2pt = zeros(1,pnobsf);
ipos = zeros(1,pr2pt);
modi = zeros(1,player);
nsmin = ones(1,prayf) * -1;
insmth = zeros(1,pncntr);

%character
flag = '';
%other
iline = 0;
ititle = 0;
xtitle = -9999999.0;
ytitle = -9999999.0;
title = ' ';
ifd = 0;
xminns = -999999.0;
xmaxns = -999999.0;
npskip = 1;
idiff = 0;
ntan = 90;
ifast = 1;
xmin1d = -999999.0;
xmax1d = -999999.0;
istep = 0;
iroute = 1;
xmmin = -999999.0;
xmmax = -999999.0;
frz = 0.0;
dxmod = 0.0;
dzmod = 0.0;
dxzmod = 0.0;
modout = 0;
i2pt = 0;
n2pt = 5;
x2pt = -1.0;
itxbox = 0;
nhray = -1;
ircol = 0;
itcol = 0;
isep = 0;
velunc = 0.1;
bndunc = 0.1;
dvmax = 1.e10;
dsmax = 1.e10;
itrev = 0;
xsmax = 0.0;
ntray = 0;
ntpts = 0;
isrch = 0;
istop = 1;
nstepr = 15;
narinv = 0;
nrskip = 1;
itxout = 0;
idata = 0;
isum = 1;
idash = 1;
ivel = 0;
iaxlab = 1;
idot = 0;
iszero = 0;
ibnd = 1;
imod = 1;
iray = 1;
irayps = 0;
nskip = 0;
invr = 0;
imodf = 0;
irays = 0;
iraysl = 0;
ncont = 1;
iflagi = 0;
nrayl = 0;
ifam = 0;
ictbnd = 0;
irbnd = 0;
nshot = 0;
ngroup = 0;
ia0 = 1;
ttunc = .01;
stol = -1.0;
velht = .7;
aamin = 5.0;
aamax = 85.0;
aainc = .1;
aaimin = 1.0;
ximax = -1.0;
i33 = 0;