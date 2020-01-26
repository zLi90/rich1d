%% Initialize data arrays
function [data, out] = init(config)
    data.h = config.hinit * ones(config.Nz,1);
    data.hn = data.h;
    data.h0 = data.h;
    data.Kr = ones(config.Nz,1);
    data.wc = config.wcs * ones(config.Nz,1);
    data.wch = data.wc;
    data.C = ones(config.Nz,1);
    data.dzf = config.dz * ones(config.Nz,1);
    data.V = data.wc * config.dz;
    out.h = zeros(config.Nz,length(config.save));
    out.wc = zeros(config.Nz,length(config.save));

end