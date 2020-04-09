%% Solve 1D Richards using P-C method by Lai2015

%% User settings
% simulation configuration
config.dz = 0.05;
config.Nz = 20;
config.dt = 0.5;
config.Nt = 8.64e4 * 2 / config.dt; % steps
config.corrector = 'Li';
% output control
config.save = [0.1 0.4 2]*86400;%[1 4 20 100]*86400; % seconds
config.T_final = config.dt * config.Nt;
config.savetype = 'column';
config.savename = 'out_scenario4_T6000Co2.mat';
% time control
config.dt_max = 6000;
config.dt_min = 0.5;
config.dt_adapt = 'peco';
config.Pe_max = 0.5;
config.Co_max = 2;
config.r_red = 0.9;
config.r_inc = 1.1;
config.dt_repeat = 0;
config.dt_minRed = 60.0;
% initial condition
config.hinit = 0.0;
config.wcinit = 0.3;
% boundary condition (0 for Neumann, 1 for Dirichlet, 2 for free drainage)
config.bcType = [0 0];
config.htop = 0.0;
config.qtop = 0.0;
config.hbot = 0.0;%config.hinit;
config.qbot = 0.0;
% soil parameters
config.wcr = 0.0;
config.wcs = 0.33;
config.Kz = 2.89e-6;
config.Ss = 1e-5;
config.alpha = 1.43;
config.n = 1.506;
config.wrf = 'h';


%% Run Simulation
% Steady 
[data, out] = init(config);
[data, out, config] = solve(data, out, config);
results.steady = out;
% Evaporation
config.dt = 0.5;
config.qtop = 2e-7;
[data, out] = init(config);
[data, out, config] = solve(data, out, config);
results.evap = out;
% Infiltration
config.Co_max = 0.9;
config.dt = 0.5;
config.wcinit = 0.03;
config.qtop = -2e-6;
[data, out] = init(config);
[data, out, config] = solve(data, out, config);
results.infiltdown = out;
% save output
results.zVec = linspace(0,config.Nz*config.dz,config.Nz);
save(config.savename,'results','-v7.3');
    
fprintf('Total computation time of PC solver = %f\n',out.time);





