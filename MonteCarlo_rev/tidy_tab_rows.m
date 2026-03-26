function desc_strct = tidy_tab_rows(str_in)
if strcmp(str_in,'MC_pVAR101_103_Minn_T2001_T3000')
    desc_strct.prior = "Minn"; desc_strct.DGP = "DGP3";
elseif strcmp(str_in,"MC_pVAR104_106_Minn_T2001_T3000")
    desc_strct.prior = "Minn"; desc_strct.DGP = "DGP2";
elseif strcmp(str_in,"MC_pVAR107_109_Minn_T2001_T3000")
    desc_strct.prior = "Minn"; desc_strct.DGP = "DGP1";
elseif strcmp(str_in,"MC_pVAR101_103_t_T1001_T2000")
    desc_strct.prior = "t-prior"; desc_strct.DGP = "DGP3";
elseif strcmp(str_in,"MC_pVAR104_106_t_T1001_T2000")
    desc_strct.prior = "t-prior"; desc_strct.DGP = "DGP2";
elseif strcmp(str_in,"MC_pVAR107_109_t_T1001_T2000")
    desc_strct.prior = "t-prior"; desc_strct.DGP = "DGP1";
elseif strcmp(str_in,"MC_pVAR_HC101_103_T1_T1000")
    desc_strct.prior = "pVAR"; desc_strct.DGP = "DGP3";
elseif strcmp(str_in,"MC_pVAR_HC104_106_T1_T1000")
    desc_strct.prior = "pVAR"; desc_strct.DGP = "DGP2";
elseif strcmp(str_in,"MC_pVAR_HC107_109_T1_T1000")
    desc_strct.prior = "pVAR"; desc_strct.DGP = "DGP1";
elseif strcmp(str_in,"MC_pVAR_flat101_103_T3001_T4000")
    desc_strct.prior = "flat"; desc_strct.DGP = "DGP3";
elseif strcmp(str_in,"MC_pVAR_flat104_106_T3001_T4000")
    desc_strct.prior = "flat"; desc_strct.DGP = "DGP2";
elseif strcmp(str_in,"MC_pVAR_flat107_109_T3001_T4000")
    desc_strct.prior = "flat"; desc_strct.DGP = "DGP1";
%% new ones
elseif strcmp(str_in,"MC_pVAR_snp120_121_T1_T1000")
    desc_strct.prior = "pVAR shrink and pool"; desc_strct.DGP = "DGP flat";  
elseif strcmp(str_in,"MC_pVAR_snp130_131_T1_T1000")
    desc_strct.prior = "pVAR shrink and pool"; desc_strct.DGP = "DGP shrinkage & pooling";  
elseif strcmp(str_in,"MC_VAR_Monly120_121_T1001_T2000")
    desc_strct.prior = "Minnesota"; desc_strct.DGP = "DGP flat";    
elseif strcmp(str_in,"MC_VAR_Monly130_131_T1001_T2000")
    desc_strct.prior = "Minnesota"; desc_strct.DGP = "DGP shrinkage & pooling";    
elseif strcmp(str_in,"MC_pVAR_poo120_121_T2001_T3000")
    desc_strct.prior = "pVAR pooling"; desc_strct.DGP = "DGP flat";     
elseif strcmp(str_in,"MC_pVAR_poo130_131_T2001_T3000")
    desc_strct.prior = "pVAR pooling"; desc_strct.DGP = "DGP shrinkage & pooling";     
elseif strcmp(str_in,"MCpVAR_flat120_121_T3001_T4000")
    desc_strct.prior = "flat"; desc_strct.DGP = "DGP flat";      
elseif strcmp(str_in,"MCpVAR_flat130_131_T3001_T4000")
    desc_strct.prior = "flat"; desc_strct.DGP = "DGP shrinkage & pooling";    
elseif strcmp(str_in,"MC_pVAR_snp140_141_T1_T1000")
     desc_strct.prior = "pVAR shrink and pool"; desc_strct.DGP = "DGP 10 identical";    
elseif strcmp(str_in,"MC_VAR_Monly140_141_T1001_T2000")
     desc_strct.prior = "Minnesota"; desc_strct.DGP = "DGP 10 identical";        
elseif strcmp(str_in,"MC_pVAR_poo140_141_T2001_T3000")
     desc_strct.prior = "pVAR pooling"; desc_strct.DGP = "DGP 10 identical";           
elseif strcmp(str_in,"MCpVAR_flat140_141_T3001_T4000")
     desc_strct.prior = "flat"; desc_strct.DGP = "DGP 10 identical";   
elseif strcmp(str_in,"MC_pVAR_snp150_151_T1_T1000")
     desc_strct.prior = "pVAR shrink and pool"; desc_strct.DGP = "DGP shrinkage only";    
elseif strcmp(str_in,"MC_VAR_Monly150_151_T1001_T2000")
     desc_strct.prior = "Minnesota"; desc_strct.DGP = "DGP shrinkage only";        
elseif strcmp(str_in,"MC_pVAR_poo150_151_T2001_T3000")
     desc_strct.prior = "pVAR pooling"; desc_strct.DGP = "DGP shrinkage only";           
elseif strcmp(str_in,"MCpVAR_flat150_151_T3001_T4000")
     desc_strct.prior = "flat"; desc_strct.DGP = "DGP shrinkage only";  
end

 