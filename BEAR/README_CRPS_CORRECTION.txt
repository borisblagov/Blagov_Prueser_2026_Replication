in panelfeval.m, the calcluation of crps score is wrong as it does not use the actual data. This has been fixed in my files
Orignal line 114
%    score=crps(forecast_record{ii,1}(:,jj),forecast_estimates{ii,1}(2,jj));
New line 
   score=crps(forecast_record{ii,1}(:,jj),data_endo_c(jj,ii));