function [data] = computeWRC(data, config)

% a = 1.43;
% n = 1.5;
flag = config.wrf;
a = config.alpha;
n = config.n;
m = 1 - 1/n;
hs = -0.02;
wcm = config.wcs + 0.001;

% S = ((1 + abs(a*-0.05)^n)^m)^-1;
% config.wcr + (config.wcs - config.wcr) * S
% -(((config.wcs-config.wcr)/(0.2-config.wcr))^(1/m) - 1)^(1/n) / a

if strcmp(flag,'h') || strcmp(flag,'wc')
    for ii = 1:config.Nz
        h = data.h(ii);
    % compute saturation
        if flag == 'h'
            S = ((1 + abs(a*h)^n)^m)^-1;
        elseif flag == 'wc'
            S = (data.wc(ii) - config.wcr) / (config.wcs - config.wcr);
        end
        if S > 1.0
            S = 1.0;
        elseif S < 0
            S = 0.0;
        end
    % compute water content from h
        data.wch(ii) = config.wcr + (config.wcs - config.wcr) * S;
        if h > 0
            data.wch(ii) = config.wcs;
        end
    % computer h from water content
        data.hwc(ii) = -(((config.wcs-config.wcr)/(data.wc(ii)-config.wcr))^(1/m) - 1)^(1/n) / a;
    % compute hydraulic conductivity
        data.Kr(ii) = config.Kz * sqrt(S) * (1 - (1-S^(n/(n-1)))^m)^2;
    % compute C(h)
        data.C(ii) = (a*n*m*(config.wcs-config.wcr)*abs(a*h)^(n-1)) / (1+abs(a*h)^n)^(1+m);
        if h > 0
            data.C(ii) = 0;
        end
        data.C(ii) = data.C(ii) + config.Ss * data.wc(ii)/config.wcs;
        
    end
    
    % calculate maximum allowable dt
    dKdS0 = 1e-8;
    for ii = 1:config.Nz
        S = ((1 + abs(a*data.h(ii))^n)^m)^-1;
        if S > 1.0
            S = 1.0;
        elseif S < config.wcr/config.wcs
            S = config.wcr/config.wcs;
        end
        
        if S < 0.9999
            dKdS = (0.5*config.Kz.*S.^(-0.5).*(1-(1-S.^(1/m)).^m).^2 + ...
                2*config.Kz.*sqrt(S).*(1-(1-S.^(1/m)).^m).*(1-S.^(1/m)).^(m-1).*S.^(1/m-1));
        else
            dKdS = dKdS0;
        end
        
        if data.C(ii) > config.Ss & S < 0.9999
            if ii == 1 & data.wc(ii+1) < config.wcs
                if dKdS > dKdS0
                    dKdS0 = dKdS;
                end
            elseif ii == config.Nz & data.wc(ii-1) < config.wcs
                if dKdS > dKdS0
                    dKdS0 = dKdS;
                end
            elseif ii > 1 & ii < config.Nz
                if data.wc(ii-1) < config.wcs & data.wc(ii+1) < config.wcs
                    if dKdS > dKdS0
                        dKdS0 = dKdS;
                    end
                end
            end
        end
    end
    if dKdS0 ~= 1e-8
        data.dt_maxCo = config.Co_max * config.dz / (dKdS0 / (config.wcs-config.wcr));
    else
        data.dt_maxCo = config.dt_max;
    end
    
    
elseif strcmp(flag,'mod')
    for ii = 1:config.Nz
        h = data.h(ii);
        S = ((1 + abs(a*h)^n)^m)^-1;
        if h < hs
            data.wch(ii) = config.wcr + (wcm - config.wcr) * S;
        else
            data.wch(ii) = config.wcs;
        end
        data.hwc(ii) = -(((config.wcs-config.wcr)/(data.wc(ii)-config.wcr))^(1/m) - 1)^(1/n) / a;
        
        St = S * (config.wcs-config.wcr) / (wcm-config.wcr);
        S1 = (config.wcs-config.wcr) / (wcm-config.wcr);
        F = (1 - St^(1/m))^m;
        F1 = (1 - S1^(1/m))^m;
        data.Kr(ii) = config.Kz * sqrt(S) * ((1-F)/(1-F1)).^2;
        data.C(ii) = (a*n*m*(1-config.wcr)*abs(a*h)^(n-1)) / (1+abs(a*h)^n)^(2-1/n);
        data.C(ii) = data.C(ii) + config.Ss * S;

    end
    
    
end
