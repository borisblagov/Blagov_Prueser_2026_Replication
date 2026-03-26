function [irf_record_allt]=tvbvarirf3(beta_gibbs,sigma_t_gibbs,IRFt,It,Bu,IRFperiods,n,m,p,k,T)





% create the cell aray that will store the values from the simulations
irf_record_allt=cell(n,n);

% loop over sample periods
for tt=1:T
   % loop over iterations
   for jj=1:It-Bu
   % draw beta
   beta=beta_gibbs{tt}(:,jj);
   sigma=sigma_t_gibbs{tt}(:,:,jj);
      if IRFt==1
      D=eye(n);
      elseif IRFt==2
      D=chol(nspd(sigma),'lower');
      elseif IRFt==3
      [D,~]=triangf(sigma);
      end
   [~,ortirfmatrix]=irfsim(beta,D,n,m,p,k,IRFperiods);
      for kk=1:n
         for ll=1:n
            for mm=1:IRFperiods
            irf_record_allt{kk,ll}(jj,mm,tt)=ortirfmatrix(kk,ll,mm);
            end
         end
      end
   end
end



