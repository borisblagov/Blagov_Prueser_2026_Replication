function str_out = renames(str_in)
if strcmp(str_in,'MC_pVAR101_103_Minn_T2001_T3000')
str_out = 'Minn, DGP3';
elseif strcmp(str_in,'MC_pVAR104_106_Minn_T2001_T3000')
    str_out = 'Minn, DGP2';
elseif strcmp(str_in,'MC_pVAR107_109_Minn_T2001_T3000')
    str_out = 'Minn, DGP1';
elseif strcmp(str_in,'MC_pVAR101_103_t_T1001_T2000')
    str_out = 't-prior, DGP3';
elseif strcmp(str_in,'MC_pVAR104_106_t_T1001_T2000')
    str_out = 't-prior, DGP2';
elseif strcmp(str_in,'MC_pVAR107_109_t_T1001_T2000')
    str_out = 't-prior, DGP1';
elseif strcmp(str_in,'MC_pVAR_HC101_103_T1_T1000')
    str_out = 'pVAR, DGP3';
elseif strcmp(str_in,'MC_pVAR_HC104_106_T1_T1000')
    str_out = 'pVAR, DGP2';
elseif strcmp(str_in,'MC_pVAR_HC107_109_T1_T1000')
    str_out = 'pVAR, DGP1';
elseif strcmp(str_in,'MC_pVAR_flat101_103_T3001_T4000')
    str_out = 'flat, DGP3';
elseif strcmp(str_in,'MC_pVAR_flat104_106_T3001_T4000')
    str_out = 'flat, DGP2';
elseif strcmp(str_in,'MC_pVAR_flat107_109_T3001_T4000')
    str_out = 'flat, DGP1';
end

 