function [y_out,PHI,N,G,T,Phi_alt,L] = simpvardgp_compTime(T,N,G)
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

% N = 20;             %Number of countries (N)
% G = 20;             %Number of macro variables (G)
NG = N*G;
L = 4;             %Lag order
burn = 100+L;         % initial 100+L lags will be discarded as a training sample (lags later)



% load('DGPshrinkpool.mat')
load('DGPcompTime.mat')

Btrans       = B';
% Sigma        = kron(eye(N),Psi);
Sigma        = eye(N*G);
% PHI_diff     = VARcoef';
% PHI          = PHI_diff;
PHI          = zeros(L*N*G,N*G);
A1           = Btrans(1:G,1:G);
A2           = Btrans(1+G:G+G,1:G);
A3           = Btrans(1+G*2:G+G*2,1:G);
A4           = Btrans(1+G*3:G+G*3,1:G);
for ii = 1:N
    PHI(1+(ii-1)*G:G+(ii-1)*G,1+(ii-1)*G:G+(ii-1)*G) = A1;
    PHI(1*G*N+1+(ii-1)*G:1*G*N + G+(ii-1)*G,1+(ii-1)*G:G+(ii-1)*G) = A2;
    PHI(2*G*N+1+(ii-1)*G:2*G*N + G+(ii-1)*G,1+(ii-1)*G:G+(ii-1)*G) = A3;
    PHI(3*G*N+1+(ii-1)*G:3*G*N + G+(ii-1)*G,1+(ii-1)*G:G+(ii-1)*G) = A4;
end
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
%     subplot(N,G,ii)
%     plot(y_out(:,ii));
%     axis tight
% end

%     plot(y_out(:,1:2));
% PHI;

%}
end
