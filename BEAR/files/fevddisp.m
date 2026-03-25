function []=fevddisp(n,endo,IRFperiods,fevd_estimates,pref,IRFt,signreslabels)



% function []=fevddisp(n,endo,IRFperiods,fevd_estimates,datapath)
% plots the results for the forecast error variance decomposition
% inputs:  - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - cell 'endo': list of endogenous variables of the model
%          - integer 'IRFperiods': number of periods for IRFs
%          - cell 'fevd_estimates': lower bound, point estimates, and upper bound for the FEVD
%          - string 'datapath': user-supplied path to excel data spreadsheet
% outputs: none

% fevd_estimates records variable 1 in row 1, variable 2 in row 2 etc
% records shock 1 in column 1, shock 2 in column 2 etc
% as in the Excel output



contributions = NaN(n,n,IRFperiods);    % reports the median variance contribution of shock col1 to variable row1 

for rrr = 1:n       % loops over rows i.e. variables
    for ccc = 1:n   % loops over columns i.e. shocks
        contributions(rrr,ccc,:) = fevd_estimates{rrr,ccc}(2,:);     % 2 picks the median
    end
  if verLessThan('matlab','9.1') == 0    
    aux = sum(contributions(rrr,:,:));
    contributions(rrr,:,:) = contributions(rrr,:,:)./aux*100;
  else
    msgbox('Error: FEVD requires Matlab version 2016b or higher');
  end
end


if pref.plot

    
ncolumns=ceil(n^0.5);
nrows=ceil(n/ncolumns);
FEVD=figure;
set(FEVD,'Color',[0.9 0.9 0.9]);
set(FEVD,'name','Forecast error variance decomposition')
for rrr=1:n % loop over rows, i.e. variables
subplot(nrows,ncolumns,rrr)
bar(1:IRFperiods,squeeze(contributions(rrr,:,:))', 0.8, 'stacked');
axis tight
title(endo{rrr,1},'FontWeight','normal');
if rrr==1
legend(signreslabels{1:n},'Location','Northwest');
legend('boxoff')
end
end

end % pref.plot
% finally, record results in excel
excelrecord6
