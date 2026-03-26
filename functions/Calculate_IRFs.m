%% Cacluate IRFs


    %% load in data%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % choices data: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    countries       ={ 'DE', 'FR','IT','ES','NL','BE','AT','PT','GR','FI'};%{ 'DE', 'FR','GR'};%,,'ES','IT','NL','BE','AT','PT','FI'}; %{'DE', 'FR','IT'};%{'FR','ES','GR'};%{'DE', 'FR','IT','ES','NL','BE','AT'}
   % countries       ={'DE','ES','GR'};%,'GR', 'FR','IT','NL','BE','AT','PT','FI'}; %
    common_vars     = {'RGDP' ,'HICP','EURIBOR'};%,%' GOVB10Yd' , 'RGDP' ,'HICP','EURIBOR' SSR
    %common_vars     = {'RGDP'};%,%' GOVB10Yd' , 'RGDP' ,'HICP','EURIBOR'
    SSRq_tab = readtable("data\SSRquarterly.xlsx",'Sheet','dataSSR');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    common_varsSSR = 'SSR';


    %% specification choices
    
        standardize=1;
        G         = size(common_vars,2);  % G variabes for each country
        N         = size(countries,2);    % N countries
        
        var_list        = cell(1,N*G);
        load Country_data_bal_select.mat
        fdata_mat=[];
        for ip = 1:N

            Country_data_balanced.(countries{ip}) =  [Country_data_balanced.(countries{ip}) array2table(SSRq_tab.SSR,'RowNames',Country_data_balanced.(countries{ip}).Properties.RowNames,'VariableNames',{'SSR'})];
            fdata_mat(:, G*(ip-1)+1:G*ip) = Country_data_balanced.(countries{ip}){:,common_vars};
            for iq = 1:G
                var_list{1,(ip-1)*(G) + iq}                = strcat(common_vars{1,iq},'_',countries{1,ip});
            end
        end
        
   
    
    
    
    
    
    %%%% model choices: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    MCMC=5000;
    BURNIN=5000;
    thin=1;
    Rue=1;% set to 1 is prefered 
    delta2=0.0; %set to small number. plays a rule if rue=0. set to zero algo is exact. set to small number algo gets faster.
    
    shockvariable=repmat([0 0 1],1,N);% be carefull you can only shock one variable for each country, length is equal to G, [0 0 1] shock third variable
    % Select=cumsum(ones(N*G,1))'.*shockvariable;
    % Select(Select==0)=[];
    % plot(fdata_mat(:, Select))
    noexplosivdraw=1;
    
    P=4;% use 1,2,3,4 laqs
    
    hor=40; %how many quarters we want to predict ahead, set to 0-> no IRFs
    
    startminesota=1;% do not change
    minesotaadaptive=hyper_minesota; %1: use standard minesota prior
    minesotafix=1;  
    MinesotaGL =0;       %if 1 use local priors for minesota prior like jochua chan
    Minesota_shape=0;
    Minesota_scale=0;
    Minesota_cplus=0; % 1: half-Cauchy otherwise use inversegamma prior IG(shape,scale)
    delta_minesota=1; % do not change

    
    %%homogeneity restirction
    %setting all to zero we have a normal VAR with minesota prior
    %setting only CS_country to one: we have prior similar to Korrobilis/Koop
    all_comb=1; % do not change
    delta = 1; % do not change
    
    CS_local   =hyper_CSlocal;
    CS_country = hyper_CScountry;
    CS_global  = 0;% do not change
    CS_shape=0;
    CS_scale=0.0000;
    CS_cplus=Minesota_cplus; % 1: half-Cauchy otherwise use inversegamma prior IG(shape,scale)
    
    rng(1) ;

      
      %% prepare stuff
    nrun=BURNIN+MCMC;
    effsamp=(nrun-BURNIN)/thin;
    
    Yins=fdata_mat;
    
    if standardize==1
        standardizemeanY=mean(Yins);
        standardizesdY=std(Yins);
        %     Yins=(Yins-standardizemeanY)./standardizesdY;
        Yins_dem = bsxfun(@minus,Yins,standardizemeanY); % the above line does not work on Matlab 2015a :)
        Yins    = bsxfun(@rdivide,Yins_dem,standardizesdY);%data= Yins
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
    
    if minesotaadaptive==1 || MinesotaGL==1
        c3=10;
        [V_Minnconstruction,V_Minnlaq] =priorconstruction(P,G,c3);
        % set V_minnlag= ones we do not have minesota anymore
        V_Minnlaq( V_Minnconstruction==3)=[];%remove constant
        V_Minnconstruction( V_Minnconstruction==3)=[];
        Vbeta=repmat(V_Minnlaq,N,1);
        iVbeta = sparse(1:P*G^2*N,1:P*G^2*N,1./ Vbeta);
        Vbeta=repmat(V_Minnlaq,1,N)*100000000000;
    else
        tmP = ones(K*G,1)*1/1000;  tmP(1:P*G+1:K*G) = 1/1000;
        iVbeta = sparse(1:K*G,1:K*G,tmP);
    end
    
    %inverse Wishart prior for SIGMA
    S0=0.001;
    nu0=0.001;
    
    
    %%% for homogeneity between countries:C-S restrictions
    
    if all_comb==1
    n_CS = N*(N-1)/2;    % Number of C-S restrictions
    else
    n_CS =N-1;
    end
    if N>1
        pairs_index = combntns(1:N,2);   % Index of pairs
    end
    

    %scalingfactor=ones(n_CS,1)*(N-1);
    
    %%%% MCMC initial values  %%%%%


    % imortant to let start some lamdas at one
    LambdaARlocal=ones(G^2*P,N);
    LambdaARC1=1*ones(N,1);
    LambdaARC2=1*ones(N,1);
    LiDL = sparse(eye(q*n));
    LambdaCS=ones(n_CS,1);
    %LambdaCS=    [0.144  0.3235   0.1597]';
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
     storeSIG=NaN(effsamp,N*G*G);
    AR_store=zeros(q,K,effsamp);
    betaAR_store=zeros(effsamp,G^2*P*N,1);
    LambdaARC1_store=zeros(effsamp,N);
    LambdaARC2_store=zeros(effsamp,N);
    LambdaCS_store=(zeros(n_CS,effsamp));
    LambdaCS_global_store=zeros(effsamp,1);
    LambdaCS_local_store=zeros(G^2*P,n_CS,effsamp);
    yirf_store=zeros(hor,effsamp,q);
    D_theta_nopooling=zeros(effsamp,N);
    sum_utilde=0;
    sum_Sgima=0;
    D_theta_joint_nopooling=zeros(effsamp,1);
    %% Start MCMC %%
    
    for i=1:nrun
        
        if mod(i,1000) == 0%
            disp([num2str(i) ' Simulations'])
        end
        
        
        
        %%%% sample varcoefs %%%
        
        check=0;
        count=0;
        while check==0
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
                
                
                
           % else %Scalable Approximate MCMC Algorithms
           catch
                %  for the Horseshoe Prior
                
                XLiDL = Ylagtilde'*LiDL;
                %ytilde= LiDL*y;
                B0=inv(iVbeta);
                v= mvnrnd(zeros(K*G,1),B0,1)';
                w=XLiDL'*v+randn(n*q,1);
                ind=diag(B0)>delta2;
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
            
            
            F=zeros(q*P,q*P);
            F(1:q*(P-1),q+1:q*P)=eye(q*(P-1),q*(P-1));
            F(1:q*P,1:q)=BetaAR';
            explosiv=(max(abs(eig(F))))>=1.0000;
            
            if explosiv==0 || noexplosivdraw==0|| i<100
                check=1;
            end
        end
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
            iVbeta=zeros(K*G,K*G);
        else
            for nn=startminesota:N
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
               LambdaCS(kk,1)=LambdaCS(kk,1).*(1/delta);           
            end
           
        end
        
        
        if CS_local==1
            for kk=1:n_CS %use N instead to shrink only to the first country
                for gp=1:G*G*P
                    if CS_cplus==1 %
                        xiLambdaCS=1/gamrnd(1,1/(1+1/LambdaCS_local(gp,kk)),1);%1/A^2
                        LambdaCS_local(gp,kk)=1/gamrnd(1/2+0.5*delta,1/(1/xiLambdaCS+delta*0.5*( (( betaARreshape(gp,pairs_index(kk,1))-betaARreshape(gp,pairs_index(kk,2))).^2)./(LambdaCS(kk,1)*LambdaCS_global)) ),1);
                    else
                        LambdaCS_local(gp,kk)=1/gamrnd(1/2*delta+CS_shape,1/(CS_shape+delta*0.5*( (( betaARreshape(gp,pairs_index(kk,1))-betaARreshape(gp,pairs_index(kk,2))).^2)./(LambdaCS(kk,1)*LambdaCS_global)) ),1);
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
            Sig(1+(NN-1)*G:G+(NN-1)*G,1+(NN-1)*G:G+(NN-1)*G)= iwishrnd(S0 +u(1+(NN-1)*G:G+(NN-1)*G,1+(NN-1)*G:G+(NN-1)*G),nu0 + n);
        end
        
        iSig=(sparse(Sig))\speye(q);
        %iSig=diag(diag(Sig))\speye(q);
        LiDL= kron(iSig,speye(n));  %% is this correct??
        % LiDL=kron(speye(n),iSig);







        
        
        if i > BURNIN && mod(i, thin)== 0 %% save stuff
            
                   LambdaARC1_store((i-BURNIN)/thin,:)=LambdaARC1' ;
            LambdaARC2_store((i-BURNIN)/thin,:)=LambdaARC2';
            %%% calculate IRFs here
