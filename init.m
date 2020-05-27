%% Initialize data arrays
function [data, out] = init(config)
    data.h = config.hinit * ones(config.Nz,1);
    data.hn = data.h;
    data.hp = data.h;
    data.h0 = data.h;
    data.Kr = ones(config.Nz,1);
    data.wcflag = ones(config.Nz,1);
    data.Qp = ones(config.Nz,1);
    data.Qm = ones(config.Nz,1);
    data.wch = zeros(config.Nz,1);
    if isfield(config, 'wcinit')
        data.wc = config.wcinit * ones(config.Nz,1);
%         data.wc(1:6) = [0.03 0.08 0.13 0.18 0.23 0.28];
        [data] = computeWRC(data, config);
        data.h = data.hwc;
%         for ii = 1:config.Nz
%             data.h(ii) = data.h(ii) + ii*config.dz - 0.5*config.dz;
%         end
    else
        data.h = config.hinit * ones(config.Nz,1);
        data.wc = config.wcs * ones(config.Nz,1);
        [data] = computeWRC(data, config);
        data.wc = data.wch;
    end
    data.wcn = data.wc;
    data.wcp = data.wc;
    data.C = ones(config.Nz,1);
    data.Pe = ones(config.Nz,1);
    data.Co = ones(config.Nz,1);
    data.dzf = config.dz * ones(config.Nz,1);
    data.V = data.wc * config.dz;
    data.dwc = zeros(config.Nz,1);
    data.lost = [];
    data.allsendrecv = [];
    data.wc_track = [];
    data.alltrack = [];
    data.sendrecv = zeros(3,1);
    % monitor array
    % head before, head after, hwc
    % wc before, wc after, wch
    % flow rate, flag
    data.monitor = zeros(config.Nz,11);
    data.Vsend = 0;
    data.Vrecv = 0;
    data.loss = 0;
    data.mb = [];
    data.qin_sum = 0;
    data.qou_sum = 0;
    
    % -0.05 --- 0.3291
    % -0.875 --- 0.2
%     data.h = [-0.875 0 0.05];
%     data.wc = [0.2; 0.33; 0.33];
%     data.wc = [0.33; 0.2; 0.2];
%     data.h = [0.0 -0.875 -0.875];

    
    % output data arrays
    if strcmp(config.savetype, 'column')
        out.h = zeros(config.Nz,length(config.save));
        out.wc = zeros(config.Nz,length(config.save));
    elseif strcmp(config.savetype, 'time')
        out.h = [];
        out.wc = [];
    end
    
%     out.ts.h = zeros(config.Nz, config.Nt);
%     out.ts.wc = zeros(config.Nz, config.Nt);
%     out.ts.wch = zeros(config.Nz, config.Nt);
%     out.ts.hwc = zeros(config.Nz, config.Nt);
%     out.ts.Kr = zeros(config.Nz, config.Nt);
%     out.ts.C = zeros(config.Nz, config.Nt);
%     out.ts.Q = zeros(config.Nz, config.Nt);

end