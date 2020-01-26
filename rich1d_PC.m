%% Solve 1D Richards using P-C method by Lai2015

%% User settings
% domain
config.dz = 0.06;
config.Nz = 100;
config.dt = 300.0;
config.Nt = 100 * 86400 / config.dt;%60*24*4;
config.save = (86400 / config.dt) * [1 4 20 100];
% initial condition
config.hinit = 0.0;
% boundary condition (0 for Neumann, 1 for Dirichlet)
config.bcType = [0 1];
config.htop = 1.0;
config.qtop = 0.0;
config.hbot = 0.0;%config.hinit;
config.qbot = 0.0;
% parameters
config.wcr = 0.0;
config.wcs = 0.33;
config.Kz = 2.89e-6;
config.Ss = 9800 * (1e-7 + config.wcs*5e-10);
% config.Ss = 0;
% figure settings
config.fs = 14;

%% Initialize 
[data, out] = init(config);

%% Time stepping
tout = 1;
coeff = config.dt * config.dz;
for tt = 1:config.Nt
    % update coefficients at n-level
    [data] = computeWRC(data, config, 'h');
    data.hn = data.h;
    if tt == 1
        data.wcn = data.wch;
    else
        data.wcn = data.wc;
    end
    % build linear system
    [A, B] = linearSys(data, config);
    % solve the linear system
    data.h = A \ B;
    % compute wc using new h
    [data] = computeWRC(data, config, 'h');
    % update wc
    [data] = updateWC(data, config);
    % compute h using new wc
    [data] = computeWRC(data, config, 'h');
    % update h
    [data] = finalAdjust(data, config);
    fprintf('>>>> Time step %d has been completed!\n',tt);
    % save output 
    if ismember(tt, config.save)
        out.h(:,tout) = data.h;
        out.wc(:,tout) = data.wc;
        tout = tout + 1;
    end
end

%% Plot results
figure(1);
subplot(1,2,1);
for kk = 1:length(config.save)
    plot(flipud(out.wc(:,kk)),linspace(0,config.Nz/config.dz,config.Nz));
    hold on;
end
hold off;
grid on;
xlabel('Water content','FontSize',config.fs);

subplot(1,2,2);
for kk = 1:length(config.save)
    plot(flipud(out.h(:,kk)),linspace(0,config.Nz/config.dz,config.Nz));
    hold on;
end
hold off;
grid on;
xlabel('Head [m]','FontSize',config.fs);


