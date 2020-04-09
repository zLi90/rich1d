function [data, config] = finalAdjust2(data, config)

    eps = 0e-8;
    a = config.alpha;
    n = config.n;
    m = 1 - 1/n;
    
    data.wcp = data.wc;
    data.hp = data.h;
   
    data.wcflag = zeros(config.Nz,1);
    %% <<<<<<<< First layer >>>>>>>>
    ii = 1;
    % <<<<CASE 1 : Over-saturated cell - send down>>>>
    if data.wc(ii) >= config.wcs-eps
        V = (data.wc(ii) - config.wcs) * config.dz;
        data.wc(ii) = config.wcs;
        [data, V] = send_to_layer(data, V, ii, config ,'down');
        data.wcflag(ii) = 1;
    % <<<<CASE 2 : Unsaturated cell>>>>
    elseif data.wc(ii) < config.wcs-eps
        % <<CASE 2.1>> : Isolated unsaturated cell
        if data.wc(ii+1) < config.wcs-eps & config.bcType(1) == 0
            data.h(ii) = -(((config.wcs-config.wcr)/(data.wc(ii)-config.wcr))^(1/m) - 1)^(1/n) / a;
            data.wcflag(ii) = 211;
        % <<CASE 2.2>> : Unsat adjacent to sat
        else
            % <<CASE 2.2.1>> : Receiving water
            if data.wch(ii) > data.wc(ii)
                V = (data.wch(ii) - data.wc(ii)) * config.dz;
                data.wc(ii) = data.wch(ii);
                if data.wc(ii+1) >= config.wcs-eps
                    [data, V] = recv_from_layer(data, V, ii, config ,'down');                    
                end
                data.wcflag(ii) = 221;
            % <<CASE 2.2.2>> : Sending water
            else
                V = (data.wc(ii) - data.wch(ii)) * config.dz;
                data.wc(ii) = data.wch(ii);
                [data, V] = send_to_layer(data, V, ii, config ,'down');
                if V > 0
                    data.wc(ii) = data.wc(ii) + V/config.dz;
                end
                data.wcflag(ii) = 222;
            end
        end
    end
    
    %% <<<<<<<< Middle layers >>>>>>>>
    for ii = 2:config.Nz-1
        % <<<<CASE 1 : Over-saturated cell>>>>
        if data.wc(ii) >= config.wcs-eps
            if data.redflag(ii) == 1
                data.redflag(ii) = 0;
            end
            V = (data.wc(ii) - config.wcs) * config.dz;
            data.wc(ii) = config.wcs;
            % <<CASE 1.1>> : Downward flow
            if data.h(ii) > data.h(ii+1)-config.dz && data.h(ii) < data.h(ii-1)+config.dz
                % send extra water to lower layers first
                [data, V] = send_to_layer(data, V, ii, config ,'down');
                % if bottom space is not enough, send remaining water up
                if V > 0
                    [data, V] = send_to_layer(data, V, ii, config ,'up');
%                     data.redflag = 1;
                end
                data.wcflag(ii) = 11;
            % <<CASE 1.2>> : Upward flow
            elseif data.h(ii) < data.h(ii+1)-config.dz && data.h(ii) > data.h(ii-1)+config.dz
                % send extra water to upper layers
                [data, V] = send_to_layer(data, V, ii, config ,'up');
                % if top space is not enough, send remaining water down
                if V > 0
                    [data, V] = send_to_layer(data, V, ii, config ,'down');
%                     data.redflag = 1;
                end
                data.wcflag(ii) = 12;
            % <<CASE 1.3>> : Splitting flow
            else
