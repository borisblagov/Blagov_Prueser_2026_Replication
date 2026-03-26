

close all;
clear;
clc;


Save=1;
hyper_CSlocal=1;
hyper_CScountry=1;
ineffplot=0;
hyper_minesota=1;


Calculate_IRFs

close all;
clear;
clc;


Save=1;
hyper_CSlocal=0;
hyper_CScountry=0;
hyper_minesota=1;
ineffplot=0;

Calculate_IRFs

clear all;

Save=1;

 load('IRF_CS_local=0CS_country=0minesota=1Minesotafix=1MCMC=5000MCMC=5000Cplus=0.mat')
 sum(DIC);

Xirf=yirf_store;
sum(DIC)
load('IRF_CS_local=1CS_country=1minesota=1Minesotafix=1MCMC=5000MCMC=5000Cplus=0.mat')
sum(DIC);

Xirf_prior=yirf_store;

Plots_IRFs


