clc
clear
close all
addpath('data')
addpath('functions')

% Choose what you want to replicate here, by uncommenting the relevant lines

%% Genrate the DIC Table, Table 2 in the paper
% repication_Table2_DIC

%% Repicate the IRF results from Section 3
% replicationIRFs

%% Repicate the IRF results from the Appendix (with sign restrictions)
% replicationIRFs_sign

%% Calculate the inefficiency factors from the Appendix, requires the Econometrics Toolbox
% replicationINEFF