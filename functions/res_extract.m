function [table_out targetv_tab_LP,targetv_tab_CRPS,targetv_tab] = res_extract(targetv,targetc,PanelVAR_output,spec_vec,target_vec,rowName_str,baseModel)


targetv_tab2 = spec_extract(PanelVAR_output,targetv,targetc);

targetv_tab = spec_extractVs(PanelVAR_output,targetv,targetc,spec_vec,target_vec,baseModel);
targetv_str = strcat(targetv,'_',targetc);


TT          = NaN(numel(spec_vec),1);
for kk = 1:size(target_vec,2)
    choice_outtab = choice_extract(target_vec{kk},spec_vec,targetv_tab,targetv_str);
    rowToExtract = find(strcmp(rowName_str,choice_outtab.(1))==1);    % finds the desired horizon
    if isempty(rowToExtract)
        disp('The desired horizon cannot be found');
    else
        if isempty(choice_outtab{rowToExtract,2:end})
            disp('The desired variable cannot be found');
            disp(targetv_str);
            TT(:,kk) = NaN(numel(spec_vec),1);
        else
            TT(:,kk) = choice_outtab{rowToExtract,2:end}';
        end
    end
end
table_out = array2table(TT,'RowNames',spec_vec,'VariableNames',target_vec);

%% Extract PL
targetv_tab_LP = spec_extract_LP(PanelVAR_output,targetv,targetc,spec_vec,target_vec,baseModel);
TT          = NaN(numel(spec_vec),1);
for kk = 1:size(target_vec,2)
    choice_outtab = choice_extract(target_vec{kk},spec_vec,targetv_tab_LP,targetv_str);
    rowToExtract = find(strcmp(rowName_str,choice_outtab.(1))==1);    % finds the desired horizon
    if isempty(rowToExtract)
        disp('The desired horizon cannot be found');
    else
        if isempty(choice_outtab{rowToExtract,2:end})
            disp('The desired variable cannot be found');
            disp(targetv_str);
            TT(:,kk) = NaN(numel(spec_vec),1);
        else
            TT(:,kk) = choice_outtab{rowToExtract,2:end}';
        end
    end
end
tablePL_out = array2table(TT,'RowNames',spec_vec,'VariableNames',target_vec);

%% Extract CRPS
[targetv_tab_CRPS, targetvAbs_tab_CRPS] = spec_extract_CRPS(PanelVAR_output,targetv,targetc,spec_vec,target_vec,baseModel);
TT          = NaN(numel(spec_vec),1);
for kk = 1:size(target_vec,2)
    choice_outtab = choice_extract(target_vec{kk},spec_vec,targetv_tab_CRPS,targetv_str);
    rowToExtract = find(strcmp(rowName_str,choice_outtab.(1))==1);    % finds the desired horizon
    if isempty(rowToExtract)
        disp('The desired horizon cannot be found');
    else
        if isempty(choice_outtab{rowToExtract,2:end})
            disp('The desired variable cannot be found');
            disp(targetv_str);
            TT(:,kk) = NaN(numel(spec_vec),1);
        else
            TT(:,kk) = choice_outtab{rowToExtract,2:end}';
        end
    end
end
tableCRPS_out = array2table(TT,'RowNames',spec_vec,'VariableNames',target_vec);



end