%             if hor>0
%                 
%                 Sigmachol=chol(Sig);
%                 v=zeros(hor+P,q);
%                 v(P+1,:)=shockvariable;
%                 yirf=zeros(hor+P,q);
%                 xtp =  zeros(1,q*P);
%                 for iii=1+P:hor+P %works only for P>0
%                     yirf(iii,:)=xtp*BetaAR'+v(iii,:)*Sigmachol;
%                     xtp =  [ yirf(iii,:) xtp(1:end-q)];
%                 end
%                 
%                 yirf_store(:,(i-BURNIN)/thin,:)=  yirf(P+1:end,:).*standardizesdY;
%             end

            LambdaCS_store(:,(i-BURNIN)/thin,1)=LambdaCS;
            LambdaCS_global_store((i-BURNIN)/thin,1)=LambdaCS_global;
            LambdaCS_local_store(:,:,(i-BURNIN)/thin)=  LambdaCS_local;

                    utilde=U(:);

        for NN=1:N
            error2=-.5*utilde(1+(NN-1)*n*G:n*(G+G*(NN-1)))'*LiDL(1+(NN-1)*n*G:n*(G+G*(NN-1)),1+(NN-1)*n*G:n*(G+G*(NN-1)))*utilde(1+(NN-1)*n*G:n*(G+G*(NN-1)));
           ldet =-0.5*n*log(det(Sig(1+G*(NN-1):G+G*(NN-1),1+G*(NN-1):G+G*(NN-1))));
          D_theta_nopooling((i-BURNIN)/thin,NN)  =  -n*G*.5*log(2*pi)+ldet +error2 ;
        end

          error2=-.5*utilde'*LiDL*utilde;
           ldet =-0.5*n*log(det(Sig));
          D_theta_joint_nopooling((i-BURNIN)/thin,1)  =  -n*G*N*.5*log(2*pi)+ldet +error2 ;

        sum_utilde=sum_utilde+utilde;
             sum_Sgima=sum_Sgima+Sig;
        end
    end
   LambdaARC1=median(LambdaARC1_store)';
   LambdaARC2=median(LambdaARC2_store)';

 Sigma=   sum_Sgima/effsamp;
 utilde=sum_utilde/effsamp;

        iSig=(sparse( Sigma))\speye(q);
        LiDL= kron(iSig,speye(n)); 
        D_theta_bar_noppoling=NaN(1,N); 
        for NN=1:N
            error2=-.5*utilde(1+(NN-1)*n*G:n*(G+G*(NN-1)))'*LiDL(1+(NN-1)*n*G:n*(G+G*(NN-1)),1+(NN-1)*n*G:n*(G+G*(NN-1)))*utilde(1+(NN-1)*n*G:n*(G+G*(NN-1)));
           ldet =-0.5*n*log(det(Sig(1+G*(NN-1):G+G*(NN-1),1+G*(NN-1):G+G*(NN-1))));
       D_theta_bar_noppoling(1,NN)  =  -n*G*.5*log(2*pi)+ldet +error2 ;
        end


