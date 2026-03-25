function Output=VARpanel_twostep(Input)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% novel: combine the minesota prior with flexible homogeneity restrictions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% this functions needs these inputs:

%Input.Yins % Yins: [gdpGermany infGermany gdpSpain infSpain gdpFrance infFrance] ->G=2 N=3
%Input.G;   %G variabes for each country
%Input.N;   %N countries

%Input.standardize; Set to 1 as this model is estimated without a constant
%Input.MCMC % 1000
%Input.BURNIN $ 100

%P=Input.P;%4: use 4 laqs
%Input.hor; %how many quarters we want to predict ahead, set to 0-> no forecasts


%%% priors: you can try all 64 combinations. Set to 1 (active) or 0 (inactive)

%Input.minesotaadaptive; %1: use minesota prior, set this rather to 1, the mineosota prior is country specific
%Input.MinesotaGL;%if 1 use local priors for minesota prior, set this rather to 0, very flexiable


%Input.CS_local;if 1 local priors for homogeneity restirction, set this rather to 0, very flexiable
%Input.CS_country;%if 1 shrinks country pairs i.e. N*(N-1)/2 hyperparameter
%Input.CS_global;%if 1 shrinks all country pairs i.e. one hyperparameter for all countries

%Input.HC; % 1: half-Cauchy otherwise use inversegamma prior IG(0,0)i.e. jeffry, this applys to all prior

% Input.dispsim: how often to display the progress of the MCMC. Default is 100 if nothing is specified.
% Input.dispinfo: 1 or 0. Whether to show a summary of the settings. Set to 0 for pseudo oos.

%Outputs:
%Output.yfor_median, is hor x N*G, same columns as Yins
%Output.yfor_mean, is hor x N*G, same columns as Yins
%Output.yfor_draws, is hor x N*G x MCMC
% Output.AR_store_mean is the PHI matrix




%%% data and set N and G


G=Input.G;%G variabes for each country
N=Input.N;%N countries


%%%% choices:

MCMC=Input.MCMC;
BURNIN=Input.BURNIN;
thin=1;
Rue=1;% set to 1 is prefered (this changes if we have more variables than obs)
delta_algo=0.0;%set to small number. plays a rule if rue=0. set to zero algo is exact. set to small number algo gets faster.



P=Input.P;% use 1,2,3,4 laqs
hor=Input.hor; %how many quarters we want to predict ahead, set to 0-> no forecasts

minesotaadaptive=Input.minesotaadaptive; %1: use minesota prior
MinesotaGL=Input.MinesotaGL;%if 1 use local priors for minesota prior
Minesota_shape=Input.Minesota_shape;
Minesota_scale=Input.Minesota_scale;
Minesota_cplus=Input.Min_HC; % 1: half-Cauchy otherwise use inversegamma prior IG(shape,scale)
startminesota=1; % do not change
minesotafix=1;% if you set to 0 you use hierachical bayes: not recommended
minesotafix=Input.delta_minesota;
delta_minesota=1;

%%homogeneity restirction
%setting all to zero we have a normal VAR with minesota prior
%setting only CS_country to one: we have prior similar to Korrobilis/Koop
CS_local=Input.CS_local;
CS_country=Input.CS_country;%
CS_global=Input.CS_global;
CS_shape=Input.CS_shape;
CS_scale=Input.CS_scale;
CS_cplus=Input.CS_HC; % 1: half-Cauchy otherwise use inversegamma prior IG(shape,scale)
shrinkpool=Input.delta;
delta=1; % set to one nothing changes, set delta <1 we have discounting


if isfield(Input,'dispsim')
    dispsim = Input.dispsim;
else
    dispsim = 100;
end

if isfield(Input,'dispinfo')
    dispinfo = Input.dispinfo;
else
    dispinfo = 1;
end

if dispinfo
    fprintf('VARpanel function called with the following settings:\n');
    disp(Input);
end

if isfield(Input,'Vbeta_ind')
    Vbeta_ind = Input.Vbeta_ind;                  % Chosen automatically now, leave it. Set to 1 if we want to save Vbeta (large matrix, used for the Monte Carlo)
else
    Vbeta_ind = 0;
end
    
    %%
nrun=BURNIN+MCMC;
effsamp=(nrun-BURNIN)/thin;

Yins=Input.Yins;
standardize=Input.standardize;

if standardize==1
    standardizemeanY=mean(Yins);
    standardizesdY=std(Yins);
    %     Yins=(Yins-standardizemeanY)./standardizesdY;
    Yins_dem = bsxfun(@minus,Yins,standardizemeanY); % the above line does not work on Matlab 2015a :)
    Yins    = bsxfun(@rdivide,Yins_dem,standardizesdY);
