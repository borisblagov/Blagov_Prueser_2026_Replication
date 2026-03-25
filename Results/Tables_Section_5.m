clc
clear
close all


plotting = 0;

% uncomment the following line if you have NOT ran the Jarocinski model using the BEAR toolbox
% spec_list = {'N15G3f_spec02','N15G3f_spec01','N15G3f_spec04','N15G3f_spec07','N15G3f_spec08','N15G3f_spec09','N15G3f_spec10','N15G3f_spec03'};

% comment the following line if you have NOT ran the Jarocinski model using the BEAR toolbox
spec_list = {'N15G3f_spec02','N15G3f_spec01','N15G3f_spec04','N15G3f_spec07','N15G3f_spec08','N15G3f_spec09','N15G3f_spec10','N15G3f_spec03','N15G3f_spec18'};


countries_vec       = {'DE','FR','IT','GB','US','CA','AG','BR','MX','CN','JP','AU','AT','IN','CH'};

variables_vec     = {'y', 'Dp','r'};


n_cunt = numel(countries_vec);
n_vars = numel(variables_vec);
n_spec = numel(spec_list);
%% Forecast error figure
rmsfe_all_tab = table();
tplush_all_pvalR_tab = table();
tplush_all_pvalL_tab = table();
tplush_all_pvalLR_tab = table();
minimum_all_tab = table(); % This will hold where the best rmsfes are
    
for in = 1:n_vars
    if plotting == 1
        fcast_err_fig = figure;
        cprs_err_fig = figure;
    end
    rmsfe_in_tab = table(); % this table will contain all rmsfe per variable (all countries)
    tplush_in_pvalR_tab = table(); % this table will contain the DM pvalues per variable (all countries)
    tplush_in_pvalL_tab = table(); % this table will contain the DM pvalues per variable (all countries)
    tplush_in_pvalLR_tab = table(); % this table will contain the DM pvalues per variable (all countries)
    minimum_in_tab = table();
    for ic = 1:n_cunt
        country = countries_vec{ic};
        %     variable = 'RGDP';
        variable = variables_vec{in};

        current_var = strcat(variable,'_',country);
        
        if plotting 
            fcast_err_hnd = subplot(4,ceil(n_cunt/4),ic,'Parent',fcast_err_fig);
            crps_hnd = subplot(4,ceil(n_cunt/4),ic,'Parent',cprs_err_fig);
        end
    
        tplush_ik_pvalR_mat = nan(8,n_spec); % This will hold the pvalues for DM R test 
        tplush_ik_pvalL_mat = nan(8,n_spec); % This will hold the pvalues for DM L test 
        tplush_ik_pvalLR_mat = nan(8,n_spec); % This will hold the pvalues for DM LR test 
        rmsfe_ic_spec_tab_temp = table(); % This will hold just the chunk of 1:ik:n_spec
        for ik=1:n_spec
            load(spec_list{ik})
            if strcmp(spec_list{ik},'N15G3f_spec02')
                base_struct = out_struct;
            end

            allVarNames = out_struct.FE_mean.rmsfe_tab.Properties.VariableNames;
            allRowNames = out_struct.FE_mean.rmsfe_tab.Properties.RowNames;
            current_pos = find(contains(allVarNames,current_var));  % position, needed for the dm test as the msfe are tables
           
            % RMSFE
            rmsfe_var = out_struct.FE_mean.rmsfe_tab.(current_var)./base_struct.FE_mean.rmsfe_tab.(current_var);
            % FIX THIS
