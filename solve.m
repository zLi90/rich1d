function [data, out, config] = solve(data, out, config)

tout = 1;
tt = 1;
T = 0;
dt0 = config.dt;
tVec = [];
iter = [0 0];
niter = 1;
tic;
data.redflag = zeros(config.Nz,1);

while T < config.T_final
%     data.redflag = 0;
    if sum(data.redflag) > 0 & config.dt > config.dt_minRed & config.dt_repeat == 1
        tt = tt - 1;
        T = T - dt0;
        config.dt = max(config.dt * 0.5, config.dt_minRed);
        fprintf('Time step %d is repeated! New dt = %f\n',tt,config.dt);
        data.wc = data.wcn;
        data.h = data.hn;
%         data.hn = data.hnn;
    else
        data.hnn = data.hn;
        data.hn = data.h;
        data.wcn = data.wc;
    end
    data.redflag = zeros(config.Nz,1);
    % update coefficients at n-level
    [data] = computeWRC(data, config);  
        
    % build linear system
    [A, B] = linearSys(data, config);
    % solve the linear system
    data.h = A \ B;
    niter = niter + 1;
    iter(niter,:) = [iter(niter-1,1)+1 T];
    % compute wc using new h
    [data] = computeWRC(data, config);
    % update wc
    [data] = updateWC(data, config);
    data.TMAX = data.dt_maxCo;
    % compute h using new wc
    [data] = computeWRC(data, config);
    % update h
%     [reshape(data.h,20,1) reshape(data.wc,20,1)]
    if strcmp(config.corrector, 'Li')
        [data, config] = finalAdjust2(data, config);
    else
        [data, config] = finalAdjust(data, config);
    end
    % adjust time step
    dt0 = config.dt;
    T = T + config.dt;
    [data, config] = timeStep(data, config, tVec);
    
    
    if sum(data.redflag) == 0
        tVec(tt) = T;
        dM = (sum(data.wc)*config.dz)-(config.wcinit*config.Nz*config.dz - config.qtop*T);
        
        fprintf('>>>> Time step %d completed! dt = %f, Time = %f, Mass error = %f\n',tt,config.dt,T,dM);
        fprintf('=======================================================\n');
        % save output 
        if strcmp(config.savetype, 'column')
            for ss = 1:length(config.save)
%                 if tt > 1 && tVec(tt)+config.dt >= config.save(ss) && tVec(tt) < config.save(ss)
                if T == config.save(ss)
                    fprintf('Saving output at %f!\n',T);
                    out.h(:,tout) = data.h;
                    out.wc(:,tout) = data.wc;
                    tout = tout + 1;
                end
            end
        elseif strcmp(config.savetype, 'time')
            % save time series output
            for ss = 1:length(config.save)
                loc = config.save(ss);
                out.h(tt,ss) = data.h(loc);
                out.wc(tt,ss) = data.wc(loc);
                out.tVec(tt) = T;
            end
        end
        % remove flux BC under certain circumstances
        if config.bcType(1) == 0
            if mean(data.wc) >= config.wcs
                if config.qtop < 0
%                     config.qtop = 0;
                    config.bcType(1) = 1;
                    config.htop = 0;
                end
                if config.qbot > 0
                    config.qbot = 0;
                end
            end
            if mean(data.wc) == config.wcr
                if config.qtop > 0
                    config.qtop = 0;
                end
                if config.qbot < 0
                    config.qbot = 0;
                end
            end
        end
        
    end
    
    % adjust time step to match output time
    for ss = 1:length(config.save)
        if config.save(ss) - T > 0 & config.save(ss) - T < config.dt
            config.dt = config.save(ss) - T;
        end
    end
    
    tt = tt + 1;
end
tf = toc;
out.time = tf;
fprintf('========== Total computation time = %f\n',tf);

out.tVec = tVec;
out.iter = iter;



end