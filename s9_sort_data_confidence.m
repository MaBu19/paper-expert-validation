% sort data automatically
% 9) confidence questions
%
% MB 23.03.22
%
% Matlab R2020b
%
%

clear all;
close all;
clc;


%% read raw data (survey)
T = table();

for n_exp = 1:2
    if n_exp == 1
        files_exp1 = dir(['./expert' num2str(n_exp) '/*mainpart*.csv']);
    elseif n_exp == 2
        files_exp1 = dir(['./expert' num2str(n_exp) '_orig/*mainpart*.csv']);
    end
    for n = 1:length(files_exp1)
        idx(n) = isempty(strfind(files_exp1(n).name,'trials'));
    end
    files_exp1 = files_exp1(idx);
    num_res(n_exp) = sum(idx); 
     
    
    for ie = 1:length(files_exp1)
        if n_exp == 1
            T_tmp = readtable(['./expert' num2str(n_exp) '/' files_exp1(ie).name]);
        elseif n_exp == 2
            T_tmp = readtable(['./expert' num2str(n_exp) '_orig/' files_exp1(ie).name]);
        end
        
        if any(strcmp(T_tmp.Properties.VariableNames,'slider_1fr_response'))            
            conf1(ie+num_res(1) *(n_exp-1)) = T_tmp.slider_1fr_response(20); 
            conf2(ie+num_res(1) *(n_exp-1)) = T_tmp.slider_2fr_response(20);
            %            conf3(ie+length(files_exp1) *(n_exp-1)) =
            %            T_tmp.slider_3fr_response(20); % Frage war nicht sinnvoll,
            %            keine Versorgung in Umfrage
            
            
        else
            if any(strcmp(T_tmp.Properties.VariableNames,'firstq_response')) % special case in one file 
                conf1(ie+num_res(1) *(n_exp-1)) = T_tmp.firstq_response(20);
                conf2(ie+num_res(1) *(n_exp-1)) = T_tmp.secondq_response(20);
                
            else
                conf1(ie+num_res(1) *(n_exp-1)) = NaN;
                conf2(ie+num_res(1) *(n_exp-1)) = NaN;
            end
            
        end
    end
end

T.Expert = [repmat(1,num_res(1),1); repmat(2,num_res(2),1)];
T.package = [1:num_res(1),1:num_res(2)]';
T.conf1 = conf1';
T.conf2 = conf2';


%% calculate mean and std per expert 

m_exp1_cafpas = nanmean(T.conf1(1:num_res(1))) 
std_exp1_cafpas = nanstd(T.conf1(1:num_res(1))) 

m_exp1_findings = nanmean(T.conf2(1:num_res(1))) 
std_exp1_findings = nanstd(T.conf2(1:num_res(1))) 

m_exp2_cafpas = nanmean(T.conf1(num_res(1)+1:end)) 
std_exp2_cafpas = nanstd(T.conf1(num_res(1)+1:end)) 

m_exp2_findings = nanmean(T.conf2(num_res(1)+1:end)) 
std_exp2_findings = nanstd(T.conf2(num_res(1)+1:end)) 


% save 
T = renamevars(T,{'conf1','conf2'},{'conf_cafpas','conf_findings'}); 

writetable(T,'./data_sorted_auto/survey-confidence.xlsx'); 
writetable(T,'./data_sorted_auto/survey-confidence','Delimiter','\t'); 








