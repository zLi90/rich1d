%% Update water content with explicit scheme
function [data] = updateWC(data, config)

    dQ = zeros(config.Nz,1);
    tmax0 = config.dt_max;
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
        
        
        % check if there is room for infiltration
        if strcmp(config.corrector, 'Li')
            if config.bcType(2) == 0 & config.qbot == 0
                room = 0;
                if ii ~= config.Nz
                    for jj = ii+1:config.Nz
                        room = room + max(config.wcs-data.wc(jj), 0) * config.dz;
                    end
                    if Qin < 0 && abs(Qin) > room
                        dQ(ii) = dQ(ii) + (abs(Qin) - room);
                        dQ(ii+1) = dQ(ii+1) - (abs(Qin)-room);
                    end
                end
            end
            if config.bcType(1) == 0 & config.qtop == 0
                room = 0;
                if ii ~= 1
                    for jj = ii-1:-1:1
                        room = room + max(config.wcs-data.wc(jj), 0) * config.dz;
                    end
                    if Qou < 0 && abs(Qou) > room
                        dQ(ii) = dQ(ii) + (abs(Qou) - room);
                        dQ(ii-1) = dQ(ii-1) - (abs(Qou)-room);
                    end
                end
            end
        end
        % check if outflow > total water volume
        if Qou > data.V(ii)
            Qou = data.V(ii);
            fprintf('Outflow truncated at layer = %d\n',ii);
        elseif Qin < -data.V(ii)
            Qin = -data.V(ii);
            fprintf('Outflow truncated at layer = %d\n',ii);
        end     
        
        
        data.wc(ii) = data.wcn(ii) + (Qin - Qou + dQ(ii)) / config.dz; 

        data.Qp(ii) = Qin + dQ(ii);
        data.Qm(ii) = Qou - dQ(ii);
        data.V(ii) = config.dz * data.wc(ii);
        
%         % get max dt from travel distance
%         if ii > 1 & ii < config.Nz
%             if data.wc(ii) > config.wcs
%                 dwc = config.wcs - data.wcn(ii);
%             else
%                 dwc = abs(data.wc(ii) - data.wcn(ii));
%             end
%             
%             if data.Qp(ii) > 0 & data.Qm(ii) > 0
%                 Kdhdz = abs(data.Qp(ii)) / (config.dt * dwc);
%             elseif data.Qp(ii) < 0 & data.Qm(ii) < 0
%                 Kdhdz = abs(data.Qm(ii)) / (config.dt * dwc);
%             else
%                 Kdhdz = max(abs(data.Qp(ii)), abs(data.Qm(ii))) / (config.dt * dwc);
%             end
%                             
%             tmax = config.Co_max * config.dz / Kdhdz;
%             if dwc > 1e-5 & tmax < tmax0
%                 tmax0 = tmax;
%             end
%         end
        
       
    end
%     data.TMAX = tmax0;
%     fprintf('TMAX = %f\n',data.TMAX);
    
    
end