function [struct_irf_record D_record gamma_record]=irftrigstvol(F_gibbs,sbar,irf_record,It,Bu,IRFperiods,n)






% create first the cell that will store the results from the simulations
struct_irf_record=cell(n,n);

% then because each sigma from the Gibbs algorithm is obtained from sigma=F*Lambda*F',
% the triangular factor is simply F, and the covariance matrix gamma is just Lambda
% hence start by computing Lambda
Lambda=diag(sbar);
gamma=Lambda;

% repeat simulations a number of times equal to the number of simulations retained from Gibbs sampling
for ii=1:It-Bu


% obtain the triangular factorisation of sigma: the triangular factor is simply F
D=F_gibbs(:,:,ii);


% step 4: obtain orthogonalised IRFs
   % loop over periods
   for jj=1:IRFperiods

      % loop over vertical and horizontal dimensions to recover the responses of all the variables to all the shocks
      for kk=1:n
         for ll=1:n
         % recover the IRF matrix psi, representing the response of variable kk to shock ll at time horizon jj, for Gibbs iteration ii
         psi(kk,ll)=irf_record{kk,ll}(ii,jj);
         end
      end

   % compute the orthonalised irf matrix psitilde, as defined in (2.3.10)
   psi_tilde=psi*D;

      % record the results in the cell; here again, loop over vertical and horizontal dimensions
      for kk=1:n
         for ll=1:n
         struct_irf_record{kk,ll}(ii,jj)=psi_tilde(kk,ll);
         end
      end

   %go for next period
   end

% step 5: record values for D and gamma
D_record(:,ii)=D(:);
gamma_record(:,ii)=gamma(:);

% go for next iteration
end