%                 data.redflag = 1;
                % get distributing ratio
                [rp, rm] = dist_ratio(data, config, ii);
                Vp = V * rp;
                Vm = V * rm;
                % send both up and down
                [data, Vm] = send_to_layer(data, Vm, ii, config ,'up');
                [data, Vp] = send_to_layer(data, Vp, ii, config ,'down');
                if Vm > 0
                    [data, Vm] = send_to_layer(data, Vm, ii, config ,'down');
                end
                if Vp > 0
                    [data, Vp] = send_to_layer(data, Vp, ii, config ,'up');
                end
                data.wcflag(ii) = 13;
            end
        % <<<<CASE 2 : Unsaturated cell>>>>
        elseif data.wc(ii) < config.wcs-eps
            % <<CASE 2.1>> : Isolated unsaturated cell
            if data.wc(ii+1) < config.wcs-eps && data.wc(ii-1) < config.wcs-eps
                data.h(ii) = -(((config.wcs-config.wcr)/(data.wc(ii)-config.wcr))^(1/m) - 1)^(1/n) / a;
                data.wcflag(ii) = 21;
            % <<CASE 2.2>> : Unsat adjacent to sat
            else
                if data.redflag(ii) == 1
                    data.redflag(ii) = 0;
                end
                % <<CASE 2.2.1>> : Receiving water
                if data.wch(ii) > data.wc(ii)
                    V = (data.wch(ii) - data.wc(ii)) * config.dz;
                    data.wc(ii) = data.wch(ii);
                    % <<CASE 2.2.1.1>> : Downward flow
                    if data.h(ii) > data.h(ii+1)-config.dz && data.h(ii) < data.h(ii-1)+config.dz
                        [data, V] = recv_from_layer(data, V, ii, config ,'up');
                        data.wcflag(ii) = 2211;
                    % <<CASE 2.2.1.2>> : Upward flow
                    elseif data.h(ii) < data.h(ii+1)-config.dz && data.h(ii) > data.h(ii-1)+config.dz
                        [data, V] = recv_from_layer(data, V, ii, config ,'down');
                        data.wcflag(ii) = 2212;
                    % <<CASE 2.2.1.3>> : Splitting flow
                    else
                        % get distributing ratio
%                         data.redflag = 1;
                        [rp, rm] = dist_ratio(data, config, ii);
                        Vp = V * rp;
                        Vm = V * rm;
                        % send both up and down
                        [data, Vm] = recv_from_layer(data, Vm, ii, config ,'up');
                        [data, Vp] = recv_from_layer(data, Vp, ii, config ,'down');
                        if Vm > 0
                            [data, Vm] = send_to_layer(data, Vm, ii, config ,'down');
                        end
                        if Vp > 0
                            [data, Vp] = send_to_layer(data, Vp, ii, config ,'up');
                        end
                        data.wcflag(ii) = 2213;
                    end
                % <<CASE 2.2.2>> : Sending water
                else
                    V = (data.wc(ii) - data.wch(ii)) * config.dz;
                    data.wc(ii) = data.wch(ii);
                    % <<CASE 2.2.2.1>> : Downward flow
                    if data.h(ii) > data.h(ii+1)-config.dz && data.h(ii) < data.h(ii-1)+config.dz
                        [data, V] = send_to_layer(data, V, ii, config ,'down');
                        % if bottom space is not enough, send remaining water up
                        if V > 0
                            [data, V] = send_to_layer(data, V, ii, config ,'up');
%                             data.redflag = 1;
                        end
                        data.wcflag(ii) = 2221;
                    % <<CASE 2.2.2.2>> : Upward flow
                    elseif data.h(ii) < data.h(ii+1)-config.dz && data.h(ii) > data.h(ii-1)+config.dz
                        [data, V] = send_to_layer(data, V, ii, config ,'up');
                        % if top space is not enough, send remaining water down
                        if V > 0
                            [data, V] = send_to_layer(data, V, ii, config ,'down');
%                             data.redflag = 1;
                        end
                        data.wcflag(ii) = 2222;
                    % <<CASE 2.2.2.3>> : Splitting flow
                    else
                        % get distributing ratio
