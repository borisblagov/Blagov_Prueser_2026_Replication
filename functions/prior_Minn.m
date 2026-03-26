
function [iVbeta,V_Minn] = prior_Minn(P,c1,c2,c3,Y)
[~,q] = size(Y);
K =1+ q*P;
%beta_Minn = zeros(K*q,1);
V_Minn = zeros(K*q,1);



% sig2 = zeros(q,1);    
% tmpY = [Y0(end-p+1:end,:); Y];
% for i=1:q
%     Z=ones(n,1);
%     for pp=1:p
%         Z=[Z  tmpY(p-(pp-1):end-pp,i)];
%     end
%     tmpb = (Z'*Z)\(Z'*tmpY(p+1:end,i));
%     sig2(i) = mean((tmpY(p+1:end,i)-Z*tmpb).^2);
% end
% Sig_hat = sig2;
sig2=ones(q,1);
count = 1;
for i=1:q
   for ii=0:K-1
        j = mod(ii,q); % variable index
        if j==0
            j = q;
        end
        l = ceil(ii/q); % lag length        
        if ii==0 % intercept
            V_Minn(count) = c3;
        elseif i==j % own lag
            V_Minn(count) = c1/l^2;
        elseif i~=j % lag of another variable        
            V_Minn(count) = c2*sig2(i)/(l^2*sig2(j));
        end
        count = count + 1;
    end
end
iVbeta = sparse(1:q*K,1:q*K,1./V_Minn);
end