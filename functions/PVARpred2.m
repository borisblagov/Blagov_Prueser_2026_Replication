
function [Output] = PVARpred2(Y,alpha_draws,sigma_OLS,G,N,p,h,nsave,meanY)

M=N*G*p;
Ylag = mlag2(Y,p);
X = Ylag(p+1:end,:);


% Forecasting (predictive simulation)
Y_pred = zeros(nsave,N*G,h);   
X_fore = [Y(end,:) X(end,1:M*(p-1))];
for irep = 1:nsave       
    A = reshape(alpha_draws(irep,:)',N*G,N*G*p);
    % Forecast of T+1 conditional on data at time T
    Y_hat = X_fore*A + randn(1,M)*chol(sigma_OLS);
    Y_pred(irep,:,1) = Y_hat+meanY;                                  
    for i = 1:h-1  % Predict T+2, T+3 until T+h
        if i <= p                       
            X_new_temp = [Y_hat X_fore(:,1:M*(p-i))];
            % This gives the forecast T+i for i=1,..,p
            Y_temp = X_new_temp*A + randn(1,M)*chol(sigma_OLS);
            Y_pred(irep,:,i+1) = Y_temp+meanY;                
            Y_hat = [Y_hat Y_temp];
        else
            X_new_temp = Y_hat(:,1:M*p);
            Y_temp = X_new_temp*A + randn(1,M)*chol(sigma_OLS);
            Y_pred(irep,:,i+1) = Y_temp+meanY;
            Y_hat = [Y_hat Y_temp];
        end
    end
end
% we need Thor x vars x draws not vars x Thor x draws
Y_pred2=permute(Y_pred,[2 3 1]);
% Output.yfor_median = median(Y_pred2,3);
% Output.yfor_mean=mean(Y_pred2,3);
% Output.yfor_draws=Y_pred2;


Y_pred3=permute(Y_pred,[3 2 1]);
Output.yfor_median = median(Y_pred3,3);
Output.yfor_mean=mean(Y_pred3,3);
Output.yfor_draws=Y_pred3;