%                         data.redflag = 1;
                        [rp, rm] = dist_ratio(data, config, ii);
                        Vp = V * rp;
                        Vm = V * rm;
                        % send both up and down
                        [data, Vm] = send_to_layer(data, Vm, ii, config ,'up');
                        [data, Vp] = send_to_layer(data, Vp, ii, config ,'down');
                        if Vm > 0
                            [data, Vm] = send_to_layer(data, Vm, ii, config ,'down');
                        end
                        if Vp > 0
                            [data, Vp] = send_to_layer(data, Vp, ii, config ,'up');
                        end
                        data.wcflag(ii) = 2223;
                    end
                    
                end
            end
        end
    end
    
    %% <<<<<<<< Bottom layer >>>>>>>>
    ii = config.Nz;
    % <<<<CASE 1 : Over-saturated cell>>>>
    if data.wc(ii) >= config.wcs-eps
        V = (data.wc(ii) - config.wcs) * config.dz;
        data.wc(ii) = config.wcs;
        [data, V] = send_to_layer(data, V, ii, config ,'up');
        data.wcflag(ii) = 1;
    % <<<<CASE 2 : Unsaturated cell>>>>
    elseif data.wc(ii) < config.wcs-eps
        % <<CASE 2.1>> : Isolated unsaturated cell
        if data.wc(ii-1) < config.wcs-eps
            data.h(ii) = -(((config.wcs-config.wcr)/(data.wc(ii)-config.wcr))^(1/m) - 1)^(1/n) / a;
            data.wcflag(ii) = 21;
        % <<CASE 2.2>> : Unsat adjacent to sat
        else
            % <<CASE 2.2.1>> : Receiving water
            if data.wch(ii) > data.wc(ii)
                V = (data.wch(ii) - data.wc(ii)) * config.dz;
                data.wc(ii) = data.wch(ii);
                [data, V] = recv_from_layer(data, V, ii, config ,'up');
                data.wcflag(ii) = 221;
            % <<CASE 2.2.2>> : Sending water
            else
                V = (data.wc(ii) - data.wch(ii)) * config.dz;
                data.wc(ii) = data.wch(ii);
                [data, V] = send_to_layer(data, V, ii, config ,'up');
                data.wcflag(ii) = 222;
            end
        end
    end
    
    %% Final adjust of head
%     ii = 1;
%     if data.wc(ii) < config.wcs-eps && data.wc(ii+1) < config.wcs-eps
%         data.h(ii) = -(((config.wcs-config.wcr)/(data.wc(ii)-config.wcr))^(1/m) - 1)^(1/n) / a;
%     end
%     for ii = 2:config.Nz-1
%         if data.wc(ii) < config.wcs-eps && (data.wc(ii-1) < config.wcs-eps || data.wc(ii+1) < config.wcs-eps)
%             data.h(ii) = -(((config.wcs-config.wcr)/(data.wc(ii)-config.wcr))^(1/m) - 1)^(1/n) / a;
%         end
%     end
%     ii = config.Nz;
%     if data.wc(ii) < config.wcs-eps && data.wc(ii-1) < config.wcs-eps
%         data.h(ii) = -(((config.wcs-config.wcr)/(data.wc(ii)-config.wcr))^(1/m) - 1)^(1/n) / a;
%     end
    
    
    %% Final check 
    for ii = 2:config.Nz
%         fprintf('++ Layer %d ++ {wc %f->%f} ++ {h %f->%f} ++ dhdz=%f ++ flag=%d\n',ii,data.wcp(ii),data.wc(ii),data.hp(ii),data.h(ii),data.h(ii-1)-data.h(ii),data.wcflag(ii));
        if data.wc(ii) > config.wcs
            fprintf('Enforce over-sat cell %d to saturated condition!, wc = %f,\n',ii,data.wc(ii));
            data.wc(ii) = config.wcs;
        elseif data.wc(ii) < config.wcr+eps
            data.wc(ii) = config.wcr+eps;
            fprintf('Enforce empty cell %d to minimum water content!\n',ii);
        end
    end
    
end
            
            
            
            
            
            
            
            
            
            
            
            
            
            
                
                