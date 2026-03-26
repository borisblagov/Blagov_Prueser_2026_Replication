function [struct_irf_record D_record gamma_record]=irfcholstvol(F_gibbs,sbar,irf_record,It,Bu,IRFperiods,n)




% create first the cell that will store the results from the simulations
struct_irf_record=cell(n,n);

% then because each sigma from the Gibbs algorithm is obtained from sigma=F*Lambda*F',
% the Choleski factor obtains from the rewriting sigma=F*Lambda^0.5*Lambda^0.5'*F', and F*Lambda^0.5 is the Choleski factor
% hence start by computing Lambda^0.5
Lambdasq=diag(sbar.^0.5);

% repeat simulations a number of times equal to the number of simulations retained from Gibbs sampling
for ii=1:It-Bu

% obtain the Choleski factor of sigma as F*Lambdasq
D=F_gibbs(:,:,ii)*Lambdasq;


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
   psitilde=psi*D;

      % record the results in the cell; here again, loop over vertical and horizontal dimensions
      for kk=1:n
         for ll=1:n
         struct_irf_record{kk,ll}(ii,jj)=psitilde(kk,ll);
         end
      end

   %go for next period
   end

% step 5: record values for D and gamma
D_record(:,ii)=D(:);
% gamma is just identity
gamma_record(:,ii)=reshape(eye(n),n^2,1);

% go for next iteration
end

