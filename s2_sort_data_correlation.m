% sort data automatically
% 2) from ./data_sorted_auto/THE_DATA.xlsx to ./data_sorted_auto/DATA_correlation.txt
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


% corresponding best/worst E vs. M 
[G,ID] = findgroups(T_all(:,{'Subject','Evaluator'})); 
[~,idx] = ismember(ID,T_all(:,{'Subject','Evaluator'})); % automatically takes the first row for each group 

T_out1 = T_all(idx,:); 
T_out1.Evaluator((T_out1.Evaluator == 'Mw')) = 'M'; 

% save 
writetable(T_out1,'./data_sorted_auto/DATA_correlation.xlsx'); 
writetable(T_out1,'./data_sorted_auto/DATA_correlation','Delimiter','\t'); 
 


