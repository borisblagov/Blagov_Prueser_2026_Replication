function  Output= ARGibbs(Input)
%Y and X needs to go from 1 : T
%Yorg=data(:,1);
hor=Input.hor;
P=Input.P;
Yins= Input.Yins;
burnin=1000;
nkeep=10000;
%P=1;
Y0 = Yins(1:P,:);  % save the first 4 obs as the initial conditions
Y = Yins(P+1:end,:);

store_yfore=zeros(hor,nkeep);

tmpY = [Y0(end-P+1:end,:); Y];

    Z=ones(n-P,1);
    for pp=1:P
        Z=[Z  tmpY(P-(pp-1):end-pp,1)];
    end
   Beta = (Z'*Z)\(Z'*tmpY(P+1:end,1));
    sig2 = mean((Y-Z*Beta).^2);
     %ypred=[1 reshape(Y(end:-1:end-P+1,:)',1,1*P)];

    for i=1:(burnin+nkeep)
        B1=((1/sig2)*(Z'*Z))\eye(P+1);
        b1=B1*((1/sig2)*Z'*Y);
        Beta=b1+chol(B1,'lower')*randn(P+1,1);
        
       RSS= sum((Y-Z*Beta).^2);
       z0=randn(n,1);
       sig2=RSS/( z0'*z0);
       if i>burnin
           ypred=[1 reshape(Y(end:-1:end-P+1,:)',1,1*P)];
           for tt=1:hor
       ymean=ypred*Beta;
       yfore=ymean+randn(1)*sqrt(sig2);
       store_yfore(tt,i-burnin)=yfore;
       ypred = [1  yfore ypred(2:end-1)];
           end
       end
        
    end
 
Output.yfor_draws=store_yfore;
Output.yfor_mean=mean(store_yfore,2);
Output.yfor_median=median(store_yfore,2);
