%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 3. See Section 7. for Additional User Input required for Density Forecast Evaluation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

RMSE_rolling=[];
Input.hor = Fperiods;
Input.N  = N;
Input.G   = n;

numt = 80;  % constrain the sample until 2019q4 due to covid
n_pseudo = numt;
ntot = Input.N*Input.G;
start_corr = 0;
Fstartdate_rolling{80}='2019q4'

addpath('../functions')


for ii=1:numt
    
    Fstartdate=char(Fstartdate_rolling(ii,:));
    
    output = char(strcat([pref.datapath '\results\' pref.results_sub Fstartdate '.mat']));
    
    % load forecasts
    load(output,'forecast_estimates','forecast_record','names','frequency', 'Feval_unit')
    
    %     Feval_unit.US.Forecasteval.CRPS_estimates;
    
    % Dimensions:
    % - forecast_estimates (cell):   (nvars x nhor x ncountries)
    % - forecast estiamtes interior: (3 x fhor)  where the first dim is lower_median_upper interval
    % - forecast estimates example:  forecast_estimates{2,1,3} is the low, med, high, forecast for variable 2
    % of country 3
    % - forecast_record:             the same as forecast_estimates but the interior has the nsave dimension instead of 3
    % - forecast_record example:     forecast_record{2,1,3} is all nsave draws from variable 2 of country 3

    
    if ii == 1
        %                  pseudo out-of-sample forecast data (hor x N x n_pseudo)
        fcast_mean_mat      = NaN(Input.hor,Input.N*Input.G,n_pseudo);
        fcast_med_mat       = NaN(Input.hor,Input.N*Input.G,n_pseudo);
        Logpredictivelike_cum= NaN(Input.hor,Input.N*Input.G,n_pseudo);%evtl leichter Input.hor zu nehmen als Hor? f�rs speichern und average nehmen?
        CRPS_mat    = NaN(Input.hor,Input.N*Input.G,n_pseudo);
        Logpredictivelike    = NaN(Input.hor,Input.N*Input.G,n_pseudo);
        fprintf('VARpanel function called with the following settings:\n');
        disp(Input);
        fprintf('\n');
        fprintf('Pseudo out-of-sample forecasting\n');
    end
    
    frec_onecell = reshape(forecast_record,ntot,1,1);
    for ik = 1:ntot
        fcast_mean_mat(:,ik,ii) =mean(frec_onecell{ik,1})';
        fcast_med_mat(:,ik,ii) =median(frec_onecell{ik,1})';
    end
    
    for il = 1:N
        if il == 1
            crps_temp =  Feval_unit.(Units{il}).Forecasteval.CRPS_estimates;
        else
            crps_temp = [crps_temp, Feval_unit.(Units{il}).Forecasteval.CRPS_estimates];
        end
    end
    CRPS_mat(:,:,ii) = crps_temp;
 
    
end %loop ind_feval

spec_tab    = readtable('..\PanelVAR_output.xlsx','Sheet','setup','ReadRowNames',true);

data_spec_str   = 'N15G3f';
Input.data_spec_str = data_spec_str;

%% Cases for the specification
setup_spec_no = 18;     % translate the number in setup_spec to the row in PanelVAR_output.xlsx (e.g. so that spec09 does not have to be on row 9)
setup_spec  = find(spec_tab.no==setup_spec_no);
spec_auto

for iu = 1:N
    if iu == 1
    var_list = strcat(endo,'_',Units{iu});
    else
    var_list = [var_list; strcat(endo,'_',Units{iu})];
    end
end
fdata_mat = reshape(data_endo_full,162,Input.N*Input.G);
T_short = window_size;
oosdata_mat = fdata_mat(T_short+1+1:end,:);        % Out-of-sample data set (n_pseudo x N)
FE_mean     = fcast_eval(oosdata_mat(1:n_pseudo,:),fcast_mean_mat,var_list);
FE_med      = fcast_eval(oosdata_mat(1:n_pseudo,:),fcast_med_mat,var_list);
LP_mean     = fcast_eval(oosdata_mat(1:n_pseudo,:),Logpredictivelike,var_list);
CRPS_mean   = fcast_eval(oosdata_mat(1:n_pseudo,:),CRPS_mat,var_list);

out_struct.name = spec_tab.name{setup_spec};
out_struct.oosdata_mat = oosdata_mat(1:n_pseudo,:);
out_struct.fcast_mean_mat = fcast_mean_mat;
out_struct.fcast_med_mat = fcast_med_mat;
out_struct.CRPS_mat = CRPS_mat;
out_struct.FE_mean = FE_mean;
out_struct.FE_med = FE_med;
out_struct.LP_mean = LP_mean;
out_struct.CRPS_mean = CRPS_mean;

save(strcat('../Results/',data_spec_str,'_',setup_spec_str,'.mat'),'out_struct')
