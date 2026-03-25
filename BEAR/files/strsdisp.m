function []=strsdisp(n,decimaldates1,strshocks_estimates,endo,stringdates1,pref,IRFt,signreslabels)









if pref.plot
% create structural shocks figure
strshocks=figure;
set(strshocks,'Color',[0.9 0.9 0.9]);
set(strshocks,'name','structural shocks');
ncolumns=ceil(n^0.5);
nrows=ceil(n/ncolumns);
for ii=1:n
subplot(nrows,ncolumns,ii);
hold on
Xpatch=[decimaldates1' fliplr(decimaldates1')];
Ypatch=[strshocks_estimates{ii,1}(1,:) fliplr(strshocks_estimates{ii,1}(3,:))];
Fpatch=patch(Xpatch,Ypatch,[0.7 0.78 1]);
set(Fpatch,'facealpha',0.6);
set(Fpatch,'edgecolor','none');
strs=plot(decimaldates1,strshocks_estimates{ii,1}(2,:),'Color',[0.4 0.4 1],'LineWidth',2);
plot([decimaldates1(1,1),decimaldates1(end,1)],[0 0],'k--');
hold off
minband=min(strshocks_estimates{ii,1}(1,:));
maxband=max(strshocks_estimates{ii,1}(3,:));
space=maxband-minband;
Ymin=minband-0.2*space;
Ymax=maxband+0.2*space;
set(gca,'XLim',[decimaldates1(1,1) decimaldates1(end,1)],'YLim',[Ymin,Ymax],'FontName','Times New Roman');
   % if a sign restriction identification scheme has been used, use the structural shock labels
   if IRFt==4
   title(signreslabels{ii,1},'FontName','Times New Roman','FontSize',10,'FontWeight','normal');
   % otherwise, the shocks are just orthogonalised shocks from the variables: use variable names
   else
   title(endo{ii,1},'FontName','Times New Roman','FontSize',10,'FontWeight','normal');
   end
end

end % pref.plot

% finally, record the results on excel
excelrecord9


