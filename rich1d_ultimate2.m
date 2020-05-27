%% Solve 1D Richards using P-C method by Lai2015

%% User settings
% simulation configuration
config.dz = 0.002;
config.Nz = 200;
config.dt = 0.00001;
config.Nt = 8.64e4 * 0.5 / config.dt; % steps
config.corrector = 'Lai';
% output control
config.save = [0.02 0.1 0.45]*86400;%[1 4 20 100]*86400; % seconds
config.T_final = config.dt * config.Nt;
config.savetype = 'column';
config.savename = 'out_ult2_T20Lmb.mat';
config.checkwc = 100;
config.track = 100;
% time control
config.dt_max = 20.0;
config.dt_min = 0.00001;
config.dt_adapt = 'fixed';
config.Pe_max = 0.5;
config.Co_max = 3.0;
config.r_red = 0.9;
config.r_inc = 1.1;
config.dt_repeat = 0;
config.dt_minRed = 60.0;
% initial condition
config.hinit = 0.0;
config.wcinit = 0.315;
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
config.n = 1.56;
config.wrf = 'h';


%% Run Simulation
% load(config.savename);
% N-N
[data, out] = init(config);
[data, out, config] = solve(data, out, config);
results.nn = out;
save('temp_1','results','-v7.3');

% E-N
config.dt = config.dt_min;
config.qtop = 2e-7;
[data, out] = init(config);
[data, out, config] = solve(data, out, config);
results.en = out;
save('temp_2','results','-v7.3');

% I-N
config.dt = config.dt_min;
config.wcinit = 0.03;
config.qtop = -2e-6;
[data, out] = init(config);
[data, out, config] = solve(data, out, config);
results.in = out;
save('temp_3','results','-v7.3');

% H-N
config.dt = config.dt_min;
config.bcType = [1 0];
config.qtop = 0;
config.htop = 0;
[data, out] = init(config);
[data, out, config] = solve(data, out, config);
results.hn = out;
save('temp_4','results','-v7.3');

% N-H
config.dt = config.dt_min;
config.wcinit = config.wcs;
config.bcType = [0 1];
config.hbot = 0;
config.qtop = 0;
[data, out] = init(config);
[data, out, config] = solve(data, out, config);
results.nh = out;
save('temp_5','results','-v7.3');

% E-H
config.dt = config.dt_min;
config.qtop = 2e-7;
[data, out] = init(config);
[data, out, config] = solve(data, out, config);
results.eh = out;
% save output
results.zVec = linspace(0,config.Nz*config.dz,config.Nz);
save(config.savename,'results','-v7.3');

fprintf('Total computation time of PC solver = %f\n',out.time);
