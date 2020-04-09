%% Make figures to compare PC and Hydrus results

lw = 1.5;
fs = 14;
sz = 50;
shp = {'x','o','+'};
color = [1 0 0; 0 0.6 0; 0 0 1; 0 0 0];
ls = {'--','-'};
titstr = {'Steady','Infiltration','Evaporation'};
lgd1 = {'Hydrus','T6000','T6000Co','T100L'};
lgd2 = {'Steady','Infiltration','Evaporation'};

loadHydrus = 0;

PCname = {'T6000','T6000Co2','T100L'};
fnamePC = 'out_scenario4_';

zVec = linspace(0.025,0.975,20);
wcinit = [0.3 0.03 0.3];
qtop = [0 -2e-6 2e-7];

%% Load Hydrus results
% fdir = 'C:\Users\Public\Public Documents\PC-Progress\Hydrus-1D 4.xx\Examples\Direct\';
fdir = 'hydrus/';
subfolder = {'steady','infilt_down','evap'};
time = [8640 34560 172800];
Nz = 21;

if loadHydrus == 0
    for ii = 1:length(subfolder)
        data.h = zeros(Nz,length(time));
        data.wc = zeros(Nz,length(time));
        data.zVec = zeros(Nz,1);
        data.tVec = [];
        data.iter = [];
        % load model results
        fname = strcat(fdir, subfolder{ii}, '/Nod_Inf.out');
        fid = fopen(fname, 'r');
        line = fgetl(fid);
        tt = 0;
        while ischar(line)
            if length(line) >= 5 && strcmp(line(2:5),'Time')
                thistime = str2double(line(10:end));
                if ismember(thistime,time)
                    tt = tt + 1;
                    while 1
                        line = strsplit(fgetl(fid));
                        if length(line) >= 2 && line{2}(1) == '['
                            line = strsplit(fgetl(fid));
                            for kk = 1:Nz
                                line = strsplit(fgetl(fid));
                                data.zVec(kk) = str2double(line{3});
                                data.h(kk,tt) = str2double(line{4});
                                data.wc(kk,tt) = str2double(line{5});
                            end
                            break;
                        end
                    end
                end
            end
            line = fgetl(fid);
        end
        fclose(fid);
        % load time stepping
        tname = strcat(fdir, subfolder{ii}, '/Run_Inf.out');
        fid = fopen(tname, 'r');
        line = fgetl(fid);
        tt = 0;
        while 1
            line = strsplit(fgetl(fid));
            if length(line) >= 2 && strcmp(line{2},'TLevel')
                line = strsplit(fgetl(fid));
                kk = 1;
                while 1
                    line = strsplit(fgetl(fid));
                    if strcmp(line{1},'end')
                        break;
                    end
                    data.tVec(kk) = str2double(line{3});
                    if kk == 1
                        data.iter(kk) = str2double(line{5});
                    else
                        data.iter(kk) = str2double(line{5}) + data.iter(kk-1);
                    end
                    kk = kk + 1;
                end
                break;
            end
        end
        fclose(fid);

        hydrus.(subfolder{ii}) = data;
    end
    save('hydrus_scenario4.mat','hydrus');
else
    load('hydrus_scenario4.mat','hydrus');
end


%% Load PC results
PCfield = {'steady','infiltdown','evap'};
for ii = 1:length(PCname)
    fname = strcat(fnamePC, PCname{ii}, '.mat');
    load(fname);
    PCdata.(PCname{ii}) = results;
end

%% Calculate mass error
for ii = 1:length(PCname)
    for ff = 1:length(PCfield)
        if PCdata.(PCname{ii}).(PCfield{ff}).tVec(end) > 172800
            tEnd = PCdata.(PCname{ii}).(PCfield{ff}).tVec(end-1);
        else
            tEnd = PCdata.(PCname{ii}).(PCfield{ff}).tVec(end);
        end
        Mtheo = min(wcinit(ff)*20 - qtop(ff)*tEnd/0.05, 0.33*20);
        Mactu = sum(PCdata.(PCname{ii}).(PCfield{ff}).wc(:,3));
        Mloss = (Mtheo-Mactu)/Mactu;
        fprintf('Mass balance for %s - %s : LOSS = %f percent \n',PCname{ii},PCfield{ff},100*Mloss);
    end
