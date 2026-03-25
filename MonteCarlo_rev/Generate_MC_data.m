% addpath('./functions')
% clc
% clear
%% This code generates datasets for the MC and saves them
% The code will generate new data, if you want to replicate the paper,
% download the one from https://www.dropbox.com/scl/fi/qj1cqd00ev0web73rx431/MC_dataset_rev.mat?rlkey=g2micli5fdncech3nt93iao4x&dl=0


MC_dataset_rev = struct();
sample_length = 500;
MCrepetitions = 1000;



%%  10 countries based on dgp_flat
[fdata_tempmat,PHI,N,G,~,Phi_alt,P] = simpvardgp_flat(sample_length);
fdata_3dmat = zeros([size(fdata_tempmat),MCrepetitions]);   % TxN*G* MC repetitions
for ii = 1:MCrepetitions
    [fdata_tempmat] = simpvardgp_flat(sample_length);
    fdata_3dmat(:,:,ii) = fdata_tempmat;
end

MC_dataset_rev.simpvardgp_flat.fdata_3dmat = fdata_3dmat;
MC_dataset_rev.simpvardgp_flat.PHI = PHI;
MC_dataset_rev.simpvardgp_flat.N = N;
MC_dataset_rev.simpvardgp_flat.G = G;
MC_dataset_rev.simpvardgp_flat.Phi_alt = Phi_alt;
MC_dataset_rev.simpvardgp_flat.P = P;
MC_dataset_rev.simpvardgp_flat.desc = '10 countries, flat prior';

%%  10 countries based on dgp_shrinkpool
[fdata_tempmat,PHI,N,G,~,Phi_alt,P] = simpvardgp_shrinkpool(sample_length);
fdata_3dmat = zeros([size(fdata_tempmat),MCrepetitions]);   % TxN*G* MC repetitions
for ii = 1:MCrepetitions
    [fdata_tempmat] = simpvardgp_shrinkpool(sample_length);
    fdata_3dmat(:,:,ii) = fdata_tempmat;
end

MC_dataset_rev.simpvardgp_shrinkpool.fdata_3dmat = fdata_3dmat;
MC_dataset_rev.simpvardgp_shrinkpool.PHI = PHI;
MC_dataset_rev.simpvardgp_shrinkpool.N = N;
MC_dataset_rev.simpvardgp_shrinkpool.G = G;
MC_dataset_rev.simpvardgp_shrinkpool.Phi_alt = Phi_alt;
MC_dataset_rev.simpvardgp_shrinkpool.P = P;
MC_dataset_rev.simpvardgp_shrinkpool.desc = '10 countries, shrinkage prior';

%%  10 countries which are identical and are based on the first from the shrinkage prior
[fdata_tempmat,PHI,N,G,~,Phi_alt,P] = simpvardgp_10identical(sample_length);
fdata_3dmat = zeros([size(fdata_tempmat),MCrepetitions]);   % TxN*G* MC repetitions
for ii = 1:MCrepetitions
    [fdata_tempmat] = simpvardgp_10identical(sample_length);
    fdata_3dmat(:,:,ii) = fdata_tempmat;
end

MC_dataset_rev.simpvardgp_10ident.fdata_3dmat = fdata_3dmat;
MC_dataset_rev.simpvardgp_10ident.PHI = PHI;
MC_dataset_rev.simpvardgp_10ident.N = N;
MC_dataset_rev.simpvardgp_10ident.G = G;
MC_dataset_rev.simpvardgp_10ident.Phi_alt = Phi_alt;
MC_dataset_rev.simpvardgp_10ident.P = P;
MC_dataset_rev.simpvardgp_10ident.desc = '10 countries, identical dgp';


%%  10 countries based on dgpshrink
[fdata_tempmat,PHI,N,G,~,Phi_alt,P] = simpvardgp_shrinkonly(sample_length);
fdata_3dmat = zeros([size(fdata_tempmat),MCrepetitions]);   % TxN*G* MC repetitions
for ii = 1:MCrepetitions
    [fdata_tempmat] = simpvardgp_shrinkonly(sample_length);
    fdata_3dmat(:,:,ii) = fdata_tempmat;
end

MC_dataset_rev.simpvardgp_shrinkonly.fdata_3dmat = fdata_3dmat;
MC_dataset_rev.simpvardgp_shrinkonly.PHI = PHI;
MC_dataset_rev.simpvardgp_shrinkonly.N = N;
MC_dataset_rev.simpvardgp_shrinkonly.G = G;
MC_dataset_rev.simpvardgp_shrinkonly.Phi_alt = Phi_alt;
MC_dataset_rev.simpvardgp_shrinkonly.P = P;
MC_dataset_rev.simpvardgp_shrinkonly.desc = '10 countries, shrinkage dgp only';

% uncomment the line below to generate your own
save MC_dataset_rev.mat MC_dataset_rev

