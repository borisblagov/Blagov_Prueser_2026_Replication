function Out = fcast_eval(oosdata_mat,forecast_3dmat,varargin)
% Input
%   oosdata_mat:    the out-of-sample data in a matrix. If T_full is the length of your full dataset 
%                   and and T_short is the shortest sample from which you start your pseudo out-of-sample
%                   forecast, such that T_full - T_short = n_pseudo, then oosdata_mat is y(T_short:T_full, N), 
%                   where N is the number of variables
%   forecast_3dmat: a 3-D matrix of out-of sample forecasts. Dimensions (fhor x N x n_pseudo).
%   var_list:       an optional argument, cell array 1xN with the names of the variables
% Output
%   Out.rmsfe_tab:  a table with root mean-squared forecast error sqrt( \sum (yf_{T+h} - y{T+h})^2 )/pseudo_n,
%                   where yf_{T+h} is the h-step ahead forecast and y_{T+h} is the actual data
%   Out.msfe_tab:   a table with the mean squared forecast error ( \sum (yf_{T+h} - y{T+h})^2 )/pseudo_n
%   Out.mae_tab:    a table with the mean absolute error ( \sum |yf_{T+h} - y{T+h}| )/pseudo_n
%-----------------------------------%
% Written by: Boris Blagov and Jan Prüser
% This version: 06.10.2020
%-----------------------------------%
fcast_hor   = size(forecast_3dmat,1);
nvars       = size(forecast_3dmat,2);
n_pseudo    = size(forecast_3dmat,3);

% prepare the observed data in a 3d form with dimensions (fcast_hor x nvars x n_pseudo)
oosdata_3dmat = zeros(fcast_hor,nvars,n_pseudo);
msfe            =  zeros(fcast_hor,nvars);
mae             = msfe;
avg            = msfe;
for ik = 1:n_pseudo
    if ik < n_pseudo - fcast_hor +1
        oosdata_3dmat(:,:,ik) = oosdata_mat(ik:fcast_hor+ik-1,:);
    else
        count_ik = ik - (n_pseudo - fcast_hor +1);
        oosdata_3dmat(:,:,ik) = [oosdata_mat(ik:fcast_hor+ik-1-count_ik,:); NaN(count_ik,nvars)];        
    end
end


msfe_hor = nan(n_pseudo,nvars,fcast_hor);
values_hor = nan(n_pseudo,nvars,fcast_hor);
% Now calculte msfe, rmsfe and mae. You may add other measures here
for im = 1:fcast_hor 
    % calcualtes the forecast difference, removes the singleton first dimension and
    % transposes such that the matrix is npseudo x nvars for a given T + h
    tph_fcast_diff = shiftdim(oosdata_3dmat(im,:,:) - forecast_3dmat(im,:,:),1)';   
    msfe_hor(:,:,im) = tph_fcast_diff.^2;
    tph_msfe = mean(tph_fcast_diff.^2,'omitnan');
    tph_mae = mean(abs(tph_fcast_diff),'omitnan');

    values_hor(:,:,im) = shiftdim(forecast_3dmat(im,:,:),1)';
    tph_mean =mean(values_hor(:,:,im),'omitnan');

    % tph_msfe = sum(squeeze(oosdata_3dmat(im,:,:) - forecast_3dmat(im,:,:)).^2,2,'omitnan')./(n_pseudo-im+1);
    % tph_mae = sum(abs(squeeze(oosdata_3dmat(im,:,:) - forecast_3dmat(im,:,:))),2,'omitnan')./(n_pseudo-im+1);
    % tph_mean = sum(squeeze(forecast_3dmat(im,:,:)),2,'omitnan')./(n_pseudo-im+1);              % either take mean or sum and then divide by ./(n_pseudo-im+1). If you do the second watch out that the forecast has a ragged edge, i.e. for T+1 you have say 40 out of sample obs while for T+8 you have 32
    
    msfe(im,:) = tph_msfe;
    mae(im,:)  = tph_mae;
    avg(im,:) = tph_mean;  % used for CRPS for example
    rowName{im,1} = strcat('T+',num2str(im));
end
msfe_tab = array2table(msfe);
msfe_tab.Properties.RowNames = rowName;
rmsfe   = sqrt(msfe);
rmsfe_tab = array2table(rmsfe);
rmsfe_tab.Properties.RowNames = rowName;
mae_tab     = array2table(mae);
mae_tab.Properties.RowNames = rowName;
avg_tab     = array2table(avg);
avg_tab.Properties.RowNames = rowName;

if ~isempty(varargin)
    msfe_tab.Properties.VariableNames = varargin{1};
    rmsfe_tab.Properties.VariableNames = varargin{1};
    mae_tab.Properties.VariableNames = varargin{1};
    avg_tab.Properties.VariableNames = varargin{1};
end

Out.msfe_hor    = msfe_hor;
Out.values_hor    = values_hor;
Out.msfe_tab    = msfe_tab;
Out.rmsfe_tab   = rmsfe_tab;
Out.mae_tab     = mae_tab;
Out.avg_tab     = avg_tab;

