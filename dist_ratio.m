function [rp, rm] = dist_ratio(data, config, ii)

    Kp = 0.5 * (data.Kr(ii) + data.Kr(ii+1));
    Km = 0.5 * (data.Kr(ii) + data.Kr(ii-1));
    Qp = abs(Kp * (data.h(ii+1) - data.h(ii)) / config.dz - Kp);
    Qm = abs(Km * (data.h(ii) - data.h(ii-1)) / config.dz - Km);
    
    if Qp+Qm ~= 0
        rp = Qp / (Qp + Qm);
        rm = Qm / (Qp + Qm);
    else
        rp = 0.5;
        rm = 0.5;
    end

end