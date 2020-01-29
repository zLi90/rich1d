%% Update water content with explicit scheme
function [data] = updateWC(data, config)

    for ii = 1:config.Nz
        if ii == 1
            Kp = 0.5 * (data.Kr(ii) + data.Kr(ii+1));
            Km = data.Kr(ii);
            Qin = config.dt * Kp * ((data.h(ii+1)-data.h(ii))/data.dzf(ii) - 1.0);
            if config.bcType(1) == 1
                Qou = config.dt * Km * (2.0*(data.h(ii)-config.htop)/data.dzf(ii) - 1.0);
            elseif config.bcType(1) == 0
                Qou = config.dt * config.qtop;
            end
        elseif ii == config.Nz
            Kp = data.Kr(ii);
            Km = 0.5 * (data.Kr(ii) + data.Kr(ii-1));
            Qou = config.dt * Km * ((data.h(ii)-data.h(ii-1))/data.dzf(ii-1) - 1.0);
            if config.bcType(2) == 1
                Qin = config.dt * Kp * (2.0*(config.hbot-data.h(ii))/data.dzf(ii) - 1.0);
            elseif config.bcType(2) == 0
                Qin = config.dt * config.qbot;
            elseif config.bcType(2) == 2
                Qin = config.dt * Kp;
            end
        else
            Kp = 0.5 * (data.Kr(ii) + data.Kr(ii+1));
            Km = 0.5 * (data.Kr(ii) + data.Kr(ii-1));
            Qin = config.dt * Kp * ((data.h(ii+1)-data.h(ii))/data.dzf(ii) - 1.0);
            Qou = config.dt * Km * ((data.h(ii)-data.h(ii-1))/data.dzf(ii-1) - 1.0);
        end
        % check if outflow > total water volume
        if Qou > data.V(ii)
            Qou = data.V(ii);
        end
        data.wc(ii) = data.wcn(ii) + (Qin - Qou) / config.dz; 
        data.V(ii) = config.dz * data.wc(ii);
    end
    
end