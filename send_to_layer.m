function [data, V] = send_to_layer(data, V, ii, config, direc)

if strcmp(direc, 'down')
    for layer = ii+1:config.Nz
        room = max(config.wcs-data.wc(layer), 0) * config.dz;
        if room > 0
            dV = min(room, V);
            data.wc(layer) = data.wc(layer) + dV/config.dz;
            V = V - dV;
            
%             if dV > 0 && layer > ii+1
%                 data.redflag = 1;
%             end
            
        end
        if V <= 0
            break;
        end
    end
elseif strcmp(direc, 'up')
    for layer = ii-1:-1:1
        room = max(config.wcs-data.wc(layer), 0) * config.dz;
        if room > 0
            dV = min(room, V);
            wc0 = data.wc(layer);
            data.wc(layer) = data.wc(layer) + dV/config.dz;
            V = V - dV;
%             if ii == config.Nz
%                 fprintf('[ii,layer] = [%d->%d], wc: %f->%f, [V, dV] = [%f, %f]\n',ii,layer,wc0,data.wc(layer),V,dV);
%             end
            
%             if dV > 0 && layer < ii-1
%                 data.redflag = 1;
%             end
            
        end
        if V <= 0
            break;
        end
    end
end


end