%             rmsfe_var = out_struct.CRPS_mat.(current_var)./base_struct.CRPS_mat.(current_var);
            
            rmsfe_ik_tab_temp = array2table(rmsfe_var,'VariableNames',{strcat(allVarNames{current_pos},'_',spec_list{ik})},'RowNames',allRowNames);
            rmsfe_ic_spec_tab_temp = [rmsfe_ic_spec_tab_temp, rmsfe_ik_tab_temp];
            rmsfe_in_tab = [rmsfe_in_tab, rmsfe_ik_tab_temp];
            

            % DM test
            for ih = 1:8
                h = ih;
                [DM_adj,pval_L,pval_LR,pval_R] = test_DM_HLN(base_struct.FE_mean.msfe_hor(1:end+1-h,current_pos,h),out_struct.FE_mean.msfe_hor(1:end+1-h,current_pos,h),h);
                tplush_ik_pvalR_mat(h,ik) = pval_R;
                tplush_ik_pvalL_mat(h,ik) = pval_L;   
                tplush_ik_pvalLR_mat(h,ik) = pval_LR;                 
            end
            
            % if h == 8
            % save the current tplush as a table
            tplush_ik_pvalR_tab_temp = array2table(tplush_ik_pvalR_mat(:,ik),'VariableNames',{strcat(allVarNames{current_pos},'_',spec_list{ik})},'RowNames',allRowNames);
            tplush_in_pvalR_tab = [tplush_in_pvalR_tab tplush_ik_pvalR_tab_temp];
            tplush_ik_pvalL_tab_temp = array2table(tplush_ik_pvalL_mat(:,ik),'VariableNames',{strcat(allVarNames{current_pos},'_',spec_list{ik})},'RowNames',allRowNames);
            tplush_in_pvalL_tab = [tplush_in_pvalL_tab tplush_ik_pvalL_tab_temp];
            tplush_ik_pvalLR_tab_temp = array2table(tplush_ik_pvalLR_mat(:,ik),'VariableNames',{strcat(allVarNames{current_pos},'_',spec_list{ik})},'RowNames',allRowNames);
            tplush_in_pvalLR_tab = [tplush_in_pvalLR_tab tplush_ik_pvalLR_tab_temp];
        
            % end


            % Plots
            if plotting == 1

                plot(fcast_err_hnd,out_struct.FE_mean.rmsfe_tab.(current_var),'LineWidth',2)
                hold(fcast_err_hnd,'on')
                xlabel(fcast_err_hnd,'forecast horizon')
                ylabel(fcast_err_hnd,'forecast error')
                title(fcast_err_hnd,current_var,'Interpreter','none')


                plot(crps_hnd,out_struct.CRPS_mean.avg_tab.(current_var),'LineWidth',2)
                hold(crps_hnd,'on')
                xlabel(crps_hnd,'forecast horizon')
                ylabel(crps_hnd,'CRPS score')
                title(crps_hnd,current_var,'Interpreter','none')
            end


        end     % loop ik over 1:n_spec is over

            % find the minimum in this chunk
            [M, I] = min(rmsfe_ic_spec_tab_temp{:,:},[],2);
            % saving the minimum for each variable/country pair
            minimum_ic_tab = rmsfe_ic_spec_tab_temp;
            minimum_ic_tab{:,:} =  (rmsfe_ic_spec_tab_temp{:,:}==M);
            minimum_in_tab = [minimum_in_tab, minimum_ic_tab];
    end % loop ic over 1:n_cunt
    
    minimum_all_tab = [minimum_all_tab, minimum_in_tab];
    rmsfe_all_tab  = [rmsfe_all_tab, rmsfe_in_tab];
    tplush_all_pvalR_tab = [tplush_all_pvalR_tab, tplush_in_pvalR_tab];
    tplush_all_pvalL_tab = [tplush_all_pvalL_tab, tplush_in_pvalL_tab];
    tplush_all_pvalLR_tab = [tplush_all_pvalLR_tab, tplush_in_pvalLR_tab];
    % legend(spec_list,'Interpreter','none','Location','bestoutside')
end
%%
base_tab = rows2vars(tplush_all_pvalR_tab);
allRows = base_tab.OriginalVariableNames;
underscores = cell2mat(strfind(allRows,'_'));
ntot_size = size(allRows);
for kk = 1:ntot_size(1,1)
    varcell{kk,:} = allRows{kk,:}(1:underscores(kk,1)-1);
    speccell{kk,:} = allRows{kk,:}(underscores(kk,3)+1:end);
    cuntcell{kk,:} = allRows{kk,:}(underscores(kk,1)+1:underscores(kk,2)-1);
    dataspeccell{kk,:} = allRows{kk,:}(underscores(kk,2)+1:underscores(kk,3)-1);
end
help_tab = [cell2table(varcell) cell2table(speccell) cell2table(cuntcell) cell2table(dataspeccell)];
%%

% this one holds pvalR values
tplush_all_tab_pvalR_ctr = rows2vars(tplush_all_pvalR_tab);
% this one has "1" and "0" if pvalR < 0.1
tplush_all_tab_pvalR_true10 = tplush_all_tab_pvalR_ctr;
tplush_all_tab_pvalR_true10{:,2:end} = tplush_all_tab_pvalR_ctr{:,2:end}<0.1;
% this one has "1" and "0" if pvalR < 0.05
tplush_all_tab_pvalR_true05 = tplush_all_tab_pvalR_ctr;
tplush_all_tab_pvalR_true05{:,2:end} = tplush_all_tab_pvalR_ctr{:,2:end}<0.05;


