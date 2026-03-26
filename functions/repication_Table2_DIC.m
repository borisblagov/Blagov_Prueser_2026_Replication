close all;
clear
clc;

%% pool and shrinkage
Save=0;
hyper_CSlocal=1;
hyper_CScountry=1;
ineffplot=0;
hyper_minesota=1;


Calculate_IRFs
sum(DIC)

%% shrinkage

clear;
Save=0;
hyper_CSlocal=0;
hyper_CScountry=0;
ineffplot=0;
hyper_minesota=1;


Calculate_IRFs
sum(DIC)

%% flat
clear;
Save=0;
hyper_CSlocal=0;
hyper_CScountry=0;
ineffplot=0;
hyper_minesota=0;


Calculate_IRFs
sum(DIC)

%% pool
clear;
Save=0;
hyper_CSlocal=1;
hyper_CScountry=1;
ineffplot=0;
hyper_minesota=0;


Calculate_IRFs
sum(DIC)