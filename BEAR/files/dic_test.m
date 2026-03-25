function [ dic ] = dic_test( Y,X,N,T,L,beta_gibbs,sigma_gibbs,draws )


%This function calculates the Deviance Information Criteria.
%Introduced in Spiegelhalter et al.(2002), the DIC is a generalization of the Akaike information criterion —
%it penalizes model complexity while rewarding fit to the data


likelihood=[];

beta_dic=beta_gibbs';
sigma_dic=reshape(sigma_gibbs,N,N,draws);
par=size(beta_dic,2)/N; % get the number of parameters per equation to be used in the reshape function

%calculate the likelihood for each saved draw

for i=1:size(beta_dic,1)
    sigma=squeeze(sigma_dic(:,:,i));
    
    [l,problem]=loglik(reshape(beta_dic(i,:),par,N),sigma,Y,X);%likelihood linear model
    if problem
      break 
      
    end
   
    likelihood=[likelihood;l];
    end

if problem
    dic='NaN';
else
    
%get the posterior mean for the parameters
betam= squeeze(mean(beta_dic,1));
sigmam=squeeze(mean(sigma_dic,3));

%Calculate the loglikelihood at the posterior mean

D_mean=-2*loglik(reshape(betam,par,N),sigmam,Y,X);%the likelihood evaluated at the posterior mean

% Calculate the effective number of parameters
D=squeeze(mean(-2*likelihood));% the mean of the likelihood evaluated at each saved draw
params=D-D_mean;

%Calculate the DIC 
dic=D+params;
end
end

