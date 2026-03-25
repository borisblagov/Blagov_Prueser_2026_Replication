function [irf_estimates_allt]=irfestimates2(irf_record_allt,n,T,IRFperiods,IRFband,endo,stringdates1,pref)



% create first the cell that will contain the IRF estimates
irf_estimates_allt=cell(n,n);

% for the response of each variable to each shock, and each IRF period, compute the median, lower and upper bound from the Gibbs sampler records
% consider variables in turn
for ii=1:n
   % consider shocks in turn
   for jj=1:n
      % consider IRF periods in turn
      for kk=1:IRFperiods
          % consider sample periods in turn
          for tt=1:T
          % compute first the lower bound
          irf_estimates_allt{ii,jj}(1,kk,tt)=quantile(irf_record_allt{ii,jj}(:,kk,tt),(1-IRFband)/2);
          % then compute the median
          irf_estimates_allt{ii,jj}(2,kk,tt)=quantile(irf_record_allt{ii,jj}(:,kk,tt),0.5);
          % finally compute the upper bound
          irf_estimates_allt{ii,jj}(3,kk,tt)=quantile(irf_record_allt{ii,jj}(:,kk,tt),1-(1-IRFband)/2);
          end
      end
   end
end



% save on Excel

% compute the cell for the time varying VAR coefficients
% initiate the cell that will be saved on excel
IRFcell={};
% then loop over endogenous
for ii=1:n
   varcell={};
   % loop over shocks
   for jj=1:n
   % create temporary cell
   temp={};
   temp=[{''} {''} {'Periods'} stringdates1' {''} {''} {''};repmat({''},IRFperiods+4,T+6)];
   temp{3,1}='response of:';
   temp{3,2}=endo{ii,1};
   temp{4,1}='to shocks in:';
   temp{4,2}=endo{jj,1};
      % loop over IRF periods
      for kk=1:IRFperiods
      temp{2+kk,3}=kk;
         % loop over sample periods
         for tt=1:T
         temp{2+kk,3+tt}=irf_estimates_allt{ii,jj}(2,kk,tt);
         end
      end
   varcell=[varcell temp];
   end
IRFcell=[IRFcell;varcell];
end

% write in excel
if pref.results==1
    xlswrite([pref.datapath '\results\' pref.results_sub '.xlsx'],IRFcell,'IRF time variation','B2');
end