else
    standardizesdY=1;
    standardizemeanY=0;
end



Y0 = Yins(1:P,:);  % save the first 4 obs as the initial conditions, may chanqe the P to 4
Y = Yins(P+1:end,:);

[n,q] = size(Y);

if q~=N*G
    error('N or G is wrong')
end

K = q*P; %+1 if we use intercepts   %




%y=reshape(Y',[],1);
y=Y(:);
Ylagtilde=zeros(n*N*G,P*G*G*N);
countG=0;
%countN=0;
for nn=1:N
    tmpY2 = [Y0(end-P+1:end,1+(nn-1)*G:G+(nn-1)*G); Y(:,1+(nn-1)*G:G+(nn-1)*G)];
    X_tilde2 = zeros(n,G*P);
    for i=1:P
        X_tilde2(:,(i-1)*G+1:i*G) = tmpY2(P-i+1:end-i,:);
    end
    for gg=1:G
        Ylagtilde(1+countG*n+(nn-1)*n:n+(nn-1)*n+countG*n,1+(nn-1)*G*P+countG*G*P:G*P+(nn-1)*G*P+countG*G*P)=X_tilde2;
        countG=countG+1;
    end
    countG=countG-1;
end

Ylagtilde=sparse(Ylagtilde);
%betaAR=zeros(G^2*P*N,1);


%prior

if minesotaadaptive==1 || Input.MinesotaGL==1
    c3=10;
    [V_Minnconstruction,V_Minnlaq] =priorconstruction(P,G,c3);
    % set V_minnlag= ones we do not have minesota anymore
    V_Minnlaq( V_Minnconstruction==3)=[];%remove constant
    V_Minnconstruction( V_Minnconstruction==3)=[];
    Vbeta=repmat(V_Minnlaq,N,1);
    iVbeta = sparse(1:P*G^2*N,1:P*G^2*N,1./ Vbeta);
    Vbeta=repmat(V_Minnlaq,1,N);
else
    tmP = ones(K*G,1)*1/1000;  tmP(1:P*G+1:K*G) = 1/1000;
    iVbeta = sparse(1:K*G,1:K*G,tmP);
end

%inverse Wishart prior for SIGMA
S0=0.001;
nu0=0.001;


%%% for homogeneity between countries:C-S restrictions


n_CS = N*(N-1)/2;    % Number of C-S restrictions
if N>1
    pairs_index = nchoosek(1:N,2);   % Index of pairs
end


%%%% MCMC initial values  %%%%%

% imortant to let start some lamdas at one
LambdaARlocal=ones(G^2*P,N);
LambdaARC1=.1*ones(N,1);
LambdaARC2=.1*ones(N,1);
LiDL = sparse(eye(q*n));
LambdaCS=ones(n_CS,1);
LambdaCS_global=1;
LambdaCS_local=ones(G^2*P,n_CS);%G*G*P*n_CS
BetaAR=zeros(N*G,N*G*P);
yforsave=zeros(hor,q);
%%%%%%%% MCMC helper %%%%%%%%%%%
Sig=zeros(G*N,G*N);
seq=[];
for gg=1:G
    first=1+(gg-1)*G*P;
    second=G+(gg-1)*G*P;
    seq=  [seq,first:second];
end
%%%%%%%% MCMC storage %%%%%%%%%

AR_store=zeros(q,K,effsamp);
betaAR_store=zeros(effsamp,G^2*P*N,1);
% if Vbeta_ind == 1
%     Vbeta_store= zeros(K*G,K*G,effsamp);
% end
LambdaARC1_store=zeros(effsamp,N);
LambdaARC2_store=zeros(effsamp,N);
LambdaCS_store=(zeros(n_CS,effsamp));
LambdaCS_global_store=zeros(effsamp,1);
LambdaCS_local_store=zeros(G^2*P,n_CS,effsamp);
yfor_store=zeros(hor,q,effsamp);
if MinesotaGL==1 &&minesotafix==1
  LambdaARlocal_store=zeros(P*G^2,N,effsamp);
end
%% Start MCMC %%
if CS_local==1||CS_country==1||CS_global==1||minesotaadaptive==1
    for i=1:nrun
        
        if mod(i,dispsim) == 0%
            disp([num2str(i) ' Simulations'])
        end
        
        
        
        %%%% sample varcoefs %%%
        
        %     check=0;
        %     count=0;
        %     while check==0
       % if Rue==1
       try
            %count=count+1;
            XLiDL = Ylagtilde'*LiDL;%;%*LiDL
            Kbeta =iVbeta+ XLiDL*Ylagtilde;%+iVbeta
            
            
            %%% Use alqo from Rue (2001) %%%
            
            beta_hattilde = Kbeta\( XLiDL*(y));% numerical unstable sometimes
            
            %     beta_hattilde = conjgrad(Kbeta,( XLiDL*(y)));%this function is
            %     very unstable !!!
            
            Kbeta=(Kbeta'+Kbeta)/2;
            
            
            
            %       check=0;
            %          while check==0
            %         try
            
            Kbetachol=chol(Kbeta,'lower');
            
            %        check=1;
            %         catch
            %        Kbeta=nearestSPD(full(Kbeta));
            %        Kbeta=sparse(  Kbeta);
            %        check=0;
            %         end
            %          end
            betaAR =  beta_hattilde + Kbetachol'\randn(K*G,1);
            
            
       catch
        %else %Scalable Approximate MCMC Algorithms
            %  for the Horseshoe Prior
            
            XLiDL = Ylagtilde'*LiDL;
            %ytilde= LiDL*y;
            B0=inv(iVbeta);
            v= mvnrnd(zeros(K*G,1),B0,1)';
            w=XLiDL'*v+randn(n*q,1);
            ind=diag(B0)>delta_algo;
            B1=(eye(n*q)+ XLiDL(ind,:)'*B0(ind,ind)*XLiDL(ind,:));
            uu=B1\(LiDL*y-w);
            betaAR=B0(:,ind)*  XLiDL(ind,:)*uu+v;
            
        end
        
        
        
        %ytilde= Ylagtilde* betaAR;
        % plot(betaARreshape)
        betaARreshape=reshape( betaAR,P*G^2,N);
        for nn=1:N
            for pp=1:P
                BetaAR(1+(nn-1)*G:G+(nn-1)*G,1+(nn-1)*G+(pp-1)*G*N:G+(nn-1)*G+(pp-1)*G*N)=  reshape(betaAR(seq+G*(pp-1)+(nn-1)* G*G*P,1),G,G)';
            end
        end
        
        %
        %     F=zeros(q*P,q*P);
        % F(1:q*(P-1),q+1:q*P)=eye(q*(P-1),q*(P-1));
        % F(1:q*P,1:q)=BetaAR';
        % explosiv=(max(abs(eig(F))))%>=1.0000;
        %
        % if explosiv==0
        %    check=1;
        % end
        %   end
        %BetaAR*xtp' ,xtp' is a column vector
        %% Update hyperparameter %%
        
        
        %%% minesotaprior
        
        
        if minesotaadaptive==1
            for nn=startminesota:N%2:N do not use minesota for country 1
                if Minesota_cplus==1
                    xiLambdaARC1=1/gamrnd(1,1/(1+1/LambdaARC1(nn,1)),1);%1/A^2
                    LambdaARC1(nn,1)=1/gamrnd((delta_minesota*P*G+1)/2,1/(1/xiLambdaARC1+delta_minesota*0.5*sum( ( betaARreshape(V_Minnconstruction==1,nn).^2)./(LambdaARlocal(V_Minnconstruction==1,nn).*V_Minnlaq(V_Minnconstruction==1) ))),1);
                    
                    xiLambdaARC2=1/gamrnd(1,1/(1+1/LambdaARC2(nn,1)),1);%1/A^2
                    LambdaARC2(nn,1)=1/gamrnd(( delta_minesota*sum(V_Minnconstruction==2)+1)/2,1/(1/xiLambdaARC2+delta_minesota*0.5*sum( ( betaARreshape(V_Minnconstruction==2,nn).^2)./(LambdaARlocal(V_Minnconstruction==2,nn).*V_Minnlaq(V_Minnconstruction==2))  )),1);
                else
                    LambdaARC1(nn,1)=1/gamrnd((delta_minesota*P*G)/2+Minesota_shape,1/(Minesota_scale+delta_minesota*0.5*sum( ( betaARreshape(V_Minnconstruction==1,nn).^2)./(LambdaARlocal(V_Minnconstruction==1,nn).*V_Minnlaq(V_Minnconstruction==1) ))),1);
                    LambdaARC2(nn,1)=1/gamrnd(( delta_minesota*sum(V_Minnconstruction==2))/2+Minesota_shape,1/(Minesota_scale+delta_minesota*0.5*sum( ( betaARreshape(V_Minnconstruction==2,nn).^2)./(LambdaARlocal(V_Minnconstruction==2,nn).*V_Minnlaq(V_Minnconstruction==2))  )),1);
                end
                LambdaARC1(nn,1)=LambdaARC1(nn,1)*(1/delta_minesota)+1e-4;
                LambdaARC2(nn,1)=LambdaARC2(nn,1)*(1/delta_minesota)+1e-4;
            end
            if G>7
                 LambdaARC1(LambdaARC1>0.05)=0.05;
                 LambdaARC2(LambdaARC2>0.001)=0.001;

            end
        end
        if MinesotaGL==1
            for nn=startminesota:N%2:N do not use minesota for country 1
                for k=1:P*G^2
                    if V_Minnconstruction(k)==1
                        if Minesota_cplus==1
                            xiLambdaARlocal=1/gamrnd(1,1/(1+1/LambdaARlocal(k,nn)),1);%1/A^2
                            LambdaARlocal(k,nn)= 1/gamrnd(0.5+0.5*delta_minesota,1/(1/xiLambdaARlocal+delta_minesota*0.5* (betaARreshape(k,nn)^2)/(LambdaARC1(nn,1) *V_Minnlaq(k))),1);
                        else
                            LambdaARlocal(k,nn)= 1/gamrnd(Minesota_shape+delta_minesota*0.5,1/(Minesota_scale+delta_minesota*0.5* (betaARreshape(k,nn)^2)/(LambdaARC1(nn,1) *V_Minnlaq(k))),1);
                        end
                    elseif  V_Minnconstruction(k)==2
                        if Minesota_cplus==1
                            xiLambdaARlocal=1/gamrnd(1,1/(1+1/LambdaARlocal(k,nn)),1);%1/A^2
                            LambdaARlocal(k,nn)= 1/gamrnd(0.5+0.5*delta_minesota,1/(1/xiLambdaARlocal+delta_minesota*0.5*(betaARreshape(k,nn)^2)/(LambdaARC2(nn,1) *V_Minnlaq(k))),1);
                        else
                            LambdaARlocal(k,nn)= 1/gamrnd(Minesota_shape+delta_minesota*0.5,1/(Minesota_scale+delta_minesota*0.5*( betaARreshape(k,nn)^2)/(LambdaARC2(nn,1) *V_Minnlaq(k))),1);
                        end
                    end
                end
            end
            LambdaARlocal=LambdaARlocal*(1/delta_minesota)+1e-10;
        end
        
        
       if minesotaadaptive==0 &&   MinesotaGL==0
%             iVbeta=zeros(K*G,K*G);
        else
            for nn=1:N
                Vbeta(V_Minnconstruction==1,nn)=V_Minnlaq(V_Minnconstruction==1).*LambdaARlocal(V_Minnconstruction==1,nn)*LambdaARC1(nn,1);
                Vbeta(V_Minnconstruction==2,nn)=V_Minnlaq(V_Minnconstruction==2).*LambdaARlocal(V_Minnconstruction==2,nn)*LambdaARC2(nn,1);
            end
            iVbeta = sparse(1:K*G,1:K*G,1./ Vbeta(:));%diag(1./Vbeta(:))
        end
        
        
        
        %%% Cross sectional heterogeneities
        
        if CS_global==1
            if CS_cplus==1
                xiLambdaCS=1/gamrnd(1,1/(1+1/LambdaCS_global),1);%1/A^2
                LambdaCS_global=1/gamrnd((n_CS*P*G^2+1)/2,1/(1/xiLambdaCS+0.5*sum(sum( (( betaARreshape(:,pairs_index(1:n_CS,1))-betaARreshape(:,pairs_index(1:n_CS,2))).^2)./(LambdaCS'.*LambdaCS_local))) ),1);
            else
                LambdaCS_global=1/gamrnd((n_CS*P*G^2)/2+CS_shape,1/(CS_scale+0.5*sum( sum((( betaARreshape(:,pairs_index(1:n_CS,1))-betaARreshape(:,pairs_index(1:n_CS,2))).^2)./(LambdaCS'.*LambdaCS_local))) ),1);
            end
            LambdaCS_global= LambdaCS_global.*(1/delta)+1e-5;%(N-1)*
            
        end
        
        %   -0.5*G*G*P*log(LambdaCS(kk,1))- 1/LambdaCS(kk,1) *0.5*sum( (( betaARreshape(:,pairs_index(kk,1))- betaARreshape(:,pairs_index(kk,2))).^2))
        %     sig=0.01;
        %       -0.5*G*G*P*log(sig)- 1/sig *0.5*sum( (( betaARreshape(:,pairs_index(kk,1))- betaARreshape(:,pairs_index(kk,2))).^2))
        
        
        %sum( (( betaARreshape(:,pairs_index(kk,1))- betaARreshape(:,pairs_index(kk,2))).^2))/((G^2*P)/2-1)
        if CS_country==1
            for kk=1:n_CS % you can choose here which pair you want to shrink use N instead of n_CS for shrinking only on country!
                if CS_cplus==1
                    xiLambdaCS=1/gamrnd(1,1/(1+1/LambdaCS(kk,1)),1);%1/A^2
                    LambdaCS(kk,1)=1/gamrnd((delta*G^2*P+1)/2,1/(1/xiLambdaCS+delta*0.5*sum( (( betaARreshape(:,pairs_index(kk,1))- betaARreshape(:,pairs_index(kk,2))).^2)./(LambdaCS_local(:,kk)*LambdaCS_global)) ),1);
                else
                    LambdaCS(kk,1)=1/gamrnd(delta*(G^2*P)/2+CS_shape,1/(CS_scale+delta*0.5*sum( ((  betaARreshape(:,pairs_index(kk,1))- betaARreshape(:,pairs_index(kk,2))).^2)./(LambdaCS_local(:,kk)*LambdaCS_global) )),1);
                end
                LambdaCS(kk,1)=LambdaCS(kk,1)+1e-5;% ((N-1))*
                LambdaCS(kk,1)= 1./(1./(LambdaCS(kk,1))+1);
                
            end
            LambdaCS=LambdaCS.*(1/delta);
        end
        
        
        if CS_local==1
            for kk=1:n_CS %use N instead to shrink only to the first country
                for gp=1:G*G*P
                    if CS_cplus==1 %
                        xiLambdaCS=1/gamrnd(1,1/(1+1/LambdaCS_local(gp,kk)),1);%1/A^2
                        LambdaCS_local(gp,kk)=1/gamrnd(1/2+0.5*delta,1/(1/xiLambdaCS+delta*0.5*( (( betaARreshape(gp,pairs_index(kk,1))-betaARreshape(gp,pairs_index(kk,2))).^2)./(LambdaCS(kk,1)*LambdaCS_global)) ),1);
                    else
                        LambdaCS_local(gp,kk)=1/gamrnd(1/2*delta+CS_shape,1/(CS_shape+0.5*( (( betaARreshape(gp,pairs_index(kk,1))-betaARreshape(gp,pairs_index(kk,2))).^2)./(LambdaCS(kk,1)*LambdaCS_global)) ),1);
                    end
                    LambdaCS_local(gp,kk)= LambdaCS_local(gp,kk)*(1/delta)+1e-5;%((N-1))*
                    % LambdaCS_local(gp,kk)= 1./(1./(LambdaCS_local(gp,kk))+1e-10);
                    
                end
            end
            
        end
        
        
        
        
        %% Update Sigma %%
        
        
        M=reshape(Ylagtilde* betaAR,n,q);
        U=Y-M;
        u=U'*U;
        for NN=1:N
            Sig(1+(NN-1)*G:G+(NN-1)*G,1+(NN-1)*G:G+(NN-1)*G)= nearestSPD(iwishrnd(S0 +u(1+(NN-1)*G:G+(NN-1)*G,1+(NN-1)*G:G+(NN-1)*G),nu0 + n));
        end
        
        iSig=(sparse(Sig))\speye(q);
        %iSig=diag(diag(Sig))\speye(q);
        LiDL= kron(iSig,speye(n));  %% is this correct??
        % LiDL=kron(speye(n),iSig);
        
        
        if i > BURNIN && mod(i, thin)== 0 %% save stuff
            LambdaARC1_store((i-BURNIN)/thin,:)=LambdaARC1' ;
            LambdaARC2_store((i-BURNIN)/thin,:)=LambdaARC2';
            if MinesotaGL==1&&minesotafix==1
              LambdaARlocal_store(:,:,(i-BURNIN)/thin)=LambdaARlocal;
            end
            LambdaCS_store(:,(i-BURNIN)/thin,1)=LambdaCS;
            LambdaCS_global_store((i-BURNIN)/thin,1)=LambdaCS_global;
            LambdaCS_local_store(:,:,(i-BURNIN)/thin)=  LambdaCS_local;
        end
    end
    
    %% estimate and then fix hyperparameters
    
       LambdaARC1=median(LambdaARC1_store)';
   LambdaARC2=median(LambdaARC2_store)';
if MinesotaGL==1&&minesotafix==1
   LambdaARlocal=median( LambdaARlocal_store,3);
end
    LambdaCS_comb_store=zeros(G^2*P*n_CS,MCMC);
    
    for ii=1:MCMC/thin
        LambdaCS_local=   LambdaCS_local_store(:,:,ii);
        LambdaCS=LambdaCS_store(:,ii);
        LambdaCS_global= LambdaCS_global_store(ii);
        LambdaCS_comb_store(:,ii)=LambdaCS_local(:).*cell2mat(arrayfun(@(LambdaCS)repmat(LambdaCS,G^2*P,1),LambdaCS,'uni',0))*LambdaCS_global;
    end
    
    if Input.mean==1
        
        LambdaCS_comb=mean( LambdaCS_comb_store,2);
        % elseif Input.mode==1
        %         for ii=1:G^2*P*n_CS
        %     [   f,xi] = ksdensity(LambdaCS_comb_store(ii,:),'Support','positive')
        %         [value,pos]=max(f);
        %         LambdaCS_comb(ii)=xi(pos);
        %         end
    else
        LambdaCS_comb=median( LambdaCS_comb_store,2);
    end

    LambdaCS_comb=LambdaCS_comb*shrinkpool;
    iVbeta_CS=zeros(G^2*P*N,G^2*P*N);
    for kk=1:n_CS %use N instead to shrink only to the first country
        
        range=1+(kk-1)*P*G^2:P*G^2+(kk-1)*P*G^2;
        ind_temp1=1+(pairs_index(kk,2)-1)*P*G^2:P*G^2+(pairs_index(kk,2)-1)*P*G^2;
        ind_temp2=1+(pairs_index(kk,1)-1)*P*G^2:P*G^2+(pairs_index(kk,1)-1)*P*G^2;
        
        iVbeta_CS(  ind_temp1,ind_temp1) =diag(diag(iVbeta_CS(  ind_temp1 , ind_temp1))+ 1./ LambdaCS_comb(  range));
        iVbeta_CS(   ind_temp2, ind_temp2) =diag(diag(iVbeta_CS(   ind_temp2 ,  ind_temp2))+ 1./ LambdaCS_comb(  range));
        iVbeta_CS(ind_temp2,ind_temp1)   =diag(-1./ LambdaCS_comb(  range));
        iVbeta_CS(ind_temp1,ind_temp2)   =diag(-1./ LambdaCS_comb(  range));
        
    end
    iVbeta_CS = sparse(iVbeta_CS);



        if minesotaadaptive==0 &&   MinesotaGL==0
            iVbeta=zeros(K*G,K*G);
        else
            for nn=startminesota:N
                Vbeta(V_Minnconstruction==1,nn)=V_Minnlaq(V_Minnconstruction==1).*LambdaARlocal(V_Minnconstruction==1,nn)*LambdaARC1(nn,1);
                Vbeta(V_Minnconstruction==2,nn)=V_Minnlaq(V_Minnconstruction==2).*LambdaARlocal(V_Minnconstruction==2,nn)*LambdaARC2(nn,1);
            end
            iVbeta = sparse(1:K*G,1:K*G,1./ Vbeta(:));%diag(1./Vbeta(:))
        end
           if CS_local==1||CS_country==1||CS_global==1
         iVbeta= iVbeta_CS+ iVbeta;
           end      
            
    
end
%% Start MCMC %%

for i=1:nrun
    
    if mod(i,dispsim) == 0%
        disp([num2str(i) ' Simulations'])
    end
    
    
    
    %%%% sample varcoefs %%%
    
    %     check=0;
    %     count=0;
    %     while check==0
    %if Rue==1
        try
        %count=count+1;
        XLiDL = Ylagtilde'*LiDL;%;%*LiDL
        Kbeta =iVbeta+ XLiDL*Ylagtilde;%+iVbeta
        
        
        %%% Use alqo from Rue (2001) %%%
        
        beta_hattilde = Kbeta\( XLiDL*(y));% numerical unstable sometimes
        
        %     beta_hattilde = conjgrad(Kbeta,( XLiDL*(y)));%this function is
        %     very unstable !!!
        
        Kbeta=(Kbeta'+Kbeta)/2;
        
        
        
        %       check=0;
        %          while check==0
        %         try
        
        Kbetachol=chol(Kbeta,'lower');
        
        %        check=1;
        %         catch
        %        Kbeta=nearestSPD(full(Kbeta));
        %        Kbeta=sparse(  Kbeta);
        %        check=0;
        %         end
        %          end
        betaAR =  beta_hattilde + Kbetachol'\randn(K*G,1);
        
        
        catch
    %else %Scalable Approximate MCMC Algorithms
        %  for the Horseshoe Prior
        
        XLiDL = Ylagtilde'*LiDL;
        %ytilde= LiDL*y;
        B0=inv(iVbeta);
        v= mvnrnd(zeros(K*G,1),B0,1)';
        w=XLiDL'*v+randn(n*q,1);
        ind=diag(B0)>delta_algo;
        B1=(eye(n*q)+ XLiDL(ind,:)'*B0(ind,ind)*XLiDL(ind,:));
        uu=B1\(LiDL*y-w);
        betaAR=B0(:,ind)*  XLiDL(ind,:)*uu+v;
        
        end
    
    
    
    %ytilde= Ylagtilde* betaAR;
    % plot(betaARreshape)
    betaARreshape=reshape( betaAR,P*G^2,N);
    for nn=1:N
        for pp=1:P
            BetaAR(1+(nn-1)*G:G+(nn-1)*G,1+(nn-1)*G+(pp-1)*G*N:G+(nn-1)*G+(pp-1)*G*N)=  reshape(betaAR(seq+G*(pp-1)+(nn-1)* G*G*P,1),G,G)';
        end
    end
    
    %
    %     F=zeros(q*P,q*P);
    % F(1:q*(P-1),q+1:q*P)=eye(q*(P-1),q*(P-1));
    % F(1:q*P,1:q)=BetaAR';
    % explosiv=(max(abs(eig(F))))%>=1.0000;
    %
    % if explosiv==0
    %    check=1;
    % end
    %   end
    %BetaAR*xtp' ,xtp' is a column vector
    %% Update hyperparameter %%
    
    
    %%% minesotaprior
    
            if minesotafix==0 % take the empirical bayes estimates if =1

    if minesotaadaptive==1
        for nn=startminesota:N%2:N do not use minesota for country 1
            if Minesota_cplus==1
                xiLambdaARC1=1/gamrnd(1,1/(1+1/LambdaARC1(nn,1)),1);%1/A^2
                LambdaARC1(nn,1)=1/gamrnd((delta_minesota*P*G+1)/2,1/(1/xiLambdaARC1+delta_minesota*0.5*sum( ( betaARreshape(V_Minnconstruction==1,nn).^2)./(LambdaARlocal(V_Minnconstruction==1,nn).*V_Minnlaq(V_Minnconstruction==1) ))),1);
                
                xiLambdaARC2=1/gamrnd(1,1/(1+1/LambdaARC2(nn,1)),1);%1/A^2
                LambdaARC2(nn,1)=1/gamrnd(( delta_minesota*sum(V_Minnconstruction==2)+1)/2,1/(1/xiLambdaARC2+delta_minesota*0.5*sum( ( betaARreshape(V_Minnconstruction==2,nn).^2)./(LambdaARlocal(V_Minnconstruction==2,nn).*V_Minnlaq(V_Minnconstruction==2))  )),1);
            else
                LambdaARC1(nn,1)=1/gamrnd((delta_minesota*P*G)/2+Minesota_shape,1/(Minesota_scale+delta_minesota*0.5*sum( ( betaARreshape(V_Minnconstruction==1,nn).^2)./(LambdaARlocal(V_Minnconstruction==1,nn).*V_Minnlaq(V_Minnconstruction==1) ))),1);
                LambdaARC2(nn,1)=1/gamrnd(( delta_minesota*sum(V_Minnconstruction==2))/2+Minesota_shape,1/(Minesota_scale+delta_minesota*0.5*sum( ( betaARreshape(V_Minnconstruction==2,nn).^2)./(LambdaARlocal(V_Minnconstruction==2,nn).*V_Minnlaq(V_Minnconstruction==2))  )),1);
            end
            LambdaARC1(nn,1)=LambdaARC1(nn,1)*(1/delta_minesota)+1e-4;
            LambdaARC2(nn,1)=LambdaARC2(nn,1)*(1/delta_minesota)+1e-4;
        end
    end
    if MinesotaGL==1
        for nn=startminesota:N%2:N do not use minesota for country 1
            for k=1:P*G^2
                if V_Minnconstruction(k)==1
                    if Minesota_cplus==1
                        xiLambdaARlocal=1/gamrnd(1,1/(1+1/LambdaARlocal(k,nn)),1);%1/A^2
                        LambdaARlocal(k,nn)= 1/gamrnd(0.5+0.5*delta_minesota,1/(1/xiLambdaARlocal+delta_minesota*0.5* (betaARreshape(k,nn)^2)/(LambdaARC1(nn,1) *V_Minnlaq(k))),1);
                    else
                        LambdaARlocal(k,nn)= 1/gamrnd(Minesota_shape+delta_minesota*0.5,1/(Minesota_scale+delta_minesota*0.5* (betaARreshape(k,nn)^2)/(LambdaARC1(nn,1) *V_Minnlaq(k))),1);
                    end
                elseif  V_Minnconstruction(k)==2
                    if Minesota_cplus==1
                        xiLambdaARlocal=1/gamrnd(1,1/(1+1/LambdaARlocal(k,nn)),1);%1/A^2
                        LambdaARlocal(k,nn)= 1/gamrnd(0.5+0.5*delta_minesota,1/(1/xiLambdaARlocal+delta_minesota*0.5*(betaARreshape(k,nn)^2)/(LambdaARC2(nn,1) *V_Minnlaq(k))),1);
                    else
                        LambdaARlocal(k,nn)= 1/gamrnd(Minesota_shape+delta_minesota*0.5,1/(Minesota_scale+delta_minesota*0.5*( betaARreshape(k,nn)^2)/(LambdaARC2(nn,1) *V_Minnlaq(k))),1);
                    end
                end
            end
        end
        LambdaARlocal=LambdaARlocal*(1/delta_minesota)+1e-10;
    end
    
    
    if minesotaadaptive==0 &&   MinesotaGL==0
        iVbeta=sparse(zeros(K*G,K*G));
    else
        for nn=1:N
            Vbeta(V_Minnconstruction==1,nn)=V_Minnlaq(V_Minnconstruction==1).*LambdaARlocal(V_Minnconstruction==1,nn)*LambdaARC1(nn,1);
            Vbeta(V_Minnconstruction==2,nn)=V_Minnlaq(V_Minnconstruction==2).*LambdaARlocal(V_Minnconstruction==2,nn)*LambdaARC2(nn,1);
        end
        iVbeta = sparse(1:K*G,1:K*G,1./ Vbeta(:));%diag(1./Vbeta(:))
    end
    
    if CS_local==1||CS_country==1||CS_global==1
        
        iVbeta= iVbeta_CS+ iVbeta;
    end
    
    
            end
    
    %% Update Sigma %%
    
    
    M=reshape(Ylagtilde* betaAR,n,q);
    U=Y-M;
    u=U'*U;
    for NN=1:N
        Sig(1+(NN-1)*G:G+(NN-1)*G,1+(NN-1)*G:G+(NN-1)*G)= nearestSPD(iwishrnd(S0 +u(1+(NN-1)*G:G+(NN-1)*G,1+(NN-1)*G:G+(NN-1)*G),nu0 + n));
    end
    
    iSig=(sparse(Sig))\speye(q);
    %iSig=diag(diag(Sig))\speye(q);
    LiDL= kron(iSig,speye(n));  %% is this correct??
    % LiDL=kron(speye(n),iSig);
    
    
    if i > BURNIN && mod(i, thin)== 0 %% save stuff
        
        
        %%% do forcasts here
        if hor>0
            %Cov=(full(LiDL(end-q+1:end,end-q+1:end)))\speye(q);
            cholcov=chol(Sig,'lower');
            xtp =  reshape(Y(end:-1:end-P+1,:)',1,q*P);
            %xfor=Xins(end,:);
            for tt =1:hor
                yfor=xtp*BetaAR';
                yforsim=yfor+(cholcov*randn(q,1))';
                yforsimstandardize=yforsim.*standardizesdY+ standardizemeanY;
                %xfor=xfor+yforsimstandardize;
                xtp = [ yforsim xtp(1:end-q)];
                yforsave(tt,:)=yforsimstandardize;
                % Xforsave(tt,:)=xfor;
            end
            yfor_store(:,:,(i-BURNIN)/thin)=yforsave;
        end
%         if Vbeta_ind
%             Vbeta_store(:,:,(i-BURNIN)/thin) = iVbeta^-1;
%         end
        AR_store(:,:,(i-BURNIN)/thin) = BetaAR;
        betaAR_store((i-BURNIN)/thin,:,1)=betaAR;
     %   LambdaARC1_store((i-BURNIN)/thin,:)=LambdaARC1' ;
      %  LambdaARC2_store((i-BURNIN)/thin,:)=LambdaARC2';
        
    end
    
end



yfor_median = median(yfor_store,3);
yfor_mean=mean(yfor_store,3);

Output.yfor_median  = yfor_median;
Output.yfor_mean    = yfor_mean;
Output.yfor_draws   = yfor_store;
% if Vbeta_ind
%     Output.Vbeta_store   = diag(mean(Vbeta_store,3));
% end
Output.AR_store     = mean( AR_store,3);
AR_store_NAN=AR_store;
 AR_store_NAN(AR_store_NAN==0) = NaN;
Output.AR_sd     = std( AR_store_NAN ,0,3,'omitnan');


Output.betaAR_store   = mean(betaAR_store)';
Output.betaAR_prctiles = prctile(betaAR_store,[0.025, 0.16, 0.84, 0.975]*100,1)';
if CS_local==1||CS_country==1||CS_global==1
Output.LambdaCS_local = squeeze(mean(LambdaCS_local_store,3));
Output.LambdaCS     = mean(LambdaCS_store,2);
Output.LambdaCSM     = median(LambdaCS_store,2);
Output.LambdaCS_comb=LambdaCS_comb;
end

Output.yfor_errorbands=zeros(5,hor,q);
for i=1:q
    for tt=1:hor
        Output.yfor_errorbands(:,tt,i)=prctile(Output.yfor_draws(tt,i,:),[5 16 50 84 95])';
    end
end























%
