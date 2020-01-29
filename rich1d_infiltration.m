%% Solve 1D Richards using P-C method by Lai2015

%% User settings
% domain
config.dz = 0.004;
config.Nz = 150;
config.dt = 0.1;
config.Nt = 4 * 3600 / config.dt;%60*24*4;
config.outItvl = 600;
config.save = config.Nt * [0.1 0.2 0.4 0.8];
% initial condition
config.wcinit = 0.3;
% boundary condition (0 for Neumann, 1 for Dirichlet, 2 for free drainage)
config.bcType = [1 2];
config.htop = 0.0;
config.qtop = 0.0;
config.hbot = 0.0;%config.hinit;
config.qbot = 0.0;
% parameters
config.wcr = 0.062;
config.wcs = 0.46;
config.Kz = 1.22e-6;
config.Ss = 9800 * (1e-7 + config.wcs*5e-10);
% config.Ss = 0;
% figure settings
config.fs = 14;

%% Initialize 
a = 3.7;
n = 1.67;
m = 1 - 1/n;
config.hinit = -(((config.wcs-config.wcr)/(config.wcinit-config.wcr))^(1/m) - 1)^(1/n) / a;
[data, out] = init(config);
out.hT = zeros(config.Nt/config.outItvl,4);
out.wcT = zeros(config.Nt/config.outItvl,4);

%% Time stepping
tout = 1;
toutT = 1;
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
    if round(tt / config.outItvl) == tt/config.outItvl
        out.hT(toutT,:) = [data.h(13) data.h(25) data.h(38) data.h(50)];
        out.wcT(toutT,:) = [data.wc(13) data.wc(25) data.wc(38) data.wc(50)];
        toutT = toutT + 1;
    end
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


