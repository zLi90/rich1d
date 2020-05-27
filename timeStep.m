function [data, config] = timeStep(data, config, tVec)

    eps = 1e-9;
    s = 0.9;
    rmax = 4;
    rmin = 0.1;
    tau = 1e-3;
    
    if strcmp(config.dt_adapt, 'truncation')
        if length(tVec) > 1
            et = 0.5*tVec(end) * ...
                ((data.h-data.hn)/tVec(end) - (data.hn-data.hnn)/tVec(end-1));
            [val, ind] = max(abs(et));
            if val < tau
                coeff = min(s*sqrt(tau/max(abs(et(ind)),eps)), rmax);
            else
                coeff = max(s*sqrt(tau/max(abs(et(ind)),eps)), rmin);
            end
            config.dt = config.dt * coeff;
            if config.dt < config.dt_min
                config.dt = config.dt_min;
            end
        end
        data.redflag(:) = 0;
    elseif strcmp(config.dt_adapt, 'peco')
        eps = max(abs(data.Qp - data.Qm)) / config.dz;
        if eps > 0.02
            config.dt = config.dt * config.r_red;
        elseif eps < 0.01
            config.dt = config.dt * config.r_inc;
        end
        
        if config.dt > data.TMAX
            config.dt = data.TMAX;
        end
        
        if config.dt > config.dt_max
            config.dt = config.dt_max;
        elseif config.dt <= config.dt_min
            config.dt = config.dt_min;
        end
        data.redflag(:) = 0;
    else
        if config.dt_repeat == 1
            eps = max(abs(data.Qp - data.Qm)) / config.dz;
            if sum(data.redflag) == 0 | config.dt < config.dt_minRed
                if eps > 0.02
                    config.dt = config.dt * config.r_red;
                elseif eps < 0.01
                    config.dt = config.dt * config.r_inc;
                end
            end
            if config.dt > config.dt_max
                config.dt = config.dt_max;
            elseif config.dt <= config.dt_min
                config.dt = config.dt_min;
                data.redflag(:) = 0;
            elseif config.dt <= config.dt_minRed
                data.redflag(:) = 0;
            end
        else
            eps = max(abs(data.Qp - data.Qm)) / config.dz;
            if eps > 0.02
                config.dt = config.dt * config.r_red;
            elseif eps < 0.01
                config.dt = config.dt * config.r_inc;
            end
            
            if config.dt > config.dt_max
                config.dt = config.dt_max;
            elseif config.dt <= config.dt_min
                config.dt = config.dt_min;
            end
            data.redflag(:) = 0;
        end
    end
    


end