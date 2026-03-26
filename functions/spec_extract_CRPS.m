function [output_tab, outputAbs_tab] = spec_extract_CRPS(PanelVAR_output,targetv_str,targetc_str,spec_vec,target_vec,baseSpec_str)

if strcmp(baseSpec_str,'AR_forecast')
    leaveitbe = 1;
elseif strcmp(baseSpec_str,'RW_forecast')
    leaveitbe = 1;
else
    leaveitbe = 0;
end

hor = 8;
targetall_str   = strcat(targetv_str,'_',targetc_str);
fnames_all      = fieldnames(PanelVAR_output);
% fnames          = spec_vec';

% fnames(1,:)     = [];    % delete the simulated data
% fnames(2,:)     = [];    % delete the special case N=2, G=2
% fnames(14,:)    = [];    % delete the simulated data
fnames          = cell(0);
for ii = 1:numel(spec_vec)
    idx = ~cellfun('isempty',strfind(fnames_all,spec_vec{ii}));
    fnames = [fnames; fnames_all(idx)];
end

% n_fnames        = numel(fnames);

%Sort the fnames
fnames_alt          = cell(0);
for ii = 1:numel(target_vec)
    idx = ~cellfun('isempty',strfind(fnames,strcat(target_vec{ii},'_')));
    fnames_alt = [fnames_alt; fnames(idx)];
end
fnames          = fnames_alt;           % replace with the sorted
n_fnames        = numel(fnames);
targetvar_mat   = zeros(hor,n_fnames);
targetvarAbs_mat= zeros(hor,n_fnames);
spec_list       = cell(1,n_fnames);


for ii_fnames = 1:n_fnames
    spec_str = fnames{ii_fnames,:};
%     indc=find(ismember(PanelVAR_output.(spec_str).countries,targetc_str));
%     if isempty(indc)
%     else
%         indv=find(ismember(PanelVAR_output.(spec_str).common_vars,targetv_str));
%         if isempty(indv)
%         else
            if leaveitbe
                baseModel = baseSpec_str;
            else
                baseModel = [extractBefore(spec_str,'_'),'_',baseSpec_str];
            end
            spec_list{1,ii_fnames} = spec_str;
            targetvar_mat(:,ii_fnames) = PanelVAR_output.(spec_str).CRPS_mean.avg_tab.(targetall_str)./PanelVAR_output.(baseModel).CRPS_mean.avg_tab.(targetall_str);
            targetvarAbs_mat(:,ii_fnames) = PanelVAR_output.(spec_str).CRPS_mean.avg_tab.(targetall_str);
            
%         end
%     end
end
targetvar_mat   = targetvar_mat(:,~cellfun(@isempty,spec_list));
spec_list       = spec_list(~cellfun(@isempty,spec_list));
targetvar_tab   = array2table(targetvar_mat);
targetvar_tab.Properties.VariableNames = spec_list;
targetvar_tab(end+1:end+1,:)= array2table(mean(targetvar_tab{:,:}));

name_tab = table({'T+1';'T+2';'T+3';'T+4';'T+5';'T+6';'T+7';'T+8';'AVG'},'VariableNames',{targetall_str});
output_tab = [name_tab, targetvar_tab];

targetvarAbs_mat   = targetvarAbs_mat(:,~cellfun(@isempty,spec_list));
targetvarAbs_tab   = array2table(targetvarAbs_mat);
targetvarAbs_tab.Properties.VariableNames = spec_list;
targetvarAbs_tab(end+1:end+1,:)= array2table(mean(targetvarAbs_tab{:,:}));

outputAbs_tab = [name_tab, targetvarAbs_tab];
