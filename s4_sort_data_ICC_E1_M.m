% sort data automatically
% 4) from ./data_sorted_auto/DATA_correlation.xlsx to ./data_sorted_auto/DATA_for_ICC_E1_M.txt
%
% MB 17.03.22
% 
% Matlab R2020b
%

clear all;
close all;
clc;


%% corresponding best/worst E vs. M 
T_in = readtable(['./data_sorted_auto/DATA_correlation.xlsx']);

T_in.Evaluator = categorical(cellstr(T_in.Evaluator)); 
T_in.best_worst = categorical(cellstr(T_in.best_worst)); 

subj_corr = T_in.Evaluator == 'E2'; 
T_in(subj_corr,:) = [];

T_out1 = T_in(:,{'Subject','Evaluator','SubjectID','CA1','CA2','CA3','CA4','CU1','CU2','CB','CN','CC','CE'}); 

% save 
writetable(T_out1,'./data_sorted_auto/DATA_for_ICC_E1_M.xlsx'); 
writetable(T_out1,'./data_sorted_auto/DATA_for_ICC_E1_M','Delimiter','\t'); 