tplush_all_tab_pvalL_ctr = rows2vars(tplush_all_pvalL_tab);
% this one has "1" and "0" if pvalL < 0.1
tplush_all_tab_pvalL_true10 = tplush_all_tab_pvalL_ctr;
tplush_all_tab_pvalL_true10{:,2:end} = tplush_all_tab_pvalL_ctr{:,2:end}<0.1;
% this one has "1" and "0" if pvalL < 0.05
tplush_all_tab_pvalL_true05 = tplush_all_tab_pvalL_ctr;
tplush_all_tab_pvalL_true05{:,2:end} = tplush_all_tab_pvalL_ctr{:,2:end}<0.05;


% this one holds pvalLR values
tplush_all_tab_pvalLR_ctr = rows2vars(tplush_all_pvalLR_tab);
% this one has "1" and "0" if pvalLR < 0.1
tplush_all_tab_pvalLR_true10 = tplush_all_tab_pvalLR_ctr;
tplush_all_tab_pvalLR_true10{:,2:end} = tplush_all_tab_pvalLR_ctr{:,2:end}<0.1;
% this one has "1" and "0" if pvalLR < 0.05
tplush_all_tab_pvalLR_true05 = tplush_all_tab_pvalLR_ctr;
tplush_all_tab_pvalLR_true05{:,2:end} = tplush_all_tab_pvalLR_ctr{:,2:end}<0.05;

rmsfe_all_tab_ctr = rows2vars(rmsfe_all_tab);
minimum_all_tab_ctr = rows2vars(minimum_all_tab);



%%
writetable([rmsfe_all_tab_ctr help_tab],'./Results/Results.xlsx','Sheet','rmsfe');

writetable([tplush_all_tab_pvalR_true10 help_tab],'./Results/Results.xlsx','Sheet','pvalR_true_false10');
writetable([tplush_all_tab_pvalR_true05 help_tab],'./Results/Results.xlsx','Sheet','pvalR_true_false05');
writetable([tplush_all_tab_pvalR_ctr help_tab],'./Results/Results.xlsx','Sheet','pvalR');

writetable([tplush_all_tab_pvalL_true10 help_tab],'./Results/Results.xlsx','Sheet','pvalL_true_false10');
writetable([tplush_all_tab_pvalL_true05 help_tab],'./Results/Results.xlsx','Sheet','pvalL_true_false05');
writetable([tplush_all_tab_pvalL_ctr help_tab],'./Results/Results.xlsx','Sheet','pvalL');

writetable([tplush_all_tab_pvalLR_true10 help_tab],'./Results/Results.xlsx','Sheet','pvalLR_true_false10');
writetable([tplush_all_tab_pvalLR_true05 help_tab],'./Results/Results.xlsx','Sheet','pvalLR_true_false05');
writetable([tplush_all_tab_pvalLR_ctr help_tab],'./Results/Results.xlsx','Sheet','pvalLR');

writetable([minimum_all_tab_ctr help_tab],'./Results/Results.xlsx','Sheet','min_rmsfe');

%% CRPS

%{
for in = 1:n_vars
figure
for ic = 1:n_cunt
    country = countries_vec{ic};
%     variable = 'RGDP';
variable = variables_vec{in};

    subplot(4,ceil(n_cunt/4),ic)
    hold all
    for ik=1:numel(spec_list)
        load(spec_list{ik})
        plot(out_struct.CRPS_mean.avg_tab.(strcat(variable,'_',country)),'LineWidth',2)
    end
    xlabel('forecast horizon')
    ylabel('CRPS score')
    title(strcat(variable,'_',country),'Interpreter','none')
end
    legend(spec_list,'Interpreter','none','Location','bestoutside')
end
%}

%% Log-predictive likelihood

%{
for in = 1:n_vars
figure
for ic = 1:n_cunt
    country = countries_vec{ic};
%     variable = 'RGDP';
variable = variables_vec{in};

    subplot(4,ceil(n_cunt/4),ic)
    hold all
    for ik=1:numel(spec_list)
        load(spec_list{ik})
        plot(out_struct.LP_mean.avg_tab.(strcat(variable,'_',country)),'LineWidth',2)
    end
    xlabel('forecast horizon')
    ylabel('LP score')
    title(strcat(variable,'_',country),'Interpreter','none')
end
    legend(spec_list,'Interpreter','none','Location','bestoutside')
end
%}