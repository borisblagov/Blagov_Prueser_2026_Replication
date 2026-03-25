
close all;
clear all;
clc;


Save=1;
hyper_CSlocal=1;
hyper_CScountry=1;


Calculate_IRFs_sign

close all;
clear all;
clc;


Save=1;
hyper_CSlocal=0;
hyper_CScountry=0;
ineffplot=0;

Calculate_IRFs_sign

clear all;

Save=1;

 load('IRF_Sign__CS_local=0CS_country=0minesota=1Minesotafix=1MCMC=5000MCMC=5000Cplus=0.mat')

Xirf=yirf_store;
load('IRF_Sign__CS_local=1CS_country=1minesota=1Minesotafix=1MCMC=5000MCMC=5000Cplus=0.mat')

Xirf_prior=yirf_store;

Plots_IRFs_sign
