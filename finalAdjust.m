%% Adjust h and wc to conserve mass
function [data, config] = finalAdjust(data, config)

    eps = 0e-8;
    data.wcp = data.wc;
    
    dsends = NaN;
    dsendu = NaN;
    drecv = NaN;
    
    todown = zeros(config.Nz,1);
    toup = zeros(config.Nz,1);
    fromdown = zeros(config.Nz,1);
    fromup = zeros(config.Nz,1);
    for ii = 1:config.Nz
        data.wcflag(ii) = 0;
        
        if data.wc(ii) < config.wcs-eps
            dV = abs(data.wch(ii) - data.wc(ii)) * config.dz;
            if ii == 1
                if config.bcType(1) == 0 && config.qtop >= 0
                    if data.wc(ii+1) < config.wcs-eps
                        data.h(ii) = data.hwc(ii);
                        data.wcflag(ii) = 2;
                    else
                        if data.wch(ii) > data.wc(ii)
                            data.wc(ii) = data.wch(ii);
                            if data.h(ii+1) > data.h(ii)+config.dz
                                fromdown(ii) = dV;
                            end
                        end
                    end
                elseif config.bcType(1) == 1 && config.htop >= 0
                    if data.wch(ii) > data.wc(ii)
                        data.wc(ii) = data.wch(ii);
                        if data.h(ii+1) > data.h(ii)+config.dz
                            fromdown(ii) = dV;
                        else
                            data.Qm(1) = data.Qm(1) - dV;
                        end
                    end
                else
                    data.h(ii) = data.hwc(ii);
%                     if data.wch(ii) > data.wc(ii)
%                         data.wc(ii) = data.wch(ii);
%                     end
                end
            elseif ii == config.Nz
                if config.bcType(2) ~= 1 && config.qbot == 0
                    if data.wc(ii-1) < config.wcs-eps
                        data.h(ii) = data.hwc(ii);
                        data.wcflag(ii) = 2;
                    else
                        if data.wch(ii) > data.wc(ii)
                            data.wc(ii) = data.wch(ii);
                            if data.h(ii-1) > data.h(ii)-config.dz
                                fromup(ii) = dV;
                            end
                        end
                    end
                elseif config.bcType(2) == 1 && config.hbot >= 0
                    if data.wch(ii) > data.wc(ii)
                        data.wc(ii) = data.wch(ii);
                        if data.h(ii-1) > data.h(ii)-config.dz
                            fromup(ii) = dV;
                        else
                            data.Qp(end) = data.Qp(end) + dV;
                        end
                    end
                else
                    error('Undefined case for corrector!');
                end
            else
                if data.wc(ii+1) >= config.wcs-eps || data.wc(ii-1) >= config.wcs-eps
                    if data.wch(ii) > data.wc(ii)
                        data.wc(ii) = data.wch(ii);
                        % move water from upwind cell
                        if data.h(ii) < data.h(ii-1)
                            fromup(ii) = dV;
                        elseif data.h(ii) < data.h(ii+1)
                            fromdown(ii) = dV;
                        end
                    end
                else
                    data.wcflag(ii) = 2;
                    data.h(ii) = data.hwc(ii);
                end
                drecv = track_dwc(data, drecv, ii, config);
            end
        else
            dV = (data.wc(ii) - config.wcs) * config.dz;
            if dV > 0
                data.wc(ii) = config.wcs;
                % move excess water to downwind cell
                if ii == config.Nz
                    if data.h(ii) > data.h(ii-1)+config.dz
                        toup(ii) = toup(ii) + dV;
                    else
                        if config.bcType(2) == 1
                            data.Qp(end) = data.Qp(end) - dV;
                        end
                    end
                elseif ii == 1
                    if data.h(ii) > data.h(ii+1)-config.dz
                        todown(ii) = todown(ii) + dV;
                    else
                        if config.bcType(1) == 1
                            data.Qm(1) = data.Qm(1) + dV;
                        end
                    end
                else
                    if data.h(ii) > data.h(ii+1)-config.dz
                        todown(ii) = todown(ii) + dV;                    
                    elseif data.h(ii) > data.h(ii-1)+config.dz
                        toup(ii) = toup(ii) + dV;
                    end
                end
            end
            dsends = track_dwc(data, dsends, ii, config);
        end 
        
    end
    % adjust wc for excess or inadequate water
    for ii = 1:config.Nz
        if todown(ii) > 0
            data.wc(ii+1) = min((data.wc(ii+1)*config.dz + todown(ii))/config.dz, 1.0);
            data.wcflag(ii) = 3;
        end
        if toup(ii) > 0
            data.wc(ii-1) = min((data.wc(ii-1)*config.dz + toup(ii))/config.dz, 1.0);
            data.wcflag(ii) = 3;
        end
        if fromdown(ii) > 0
            data.wc(ii+1) = max((data.wc(ii+1)*config.dz - fromdown(ii))/config.dz, config.wcr);
            data.wcflag(ii) = 1;
        end
        if fromup(ii) > 0
            data.wc(ii-1) = max((data.wc(ii-1)*config.dz - fromup(ii))/config.dz, config.wcr);
            data.wcflag(ii) = 1;
        end 
    end
    
    send_from_sat = data.wcflag == 3;
    recv = data.wcflag == 1;
    data.sendrecv(1) = sum(send_from_sat);
    data.sendrecv(2) = 0;
    data.sendrecv(3) = sum(recv);
    
    %% Summarize tracked wc change
    if ~isnan(dsends)
        data.wc_track = [dsends 1 data.wcp(config.track) data.wc(config.track)];
    elseif ~isnan(dsendu)
        data.wc_track = [dsendu 2 data.wcp(config.track) data.wc(config.track)];
    elseif ~isnan(drecv)
        data.wc_track = [drecv 3 data.wcp(config.track) data.wc(config.track)];
    else
        data.wc_track = [0 4 data.wcp(config.track) data.wc(config.track)];
    end
    
    for ii = 1:config.Nz
        if data.wc(ii) > config.wcs
            fprintf('Enforce over-sat cell %d to saturated condition!, wc = %f, flag = %d\n',...
                ii,data.wc(ii),data.wcflag(ii));
            data.loss = data.loss + (data.wc(ii)-config.wcs)*config.dz;
            data.wc(ii) = config.wcs;
        elseif data.wc(ii) < config.wcr+eps
            data.wc(ii) = config.wcr+eps;
            fprintf('Enforce empty cell %d to minimum water content!\n',ii);
        end
    end
    
    
    
    
end