function [data] = computeWRC(data, config, flag)

a = 1.43;
n = 1.5;
m = 1 - 1/n;

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
    elseif S < config.wcr/config.wcs
        S = config.wcr/config.wcs;
    end
% compute water content from h
    data.wch(ii) = config.wcr + (config.wcs - config.wcr) * S;
% computer h from water content
    data.hwc(ii) = -(((config.wcs-config.wcr)/(data.wc(ii)-config.wcr))^(1/m) - 1)^(1/n) / a;
% compute hydraulic conductivity
    data.Kr(ii) = config.Kz * sqrt(S) * (1 - (1-S^(n/(n-1)))^m)^2;
% compute C(h)
    data.C(ii) = (a*n*m*(1-config.wcr)*abs(a*h)^(n-1)) / (1+abs(a*h)^n)^(2-1/n);
    data.C(ii) = data.C(ii) + config.Ss * S;

end
