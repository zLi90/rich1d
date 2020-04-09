%% Make figures to compare PC and Hydrus results

lw = 2;
fs = 14;
sz = 50;
shp = {'x','o','+'};
color = [0 0 1; 0 0.6 0; 1 0 0; 0.5 0.5 0.5];
ls = {'--','-','--',':'};
titstr = {'Steady','Infilt-Down','Evaporation'};
lgd1 = {'Hydrus','T6000','T6000Co','T100','Trunc'};
lgd2 = {'Steady','Infiltration','Evaporation'};

savefig = 0;


PCname = {'T6000','T6000Co2','T100','Trunc'};
fnamePC = 'out_scenario4_';

zVec = linspace(0.025,0.975,20);
wcinit = [0.3 0.03 0.3];
qtop = [0 -2e-6 2e-7];

%% Load Hydrus results
fdir = 'hydrus/';
subfolder = {'steady','infilt_down','evap'};

load('hydrus_scenario4.mat','hydrus');


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
%% Make Plots

figure(1);
set(gcf,'PaperPositionMode','auto')
set(gcf,'Position',[200 200 800 700]);
set(gcf,'Color',[1 1 1]);
ifig = 0;
for ff = 1:length(subfolder)
    ifig = ifig + 1;
    subplot(length(subfolder),1,ifig);
    plot(hydrus.(subfolder{ff}).iter, hydrus.(subfolder{ff}).tVec,'LineStyle', ':','Color','k','LineWidth',3);
    hold on;
    for kk = 1:length(PCname)
        model = PCdata.(PCname{kk});
        plot(model.(PCfield{ff}).iter(:,1)-1,model.(PCfield{ff}).iter(:,2),...
            'LineStyle',ls{kk},'Color',color(kk,:),'LineWidth',lw);
        hold on;
    end
    hold off;
    xlim([1,2e3]);
    ylim([2e-1,2e5]);
%     set(gca,'YScale','log');
%     set(gca,'XScale','log');
    set(gca,'FontSize',fs);
    if ff == length(subfolder)
        xlabel('Number of iterations','FontSize',fs);
    elseif ff == 1
        legend(lgd1,'FontSize',fs,'Location','southeast');
    end
    ylabel('Total time [sec]','FontSize',fs);
    title(lgd2{ff},'FontSize',fs);
end

if savefig == 1
    print('-depsc2','Fig6','-painters');
end
    

