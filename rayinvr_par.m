%% initialize all parameters in rayinvr.par

% 使用全局变量 has_rayinvr_par_init 避免该文件中的变量被重复定义
global has_rayinvr_par_init;

%% use "global" variables to substitute the common blocks
%% these variables should have been in rayinvr_com.m
%% but global variables must initialize first in matlab.

global player ppcntr ptrap pshot prayf ptrayf ppray pnrayf ...
       pray prefl preflt pconv pconvt pnsmth pnvar ... % papois
       prayi ppvel pncntr picv pinvel prayt pshot2 pfrefl ...
       ppfref pn2pt pnobsf pr2pt pcol pxgrid pzgrid pitan ...
       pitan2 piray;
global pi4 pi2 pi34 pi18 pit2;

if isempty(has_rayinvr_par_init)
    %% these parameters are all constant.

    % pi = 3.141592654;
    % pi4 = 0.785398163;
    % pi2 = 1.570796327;
    % pi34 = 2.35619449;
    % pi18 = 57.29577951;
    % pit2 = -6.283185307;
    pi4 = pi / 4;
    pi2 = pi / 2;
    pi34 = pi * 3 / 4;
    pi18 = 180 / pi;
    pit2 = - pi * 2;

    player = 42;      % model layers
    ppcntr = 300;     % points defining a single model layer(must be a multiple of 10)
    ptrap = 300;      % trapezoids within a layer
    pshot = 200;      % shot points
    prayf = 30;       % ray groups for a single shot
    ptrayf = 3000;    % ray groups for all shots
    ppray = 500;      % points defining a single ray
    pnrayf = 1000;    % rays in a single group
    pray = 100000;    % rays reaching the surface (not including the search mode)
    prefl = 20;       % reflecting boundaries for a single group
    preflt = 150;     % reflecting boundaries for all groups
    pconv = 10;       % converting boundaries for a single group
    pconvt = 100;     % converting boundaries for all groups
    pnsmth = 500;     % points defining smooth layer boundary
    % papois = 50;      % blocks within which Poisson's ratio is altered
    pnvar = 400;      % model parameters varied in inversion
    prayi = 100000;   % travel times used in inversion
    ppvel = 300;      % points at which upper & lower layer velocities defined(must be a multiple of 10)
    pfrefl = 10;      % floating refectors
    ppfref = 10;      % points defining a single floating reflector
    pn2pt = 15;       % iterations in two-point ray tracing search
    pnobsf = 1200;    % travel times with the same integer code for a single shot
    pcol = 20;        % colours for ray groups & observed travel times
    pxgrid = 1000;    % number of grid points in x-direction for output of uniformly sampled velocity model
    pzgrid = 500;     % number of grid points in z-direction for output of uniformly sampled velocity model
    pitan = 1000;     % number of intervals at which tangent function is pre-evaluated & used for interpolation
    piray = 100;      % intersections with model boundaries for a single ray

    pncntr = player + 1;
    picv = player * ptrap * 20;
    pinvel = player * 2;
    pshot2 = pshot * 2;
    prayt = pshot2 * prayf;
    pitan2 = pitan * 2;
    pr2pt = pnrayf + (pn2pt-1) * pnobsf;
end

if isempty(has_rayinvr_par_init)
    has_rayinvr_par_init = 1;
end
