% sort data automatically
% 3) from ./data_sorted_auto/DATA_correlation.xlsx to ./data_sorted_auto/DATA_for_ICC.txt
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

subj_corr = T_in.Subject(T_in.Evaluator == 'E2',:); 

T_tmp = T_in(any(T_in.Subject == subj_corr',2),:); 
T_tmp = renamevars(T_tmp,{'Subject'},{'SubjectOld'}); 

T_subj_list = table(subj_corr, [1:length(subj_corr)]','VariableNames',{'SubjectOld','Subject'});
T_tmp = outerjoin(T_subj_list,T_tmp,'Keys','SubjectOld','MergeKeys',true);


T_out1 = T_tmp(:,{'Subject','Evaluator','SubjectID','CA1','CA2','CA3','CA4','CU1','CU2','CB','CN','CC','CE'}); 

% save 
writetable(T_out1,'./data_sorted_auto/DATA_for_ICC.xlsx'); 
writetable(T_out1,'./data_sorted_auto/DATA_for_ICC','Delimiter','\t'); 