end

%% Calculate RMSE
T100 = load('out_scenario4_T100.mat');

for ff = 1:length(PCfield)
    for tt = 1:length(time)
        for ii = 1:length(PCname)
            model = PCdata.(PCname{ii});

            h_hyd = T100.results.(PCfield{ff}).h(:,tt);
            wc_hyd =T100.results.(PCfield{ff}).wc(:,tt);
            
            h_mod = model.(PCfield{ff}).h(:,tt);
            wc_mod = model.(PCfield{ff}).wc(:,tt);
            
            err_h = sqrt(mean((h_hyd(2:end-1) - h_mod(2:end-1)).^2));
            err_wc = sqrt(mean((wc_hyd(2:end-1) - wc_mod(2:end-1)).^2));
            fprintf('[%s] - [%s] - [%d] : RMSE in h, wc = [%f, %f]\n',...
                PCname{ii},PCfield{ff},time(tt),err_h,err_wc);
        end
        fprintf('--------------------\n');
    end
end

%% Make Plots

for ff = 1:length(PCfield)
    figure(ff);
    set(gcf,'PaperPositionMode','auto')
    set(gcf,'Position',[100 100 800 600]);
    set(gcf,'Color',[1 1 1]);
    
    subplot(1,2,1);
    for tt = 1:length(time)
        scatter(hydrus.(subfolder{ff}).h(:,tt),hydrus.(subfolder{ff}).zVec,sz, ...
                shp{1},'MarkerEdgeColor',color(tt,:),'LineWidth',lw);
        hold on;
        for kk = 1:length(PCname)
            model = PCdata.(PCname{kk});
            if kk > length(ls)
                scatter(model.(PCfield{ff}).h(:,tt),-zVec',sz, ...
                    shp{kk-length(ls)+1},'MarkerEdgeColor',color(tt,:),'LineWidth',lw);
            else
                plot(model.(PCfield{ff}).h(:,tt),-zVec','LineStyle', ...
                    ls{kk},'Color',color(tt,:),'LineWidth',lw);
            end
            hold on;
        end
    end
    hold off;
    grid on;
    if ff == 2
        xlim([-18 2]);
    elseif ff == 3
        xlim([-2.5 0.5]);
    end
    xlabel('Head [m]','FontSize',fs);
    title(titstr{ff},'FontSize',fs);
    ylabel('Depth [m]','FontSize',fs);
    set(gca,'FontSize',fs);
    legend(lgd1,'FontSize',fs,'Location','southwest');
    
    subplot(1,2,2);
    for tt = 1:length(time)
        scatter(hydrus.(subfolder{ff}).wc(:,tt),hydrus.(subfolder{ff}).zVec,sz, ...
                shp{1},'MarkerEdgeColor',color(tt,:),'LineWidth',lw);
        hold on;
        for kk = 1:length(PCname)
            model = PCdata.(PCname{kk});
            if kk > length(ls)
                scatter(model.(PCfield{ff}).wc(:,tt),-zVec',sz, ...
                    shp{kk-length(ls)+1},'MarkerEdgeColor',color(tt,:),'LineWidth',lw);
            else
                plot(model.(PCfield{ff}).wc(:,tt),-zVec','LineStyle', ...
                    ls{kk},'Color',color(tt,:),'LineWidth',lw);
            end
            hold on;
        end
    end
    hold off;
    grid on;
    if ff == 3
        xlim([0.15 0.34]);
    end
    xlabel('Water Content','FontSize',fs);
    set(gca,'FontSize',fs);
    title(titstr{ff},'FontSize',fs);
    
%     print('-depsc2',titstr{ff},'-painters');
end
    
