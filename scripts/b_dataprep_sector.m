% Explore data using simple moving average, daily returns
% Compile data from four specific sectors of interest for further analysis
%   Input: cleaned_alltickers.mat from a_dataprep_all.m
%   Output: (1) cleaned_sectortickers.mat 
%              - D.consumercyclicaldata = data_CC;
%              - D.consumerNoncyclicaldata = data_CNC;
%              - D.findata = data_fin;
%              - D.techdata = data_tech;
%              - D.sectorysummary = sector_summary;
%           (2) Figures of Mov_Avg_sectors.png
% =========================================================================
% Y-intercept Coding test
% version: Hilary Ngai 240313
% =========================================================================
clear
clc
close all

%% setup: change directory if using different computer
%--------------------------------------------------------------------------
addpath(genpath("/Users/hilaryngai/Desktop/To DO/y_intercept_coding_test"))
script_dir = "/Users/hilaryngai/Desktop/To DO/y_intercept_coding_test/scripts";
input_dir = "/Users/hilaryngai/Desktop/To DO/y_intercept_coding_test/input_data";
fig_dir = "/Users/hilaryngai/Desktop/To DO/y_intercept_coding_test/figures";
save_dir = '/Users/hilaryngai/Desktop/To DO/y_intercept_coding_test/output';
cd(save_dir)

%% Read files
% =========================================================================
load('cleaned_alltickers13-Mar-2024-15-37-45.mat', 'C');
num_tickers = size(C.data,1);

%% Visualize simple moving average in each sector
% =========================================================================
data_sec = C.datasec;
unique_sec = unique(data_sec.bics_sector);
num_uniquesec = numel(unique_sec);
sector_summary = groupsummary (data_sec, "bics_sector");

for j = 1:num_uniquesec
    tmp_sec = unique_sec{j};
    tmp_rows_vol = find(strcmp(data_sec.bics_sector,tmp_sec));
    for k = 1:size(tmp_rows_vol,1)
        tmp_row = tmp_rows_vol(k);
        data_by_sector{j,k} = C.data{tmp_row,1}; %separate data into each sector
    end
    clear tmp*
end
tmp_databysector = {};
lag = 6;
for j = 1:num_uniquesec
    tmp_sc = unique_sec{j};
    tmp_totaltickers_insector = table2array(sector_summary(j,2));
    tmp_databysector = data_by_sector{j,1:tmp_totaltickers_insector};
    for k = 1:tmp_totaltickers_insector
        tmp = data_by_sector{j,k};
        simple = movavg(tmp.last,'simple',lag);
        hold on
        plot(tmp.date,tmp.last, tmp.date,simple);%plot simple moving average
    end
    grid on
    title(tmp_sc)
    set(gca,'FontSize',14,'FontName','Arial') 
    hold off
    tmp_tosave = gcf;
    cd(fig_dir)
    tmp_fig_name = strcat('MovAvg_',tmp_sc,'.png')
    exportgraphics(tmp_tosave,tmp_fig_name,'BackgroundColor','none','Resolution',600)
    close all
    clear tmp*
end
%% Save Consumer, cyclical as the sector I would like to test my trading strat on
% and explore the daily returns over the years
% =========================================================================
tmp_CCrows = find(strcmp(sector_summary{:,1},'Consumer, Cyclical'));
num_CCcompanies = sector_summary{tmp_CCrows,2};
data_CC = {};
for l = 1:num_CCcompanies
    data_CC{l} = data_by_sector{tmp_CCrows,l};
end
num_days_all = size(data_CC{1,1},1);
daily_returns_CC = zeros(num_days_all,num_CCcompanies);
for l = 1:num_CCcompanies
    tmp = data_CC{l};
    tmp = tmp.last;
    for i = 2:num_days_all
        daily_returns_CC(i,l) = (tmp(i) - tmp(i-1)) / tmp(i-1);
    end
end
clear tmp*
%% Chosen Consumer, NONcyclical as the sector I would like to test my trading strat on
% and explore the daily returns over the years
% =========================================================================
tmp_CNCrows = find(strcmp(sector_summary{:,1},'Consumer, Non-cyclical'));
num_CNCcompanies = sector_summary{tmp_CNCrows,2};
data_CNC = {};
for l = 1:num_CNCcompanies
    data_CNC{l} = data_by_sector{tmp_CNCrows,l};
end
num_days_all = size(data_CNC{1,1},1);
daily_returns_CNC = zeros(num_days_all,num_CNCcompanies);
for l = 1:num_CNCcompanies
    tmp = data_CNC{l};
    tmp = tmp.last;
    for i = 2:num_days_all
        daily_returns_CNC(i,l) = (tmp(i) - tmp(i-1)) / tmp(i-1);
    end
end
clear tmp*
%% Chosen financial as the sector I would like to test my trading strat on
% and explore the daily returns over the years
% =========================================================================
tmp_finrows = find(strcmp(sector_summary{:,1},'Financial'));
num_fincompanies = sector_summary{tmp_finrows,2};
data_fin = {};
for l = 1:num_fincompanies
    data_fin{l} = data_by_sector{tmp_finrows,l};
end
num_days_all = size(data_fin{1,1},1);
daily_returns_fin = zeros(num_days_all,num_fincompanies);
for l = 1:num_fincompanies
    tmp = data_fin{l};
    tmp = tmp.last;
    for i = 2:num_days_all
        daily_returns_fin(i,l) = (tmp(i) - tmp(i-1)) / tmp(i-1);
    end
end
clear tmp*

%% Chosen technology as the sector I would like to test my trading strat on
% and explore the daily returns over the years
% =========================================================================
tmp_techrows = find(strcmp(sector_summary{:,1},'Technology'));
num_techcompanies = sector_summary{tmp_techrows,2};
data_tech = {};
for l = 1:num_techcompanies
    data_tech{l} = data_by_sector{tmp_techrows,l};
end
num_days_all = size(data_tech{1,1},1);
daily_returns_tech = zeros(num_days_all,num_techcompanies);
for l = 1:num_techcompanies
    tmp = data_tech{l};
    tmp = tmp.last;
    for i = 2:num_days_all
        daily_returns_tech(i,l) = (tmp(i) - tmp(i-1)) / tmp(i-1);
    end
end
clear tmp*
%% Save output
% =========================================================================
var_names = {'date','ticker','volume','mktcap','last','sector'};
D.consumercyclicaldata = data_CC;
D.consumerNoncyclicaldata = data_CNC;
D.findata = data_fin;
D.techdata = data_tech;
D.sectorysummary = sector_summary;

Log = [];
Log.data_generation_date = datetime;
Log.data_generation_script = mfilename('fullpath');

cd(save_dir)
eval(['save cleaned_sectortickers',...
    char(datetime('now','Format','dd-MMM-yyyy-HH-mm-ss'))]);
