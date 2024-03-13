% Implement two trading strategies: Equal Weighted & Markowitz Optimization
% Backtest by splitting the available data by median date 171130
% Save final_data.csv and figures to examine the performance 
%   Input: cleaned_sectortickers.mat from b_dataprep_sector.m
%   Output: (1) final_data.csv
%           (2) Figures of Initial_Weights_sectors.png
%           (3) Figures of sector_strat_Change_Allocation.png
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

%% Read files & Initialization
% =========================================================================
load('cleaned_sectortickers13-Mar-2024-20-24-40.mat', 'D');
num_tech_tickers = size(D.techdata,2);
num_fin_tickers = size(D.findata,2);
num_CC_tickers = size(D.consumercyclicaldata,2);
num_CNC_tickers = size(D.consumerNoncyclicaldata,2);
num_days_all = size(D.techdata{1,1},1);

%% Combine each sector's all companies last price
% I am assuming last stands for daily adjusted close price
% =========================================================================
for i = 1:num_CC_tickers
    tmp = D.consumercyclicaldata{i};
    tmp_digits = regexp(tmp.ticker(1,1), '\d{4}', 'match');
    tmp = renamevars(tmp, 'last', tmp_digits);
    D.consumercyclicaldata{i} = tmp;
    clear tmp*
end
for i = 1:num_CNC_tickers
    tmp = D.consumerNoncyclicaldata{i};
    tmp_digits = regexp(tmp.ticker(1,1), '\d{4}', 'match');
    tmp = renamevars(tmp, 'last', tmp_digits);
    D.consumerNoncyclicaldata{i} = tmp;
    clear tmp*
end
for i = 1:num_fin_tickers
    tmp = D.findata{i};
    tmp_digits = regexp(tmp.ticker(1,1), '\d{4}', 'match');
    tmp = renamevars(tmp, 'last', tmp_digits);
    D.findata{i} = tmp;
    clear tmp*
end
for i = 1:num_tech_tickers
    tmp = D.techdata{i};
    tmp_digits = regexp(tmp.ticker(1,1), '\d{4}', 'match');
    tmp = renamevars(tmp, 'last', tmp_digits);
    D.techdata{i} = tmp;
    clear tmp*
end

selectedcolumn = 4; %last known price

price_CC = synchronize(D.consumercyclicaldata{1}(:,selectedcolumn));
for i = 2:num_CC_tickers
    price_CC = synchronize(price_CC, D.consumercyclicaldata{i}(:, selectedcolumn));
end
price_CNC = synchronize(D.consumerNoncyclicaldata{1}(:,selectedcolumn));
for i = 2:num_CNC_tickers
    price_CNC = synchronize(price_CNC, D.consumercyclicaldata{i}(:, selectedcolumn));
end
price_fin = synchronize(D.findata{1}(:,selectedcolumn));
for i = 2:num_fin_tickers
    price_fin = synchronize(price_fin, D.findata{i}(:, selectedcolumn));
end
price_tech = synchronize(D.techdata{1}(:,selectedcolumn));
for i = 2:num_tech_tickers
    price_tech = synchronize(price_tech, D.techdata{i}(:, selectedcolumn));
end
%% CC
% =========================================================================
%Compute initial strategy weights 
warmup_period = 799; %first 799 entries as training data
current_weights_CC = zeros(1,num_CC_tickers); % 100% cash position
warmup_last_CC = price_CC(1:warmup_period,:);
% Compute the initial portfolio weights
equalweight_initial_CC = equalWeightFcn(current_weights_CC,warmup_last_CC);
markowitz_initial_CC = markowitzFcn(current_weights_CC,warmup_last_CC);
strategy_name = {'Equal Weighted', 'Markowitz Optimization'};
ticker_number_CC = price_CC.Properties.VariableNames;
initial_weight_CC = [equalweight_initial_CC(:), markowitz_initial_CC(:)];
heatmap(strategy_name, ticker_number_CC, initial_weight_CC, 'title','Initial Asset Allocations CC','Colormap', parula);
set(gca,'FontSize',10,'FontName','Arial')
tmp_tosave = gcf;
cd(fig_dir)
tmp_fig_name = strcat('Initial_weights_CC.png')
exportgraphics(tmp_tosave,tmp_fig_name,'BackgroundColor','none','Resolution',600)
close all

% Create backtest strategy
freq_rebalance = num_days_all/7/12; %rebalance approx every month of a year
lookback  = [30 120]; %lookback window
CC1 = backtestStrategy('Equal Weighted', @equalWeightFcn, ...
    'RebalanceFrequency', freq_rebalance, ...
    'LookbackWindow', 0, ...
    'InitialWeights', equalweight_initial_CC);
CC2 = backtestStrategy('Markowitz Optimization', @markowitzFcn, ...
    'RebalanceFrequency', freq_rebalance, ...
    'LookbackWindow', lookback, ...
    'InitialWeights', markowitz_initial_CC);
strats_CC = [CC1, CC2];

