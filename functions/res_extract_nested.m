function [table_out targetv_tab_LP,targetv_tab_CRPS,targetv_tab] = res_extract_nested(targetv,targetc,PanelVAR_output,spec_vec,target_vec,rowName_str)


% targetv_tab2 = spec_extract(PanelVAR_output,targetv,targetc);

targetv_tab = spec_extractVs(PanelVAR_output,targetv,targetc,spec_vec,target_vec,'spec60');
targetv_str = strcat(targetv,'_',targetc);

TT          = row_extract(targetv_tab);
table_out = array2table(TT,'RowNames',spec_vec,'VariableNames',target_vec);

%% Extract PL
targetv_tab_LP = spec_extract_LP(PanelVAR_output,targetv,targetc,spec_vec,target_vec,'spec60');

TT          = row_extract(targetv_tab_LP);
tablePL_out = array2table(TT,'RowNames',spec_vec,'VariableNames',target_vec);

%% Extract CRPS
[targetv_tab_CRPS, targetvAbs_tab_CRPS] = spec_extract_CRPS(PanelVAR_output,targetv,targetc,spec_vec,target_vec,'spec60');

TT = row_extract(targetv_tab_CRPS);
tableCRPS_out = array2table(TT,'RowNames',spec_vec,'VariableNames',target_vec);
TT = row_extract(targetvAbs_tab_CRPS);
tableCRPS_Abs_out = array2table(TT,'RowNames',spec_vec,'VariableNames',target_vec);

%% Function to extract the table
    function TT = row_extract(tab_in)
    % Extracts the row defined in "rowName_str"
        TT          = NaN(numel(spec_vec),1);
        for kk = 1:size(target_vec,2)
            choice_outtab = choice_extract(target_vec{kk},spec_vec,tab_in,targetv_str);
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
    end


end