
% plot irfs in paper
% first run Calculate_IRFs.m


figure
% set(gcf,'Position',[-1919 -439 1920 1090]);

 titles=char(' Response RGDP DE ','Response of HICP DE', 'Response of EURIBOR DE',...
        ' Response RGDP FR ', 'Response of HICP FR', 'Response of EURIBOR FR',...
        ' Response RGDP IT ', 'Response of HICP IT', 'Response of EURIBOR IT');%adjust thisby hand
ncountries=3;
horizon=hor;
x_axis=1:hor;
for i=1:ncountries*G
 
IRF=prctile(Xirf(:,:,i),[5 16 50 84 95],2);%Xirf_store(:,:,i)
b1=IRF(:,1);
b2=IRF(:,2);
b3=IRF(:,4);
b4=IRF(:,5);
a=IRF(:,3);
subplot(3,3,i)

    %figure
    plot(x_axis, zeros(1,size(x_axis,2)), 'Color', 'black')
    %ylim([min(b1)-abs(min(b1)), max(b4)+abs(max(b4))])
    xlim([1,hor])
    ax = gca;
    ax.YAxis.Exponent = 0;
    hold on 
   % plot(x_axis,b2,'Color',[0    0.4470    0.7410],'LineWidth',3)
    plot(x_axis,b1,'Color',[0.28    0.63   0.86],'LineWidth',2)
    plot(x_axis,b4,'Color',[0.28    0.63   0.86],'LineWidth',2)
    %plot(x_axis,b3,'Color',[0    0.4470    0.7410],'LineWidth',3)
%     plot(x_axis,b1,'Color','none')
%     plot(x_axis,b2,'Color','none')
%     plot(x_axis,b3,'Color','none')
%     plot(x_axis,b4,'Color','none')
   p1= plot(x_axis,a,'Color', 'blue','LineWidth',3);
    x_axis2 = [x_axis,  fliplr(x_axis)];
    inBetween = [a', fliplr(b1')];
    h=fill(x_axis2, inBetween,[0.28    0.63   0.86],'LineStyle','none');
    set(h,'facealpha',.5)
%     inBetween = [b2', fliplr(b1')];
%     h=fill(x_axis2, inBetween,[0    0.4470    0.7410],'LineStyle','none','FaceAlpha',.7);
%         set(h,'facealpha',.5)
    inBetween = [a', fliplr(b4')];
    h=fill(x_axis2, inBetween,[0.28    0.63   0.86],'LineStyle','none');%0.5625 0.9297 0.5625
        set(h,'facealpha',.5)
%     inBetween = [b3', fliplr(b4')];
%     h=fill(x_axis2, inBetween,[0    0.4470    0.74100.28    0.63   0.86],'LineStyle','none','FaceAlpha',.7);%0 0.3906 0
%         set(h,'facealpha',.5)
    plot(x_axis,a,'Color', 'blue')
%     title(titles(i,:))
%     set(gca,'fontsize',14)
     hold off


    IRF=prctile(Xirf_prior(:,:,i),[5 16 50 84 95],2);%Xirf_store(:,:,i)
b1=IRF(:,1);
b2=IRF(:,2);
b3=IRF(:,4);
b4=IRF(:,5);
a=IRF(:,3);
  hold on 
    %plot(x_axis,b2,'--','Color',[1 0 0],'LineWidth',3)%'Color',,[0.5625 0.9297 0.5625]
    plot(x_axis,b1,'Color',[1 0 0],'LineWidth',3)
    plot(x_axis,b4,'Color',[1 0 0],'LineWidth',3)
   % plot(x_axis,b3,'--','Color',[1 0 0],'LineWidth',3)
%     plot(x_axis,b1,'Color','none')
%     plot(x_axis,b2,'Color','none')
%     plot(x_axis,b3,'Color','none')
%     plot(x_axis,b4,'Color','none')
   p3=  plot(x_axis,a,'--','Color', [1 0 0],'LineWidth',3)
