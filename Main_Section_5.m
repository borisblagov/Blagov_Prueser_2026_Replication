%% ----------------------------------------------------------------------------------------- %%
% Panel VAR with flexible homogeneity restrictions
% ------------------------------------------------------------------------------------------ %%
% Written by Jan Prueser and Boris Blagov
% This version: 23.03.2026
%
% ------------------------------------------------------------------------------------------ %%
%% HOUSEKEEPING
clear
clc

addpath('functions');
addpath('data');

tic
%% SETUP

spec_tab    = readtable('PanelVAR_output.xlsx','Sheet','setup','ReadRowNames',true);
setup_spec_vec= [1 2 3 4 7 8 9 10]; % [1 2 4 5];   % A vector of setup specifications to estimate, lines from the file PanelVAR_output.xlsx,
    % 1. pVAR_main:  combines zero shrinkage with pooling over countries, our contribution
    % 2. BVAR_Minn:  classical BVAR with only zero shrinkage ((baseline)
    % 3. pVAR_pooling: does not do zero shrinkage, resembles a more classical panel VAR
    % 4. BVAR_Chan:  zero shrinkage with global local prior as in Chan 2021
    % 7. KK_BFCS:   Koop and Koroboilis panel var specifications (only work with 1 lag)
    % 8. KK_SSSS:   Koop and Koroboilis panel var specifications (only work with 1 lag)
    % 9. KK_BMS:    Koop and Koroboilis panel var specifications (only work with 1 lag)
    % 10. KK_CC:     Koop and Koroboilis panel var specifications (only work with 1 lag)
    % 18. Jarocinski: DOES NOT WORK IN THIS CODE, estimated using the BEAR Toolbox (see readme for details)



data_spec_vec   =[36];    % A vector of data specifications to estimate, e.g. [7], [7:9] or [2, 5, 7]
                          % add your cases below
                          
%------------Pesaran Data from 1979Q3 ti 2019Q4
% 36: 12 countries, 3 variables, y, pi, r


xlss            = 0;        % Whether to save the output
n_pseudo        = 80;       % Set to 0 or to 40. Whether to do recursive fcasts
nps_last        = 1;        % Set to 1 to skip the last estimation or to 0 to estimate with full dataset one last time. Not useful for recursive oos estimation.


%% ESTIMATION

%% -- Model loop -- %
% This is the outer loop wher we loop over specification paramters such as lags, priors, etc.
for mm = 1:size(setup_spec_vec,2)
    clear Input fdata_mat
    %% -- Data loop -- %
    % This is the outer loop wher we loop over the data
    for kk = 1:size(data_spec_vec,2)
        data_spec = data_spec_vec(kk);
        % Cases for the data
        % code to plot specific variable
        switch data_spec
            case 1
                % example case for your own data
                data_spec_str   = 'N10G3';
                countries       = {'DE','FR','IT','ES','NL','BE','AT','PT','FI','GR'};
                common_vars     = {'RGDP', 'HICP','EURIBOR'};   
                n_pseudo        = 40;                      
            case 36
                % data for replication
                data_spec_str   = 'N15G3f';
                countries       =  {'DE','FR','IT','GB','US','CA','AG','BR','MX','CN','JP','AU','AT','IN','CH'};
                common_vars     = {'y', 'Dp','r'};  
        end  % End cases for the data settings
        
        
        
        G         = size(common_vars,2);  % G variabes for each country
        N         = size(countries,2);    % N countries
        Input.G         = G;  Input.N         = N;
        Input.common_vars = common_vars;
        Input.countries = countries;
        var_list        = cell(1,N*G);
        
        
        
        clear fdata_mat
        for ip = 1:N
            if data_spec >= 30 && data_spec< 40
                load GVAR_balanced
                fdata_mat(:, G*(ip-1)+1:G*ip) = GVAR_balanced.(countries{ip}){:,common_vars};
            elseif data_spec < 30
                % add your own data here
                load ownData
                fdata_mat(:, G*(ip-1)+1:G*ip) = ownData.(countries{ip}){:,common_vars};
            end
            for iq = 1:G
                var_list{1,(ip-1)*(G) + iq}                = strcat(common_vars{1,iq},'_',countries{1,ip});
            end
        end
        
        Input.data_spec_str = data_spec_str;
        
        % Cases for the specification
        setup_spec_no = setup_spec_vec(mm);     % translate the number in setup_spec to the row in PanelVAR_output.xlsx (e.g. so that spec09 does not have to be on row 9)
        setup_spec  = find(spec_tab.no==setup_spec_no);
        spec_auto
        
        T_full          = size(fdata_mat,1);
        T_short         = T_full - n_pseudo;

        % Misc settings
        Input.dispsim           = 0100;         % How often to display results. 0 supresses output. Low values (e.g. 1) impact performance. Set to 0 for pseudo oos.
        Input.dispinfo          = 0;            % 1 or 0. Whether to show a summary of the settings. Set to 0 for pseudo oos.

        
        %% -------------------------------------- Inner loop -------------------------------------- %
        % This is the inner loop for pseudo out-of-sample forecasting. Here we take a subset of the data T_s<T_full
        % and extend the data by one time period each iteration. For each run, the specification must be identical
        for ij = 0:n_pseudo-nps_last                             %n_pseudo is defined in spec0x
            Input.Yins = fdata_mat(1:T_short+ij,:);
            
            if Input.twostep == 0
                Output      = VARpanel(Input);
            elseif Input.twostep == 1
                Output      = VARpanel_twostep(Input);
            elseif Input.twostep > 1 && Input.twostep <6
                
                if Input.P~=1
                    %benchmark model FIX p=1 because KK code only runs for p=1
                    % does not work when the same variables across countries are used
                    warning('number of lags set too high, resetting to 1');
                    Input.P = 1;
                end
                
                pri_nburn= Input.BURNIN;    %default 1000
                pri_nsave= Input.MCMC;
                pri_ntot = pri_nsave+pri_nburn;      % default 6000
                pri_iter = 100000;
                
                if Input.twostep == 2
                    [alpha_draws] = MCMC_PVAR_BFCS(Input.Yins-mean(Input.Yins),Input.N,Input.G,Input.P,pri_nsave,pri_nburn,pri_ntot,pri_iter);
                elseif Input.twostep == 3
                    [alpha_draws] = MCMC_PVAR_SSSS(Input.Yins-mean(Input.Yins),Input.N,Input.G,Input.P,pri_nsave,pri_nburn,pri_ntot,pri_iter);
                elseif Input.twostep == 4
                    [alpha_draws]  =MCMC_PVAR_BMS(Input.Yins-mean(Input.Yins),Input.N,Input.G,Input.P,pri_nsave,pri_nburn,pri_ntot,pri_iter);
                elseif Input.twostep == 5
                    [alpha_draws]  =MCMC_PVAR_CC(Input.Yins-mean(Input.Yins),Input.N,Input.G,Input.P,pri_nsave,pri_nburn,pri_ntot,pri_iter);
                end
                [alpha_OLS,sigma_OLS] = OLS_PVAR(Input.Yins-mean(Input.Yins),Input.N,Input.G,1);
                [Output] = PVARpred2(Input.Yins-mean(Input.Yins),alpha_draws,sigma_OLS,Input.N,Input.G,Input.P,Input.hor,pri_nsave,mean(Input.Yins));
                
                
            end
            
            
            if n_pseudo > 0 && ij == 0
                %                  pseudo out-of-sample forecast data (hor x N x n_pseudo)
                fcast_mean_mat      = zeros(Input.hor,Input.N*Input.G,n_pseudo);
                fcast_med_mat       = zeros(Input.hor,Input.N*Input.G,n_pseudo);
                Logpredictivelike_cum= NaN(Input.hor,N*G,n_pseudo);%evtl leichter Input.hor zu nehmen als Hor? f�rs speichern und average nehmen?
                CRPS_mat    = NaN(Input.hor,N*G,n_pseudo);
                Logpredictivelike    = NaN(Input.hor,N*G,n_pseudo);
                fprintf('VARpanel function called with the following settings:\n');
                disp(Input);
                fprintf('\n');
                fprintf('Pseudo out-of-sample forecasting\n');
            end     % if we do an esleif here fcast_mean_mat(:,:,1) is zeroes
            if n_pseudo>0 && ij~=n_pseudo
                fcast_mean_mat(:,:,ij+1)    = Output.yfor_mean;
                fcast_med_mat(:,:,ij+1)     = Output.yfor_median;
                Hor                         = min(size(fdata_mat,1)-(T_short+ij),Input.hor);
                Yout                        = fdata_mat(T_short+ij+1:T_short+ij+Hor,:);
                
                
                
                for gn=1:G*N
                    for hh=1:Hor
                        Logpredictivelike(hh,gn,ij+1)= log(  ksdensity(reshape(Output.yfor_draws(hh,gn,:),...
                            Input.MCMC,1),Yout(hh,gn))  +1e-15);
                        Logpredictivelike_cum(hh,gn,ij+1)=ksdensity(reshape(Output.yfor_draws(hh,gn,:),Input.MCMC,1),Yout(hh,gn),'Function','cdf');
                        idx = randperm(Input.MCMC);%(hh,gn,ij+1)
                        CRPS_mat(hh,gn,ij+1)=mean(abs(reshape(Output.yfor_draws(hh,gn,:),Input.MCMC,1)-Yout(hh,gn)))...
                            -0.5*mean(abs(reshape(Output.yfor_draws(hh,gn,:),Input.MCMC,1)-reshape(Output.yfor_draws(hh,gn,idx),Input.MCMC,1)));
                    end
                end
                
                fprintf('%2.0f/%2.0f in %f mins.\n',ij+1,n_pseudo,(toc/60));
             end
        end     % end pseudo ouf-of-sample loop
        %  -------------------------------------- Inner loop -------------------------------------- %
        %%
        if n_pseudo ~=0
            oosdata_mat = fdata_mat(T_short+1:end,:);        % Out-of-sample data set (n_pseudo x N)
            FE_mean     = fcast_eval(oosdata_mat,fcast_mean_mat,var_list);
            FE_med      = fcast_eval(oosdata_mat,fcast_med_mat,var_list);
            LP_mean     = fcast_eval(oosdata_mat,Logpredictivelike,var_list);
            CRPS_mean   = fcast_eval(oosdata_mat,CRPS_mat,var_list);
            
            out_struct = Input;
            out_struct.name = spec_tab.name{setup_spec};
            %             out_struct.spec = setup_spec_str;
            %             out_struct.dataspec = data_spec_str;
            out_struct.oosdata_mat = oosdata_mat;
            out_struct.Logpredictivelike = Logpredictivelike;
            out_struct.Logpredictivelike_cum = Logpredictivelike_cum;
            out_struct.fcast_mean_mat = fcast_mean_mat;
            out_struct.fcast_med_mat = fcast_med_mat;
            out_struct.CRPS_mat = CRPS_mat;
            out_struct.FE_mean = FE_mean;
            out_struct.FE_med = FE_med;
            out_struct.LP_mean = LP_mean;
            out_struct.CRPS_mean = CRPS_mean;
            save(strcat('Results/',data_spec_str,'_',setup_spec_str,'.mat'),'out_struct')
        end
     
        
    end         % end loop over the data
    
end         % end loop over the models

