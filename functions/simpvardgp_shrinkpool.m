function [y_out,PHI,N,G,T,Phi_alt,L] = simpvardgp_shrinkpool(T)
%--------------------------------------------------------------------------
%   PURPOSE:
%      Get matrix of Y generated from a VAR model
%--------------------------------------------------------------------------
%   INPUTS:
%     T     - Number of observations (rows of Y)
%     N     - Number of series (columns of Y)
%     L     - Number of lags
%
%   OUTPUT:
%     y     - [T x N] matrix generated from VAR(L) model
% -------------------------------------------------------------------------

% randn('seed',sum(100*clock));
% rand('seed',sum(100*clock));
%-----------------------PRELIMINARIES--------------------

% T = 120;            %Number of time series observations (T)
N = 10;             %Number of countries (N)
G = 3;             %Number of macro variables (G)
NG = N*G;
L = 4;             %Lag order
burn = 100+L;         % initial 100+L lags will be discarded as a training sample (lags later)



load('DGPshrinkpool.mat')


PHI     = VARcoef';
Phi_alt = reshape(PHI(PHI~=0),L*G*G,N);


%----------------------GENERATE--------------------------
% Set storage in memory for y
% First L rows are created randomly and are used as
% starting (initial) values
y =[rand(L,NG) ; zeros(T,NG)];

% Now generate Y from VAR (L,PHI,PSI)
for nn = L+1:T+burn
    u = chol(Sigma)'*randn(NG,1);
    %     y(nn,:) = y(nn-1,:)*PHI' + u';
    y(nn,:) =  [y(nn-1,:), y(nn-2,:), y(nn-3,:), y(nn-4,:)]*PHI + u';
end
y_out = y(burn+1:end,:);


% figure
% for ii = 1:N*G
%     % subplot(N,G,1)
%     % plot(y);
%     subplot(N,G,ii);
%     plot(y(:,ii));
%     axis tight
% end

% PHI;

%}
end