%     x_axis2 = [x_axis,  fliplr(x_axis)];
%     inBetween = [a', fliplr(b2')];
%     h=fill(x_axis2, inBetween,[0.5625 0.9297 0.5625],'LineStyle','none');
%         set(h,'facealpha',.5)
%     inBetween = [b2', fliplr(b1')];
%     h=fill(x_axis2, inBetween,[0 0.3906 0],'LineStyle','none','FaceAlpha',.7);
%         set(h,'facealpha',.3)
%     inBetween = [a', fliplr(b3')];
%     h=fill(x_axis2, inBetween,[0.5625 0.9297 0.5625],'LineStyle','none');%0.5625 0.9297 0.5625
%         set(h,'facealpha',.5)
%     inBetween = [b3', fliplr(b4')];
%     h=fill(x_axis2, inBetween,[0 0.3906 0],'LineStyle','none','FaceAlpha',.7);%0 0.3906 0
%         set(h,'facealpha',.3)
    title(titles(i,:))
    set(gca,'fontsize',14)
    hold off
        box off;

end
% if Supply ==1
%  h=suptitle('Supply Shock');
% else
%  h=suptitle('Demand Shock');
% end
 %set(h, 'Position', [0.16796875 -0.0580862533692723 0],'FontWeight','bold','FontSize',15);%0.
 legend1=legend([p1 p3],{'Country VAR','VAR pooling Prior'},'Orientation','horizontal');
set(legend1,...
    'Position',[0.274479177050912 0.947204819707984 0.630078114534263 0.0360655728910789],...
    'Orientation','horizontal');
legend('boxoff')
set(gcf, 'Color', 'white')

temp=['pics\', name,'IRFs_1.pdf'];    
if Save==1
% exportgraphics(gcf,temp)
end
%%
figure
% set(gcf,'Position',[-1919 -439 1920 1090]);

    titles=char(' Response RGDP ES ','Response of HICP ES', 'Response of EURIBOR ES',...
        ' Response RGDP NL ', 'Response of HICP NL', 'Response of EURIBOR NL',...
        ' Response RGDP BE ', 'Response of HICP BE', 'Response of EURIBOR BE');%adjust thisby hand
 
horizon=hor;
x_axis=1:hor;
ncountries=3;
G=3;
count=0;
for i=(ncountries*G+1):(ncountries*G*2)
 
IRF=prctile(Xirf(:,:,i),[5 16 50 84 95],2);%Xirf_store(:,:,i)
b1=IRF(:,1);
b2=IRF(:,2);
b3=IRF(:,4);
b4=IRF(:,5);
a=IRF(:,3);
count=count+1;
subplot(3,3,count)

    %figure
    plot(x_axis, zeros(1,size(x_axis,2)), 'Color', 'black')
    %ylim([min(b1)-abs(min(b1)), max(b4)+abs(max(b4))])
    xlim([1,hor])
    ax = gca;
    ax.YAxis.Exponent = 0;
    hold on 
   % plot(x_axis,b2,'Color',[0    0.4470    0.7410],'LineWidth',3)
    plot(x_axis,b1,'Color',[0.28    0.63   0.86],'LineWidth',2)
    plot(x_axis,b4,'Color',[0.28    0.63   0.86],'LineWidth',2)
    %plot(x_axis,b3,'Color',[0    0.4470    0.7410],'LineWidth',3)
%     plot(x_axis,b1,'Color','none')
%     plot(x_axis,b2,'Color','none')
%     plot(x_axis,b3,'Color','none')
%     plot(x_axis,b4,'Color','none')
   p1= plot(x_axis,a,'Color', 'blue','LineWidth',3);
    x_axis2 = [x_axis,  fliplr(x_axis)];
    inBetween = [a', fliplr(b1')];
    h=fill(x_axis2, inBetween,[0.28    0.63   0.86],'LineStyle','none');
    set(h,'facealpha',.5)
%     inBetween = [b2', fliplr(b1')];
%     h=fill(x_axis2, inBetween,[0    0.4470    0.7410],'LineStyle','none','FaceAlpha',.7);
%         set(h,'facealpha',.5)
    inBetween = [a', fliplr(b4')];
    h=fill(x_axis2, inBetween,[0.28    0.63   0.86],'LineStyle','none');%0.5625 0.9297 0.5625
        set(h,'facealpha',.5)
%     inBetween = [b3', fliplr(b4')];
%     h=fill(x_axis2, inBetween,[0    0.4470    0.74100.28    0.63   0.86],'LineStyle','none','FaceAlpha',.7);%0 0.3906 0
%         set(h,'facealpha',.5)
    plot(x_axis,a,'Color', 'blue')
