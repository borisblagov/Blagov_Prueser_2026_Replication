
function [V_Minnconstruction,V_Minnlag] = priorconstruction(P,q,c3)

K = 1+ q*P;
V_Minnconstruction = zeros(K*q,1);
V_Minnlag = zeros(K*q,1);

% need this for sig2 as input: Y0,Y
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
            V_Minnlag(count) = c3;
             V_Minnconstruction(count) = 3;
        elseif i==j % own lag
            V_Minnlag(count) =1/l^2;% 
            V_Minnconstruction(count) = 1;
        elseif i~=j% lag of another variable        
           V_Minnlag(count) = sig2(i)/(l^2*sig2(j));
            V_Minnconstruction(count) =2;
        end
        count = count + 1;
    end
end






% 
% K= 1+ q*P;
% 
% V_Minnconstruction = ones(K*q,1)*2;
% 
% count=1;
% for i=1:q
% 
%    V_Minnconstruction(count)=3;
%    V_Minnconstruction(count+(1:q:(P*q)))=1;
%    count=count+K;
%    
% end