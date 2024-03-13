% Identifying and cleaning missing values for all data
% Compiling all data for subsequent analyses
%   Input: data_volume, data_sector, data_mktcap, data_last
%   Output: cleaned_alltickers.mat
%           - C.data: cell, with size 255x1 (# of unique company tickers)
%               1599 (dates) x 5 (ticker, vol, mktcap, last, sector)
%           - C.datavol (cleaned)
%           - C.datasec (cleaned)
%           - C.datamktcap (cleaned)
%           - C.datalast (cleaned)
%           - Log
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
save_dir = "/Users/hilaryngai/Desktop/To DO/y_intercept_coding_test/output";
cd(input_dir)

%% Read files in & check missing data
% =========================================================================
data_vol = readtable('data_volume.csv',"TextType","string","TreatAsMissing",[".","NA"]);
data_sec = readtable('data_sector.csv',"TextType","string","TreatAsMissing",[".","NA"]);
data_mktcap = readtable('data_mkt_cap.csv',"TextType","string","TreatAsMissing",[".","NA"]);
data_last = readtable('data_last.csv',"TextType","string","TreatAsMissing",[".","NA"]);

summary(data_vol); %start date 170816 to 240306... check on 0 volume entries
summary(data_sec); %263 tickers in total
summary(data_mktcap);%2846 missing values found
summary(data_last); %2846 missing values found

%explore 0 values in vol & missing values in mktcap and last
data_vol = sortrows(data_vol,'volume','ascend');
data_vol = sortrows(data_vol,'date','ascend');
data_vol = sortrows(data_vol,'date','descend');
missing_mktcap = ismissing(data_mktcap,{string(missing),NaN});
rows_mktcap = any(missing_mktcap,2);
missing_mktcaprows = data_mktcap(rows_mktcap,:);
missing_last = ismissing(data_last,{string(missing),NaN});
rows_last = any(missing_last,2);
missing_lastrows = data_last(rows_last,:);

% 1334,3893,6767,8270,8332,8815 have 0 volume for the whole period given
% i also find that ticker 5831 and 9147 have 4+ years of missing values. 
% will remove from all usable data
rows2remove_vol = find(strcmp(data_vol.ticker,'1334 JT') | strcmp(data_vol.ticker,'3893 JT') | ...
    strcmp(data_vol.ticker,'6767 JT') | strcmp(data_vol.ticker,'8270 JT') | ...
    strcmp(data_vol.ticker,'8332 JT') | strcmp(data_vol.ticker,'8815 JT') | ...
    strcmp(data_vol.ticker,'5831 JT') | strcmp(data_vol.ticker, '9147 JT'));
data_vol([rows2remove_vol],:) = [];
rows2remove_sec = find(strcmp(data_sec.ticker,'1334 JT') | strcmp(data_sec.ticker, '3893 JT') | ...
    strcmp(data_sec.ticker,'6767 JT') | strcmp(data_sec.ticker, '8270 JT') | ...
    strcmp(data_sec.ticker,'8332 JT') | strcmp(data_sec.ticker, '8815 JT') | ...
    strcmp(data_sec.ticker,'5831 JT') | strcmp(data_sec.ticker, '9147 JT'));
data_sec([rows2remove_sec],:) = [];
rows2remove_mktcap = find(strcmp(data_mktcap.ticker,'1334 JT') | strcmp(data_mktcap.ticker, '3893 JT') | ...
    strcmp(data_mktcap.ticker,'6767 JT') | strcmp(data_mktcap.ticker, '8270 JT') | ...
    strcmp(data_mktcap.ticker,'8332 JT') | strcmp(data_mktcap.ticker, '8815 JT') | ...
    strcmp(data_mktcap.ticker,'5831 JT') | strcmp(data_mktcap.ticker, '9147 JT'));
data_mktcap([rows2remove_mktcap],:) = [];
rows2remove_last = find(strcmp(data_last.ticker,'1334 JT') | strcmp(data_last.ticker, '3893 JT') | ...
    strcmp(data_last.ticker,'6767 JT') | strcmp(data_last.ticker, '8270 JT') | ...
    strcmp(data_last.ticker,'8332 JT') | strcmp(data_last.ticker, '8815 JT') |  ...
    strcmp(data_last.ticker,'5831 JT') | strcmp(data_last.ticker, '9147 JT'));
data_last([rows2remove_last],:) = [];

clear rows* missing*
%% Create cell storing each ticker's information
num_tick = height(data_sec); %number of tickers
compiled_data = {};
% Split the tables into a cell array based on ticker and date
for i = 1:num_tick
    tmp_ticker = data_sec.ticker{i}; %find the unique ticker ID
    tmp_rows_vol = find(strcmp(data_vol.ticker,tmp_ticker));
    tmp_rows_mktcap = find(strcmp(data_mktcap.ticker,tmp_ticker));
    tmp_rows_last = find(strcmp(data_last.ticker,tmp_ticker));
    tmp_datavol = data_vol([tmp_rows_vol],:);
    tmp_datamktcap = data_mktcap([tmp_rows_mktcap],:);
    tmp_datalast = data_last([tmp_rows_last],:);
    tmp_datavol = table2timetable(tmp_datavol);
    tmp_datamktcap = table2timetable(tmp_datamktcap);
    tmp_datalast = table2timetable(tmp_datalast);
    tmp_datamktcap = removevars(tmp_datamktcap, 'ticker');
    tmp_datalast = removevars(tmp_datalast, 'ticker');
    compiled_data{i,1} = synchronize(tmp_datavol, tmp_datamktcap, tmp_datalast); %combine based on date
    tmp_rows_sec = find(strcmp(data_sec.ticker,tmp_ticker));
    tmp_datasec = data_sec([tmp_rows_sec],2);
    compiled_data{i,1}(:,5) = tmp_datasec; %add back the sector
    clear tmp*
end


%% Save output
% =========================================================================
var_names = {'date','ticker','volume','mktcap','last','sector'};% Naming the headers
C.data = compiled_data;
C.datavol = data_vol;
C.datasec = data_sec;
C.datamktcap = data_mktcap;
C.datalast = data_last;
C.var_names = var_names;

Log = [];
Log.data_generation_date = datetime;
Log.data_generation_script = mfilename('fullpath');

cd(save_dir)
eval(['save cleaned_alltickers',...
    char(datetime('now','Format','dd-MMM-yyyy-HH-mm-ss'))]);