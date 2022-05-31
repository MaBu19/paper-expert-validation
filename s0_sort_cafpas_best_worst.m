% sort predicted CAFPAs for best and worst models 
% 
% MB 07.03.22 

clear all; 
close all; 
clc; 

data = load('../data-predicted-cafpas/preprocessing_cafpas_pred_unlabeled_lasso-elasticNet-randomForest.mat'); 

evaluatorString = {'M','Mw'};

data_array(:,:,1) = data.cafpas_pred{1}; % lasso
data_array(:,:,2) = data.cafpas_pred{2}; % elasticNet
data_array(:,:,3) = data.cafpas_pred{3}; % randomForest 

best_idx =  [1,3,2,1,1,3,2,1,1,1];
worst_idx = [3,1,3,3,3,2,3,2,2,3]; % according to Methods_Cafpas.xlsx
 
for s = 1:size(data_array,1)
    for tc = 1:10 
        cafpas_best(s,tc) = data_array(s,tc,best_idx(tc));
        cafpas_worst(s,tc) = data_array(s,tc,worst_idx(tc));
    end
end 

 
Tb = table(); 
Tb.Evaluator = repmat(evaluatorString(1),size(data_array,1),1); % all 355 
Tb.SubjectID = data.patID_models; 
Tb.Expert = zeros(size(data_array,1),1);
Tb.best_worst = repmat('b',size(data_array,1),1);
Tbc = array2table(cafpas_best,'VariableNames',{'CA1','CA2','CA3','CA4','CU1','CU2','CB','CN','CC','CE'}); 
Tb = [Tb,Tbc]; 

Tw = table(); 
Tw.Evaluator = repmat(evaluatorString(2),size(data_array,1),1); % all 355 
Tw.SubjectID = data.patID_models; 
Tw.Expert = zeros(size(data_array,1),1);
Tw.best_worst = repmat('w',size(data_array,1),1);
Twc = array2table(cafpas_worst,'VariableNames',{'CA1','CA2','CA3','CA4','CU1','CU2','CB','CN','CC','CE'}); 
Tw = [Tw,Twc]; 

T = [Tb;Tw];

writetable(T,'./data_sorted_auto/cafpas_M_best_worst.xlsx'); 
