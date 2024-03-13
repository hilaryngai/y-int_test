# y-int_test
This repository is created for submission of a coding test for Y-Intercept Quant Research Internship.
by Hilary HT Ngai
hilaryngai@gmail.com
240313

Structure of repository
1) figures:
	Contains figures printed using the scripts below
	- Initial_Weights_sectors.png
		the initial weights used in the two trading strategies implemented for each sector
	- Moving_Average_sectors.png
		the simple moving averages in each sector
	- sector_strat_Change_Allocation.png
		the change in asset allocation positions in the testing set of data. Testing set was defined as the median date onwards, which was 2017-11-30
		NOTE: lowercase letters are replaceable by available sectors or strategies
			uppercase letters are not replaceable
		e.g. sector_strat_Change_Allocation.png can stand for the Change in Allocation of ConsumerCyclical[sector] and Markowitz Optimization[strat]
2) input_data:
	Provided by the coding test which includes the following
	- data_last.csv (ticker time series x last known price)
		assumption was made that the last known price was the adjusted price
	- data_mkt_cap.csv (ticker time series x market cap)
	- data_sector.csv (ticker ID x sector)
		further exploration showed 9 unique sectors
	- data_volume.csv (ticker time series x volume)
3) output: 
	Includes output from each script [see below] named with datetime the script was run and log of which script was used to produce this output
	- cleaned_alltickers.mat
           - C.data: cell, with size 255x1 (# of unique company tickers)
               1599 (dates) x 5 (ticker, vol, mktcap, last, sector)
           - C.datavol (cleaned)
           - C.datasec (cleaned)
           - C.datamktcap (cleaned)
           - C.datalast (cleaned)
           - Log
	- cleaned_sectortickers.mat
	   - Output(1) cleaned_sectortickers.mat 
              - D.consumercyclicaldata = data_CC;
              - D.consumerNoncyclicaldata = data_CNC;
              - D.findata = data_fin;
              - D.techdata = data_tech;
              - D.sectorysummary = sector_summary;
           - Output(2) Figures of Mov_Avg_sectors.png
	- final_data.csv
		NOTE: Please see the acronyms and what they stand for:
			Sectors: CC = Consumer Cyclical
				 CNC = Consumer Non Cyclical
				 Fin = Financial
				 Tech = Technology
			Strategies: EW = Equal Weighted
				    MO = Markowitz Optimization
4) scripts:
  Scripts are to be run in the following order
	- a_dataprep_all.m
		Aim: (1) Identifying and cleaning missing values for all data & (2) Compiling all sector's data for subsequent analyses
	- b_dataprep_sector.m
		Aim: (1) Explore data using simple moving average, daily returns & (2) Compile data from four specific sectors of interest for further analysis
	- c_backtesting.m
		Aim: (1) Implement two trading strategies: Equal Weighted & Markowitz Optimization (2) Backtest by splitting the available data by median date 171130 (3) Save final_data.csv and figures to examine the performance 
NOTE: the function subfolder is needed to run certain lines in the scripts. However, those functions do not need to be open when running the 3 scripts. They merely have to be in the same directory.