% Backtest 
risk_free_rate = 0.01; %assuming annualized risk free rate is 1%
backtest_CC = backtestEngine(strats_CC, 'RiskFreeRate', risk_free_rate)
backtest_CC = runBacktest(backtest_CC, price_CC, 'Start', warmup_period)
%% CNC
% =========================================================================
%Compute initial strategy weights 
current_weights_CNC = zeros(1,num_CNC_tickers); % 100% cash position
warmup_last_CNC = price_CNC(1:warmup_period,:);
% Compute the initial portfolio weights
equalweight_initial_CNC = equalWeightFcn(current_weights_CNC,warmup_last_CNC);
markowitz_initial_CNC = markowitzFcn(current_weights_CNC,warmup_last_CNC);
ticker_number_CNC = price_CNC.Properties.VariableNames;
initial_weight_CNC = [equalweight_initial_CNC(:), markowitz_initial_CNC(:)];
heatmap(strategy_name, ticker_number_CNC, initial_weight_CNC, 'title','Initial Asset Allocations CNC','Colormap', parula);
set(gca,'FontSize',10,'FontName','Arial')
tmp_tosave = gcf;
cd(fig_dir)
tmp_fig_name = strcat('Initial_weights_CNC.png')
exportgraphics(tmp_tosave,tmp_fig_name,'BackgroundColor','none','Resolution',600)
close all
clear tmp*
% Create backtest strategy
CNC1 = backtestStrategy('Equal Weighted', @equalWeightFcn, ...
    'RebalanceFrequency', freq_rebalance, ...
    'LookbackWindow', 0, ...
    'InitialWeights', equalweight_initial_CNC);
CNC2 = backtestStrategy('Markowitz Optimization', @markowitzFcn, ...
    'RebalanceFrequency', freq_rebalance, ...
    'LookbackWindow', lookback, ...
    'InitialWeights', markowitz_initial_CNC);
strats_CNC = [CNC1, CNC2];

% Backtest 
backtest_CNC = backtestEngine(strats_CNC, 'RiskFreeRate', risk_free_rate)
backtest_CNC = runBacktest(backtest_CNC, price_CNC, 'Start', warmup_period)
%% Finance
% =========================================================================
%Compute initial strategy weights 
current_weights_fin = zeros(1,num_fin_tickers); % 100% cash position
warmup_last_fin = price_fin(1:warmup_period,:);
% Compute the initial portfolio weights
equalweight_initial_fin = equalWeightFcn(current_weights_fin,warmup_last_fin);
markowitz_initial_fin = markowitzFcn(current_weights_fin,warmup_last_fin);
ticker_number_fin = price_fin.Properties.VariableNames;
initial_weight_fin = [equalweight_initial_fin(:), markowitz_initial_fin(:)];
heatmap(strategy_name, ticker_number_fin, initial_weight_fin, 'title','Initial Asset Allocations Finance','Colormap', parula);
set(gca,'FontSize',10,'FontName','Arial')
tmp_tosave = gcf;
cd(fig_dir)
tmp_fig_name = strcat('Initial_weights_Finance.png')
exportgraphics(tmp_tosave,tmp_fig_name,'BackgroundColor','none','Resolution',600)
close all
clear tmp*
% Create backtest strategy
fin1 = backtestStrategy('Equal Weighted', @equalWeightFcn, ...
    'RebalanceFrequency', freq_rebalance, ...
    'LookbackWindow', 0, ...
    'InitialWeights', equalweight_initial_fin);
fin2 = backtestStrategy('Markowitz Optimization', @markowitzFcn, ...
    'RebalanceFrequency', freq_rebalance, ...
    'LookbackWindow', lookback, ...
    'InitialWeights', markowitz_initial_fin);
strats_fin = [fin1, fin2];

% Backtest 
backtest_fin = backtestEngine(strats_fin, 'RiskFreeRate', risk_free_rate)
backtest_fin = runBacktest(backtest_fin, price_fin, 'Start', warmup_period)
%% Tech
% =========================================================================
%Compute initial strategy weights 
current_weights_tech = zeros(1,num_tech_tickers); % 100% cash position
warmup_last_tech = price_tech(1:warmup_period,:);
% Compute the initial portfolio weights
equalweight_initial_tech = equalWeightFcn(current_weights_tech,warmup_last_tech);
markowitz_initial_tech = markowitzFcn(current_weights_tech,warmup_last_tech);
ticker_number_tech = price_tech.Properties.VariableNames;
initial_weight_tech = [equalweight_initial_tech(:), markowitz_initial_tech(:)];
heatmap(strategy_name, ticker_number_tech, initial_weight_tech, 'title','Initial Asset Allocations Tech','Colormap', parula);
set(gca,'FontSize',10,'FontName','Arial')
tmp_tosave = gcf;
cd(fig_dir)
tmp_fig_name = strcat('Initial_weights_Tech.png')
exportgraphics(tmp_tosave,tmp_fig_name,'BackgroundColor','none','Resolution',600)
close all
clear tmp*
% Create backtest strategy
tech1 = backtestStrategy('Equal Weighted', @equalWeightFcn, ...
    'RebalanceFrequency', freq_rebalance, ...
    'LookbackWindow', 0, ...
    'InitialWeights', equalweight_initial_tech);
