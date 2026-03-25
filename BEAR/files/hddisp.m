function []=hddisp(n,endo,Y,decimaldates1,hd_estimates,stringdates1,T,pref,IRFt,signreslabels)



% function []=hddisp(n,endo,decimaldates1,hd_estimates,stringdates1,T,datapath)
% plots the results for the historical decomposition
% inputs:  - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - cell 'endo': list of endogenous variables of the model
%          - vector 'decimaldates1': dates converted into decimal values, for the sample period
%          - cell 'hd_estimates': lower bound, point estimates, and upper bound for the historical decomposition
%          - cell 'stringdates1': date strings for the sample period
%          - integer 'T': number of sample time periods (defined p 7 of technical guide)
%          - string 'datapath': user-supplied path to excel data spreadsheet
% outputs: none



% transpose the cell of records (required for the plot function in order to obtain correctly ordered plots)
hd_estimates=hd_estimates';


% create figure for historical decomposition
%hd=figure;
%set(hd,'Color',[0.9 0.9 0.9]);
%set(hd,'name','historical decomposition');
%for ii=1:n*(n+1)
%subplot(n,n+1,ii);
%hold on
%Xpatch=[decimaldates1' fliplr(decimaldates1')];
%Ypatch=[hd_estimates{ii}(1,:) fliplr(hd_estimates{ii}(3,:))];
%HDpatch=patch(Xpatch,Ypatch,[0.7 0.78 1]);
%set(HDpatch,'facealpha',0.6);
%set(HDpatch,'edgecolor','none');
%plot(decimaldates1,hd_estimates{ii}(2,:)','Color',[0.4 0.4 1],'LineWidth',2);
%plot([decimaldates1(1,1),decimaldates1(end,1)],[0 0],'k--');
%hold off
%set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'FontName','Times New Roman');
% top labels
%   if ii<=n
      % if a sign restriction identification scheme has been used, use the structural shock labels
%      if IRFt==4
%      title(signreslabels{ii,1},'FontWeight','normal');  
      % otherwise, the shocks are just orthogonalised shocks from the variables: use variable names
%      else
%      title(endo{ii,1},'FontWeight','normal');
%      end
%   end
%   if ii==n+1
%   title('Exogenous','FontWeight','normal');
%   end
% side labels
%   if rem((ii-1)/(n+1),1)==0
%   ylabel(endo{(ii-1)/(n+1)+1,1},'FontWeight','normal');
%   end
%end
% top supertitle
%ax=axes('Units','Normal','Position',[.11 .075 .85 .88],'Visible','off');
%set(get(ax,'Title'),'Visible','on')
%title('Contribution of shock:','FontSize',11,'FontName','Times New Roman','FontWeight','normal');
% side supertitle
%ylabel('Fluctuation of:','FontSize',12,'FontName','Times New Roman','FontWeight','normal');
%set(get(ax,'Ylabel'),'Visible','on')


% create vectors for contributions and sum of contributions
%contributions=zeros(length(decimaldates1),n^2);
%contribpos=zeros(length(decimaldates1),n^2);
%contribneg=zeros(length(decimaldates1),n^2);

% loop over all shocks for all endogenous variables
%for ii=1:n^2
% positive and negative distributions are calculated seperately for
% graphical Matlab uissues
%contributions(:,ii)=[hd_estimates{ii}(2,:)'];
%contribpos(:,ii)=contributions(:,ii);
%contribpos(contribpos<0)=0;
%contribneg(:,ii)=contributions(:,ii);
%contribneg(contribneg>0)=0;
%end


% loop over all shocks for all endogenous variables
for ii=1:n*(n+1)
% positive and negative distributions are calculated seperately for
% graphical Matlab issues
contributions(:,ii)=[hd_estimates{ii}(2,:)'];
contribpos(:,ii)=contributions(:,ii);
contribpos(contribpos<0)=0;
contribneg(:,ii)=contributions(:,ii);
contribneg(contribneg>0)=0;
end

%ordering=cumsum(ones(n^2,1))';
%ordering=reshape(ordering,[n,n])';
%ordering=ordering(:)';
%contributions=contributions(:,ordering);

% calculate the sum of all contributions to proxy the actual development of
% the endogenous variable

Total = zeros(length(decimaldates1),n);
for i=1:n
    Total(:,i) = sum(contributions(:,(n+1)*(i-1)+1:(n+1)*i-1)');
end

%estimatesmodel=zeros(length(decimaldates1),n);
%deviationactual=zeros(length(decimaldates1),n);
%divided=zeros(length(decimaldates1),n);
%actualdeviationss=zeros(length(decimaldates1),n);
%for ii=1:n
%estimatesmodel(:,ii)=Total(:,ii)+hd_estimates{n^2+ii}(2,:)';
%deviationactual(:,ii)=Y(:,ii)-estimatesmodel(:,ii);
%divided(:,ii)=deviationactual(:,ii)./Total(:,ii);
%newcontributions(:,n*ii-(n-1):n*ii)=contributions(:,n*ii-(n-1):n*ii).*(ones+repmat(divided(:,ii),1,n));
%actualdeviationss(:,ii)=Y(:,ii)-hd_estimates{n^2+ii}(2,:)';
%end

%newcontribpos=zeros(length(decimaldates1),n);
%newcontribneg=zeros(length(decimaldates1),n);

%for ii=1:n^2
%newcontribpos(:,ii)=newcontributions(:,ii);
%newcontribpos(newcontribpos<0)=0;
%newcontribneg(:,ii)=newcontributions(:,ii);
%newcontribneg(newcontribneg>0)=0;
%end


if pref.plot
ncolumns=ceil(n^0.5);
nrows=ceil(n/ncolumns);
hd1=figure;
for i=1:n;
set(hd1,'name','Historical decomposition');
subplot(nrows,ncolumns,i)
hdpos=bar(decimaldates1, contribpos(:,n*(i-1)+i:(n+1)*i-1), 0.8, 'stacked');
hold on
hdneg=bar(decimaldates1, contribneg(:,n*(i-1)+i:(n+1)*i-1), 0.8, 'stacked');
hold on
plot(decimaldates1,Total(:,i),'k','LineWidth',2.8);
axis tight
hold off
% label the endogenous variables
title(endo{i,1})
set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'FontName','Times New Roman');
box off
end
if IRFt==4
   legend(signreslabels,'Location','Northoutside','Orientation','Vertical')
else
   legend(endo);
end
legend boxoff
end % pref.plot




%if pref.plot
%% plot individual figures for each endogenous variable with all structural shock contributions
%ncolumns=ceil(n^0.5);
%nrows=ceil(n/ncolumns);
%hd=figure;
%set(hd,'Color',[0.9 0.9 0.9]);
%set(hd,'name','Historical decomposition')
%for i=1:n;
%subplot(nrows,ncolumns,i)
%bar(decimaldates1, newcontribpos(:,n*i-(n-1):n*i), 0.8, 'stacked');
%hold on
%bar(decimaldates1, newcontribneg(:,n*i-(n-1):n*i), 0.8, 'stacked');
%hold on
%plot(decimaldates1,actualdeviationss(:,i),'k','LineWidth',2.8);
%axis tight
%hold off
% label the endogenous variables
%title(endo{i,1})
%end
%if IRFt==4
%   legend(signreslabels,'Location','Northoutside','Orientation','Vertical')
%else
%   legend(endo);
%end
%box off
%legend boxoff
%set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'FontName','Times New Roman');

%end % pref.plot

% finally, record results in excel
% retranspose the cell of records
hd_estimates=hd_estimates';
excelrecord7