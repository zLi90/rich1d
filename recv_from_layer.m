function [data, V] = recv_from_layer(data, V, ii, config, direc)

if strcmp(direc, 'down')
    for layer = ii+1:config.Nz
        avai = max(data.wc(layer)-config.wcr, 0) * config.dz;
        if avai > 0
            dV = min(avai, V);
            data.wc(layer) = data.wc(layer) - dV/config.dz;
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
        avai = max(data.wc(layer)-config.wcr, 0) * config.dz;
        if avai > 0
            dV = min(avai, V);
            data.wc(layer) = data.wc(layer) - dV/config.dz;
            V = V - dV;
            
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