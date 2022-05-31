% sort data automatically
% 6) from ./data_sorted_auto/THE_DATA.xlsx to ./data_sorted_auto/dat_expert1_stability.txt
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

% extract all rows with Evaluator E1 
T_out = T_all(T_all.Evaluator == 'E1',:); 

% filter for patients that were answered twice by E1 
h = hist(T_out.Subject,[1:1:max(T_out.Subject)]); 
subj_2 = find(h == 2); 
T_out = T_out(any(T_out.Subject == subj_2,2),:); 

% add session ID (can be done just with increasing number as the order of
% rows is maintained during all processing steps)
T_out.Session = repmat([1:2]',15,1); 
 
T_out = T_out(:,[1 24 3:23]);

% save 
writetable(T_out,'./data_sorted_auto/DATA_for_stability_Expert1.xlsx'); 
writetable(T_out,'./data_sorted_auto/DATA_for_stability_Expert1','Delimiter','\t'); 
