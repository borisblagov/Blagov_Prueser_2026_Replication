function [Feval_unit]=panel_feval_boris(n,N,m,p,k,T,Ymat,Xmat,Units,endo,exo,const,beta_gibbs,sigma_gibbs,forecast_record,forecast_estimates,Fcperiods,stringdates3,Fstartdate,Fcenddate,Feval,Fcomp,data_endo_c,data_endo_c_lags,data_exo_c,It,Bu,IRF,IRFt,pref,names)


% finally, estimate and print the unit-specific elements: for this model, only forecast evaluation remains to be printed
% first note that forecast evaluation can only be conducted if it is activated, and if there is some observable data after the beginning of the forecast
if Feval==1 && Fcomp==1

   % loop over units
   for ii=1:N
       % compute forecast evaluation
       [RMSE MAE MAPE Ustat CRPS_estimates S1_estimates S2_estimates]=panelfeval(n,p,k,beta_gibbs,sigma_gibbs,forecast_record(:,:,ii),forecast_estimates(:,:,ii),Fcperiods,data_endo_c(:,:,ii),data_endo_c_lags(:,:,ii),data_exo_c,const,It,Bu);
       % then display and save the results
       Feval_unit.(Units{ii,1}).Forecasteval.RMSE = RMSE;
       Feval_unit.(Units{ii,1}).Forecasteval.MAE = MAE;
       Feval_unit.(Units{ii,1}).Forecasteval.MAPE = MAPE;
       Feval_unit.(Units{ii,1}).Forecasteval.Ustat = Ustat;
       Feval_unit.(Units{ii,1}).Forecasteval.CRPS_estimates = CRPS_estimates;
       Feval_unit.(Units{ii,1}).Forecasteval.S1_estimates = S1_estimates;
       Feval_unit.(Units{ii,1}).Forecasteval.S2_estimates = S2_estimates;
   end


end




