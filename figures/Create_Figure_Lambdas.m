clc
clear
close all

addpath('../functions')
% addpath('export_fig')
N = 10; G=7; k = G*G*4; % # of params
load N10G7_lambdas.mat
pair_index      = nchoosek(1:N,2);
lambdas_mat     = reshape(lambdas,size(lambdas,1)/45,45);
countries_vec = {'DE','FR','IT','ES','NL','BE','AT','PT','FI','GR'};
load('blueWhite_cmap.mat');

%% RGDP, different lags
splot_rows = 3;
splot_cols = 4;

RGDP = zeros(N,N,4);
RGDP_upper = zeros(N,N,4);
HICP = zeros(N,N,4);
EURIBOR = zeros(N,N,4);
for ii = 1:4
    [RGDP_mat,RGDP_upper_mat,tval1] = get_lambdas(lambdas_mat,1+7*(ii-1),N);
    [HICP_mat,HICP_upper_mat,tval2] = get_lambdas(lambdas_mat,29+7*(ii-1),N);
    [EURIBOR_mat,EURIBOR_upper_mat,tval3] = get_lambdas(lambdas_mat,57+7*(ii-1),N);
%     [Tm1_mat,Tm1_upper_mat,tval] = get_lambdas(lambdas_mat,1,N);
    RGDP(:,:,ii)    = RGDP_mat;
    RGDP_upper(:,:,ii)    = RGDP_upper_mat;
    HICP(:,:,ii)    = HICP_mat;
    EURIBOR(:,:,ii) = EURIBOR_mat;
    tval_vec(ii,:) = [tval1 tval2 tval3];
end    
    
top_value = max(max(tval_vec));   

tit_help = {' First own ',' Second own ',' Third own ',' Fourth own '};
figure
for ii = 1:4
    subplot(splot_rows,splot_cols,ii)
%     subplot(splot_rows,splot_cols,1 + 3*(ii-1))
    imagesc(RGDP(:,:,ii));
    h1 = gca;
    h1.YTick = 1:N;
    h1.YTickLabel = countries_vec;
    h1.XTick = 1:N;
    h1.XTickLabel = countries_vec;
    caxis manual
    caxis([0 top_value]);
    colormap(bluewhitered), colorbar
    title(strcat('',tit_help{ii},' lag'))
%     title(['GDP  lag ',num2str(ii)])
if ii==1
    ylabel('GDP','FontWeight','bold')
end
    
    subplot(splot_rows,splot_cols,ii+4)
    imagesc(HICP(:,:,ii));
    h1 = gca;
    h1.YTick = 1:N;
    h1.YTickLabel = countries_vec;
    h1.XTick = 1:N;
    h1.XTickLabel = countries_vec;
    caxis manual
    caxis([0 top_value]);
    colormap(bluewhitered), colorbar
%     title(strcat('\Lambda pairs, \pi_{t-',num2str(ii),'}'))
    title(strcat('',tit_help{ii},' lag'))
%     title(['HICP own lag ',num2str(ii)])
if ii==1
    ylabel('HICP','FontWeight','bold')
    end
      
    subplot(splot_rows,splot_cols,ii+8)
    imagesc(EURIBOR(:,:,ii));
    h1 = gca;
    h1.YTick = 1:N;
    h1.YTickLabel = countries_vec;
    h1.XTick = 1:N;
    h1.XTickLabel = countries_vec;
    caxis manual
    caxis([0 top_value]);
    colormap(bluewhitered), colorbar
%     title(strcat('\Lambda pairs, r_{t-',num2str(ii),'}'))
    title(strcat('',tit_help{ii},' lag'))
%     title(['EURIBOR own lag ',num2str(ii)])
    if ii == 1
    ylabel('EURIBOR','FontWeight','bold')
    end
end
set(gcf,'Color',[1 1 1])
% exportgraphics(gcf,'fig_Lambdas.eps','ContentType','vector')
