%% Solve 1D Richards using P-C method by Lai2015

%% User settings
% simulation configuration
config.dz = 0.002;
config.Nz = 500;
config.dt = 0.00001;
config.Nt = 46800 / config.dt; % steps
config.corrector = 'Li';
% output control
config.save = [11700 23400 46800];
config.T_final = config.dt * config.Nt;
config.savetype = 'column';
config.savename = 'out_war2_N500T2.mat';
config.checkwc = 100;
config.track = 100;
% time control
config.dt_max = 2.0;
config.dt_min = 0.00001;
config.dt_adapt = 'fixed';
config.Pe_max = 0.5;
config.Co_max = 0.5;
config.r_red = 0.9;
config.r_inc = 1.1;
config.dt_repeat = 0;
config.dt_minRed = 60.0;
% initial condition
% config.hinit = -76.9881;
% config.wcinit = 0.2037;
config.hinit = -42.6503;
% config.wcinit = 0.033;
% boundary condition (0 for Neumann, 1 for Dirichlet, 2 for free drainage)
config.bcType = [1 0];
config.htop = 0.0;
config.qtop = 0.0;
config.hbot = 0.0;%config.hinit;
config.qbot = 0.0;
% soil parameters
% config.wcr = 0.186;
% config.wcs = 0.363;
% config.Kz = 1e-6;
% config.Ss = 1e-5;
% config.alpha = 1.0;
% config.n = 1.53;
config.wcr = 0.0;
config.wcs = 0.33;
config.Kz = 2.89e-6;
config.Ss = 1e-5;
config.alpha = 1.43;
config.n = 1.56;
config.wrf = 'h';


%% Run Simulation

% I-N
[data, out] = init(config);
if ~isfield(config, 'wcinit')
    config.wcinit = data.wc(end);
end
[data, out, config] = solve(data, out, config);
results.in = out;
% save output
results.zVec = linspace(0,config.Nz*config.dz,config.Nz);
save(config.savename,'results','-v7.3');
    
fprintf('Total computation time of PC solver = %f\n',out.time);





