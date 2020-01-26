%% Adjust h and wc to conserve mass
function [data] = finalAdjust(data, config)

    todown = zeros(config.Nz,1);
    toup = zeros(config.Nz,1);
    fromdown = zeros(config.Nz,1);
    fromup = zeros(config.Nz,1);
    for ii = 1:config.Nz
        if data.wc(ii) < config.wcs
            if ii == 1 || ii == config.Nz
                if data.wch(ii) > data.wc(ii)
                    dV = (data.wch(ii) - data.wc(ii)) * config.dz;
                    data.wc(ii) = data.wch(ii);
                    % move water from upwind cell
                    if ii > 1 && data.h(ii-1) > data.h(ii)
                        fromup(ii) = dV;
                    elseif ii < config.Nz && data.h(ii+1) > data.h(ii)
                        fromdown(ii) = dV;
                    end
                end
            else
                if data.wc(ii+1) >= config.wcs || data.wc(ii-1) >= config.wcs
                    if data.wch(ii) > data.wc(ii)
                        dV = (data.wch(ii) - data.wc(ii)) * config.dz;
                        data.wc(ii) = data.wch(ii);
                        % move water from upwind cell
                        if ii > 1 && data.h(ii-1) > data.h(ii)
                            fromup(ii) = dV;
                        elseif ii < config.Nz && data.h(ii+1) > data.h(ii)
                            fromdown(ii) = dV;
                        end
                    end
                else
                    data.h(ii) = data.hwc(ii);
                end
            end
        else
            dV = (data.wc(ii) - config.wcs) * config.dz;
            if dV > 0
                data.wc(ii) = config.wcs;
                % move excess water to downwind cell
                if ii < config.Nz && data.h(ii) > data.h(ii+1)
                    todown(ii) = dV;
                elseif ii > 1 && data.h(ii) > data.h(ii-1)
                    toup(ii) = dV;
                end
            end
        end 
        
    end
    % adjust wc for excess or inadequate water
    for ii = 1:config.Nz
        if todown(ii) > 0
            data.wc(ii+1) = min((data.wc(ii+1)*config.dz + todown(ii))/config.dz, 1.0);
        end
        if toup(ii) > 0
            data.wc(ii-1) = min((data.wc(ii-1)*config.dz + toup(ii))/config.dz, 1.0);
        end
        if fromdown(ii) > 0
            data.wc(ii+1) = max((data.wc(ii+1)*config.dz - fromdown(ii))/config.dz, config.wcr);
        end
        if fromup(ii) > 0
            data.wc(ii-1) = max((data.wc(ii-1)*config.dz - fromup(ii))/config.dz, config.wcr);
        end 
    end
    for ii = 1:config.Nz
        if data.wc(ii) > config.wcs
            data.wc(ii) = config.wcs;
        end
    end
end