DIC_nopooling = -4*mean(D_theta_nopooling) + 2*D_theta_bar_noppoling;

   error2=-.5*utilde'*LiDL*utilde;
           ldet =-0.5*n*log(det(Sig));
       D_theta_bar_joint_noppoling  =  -n*G*N*.5*log(2*pi)+ldet +error2 ;
DICjoint_nopooling = -4*mean(D_theta_joint_nopooling(:,end)) + 2*D_theta_bar_joint_noppoling;


    LambdaCS_comb_store=zeros(G^2*P*n_CS,MCMC);
        Lambda_shrinkweigth_store=zeros(G^2*P*n_CS,MCMC);

     
   for ii=1:MCMC
    LambdaCS_local=   LambdaCS_local_store(:,:,ii);
    LambdaCS=LambdaCS_store(:,ii);
   LambdaCS_global= LambdaCS_global_store(ii);
    LambdaCS_comb_store(:,ii)=LambdaCS_local(:).*cell2mat(arrayfun(@(LambdaCS)repmat(LambdaCS,G^2*P,1),LambdaCS,'uni',0))*LambdaCS_global;      
     Lambda_shrinkweigth_store(:,ii)=1./(1+ LambdaCS_comb_store(:,ii));
   end
  % LambdaCS_comb=mean( LambdaCS_comb_store,2);
   LambdaCS_comb=median( LambdaCS_comb_store,2);
   %median( Lambda_shrinkweigth_store,2)
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
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
       %% Start MCMC %%
        D_theta=zeros(effsamp,N);
    sum_utilde=0;
    sum_Sgima=0;
    for i=1:nrun
        
        if mod(i,1000) == 0%
            disp([num2str(i) ' Simulations'])
        end
        
        
        
        %%%% sample varcoefs %%%
        
        check=0;
        count=0;
        while check==0
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
           % else %Scalable Approximate MCMC Algorithms
                %  for the Horseshoe Prior
                
                XLiDL = Ylagtilde'*LiDL;
                %ytilde= LiDL*y;
                B0=inv(iVbeta);
                v= mvnrnd(zeros(K*G,1),B0,1)';
                w=XLiDL'*v+randn(n*q,1);
                ind=diag(B0)>delta2;
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
            
            
            F=zeros(q*P,q*P);
            F(1:q*(P-1),q+1:q*P)=eye(q*(P-1),q*(P-1));
            F(1:q*P,1:q)=BetaAR';
            explosiv=(max(abs(eig(F))))>=1.0000;
            
            if explosiv==0 || noexplosivdraw==0|| i<100
                check=1;
            end
        end
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
        %% Update Sigma %%
        
        
        M=reshape(Ylagtilde* betaAR,n,q);
        U=Y-M;
        u=U'*U;
        for NN=1:N
            Sig(1+(NN-1)*G:G+(NN-1)*G,1+(NN-1)*G:G+(NN-1)*G)= iwishrnd(S0 +u(1+(NN-1)*G:G+(NN-1)*G,1+(NN-1)*G:G+(NN-1)*G),nu0 + n);
        end
        
        iSig=(sparse(Sig))\speye(q);
        %iSig=diag(diag(Sig))\speye(q);
        LiDL= kron(iSig,speye(n));  %% is this correct??
        % LiDL=kron(speye(n),iSig);
        
        
        if i > BURNIN && mod(i, thin)== 0 %% save stuff
            
            
            %%% calculate IRFs here
            if hor>0
                
                Sigmachol=chol(Sig);
                v=zeros(hor+P,q);
                v(P+1,:)=shockvariable;
                yirf=zeros(hor+P,q);
                xtp =  zeros(1,q*P);
                for iii=1+P:hor+P %works only for P>0
                    yirf(iii,:)=xtp*BetaAR'+v(iii,:)*Sigmachol;
                    xtp =  [ yirf(iii,:) xtp(1:end-q)];
                end
                
                yirf_store(:,(i-BURNIN)/thin,:)=  yirf(P+1:end,:).*standardizesdY;
            end
            AR_store(:,:,(i-BURNIN)/thin) = BetaAR;
            betaAR_store((i-BURNIN)/thin,:,1)=betaAR;
            LambdaARC1_store((i-BURNIN)/thin,:)=LambdaARC1' ;
            LambdaARC2_store((i-BURNIN)/thin,:)=LambdaARC2';

                    for NN=1:N
                  A= (Sig(1+(NN-1)*G:G+(NN-1)*G,1+(NN-1)*G:G+(NN-1)*G));
                  storeSIG((i-BURNIN)/thin,1+(NN-1)*G^2:G^2+(NN-1)*G^2)=A(:);
                     end

                                utilde=U(:);

        for NN=1:N
            error2=-.5*utilde(1+(NN-1)*n*G:n*(G+G*(NN-1)))'*LiDL(1+(NN-1)*n*G:n*(G+G*(NN-1)),1+(NN-1)*n*G:n*(G+G*(NN-1)))*utilde(1+(NN-1)*n*G:n*(G+G*(NN-1)));
           ldet =-0.5*n*log(det(Sig(1+G*(NN-1):G+G*(NN-1),1+G*(NN-1):G+G*(NN-1))));
          D_theta((i-BURNIN)/thin,NN)  =  -n*G*.5*log(2*pi)+ldet +error2 ;
        end
        sum_utilde=sum_utilde+utilde;
             sum_Sgima=sum_Sgima+Sig;


        end
    end      
 
