%% Build linear system for head-based Richards
function [A, B] = linearSys(data, config)
    A = sparse(config.Nz,config.Nz);
    B = zeros(config.Nz,1);
    for ii = 1:config.Nz
        if ii == 1
            Kp = 0.5 * (data.Kr(ii) + data.Kr(ii+1));
            Km = data.Kr(ii);
            if config.bcType(1) == 1
                Km = config.Kz;
                B(ii) = data.C(ii)*data.hn(ii)*config.dz + config.dt*(Km - Kp) + ...
                    2.0 * Km * config.dt * config.htop / data.dzf(ii);
                A(ii,ii) = data.C(ii)*config.dz + config.dt*(2.0*Km/data.dzf(ii) + Kp/data.dzf(ii+1));
                A(ii,ii+1) = -Kp * config.dt / data.dzf(ii);
            elseif config.bcType(1) == 0
                B(ii) = data.C(ii)*data.hn(ii)*config.dz - config.dt*Kp - config.dt*config.qtop;
                A(ii,ii) = data.C(ii)*config.dz + config.dt*(Kp/data.dzf(ii+1));
                A(ii,ii+1) = -Kp * config.dt / data.dzf(ii);
            end
        elseif ii == config.Nz
            Kp = data.Kr(ii);
%             Kp = 0;
            Km = 0.5 * (data.Kr(ii) + data.Kr(ii-1));
            if config.bcType(2) == 1
                Kp = config.Kz;
                B(ii) = data.C(ii)*data.hn(ii)*config.dz + config.dt*(Km - Kp) + ...
                    2.0 * Kp * config.dt * config.hbot / data.dzf(ii);
                A(ii,ii) = data.C(ii)*config.dz + config.dt*(Km/data.dzf(ii-1) + 2.0*Kp/data.dzf(ii));
                A(ii,ii-1) = -Km * config.dt / data.dzf(ii-1);
            elseif config.bcType(2) == 0
                B(ii) = data.C(ii)*data.hn(ii)*config.dz + config.dt*Km - config.dt*config.qbot;
                A(ii,ii) = data.C(ii)*config.dz + config.dt*(Km/data.dzf(ii-1));
                A(ii,ii-1) = -Km * config.dt / data.dzf(ii-1);
            elseif config.bcType(2) == 2
                B(ii) = data.C(ii)*data.hn(ii)*config.dz + config.dt*Km - config.dt*Kp;
                A(ii,ii) = data.C(ii)*config.dz + config.dt*(Km/data.dzf(ii-1));
                A(ii,ii-1) = -Km * config.dt / data.dzf(ii-1);
            end 
        else
            % face Kr
            Kp = 0.5 * (data.Kr(ii) + data.Kr(ii+1));
            Km = 0.5 * (data.Kr(ii) + data.Kr(ii-1));
            B(ii) = data.C(ii)*data.hn(ii)*config.dz + config.dt*(Km - Kp);
            A(ii,ii) = data.C(ii)*config.dz + config.dt*(Km/data.dzf(ii-1) + Kp/data.dzf(ii));
            A(ii,ii+1) = -Kp * config.dt / data.dzf(ii);
            A(ii,ii-1) = -Km * config.dt / data.dzf(ii-1);
        end
        
    end

end