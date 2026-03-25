function [strshocks_record]=strshocks(beta_gibbs,D_record,Y,X,n,k,It,Bu)











% first create the call storing the results
strshocks_record=cell(n,1);


% then loop over iterations
for ii=1:It-Bu

% recover the VAR coefficients, reshaped for convenience
B=reshape(beta_gibbs(:,ii),k,n);


% obtain the residuals from (XXX)
EPS=Y-X*B;


% then recover the structural marix D
D=reshape(D_record(:,ii),n,n);


% obtain the structural disturbances from (XXX)
ETA=D\EPS';


   % save in struct_shocks_record
   for jj=1:n
   strshocks_record{jj,1}(ii,:)=ETA(jj,:);
   end


end


