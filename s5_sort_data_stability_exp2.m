% sort data automatically
% 5) from ./data_sorted_auto/THE_DATA.xlsx to ./data_sorted_auto/DATA_for_stability_Expert2.txt
%
% MB 17.03.22
% 
% Matlab R2020b
%

clear all;
close all;
clc;

%% read THE_DATA.xlsx
T_all = readtable(['./data_sorted_auto/THE_DATA.xlsx']);

T_all.Evaluator = categorical(cellstr(T_all.Evaluator)); 
T_all.best_worst = categorical(cellstr(T_all.best_worst)); 

% extract all rows with Evaluator E2 
T_out = T_all(T_all.Evaluator == 'E2',:); 

% add session ID (can be done just with increasing number as the order of
% rows is maintained during all processing steps)
T_out.Session = repmat([1:12]',15,1); 
 
T_out = T_out(:,[1 24 3:23]);

% save 
writetable(T_out,'./data_sorted_auto/DATA_for_stability_Expert2.xlsx'); 
writetable(T_out,'./data_sorted_auto/DATA_for_stability_Expert2','Delimiter','\t'); 