if ineffplot==1
ineffAR=ineff_factor(betaAR_store');
ineffSIG=ineff_factor(storeSIG');
Ineff = [ineffAR; ineffSIG];
grp = [repmat({'$\mathbf{\beta}$'}, length(ineffAR), 1);...
    repmat({'$\mathbf{\Sigma}$'}, size(storeSIG,2), 1)];

figure
boxplot( Ineff,  grp, 'whisker', 30);
set(gca, 'TickLabelInterpreter','latex' )
box off
set(gcf, 'Color', 'white')

temp=['pics\','Inefffactors.pdf'];    

exportgraphics(gcf,temp)

end

 Sigma=   sum_Sgima/effsamp;
 utilde=sum_utilde/effsamp;
 VARcoef=mean( AR_store,3);

        iSig=(sparse( Sigma))\speye(q);
        LiDL= kron(iSig,speye(n)); 
        D_theta_bar=NaN(1,N); 
        for NN=1:N
            error2=-.5*utilde(1+(NN-1)*n*G:n*(G+G*(NN-1)))'*LiDL(1+(NN-1)*n*G:n*(G+G*(NN-1)),1+(NN-1)*n*G:n*(G+G*(NN-1)))*utilde(1+(NN-1)*n*G:n*(G+G*(NN-1)));
           ldet =-0.5*n*log(det(Sig(1+G*(NN-1):G+G*(NN-1),1+G*(NN-1):G+G*(NN-1))));
       D_theta_bar(1,NN)  =  -n*G*.5*log(2*pi)+ldet +error2 ;
        end

DIC = -4*mean(D_theta) + 2*D_theta_bar;

sum(DIC);
sum(DIC_nopooling);
if Save==1
 name=['IRF_','CS_local=',num2str(CS_local),'CS_country=',num2str( CS_country),'minesota=',num2str(  minesotaadaptive),'Minesotafix=',num2str(minesotafix),'MCMC=',num2str(MCMC),'MCMC=',num2str(BURNIN),'Cplus=',num2str(Minesota_cplus),'.mat'];
  clearvars -except yirf_store hor N G name DIC DIC_nopooling Save  minesotaadaptive minesotafix VARcoef Sigma
      save(name) 
end
