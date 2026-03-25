T = 180; % number of monthly observations
nR = 1;  % number of regions
nm = 19;   % number of monthly series 
p = 4; % number of lags
R = 1;

% n = nm+1+nR;

n = nm+nR;
YY_mat = zeros(T,n,R);
for ii = 1:R
    chck = -1;
    while chck < 0 % draw new coeffecients until stationary
        % constants
        B0 = zeros(n,1);
        % coefficientsch
        B = zeros(n,n*p);
        %first lag
        B1  = -0.2 + (0.2+0.2).*rand(n,n); % off-diagonal elements are U(-0.2, 0.2)
        dg = 0 + (0.5-0.0).*rand(1,n); % diagonal elements are U(0, 0.5)
        B(:,1:n) = B1 + diag(dg' - diag(B1));


        % higher lags are iid N(0,0.05^2/ll^2)
        for ll = 2:p
            B_ll = randn(n,n)*(0.05^2/ll^2);
            B(:,(ll-1)*n+1:ll*n) = B_ll;
        end

        %covariance
        Psi = iwishrnd(0.07*eye(n)+0.031*ones(n)*ones(n)',n+10)*0.05;
%         Psi =   iwishrnd(0.5*eye(n),n+10);
%         Psi =   0.1*eye(n);
        

        % check for stationarity
        beta = [B,B0];
        coef = reshape(beta,n*p+1,n);
        % companion form
        FF=zeros(n*p,n*p);
        FF(n+1:n*p,1:n*(p-1))=eye(n*(p-1),n*(p-1));
        for i=1:p
            FF(1:n,1+n*(i-1):n+n*(i-1))=coef(1+n*(i-1):n+n*(i-1),1:n);
        end
        % eigenvalues
        ee=max(abs(eig(FF)));
        S=ee>=1;
        if S == 0
            chck = 10;
        end
    end

    % GENERATE SERIES
    errors = mvnrnd(zeros(n, 1), Psi, T)';
    YY = zeros(n,T+p);
    YY(:,1:p) = zeros(n,p);
    for t = p+1:T+p
        et = errors(:,t-p);
        for ll = 1:p
            yt = beta(:,(ll-1)*n+1:ll*n) * YY(:,t-ll) + et;
        end
        YY(:,t) = yt;
    end
 
    YY_mat(:,:,ii) = YY(:,p+1:end)';

end
plot(YY_mat(:,:,1))
% [RHO,PVAL] = corr(YY_mat(:,:,1),YY_mat(:,:,1))
% save DGP_data_long.mat YY_mat nR nm p

save DGPcompTime.mat B Psi
