%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analyses for Paper:                                                       % 
% Domain Experts about Automated Audiological Diagnostics -                 %
% Validating Machine-Predicted Common Audiological Functional Parameters    % 
% (CAFPAs) as Intermediate Representation in a Clinical Decision-Support    % 
% System                                                                    %
% Script authors: Andrea Hildebrandt, Mareike Buhl, Samira Saak, Gülce Akin %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% a2: visualize CAFPA difference 

clear all; 
close all; 
clc; 

addpath('functions'); 

sflag = 1; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RQ3: Are the estimated audiological findings consistent with expert labels 
% from previous studies collected for patients of the same database?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

T_E1_M = readtable('./Datasets/DATA_correlation.xlsx'); 
T_E1_M.best_worst = categorical(T_E1_M.best_worst);
T_E1_M.Evaluator = categorical(cellstr(T_E1_M.Evaluator)); 

% extract CAFPAs 
cafpas_E1 = T_E1_M{T_E1_M.Evaluator == 'E1',{'CA1','CA2','CA3','CA4','CU1','CU2','CB','CN','CC','CE'}};
cafpas_M = T_E1_M{T_E1_M.Evaluator == 'M',{'CA1','CA2','CA3','CA4','CU1','CU2','CB','CN','CC','CE'}}; 

% plot properties 
pp.visible = 'on';  
pp.isOctave = 0; 
pp.calc_flag = 'median'; 

% extract audiological findings
findings = T_E1_M{T_E1_M.Evaluator == 'E1',T_E1_M.Properties.VariableNames(15+[6 4 8 5 3 7 2 1])};
% --> columns already sorted to match findings_header as given below 
% findings_header = {'nh','high','low','mid','bb','cond','cent','recr'}; 

% inspect available combinations of audiological findings 
[combis, idxa, idxb] = unique(findings,'rows');
hist_combis = hist(idxb,[1:1:length(idxa)]); 
% figure; bar(1:1:length(idxa),hist_combis)

% estimate most frequent findings
idx_most_freq = find(hist_combis>=10); 
combis(idx_most_freq,:);

figh5a = figure; bar(1:1:length(idx_most_freq),hist_combis(idx_most_freq([4 2 3 1])))
xlabel('Audiological findings')
ylabel('Number of patients')
xlim([0.2 4.8])

% meaning of these combinations: 1) broadband, 2) high-freq, 3) high-freq+bb, 4) nh 
combi_names = {'bb','high','high+bb','nh'}; 
combi_names_plot = {'NH','High','High+BB','BB'}; % sorted: [4 2 3 1]

set(gca,'XTick',[1:4],'XTickLabel',combi_names_plot)

if sflag
    print(figh5a,['./plots/a2/histo_most-freq-findings.eps'],'-painters','-depsc','-r600');
    print(figh5a,['./plots/a2/histo_most-freq-findings.png'],'-dpng','-r600'); 
end 


%% Patterns (median) for CAFPAs filtered according to most frequent combinations (idx_most_freq) 

for idx_cur = 1:4
    
    
    [figh5,axh,pm] = plot_cafpas_survey_2(cafpas_E1(idxb == idx_most_freq(idx_cur),:),1,pp);
    [figh6,axh,pm] = plot_cafpas_survey_2(cafpas_M(idxb == idx_most_freq(idx_cur),:),1,pp);
    
    if sflag
        print(figh5,['./plots/a2/cafpas_E1_' combi_names{idx_cur} '_N' num2str(hist_combis(idx_most_freq(idx_cur))) '.eps'],'-painters','-depsc','-r600');
        print(figh5,['./plots/a2/cafpas_E1_' combi_names{idx_cur} '_N' num2str(hist_combis(idx_most_freq(idx_cur))) '.png'],'-dpng','-r600');
        print(figh6,['./plots/a2/cafpas_M_' combi_names{idx_cur} '_N' num2str(hist_combis(idx_most_freq(idx_cur))) '.eps'],'-painters','-depsc','-r600');
        print(figh6,['./plots/a2/cafpas_M_' combi_names{idx_cur} '_N' num2str(hist_combis(idx_most_freq(idx_cur))) '.png'],'-dpng','-r600');
    end
    
    
    T_E1 = array2table(cafpas_E1(idxb == idx_most_freq(idx_cur),:));
    T_M  = array2table(cafpas_M(idxb == idx_most_freq(idx_cur),:));
    
    T_E1.Properties.VariableNames = {'CA1','CA2','CA3','CA4','CU1','CU2','CB','CN','CC','CE'}; 
    T_M.Properties.VariableNames = {'CA1','CA2','CA3','CA4','CU1','CU2','CB','CN','CC','CE'}; 

    % save CAFPA matrices for different audiological findings for density plot in R (script a3_...):
    writetable(T_E1,['./results/a2/cafpas_E1_' combi_names{idx_cur} '.xlsx']);
    writetable(T_E1,['./results/a2/cafpas_E1_' combi_names{idx_cur}],'Delimiter','\t');
    writetable(T_M,['./results/a2/cafpas_M_' combi_names{idx_cur} '.xlsx']);
    writetable(T_M,['./results/a2/cafpas_M_' combi_names{idx_cur}],'Delimiter','\t');

end 






