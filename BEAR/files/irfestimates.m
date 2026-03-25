function [irf_estimates,D_estimates,gamma_estimates]=irfestimates(irf_record,n,IRFperiods,IRFband,IRFt,D_record,gamma_record)



% function [irf_estimates,D_estimates,gamma_estimates]=irfestimates(irf_record,n,IRFperiods,IRFband,IRFt,D_record,gamma_record)
% calculates the point estimate (median), lower bound and upper bound of the IRFs from the posterior distribution
% inputs:  - cell 'irf_record': record of the gibbs sampler draws for the IRFs
%          - integer 'n': number of endogenous variables in the BVAR model (defined p 7 of technical guide)
%          - integer 'IRFperiods': number of periods for IRFs
%          - scalar 'IRFband': confidence level for IRFs
%          - integer 'IRFt': determines which type of structural decomposition to apply (none, Choleski, triangular factorization)
%          - matrix 'D_record': record of the gibbs sampler draws for the structural matrix D
%          - matrix 'gamma_record': record of the gibbs sampler draws for the structural disturbances variance-covariance matrix gamma
% outputs: - cell 'irftrig_estimates': lower bound, point estimates, and upper bound for the orthogonalised IRFs obtained from triangular factorisation
%          - vector 'D_estimates': point estimate (median) of the structural matrix D, in vectorised form
%          - vector 'gamma_estimates': point estimate (median) of the structural disturbance variance-covariance matrix gamma, in vectorised form



% create first the cell that will contain the IRF estimates
irf_estimates=cell(n,n);

% for the response of each variable to each shock, and each IRF period, compute the median, lower and upper bound from the Gibbs sampler records
% consider variables in turn
for ii=1:n
   % consider shocks in turn
   for jj=1:n
      % consider IRF periods in turn
      for kk=1:IRFperiods
      % compute first the lower bound
      irf_estimates{ii,jj}(1,kk)=quantile(irf_record{ii,jj}(:,kk),(1-IRFband)/2);
      % then compute the median
      irf_estimates{ii,jj}(2,kk)=quantile(irf_record{ii,jj}(:,kk),0.5);
      % finally compute the upper bound
      irf_estimates{ii,jj}(3,kk)=quantile(irf_record{ii,jj}(:,kk),1-(1-IRFband)/2);
      end
   end
end


% next compute the point estimates for the matrices D and gamma
% the procedure will differ according to he chosen structural decomposition
% if no structural decomposition, return empty elements
if IRFt==1
D_estimates=[];
gamma_estimates=[];
% if the chosen scheme is Choleski, return the median of the choleski factors D, and identity for gamma
elseif IRFt==2
   for ii=1:n^2
   D_estimates(ii,1)=quantile(D_record(ii,1),0.5);
   end
gamma_estimates=reshape(eye(n),n^2,1);
% if the chosen scheme is triangular factorisation, return the median of the Gibbs estimates for both matrices
elseif IRFt==3
   for ii=1:n^2
   D_estimates(ii,1)=quantile(D_record(ii,1),0.5);
   gamma_estimates(ii,1)=quantile(gamma_record(ii,1),0.5);
   end
% if the chosen scheme is sign restrictions, return the median of the structural matrix D, and identity for gamma
elseif IRFt==4
   for ii=1:n^2
   D_estimates(ii,1)=quantile(D_record(ii,1),0.5);
   end
gamma_estimates=reshape(eye(n),n^2,1);
end










