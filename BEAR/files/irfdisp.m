function []=irfdisp(n,endo,IRFperiods,IRFt,irf_estimates,D_estimates,gamma_estimates,pref,signreslabels)



% function []=irfdisp(n,endo,IRFperiods,IRFt,irf_estimates,D_estimates,gamma_estimates,datapath)
% plots the results for the impulse response functions
% inputs:  - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - cell 'endo': list of endogenous variables of the model
%          - integer 'IRFperiods': number of periods for IRFs
%          - integer 'IRFt': determines which type of structural decomposition to apply (none, Choleski, triangular factorization)
%          - cell 'irf_estimates': lower bound, point estimates, and upper bound for the IRFs 
%          - vector 'D_estimates': point estimate (median) of the structural matrix D, in vectorised form
%          - vector 'gamma_estimates': point estimate (median) of the structural disturbance variance-covariance matrix gamma, in vectorised form
%          - string 'datapath': user-supplied path to excel data spreadsheet
% outputs: none



% transpose the cell of records (required for the plot function in order to obtain correctly ordered plots)
irf_estimates=irf_estimates';

if pref.plot
% create figure for IRFs
irf=figure;
set(irf,'Color',[0.9 0.9 0.9]);
   if IRFt==1
   set(irf,'name','impulse response functions (no structural identifcation)');
   elseif IRFt==2
   set(irf,'name','impulse response functions (structural identification by Choleski ordering)');
   elseif IRFt==3
   set(irf,'name','impulse response functions (structural identification by triangular factorisation)');
   elseif IRFt==4
   set(irf,'name','impulse response functions (structural identification by sign restrictions)');
   end
for ii=1:n^2
subplot(n,n,ii);
hold on
Xpatch=[(1:IRFperiods) (IRFperiods:-1:1)];
Ypatch=[irf_estimates{ii}(1,:) fliplr(irf_estimates{ii}(3,:))];
IRFpatch=patch(Xpatch,Ypatch,[0.7 0.78 1]);
set(IRFpatch,'facealpha',0.5);
set(IRFpatch,'edgecolor','none');
plot(irf_estimates{ii}(2,:),'Color',[0.4 0.4 1],'LineWidth',2);
plot([1,IRFperiods],[0 0],'k--');
hold off
minband=min(irf_estimates{ii}(1,:));
maxband=max(irf_estimates{ii}(3,:));
space=maxband-minband;
Ymin=minband-0.2*space;
Ymax=maxband+0.2*space;
set(gca,'XLim',[1 IRFperiods],'YLim',[Ymin Ymax],'FontName','Times New Roman');
% top labels
   if ii<=n
      % if a sign restriction identification scheme has been used, use the structural shock labels
      if IRFt==4
      title(signreslabels{ii,1},'FontWeight','normal');
      % otherwise, the shocks are just orthogonalised shocks from the variables: use variable names
      else
      title(endo{ii,1},'FontWeight','normal');
      end
   end
% side labels
   if rem((ii-1)/n,1)==0
   ylabel(endo{(ii-1)/n+1,1},'FontWeight','normal');
   end
end
% top supertitle
ax=axes('Units','Normal','Position',[.11 .075 .85 .88],'Visible','off');
set(get(ax,'Title'),'Visible','on')
title('Shock:','FontSize',11,'FontName','Times New Roman','FontWeight','normal');
% side supertitle
ylabel('Response of:','FontSize',12,'FontName','Times New Roman','FontWeight','normal');
set(get(ax,'Ylabel'),'Visible','on')

end % pref.plot


% then display the results for D and gamma, if a structural decomposition was selected

if IRFt==2 || IRFt==3 || IRFt==4

filelocation=[pref.datapath '\results\' pref.results_sub '.txt'];
fid=fopen(filelocation,'at');

fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');

svarinfo1=['D (structural decomposition matrix): posterior estimates'];
fprintf('%s\n',svarinfo1);
fprintf(fid,'%s\n',svarinfo1);

% recover D
D=reshape(D_estimates,n,n);
% calculate the (integer) length of the largest number in D, for formatting purpose
width=length(sprintf('%d',floor(max(abs(vec(D))))));
% add a separator, a potential minus sign and three digits (total=5) to obtain the total space for each entry in the matrix
width=width+5;
for ii=1:n
temp=[];
   for jj=1:n
   % convert matrix entry into string
   number=num2str(D(ii,jj),'% .3f');
      % pad potential missing blanks
      while numel(number)<width
      number=[' ' number];
      end
   number=[number '  '];
   temp=[temp number];
   end
fprintf('%s\n',temp);
fprintf(fid,'%s\n',temp);
end

fprintf('%s\n','');
fprintf(fid,'%s\n','');
fprintf('%s\n','');
fprintf(fid,'%s\n','');

svarinfo2=['gamma (structural disturbances covariance matrix): posterior estimates'];
fprintf('%s\n',svarinfo2);
fprintf(fid,'%s\n',svarinfo2);

% recover gamma
gamma=reshape(gamma_estimates,n,n);
% calculate the (integer) length of the largest number in D, for formatting purpose
width=length(sprintf('%d',floor(max(abs(vec(gamma))))));
% add a separator, a potential minus sign and three digits (total=5) to obtain the total space for each entry in the matrix
width=width+5;
for ii=1:n
temp=[];
   for jj=1:n
   % convert matrix entry into string
   number=num2str(gamma(ii,jj),'% .3f');
      % pad potential missing blanks
      while numel(number)<width
      number=[' ' number];
      end
   number=[number '  '];
   temp=[temp number];
   end
fprintf('%s\n',temp);
fprintf(fid,'%s\n',temp);
end


fclose(fid);
end



% finally, record results in excel
% retranspose the cell of records
irf_estimates=irf_estimates';
excelrecord4


