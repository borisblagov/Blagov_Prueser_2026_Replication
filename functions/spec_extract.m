function output_tab = spec_extract(PanelVAR_output,targetv_str,targetc_str)

hor = 8;
targetall_str   = strcat(targetv_str,'_',targetc_str);
fnames          = fieldnames(PanelVAR_output);
% fnames(1,:)     = [];    % delete the simulated data
% fnames(2,:)     = [];    % delete the special case N=2, G=2
% fnames(14,:)    = [];    % delete the simulated data
n_fnames        = size(fnames,1);
targetvar_mat   = zeros(hor,n_fnames);
spec_list       = cell(1,n_fnames);

for ii_fnames = 1:n_fnames
    spec_str = fnames{ii_fnames,:};
    indc=find(ismember(PanelVAR_output.(spec_str).countries,targetc_str));
    if isempty(indc)
    else
        indv=find(ismember(PanelVAR_output.(spec_str).common_vars,targetv_str));
        if isempty(indv)
        else
        spec_list{1,ii_fnames} = spec_str;
        targetvar_mat(:,ii_fnames) = PanelVAR_output.(spec_str).FE_mean.rmsfe_tab.(targetall_str)./PanelVAR_output.('AR_forecast').FE_mean.rmsfe_tab.(targetall_str);
        end
    end
end
targetvar_mat   = targetvar_mat(:,~cellfun(@isempty,spec_list));
spec_list       = spec_list(~cellfun(@isempty,spec_list));
targetvar_tab   = array2table(targetvar_mat);
targetvar_tab.Properties.VariableNames = spec_list;
targetvar_tab(end+1:end+1,:)= array2table(mean(targetvar_tab{:,:}));

name_tab = table({'T+1';'T+2';'T+3';'T+4';'T+5';'T+6';'T+7';'T+8';'AVG'},'VariableNames',{targetall_str});
output_tab = [name_tab, targetvar_tab];