tech2 = backtestStrategy('Markowitz Optimization', @markowitzFcn, ...
    'RebalanceFrequency', freq_rebalance, ...
    'LookbackWindow', lookback, ...
    'InitialWeights', markowitz_initial_tech);
strats_tech = [tech1, tech2];

% Backtest 
backtest_tech = backtestEngine(strats_tech, 'RiskFreeRate', risk_free_rate)
backtest_tech = runBacktest(backtest_tech, price_tech, 'Start', warmup_period)
%% Examine results
% =========================================================================
% Summary values 
summary_CC = summary(backtest_CC)
summary_CC = rows2vars(summary_CC);
summary_CC.Properties.VariableNames{1} = 'Strategy'
summary_CNC = summary(backtest_CNC)
summary_CNC = rows2vars(summary_CNC);
summary_CNC.Properties.VariableNames{1} = 'Strategy'
summary_fin = summary(backtest_fin)
summary_fin = rows2vars(summary_fin);
summary_fin.Properties.VariableNames{1} = 'Strategy'
summary_tech = summary(backtest_tech)
summary_tech = rows2vars(summary_tech);
summary_tech.Properties.VariableNames{1} = 'Strategy'
summary_all = vertcat(summary_CC, summary_CNC, summary_fin, summary_tech);
summary_all.Strategy = {"CC_EW","CC_MO","CNC_EW","CNC_MO","Fin_EW","Fin_MO","Tech_EW","Tech_MO"}';
cd(save_dir)
writetable(summary_all,'final_results.csv')

% Plotting the testing set's change in allocation based on diff strategies in diff sectors 
ew = "Equal_Weighted";
mo = "Markowitz_Optimization";
cd(fig_dir)

assetareaplot(backtest_CC, ew)
tmp_fig_name = strcat('Consumer Cyclical Equal Weighted Change in Allocation.png')
title(tmp_fig_name)
set(gca,'FontSize',12,'FontName','Arial')
tmp_tosave = gcf;
exportgraphics(tmp_tosave,tmp_fig_name,'BackgroundColor','none','Resolution',600)
close all
clear tmp*

assetareaplot(backtest_CC, mo)
tmp_fig_name = strcat('Consumer Cyclical Markowitz Opt Change in Allocation.png')
title(tmp_fig_name)
set(gca,'FontSize',12,'FontName','Arial')
tmp_tosave = gcf;
exportgraphics(tmp_tosave,tmp_fig_name,'BackgroundColor','none','Resolution',600)
close all
clear tmp*

assetareaplot(backtest_CNC, ew)
tmp_fig_name = strcat('Consumer NonCyclical Equal Weighted Change in Allocation.png')
title(tmp_fig_name)
set(gca,'FontSize',12,'FontName','Arial')
tmp_tosave = gcf;
exportgraphics(tmp_tosave,tmp_fig_name,'BackgroundColor','none','Resolution',600)
close all
clear tmp*

assetareaplot(backtest_CNC, mo)
tmp_fig_name = strcat('Consumer NonCyclicalMarkowitz Opt Change in Allocation.png')
title(tmp_fig_name)
set(gca,'FontSize',12,'FontName','Arial')
tmp_tosave = gcf;
exportgraphics(tmp_tosave,tmp_fig_name,'BackgroundColor','none','Resolution',600)
close all
clear tmp*

assetareaplot(backtest_fin, ew)
tmp_fig_name = strcat('Financial Equal Weighted Change in Allocation.png')
title(tmp_fig_name)
set(gca,'FontSize',12,'FontName','Arial')
tmp_tosave = gcf;
exportgraphics(tmp_tosave,tmp_fig_name,'BackgroundColor','none','Resolution',600)
close all
clear tmp*

assetareaplot(backtest_fin, mo)
tmp_fig_name = strcat('Financial Markowitz Opt Change in Allocation.png')
title(tmp_fig_name)
set(gca,'FontSize',12,'FontName','Arial')
tmp_tosave = gcf;
exportgraphics(tmp_tosave,tmp_fig_name,'BackgroundColor','none','Resolution',600)
close all
clear tmp*

assetareaplot(backtest_tech, ew)
tmp_fig_name = strcat('Tech Equal Weighted Change in Allocation.png')
title(tmp_fig_name)
set(gca,'FontSize',12,'FontName','Arial')
tmp_tosave = gcf;
exportgraphics(tmp_tosave,tmp_fig_name,'BackgroundColor','none','Resolution',600)
close all
clear tmp*

assetareaplot(backtest_tech, mo)
tmp_fig_name = strcat('Tech Markowitz Opt Change in Allocation.png')
title(tmp_fig_name)
set(gca,'FontSize',12,'FontName','Arial')
tmp_tosave = gcf;
exportgraphics(tmp_tosave,tmp_fig_name,'BackgroundColor','none','Resolution',600)
close all
clear tmp*

