% sort data automatically
% 7) from ./data_sorted_auto/DATA_for_ICC_E1_M.xlsx to ./data_sorted_auto/150_sub_meas_MLM_without_nan.txt
%
% MB 17.03.22
% 
% Matlab R2020b
%
% Note: the first part of the created file is mainly the same as
% ./data_sorted_auto/DATA_for_ICC_E1_M.xlsx 

clear all;
close all;
clc;

%% read DATA_for_ICC_E1_M.xlsx 
T_in = readtable(['./data_sorted_auto/DATA_for_ICC_E1_M.xlsx']);
T_in.Evaluator = categorical(cellstr(T_in.Evaluator)); 

T_in = renamevars(T_in,{'Evaluator'},{'EvaluatorL'}); % consistent with THE_DATA would be to call the new column "Expert", but "Evaluator" used in R (0,1)

T_in.Evaluator = nan(size(T_in,1),1); 
T_in.Evaluator(T_in.EvaluatorL == 'M') = 0; 
T_in.Evaluator(T_in.EvaluatorL == 'E1') = 1; 

T_in = T_in(:,[1 14 2:13]); 


%% read measurement data 
T_meas = readtable(['../data-previous_st/CAFPA_dataset_meas_unlabeled_18-Jun-2020.txt']);
T_meas.m_gender = categorical(T_meas.m_gender);

T_meas.Properties.VariableNames = strrep(T_meas.Properties.VariableNames,'m_','m-');
T_meas = renamevars(T_meas,{'x_PatientID'},{'SubjectID'});

% combine with CAFPAs 
T_combi = join(T_in,T_meas,'Keys','SubjectID');

% save 
writetable(T_combi,'./data_sorted_auto/150_sub_meas_MLM_nan_all.xlsx'); 
writetable(T_combi,'./data_sorted_auto/150_sub_meas_MLM_nan_all','Delimiter','\t'); 


%% only include data used for LMER models
% calculate worst ear 
pta_right = nanmean(T_meas{:,{'m-ag_ac_ri_500','m-ag_ac_ri_1000','m-ag_ac_ri_2000','m-ag_ac_ri_4000'}},2); 
pta_left = nanmean(T_meas{:,{'m-ag_ac_le_500','m-ag_ac_le_1000','m-ag_ac_le_2000','m-ag_ac_le_4000'}},2); 
idx_left = pta_left >= pta_right;
idx_right = ~idx_left; 

% add data related to worst ear 
T_meas.PTA = zeros(size(pta_right)); 
T_meas.PTA(idx_left) = pta_left(idx_left); 
T_meas.PTA(idx_right) = pta_right(idx_right); 

T_meas.("m-acalos_1_5_worst_L2_5") = zeros(size(pta_right));
T_meas.("m-acalos_1_5_worst_L2_5")(idx_left) = T_meas.("m-acalos_1_5_le_L2_5")(idx_left); 
T_meas.("m-acalos_1_5_worst_L2_5")(idx_right) = T_meas.("m-acalos_1_5_le_L2_5")(idx_right); 

T_meas.("m-acalos_1_5_worst_L50") = zeros(size(pta_right));
T_meas.("m-acalos_1_5_worst_L50")(idx_left) = T_meas.("m-acalos_1_5_le_L50")(idx_left); 
T_meas.("m-acalos_1_5_worst_L50")(idx_right) = T_meas.("m-acalos_1_5_le_L50")(idx_right); 

T_meas.("m-acalos_4_worst_L2_5") = zeros(size(pta_right));
T_meas.("m-acalos_4_worst_L2_5")(idx_left) = T_meas.("m-acalos_4_le_L2_5")(idx_left); 
T_meas.("m-acalos_4_worst_L2_5")(idx_right) = T_meas.("m-acalos_4_le_L2_5")(idx_right);  

% choose desired variables 
var_choice = {'SubjectID','PTA','m-age','m-gender','m-swi_sum','m-goesa_srt','m-wst_raw','m-demtect','m-tinnitus_ri','m-tinnitus_le','m-acalos_1_5_worst_L2_5','m-acalos_1_5_worst_L50','m-acalos_4_worst_L2_5'}; 

% combine with CAFPAs 
T_combi2 = join(T_in,T_meas(:,var_choice),'Keys','SubjectID');

% save 
writetable(T_combi2,'./data_sorted_auto/150_sub_meas_MLM_nan.xlsx'); 
writetable(T_combi2,'./data_sorted_auto/150_sub_meas_MLM_nan','Delimiter','\t'); 

