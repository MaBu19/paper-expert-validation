% sort data automatically
% 1) from raw expert data to a file structured as THE_DATA.xlsx
%
% MB 07.03.22
% 
% Matlab R2020b
%
 

clear all;
close all;
clc;

varNames = {'slider_CA1.response_raw','slider_CA2.response_raw','slider_CA3.response_raw','slider_CA4.response_raw','slider_CU1.response_raw','slider_CU2.response_raw','slider_CB.response_raw','slider_CN.response_raw','slider_CC.response_raw','slider_CE.response_raw', ...
    'Recruitment.response_raw','Zentraler_HV.response_raw','breitbandig.response_raw','hochton_HV.response_raw','mittelton_HV.response_raw','normal_h.response_raw','schallleitungs_HV.response_raw','tiefton_HV.response_raw'};
varNames = strrep(varNames, '.','_');
evaluatorString = {'E1','E2'};

%% read raw data (expert survey)
num_pat = 15; % per definition, patients per package
T = table();

for n_exp = 1:2
    files_exp1 = dir(['./data-expert/expert' num2str(n_exp) '/*mainpart*.xlsx']); 
    
    for ie = 1:length(files_exp1)        
        data_tmp = readtable(['./data-expert/expert' num2str(n_exp) '/' files_exp1(ie).name]);
        
        for ip = 1:num_pat
            % extract subjectID
            tmp = strsplit(data_tmp.survey_track{ip},'.');
            pID(ip,1) = str2num(tmp{1}(end-4:end));
            
            % extract best/worst (which CAFPAs presented to expert) 
            tmp2 = strsplit(data_tmp.CAFPAs_track{ip},'.');
            tmp2b = strsplit(tmp2{1},'_'); 
            bwmodels{ip} = strrep(tmp2b{end},'models',''); 
            if strcmp(bwmodels{ip},'best')
                bwlist{ip} = 'b'; 
            elseif strcmp(bwmodels{ip},'worst')
                bwlist{ip} = 'w'; 
            end
        end
 
        Tneu = data_tmp(1:num_pat,varNames);
        Tneu.SubjectID = pID;
        Tneu.Expert = n_exp*ones(num_pat,1);
        Tneu.Evaluator = repmat(evaluatorString{n_exp},num_pat,1);
        Tneu.best_worst = bwlist'; 
        
        % code nan in findings as 0 (interpretation: not ticked by experts
        % - in contrast to NaN for machine-predicted)
        for ic = 11:18
            Tneu.(varNames{ic})(isnan(Tneu.(varNames{ic}))) = 0;
        end
        
        T = [T; Tneu];
        
    end
end
[~,~,T.Subject]=unique(T.SubjectID,'stable'); 
% check: [T.Subject, T.SubjectID]

T = T(:,[23 21 19 20 22 1:18]);

% rename CAFPA and findings columns
T = renamevars(T,{varNames{1:10}},{'CA1','CA2','CA3','CA4','CU1','CU2','CB','CN','CC','CE'});
T = renamevars(T,varNames(11:end),strrep(varNames(11:end),'_response_raw',''));

% adapt variable types to allow filtering (before: cellstr)
T.best_worst = categorical(T.best_worst);
T.Evaluator = categorical(cellstr(T.Evaluator)); 


T = sortrows(T,'Subject'); 

%% read predicted data (best/worst models sorted in sort_cafpas_best_worst.m) and add to table T 
% filter by SubjectID and best_worst (as contained in T)
T_M = readtable(['./data_sorted_auto/cafpas_M_best_worst.xlsx']);

% estimate 'Subject' for machine-predicted data (and only include those
% patients that are already available in T)
[t_add_u iua iuc] = unique(T_M.SubjectID,'stable'); 
t_uni = unique([T.Subject, T.SubjectID],'rows'); 
T_idx = table(t_uni(:,1),t_uni(:,2),'VariableNames',{'Subject','SubjectID'}); 

T_M_subj = outerjoin(T_idx,T_M,'Keys','SubjectID','MergeKeys',true);
% T_M_subj = sortrows(T_M_subj,'Subject'); 

% adapt variable types to allow filtering (before: cellstr)
T_M_subj.best_worst = categorical(T_M_subj.best_worst); 

% t_eval_u = unique(categorical(cellstr(T.Evaluator)));
% t_bw_u = unique(categorical(cellstr(T.best_worst))); 
[G_T ID_T] = findgroups(T(:,{'SubjectID','best_worst'}));

% some info: 
% T(T.Evaluator == categorical(t_eval_u(2)),:) 
% --> all E2 cases are with best models (per definition, only package 1) 
% --> therefore, no patient ids exist that were asked with best and worst CAFPAs 
% (E1 and E2 answered the exact same patients with best models and E2 didn't answer any additional patient)


% filter with ID_T combinations (SubjectID and best_worst)
% t_tmp = T_M_subj(T_M_subj.SubjectID==ID_T.SubjectID(1) & T_M_subj.best_worst == ID_T.best_worst(1),:);
T_M_subj = T_M_subj(any(T_M_subj.SubjectID==ID_T.SubjectID' & T_M_subj.best_worst == ID_T.best_worst',2),:);
T_M_subj = T_M_subj(:,[1 3 2 4:end]); 

% include data from T_M (corresponding to available expert knowledge in T)
T_add = table('Size',[size(T_M_subj,1) size(T,2)],'VariableTypes',{'double','categorical','double','double','categorical','double','double','double','double','double','double','double','double','double','double','double','double','double','double','double','double','double','double'},'VariableNames',T.Properties.VariableNames);
% (does xlsx need 'string' as VariableType? - or able to deal with 'categorical'?)
T_add(:,[1 3:4 6:end]) = array2table(nan(size(T_add(:,[1 3:4 6:end])))); 
T_add(:,[1:size(T_M_subj,2)]) = T_M_subj;

% combine data for expert and machine-predicted CAFPAs
T = [T; T_add]; 
 
% sort by 'Subject'
T = sortrows(T,'Subject'); 

% save 
writetable(T,'./data_sorted_auto/THE_DATA.xlsx'); 
writetable(T,'./data_sorted_auto/THE_DATA','Delimiter','\t'); 