%     title(titles(i,:))
%     set(gca,'fontsize',14)
     hold off


    IRF=prctile(Xirf_prior(:,:,i),[5 16 50 84 95],2);%Xirf_store(:,:,i)
b1=IRF(:,1);
b2=IRF(:,2);
b3=IRF(:,4);
b4=IRF(:,5);
a=IRF(:,3);
  hold on 
    %plot(x_axis,b2,'--','Color',[1 0 0],'LineWidth',3)%'Color',,[0.5625 0.9297 0.5625]
    plot(x_axis,b1,'Color',[1 0 0],'LineWidth',3)
    plot(x_axis,b4,'Color',[1 0 0],'LineWidth',3)
   % plot(x_axis,b3,'--','Color',[1 0 0],'LineWidth',3)
%     plot(x_axis,b1,'Color','none')
%     plot(x_axis,b2,'Color','none')
%     plot(x_axis,b3,'Color','none')
%     plot(x_axis,b4,'Color','none')
   p3=  plot(x_axis,a,'--','Color', [1 0 0],'LineWidth',3)
%     x_axis2 = [x_axis,  fliplr(x_axis)];
%     inBetween = [a', fliplr(b2')];
%     h=fill(x_axis2, inBetween,[0.5625 0.9297 0.5625],'LineStyle','none');
%         set(h,'facealpha',.5)
%     inBetween = [b2', fliplr(b1')];
%     h=fill(x_axis2, inBetween,[0 0.3906 0],'LineStyle','none','FaceAlpha',.7);
%         set(h,'facealpha',.3)
%     inBetween = [a', fliplr(b3')];
%     h=fill(x_axis2, inBetween,[0.5625 0.9297 0.5625],'LineStyle','none');%0.5625 0.9297 0.5625
%         set(h,'facealpha',.5)
%     inBetween = [b3', fliplr(b4')];
%     h=fill(x_axis2, inBetween,[0 0.3906 0],'LineStyle','none','FaceAlpha',.7);%0 0.3906 0
%         set(h,'facealpha',.3)
    title(titles(count,:))
    set(gca,'fontsize',14)
    hold off
        box off;

end
% if Supply ==1
%  h=suptitle('Supply Shock');
% else
%  h=suptitle('Demand Shock');
% end
 %set(h, 'Position', [0.16796875 -0.0580862533692723 0],'FontWeight','bold','FontSize',15);%0.
 legend1=legend([p1 p3],{'Country VAR','VAR pooling Prior'},'Orientation','horizontal');
set(legend1,...
    'Position',[0.274479177050912 0.947204819707984 0.630078114534263 0.0360655728910789],...
    'Orientation','horizontal');
legend('boxoff')
set(gcf, 'Color', 'white')
temp=['pics\',name,'IRFs_2.pdf'];  
if Save==1

% exportgraphics(gcf,temp)

end
%%
figure
% set(gcf,'Position',[-1919 -439 1920 1090]);

  titles=char(' Response RGDP AT ','Response of HICP AT', 'Response of EURIBOR AT',...
        ' Response RGDP PT ', 'Response of HICP PT', 'Response of EURIBOR PT',...
        ' Response RGDP GR ', 'Response of HICP GR', 'Response of EURIBOR GR',...
        ' Response RGDP FI ', 'Response of HICP FI', 'Response of EURIBOR FI');%adjust thisby hand
 
horizon=hor;
x_axis=1:hor;
ncountries=4;
G=3;
count=0;
for i=19:30 % adjust this by hand
 
IRF=prctile(Xirf(:,:,i),[5 16 50 84 95],2);%Xirf_store(:,:,i)
b1=IRF(:,1);
b2=IRF(:,2);
b3=IRF(:,4);
b4=IRF(:,5);
a=IRF(:,3);
count=count+1;
subplot(4,3,count)

    %figure
    plot(x_axis, zeros(1,size(x_axis,2)), 'Color', 'black')
    %ylim([min(b1)-abs(min(b1)), max(b4)+abs(max(b4))])
    xlim([1,hor])
    ax = gca;
    ax.YAxis.Exponent = 0;
    hold on 
   % plot(x_axis,b2,'Color',[0    0.4470    0.7410],'LineWidth',3)
    plot(x_axis,b1,'Color',[0.28    0.63   0.86],'LineWidth',2)
    plot(x_axis,b4,'Color',[0.28    0.63   0.86],'LineWidth',2)
    %plot(x_axis,b3,'Color',[0    0.4470    0.7410],'LineWidth',3)
%     plot(x_axis,b1,'Color','none')
%     plot(x_axis,b2,'Color','none')
%     plot(x_axis,b3,'Color','none')
%     plot(x_axis,b4,'Color','none')
   p1= plot(x_axis,a,'Color', 'blue','LineWidth',3);
    x_axis2 = [x_axis,  fliplr(x_axis)];
    inBetween = [a', fliplr(b1')];
    h=fill(x_axis2, inBetween,[0.28    0.63   0.86],'LineStyle','none');
    set(h,'facealpha',.5)
%     inBetween = [b2', fliplr(b1')];
%     h=fill(x_axis2, inBetween,[0    0.4470    0.7410],'LineStyle','none','FaceAlpha',.7);
%         set(h,'facealpha',.5)
    inBetween = [a', fliplr(b4')];
    h=fill(x_axis2, inBetween,[0.28    0.63   0.86],'LineStyle','none');%0.5625 0.9297 0.5625
        set(h,'facealpha',.5)
%     inBetween = [b3', fliplr(b4')];
%     h=fill(x_axis2, inBetween,[0    0.4470    0.74100.28    0.63   0.86],'LineStyle','none','FaceAlpha',.7);%0 0.3906 0
%         set(h,'facealpha',.5)
    plot(x_axis,a,'Color', 'blue')
%     title(titles(i,:))
%     set(gca,'fontsize',14)
     hold off


    IRF=prctile(Xirf_prior(:,:,i),[5 16 50 84 95],2);%Xirf_store(:,:,i)
b1=IRF(:,1);
b2=IRF(:,2);
b3=IRF(:,4);
b4=IRF(:,5);
a=IRF(:,3);
  hold on 
    %plot(x_axis,b2,'--','Color',[1 0 0],'LineWidth',3)%'Color',,[0.5625 0.9297 0.5625]
    plot(x_axis,b1,'Color',[1 0 0],'LineWidth',3)
    plot(x_axis,b4,'Color',[1 0 0],'LineWidth',3)
   % plot(x_axis,b3,'--','Color',[1 0 0],'LineWidth',3)
%     plot(x_axis,b1,'Color','none')
%     plot(x_axis,b2,'Color','none')
%     plot(x_axis,b3,'Color','none')
%     plot(x_axis,b4,'Color','none')
   p3=  plot(x_axis,a,'--','Color', [1 0 0],'LineWidth',3)
%     x_axis2 = [x_axis,  fliplr(x_axis)];
%     inBetween = [a', fliplr(b2')];
%     h=fill(x_axis2, inBetween,[0.5625 0.9297 0.5625],'LineStyle','none');
%         set(h,'facealpha',.5)
%     inBetween = [b2', fliplr(b1')];
%     h=fill(x_axis2, inBetween,[0 0.3906 0],'LineStyle','none','FaceAlpha',.7);
%         set(h,'facealpha',.3)
%     inBetween = [a', fliplr(b3')];
%     h=fill(x_axis2, inBetween,[0.5625 0.9297 0.5625],'LineStyle','none');%0.5625 0.9297 0.5625
%         set(h,'facealpha',.5)
%     inBetween = [b3', fliplr(b4')];
%     h=fill(x_axis2, inBetween,[0 0.3906 0],'LineStyle','none','FaceAlpha',.7);%0 0.3906 0
%         set(h,'facealpha',.3)
    title(titles(count,:))
    set(gca,'fontsize',14)
    hold off
        box off;

end
% if Supply ==1
%  h=suptitle('Supply Shock');
% else
%  h=suptitle('Demand Shock');
% end
 %set(h, 'Position', [0.16796875 -0.0580862533692723 0],'FontWeight','bold','FontSize',15);%0.
 legend1=legend([p1 p3],{'Country VAR','VAR pooling Prior'},'Orientation','horizontal');
set(legend1,...
    'Position',[0.274479177050912 0.947204819707984 0.630078114534263 0.0360655728910789],...
    'Orientation','horizontal');
legend('boxoff')
set(gcf, 'Color', 'white')
temp=['pics\',name,'IRFs_3.pdf'];  
if Save==1
% exportgraphics(gcf,temp)
end

