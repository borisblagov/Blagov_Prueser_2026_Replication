% Run name
setup_spec_str  = spec_tab.Properties.RowNames{setup_spec};
Input.setup_spec_str   = setup_spec_str;


% Model settings
Input.P         = spec_tab{setup_spec,'P'};                    % use 1,2,3,4 laqs
Input.hor       = spec_tab{setup_spec,'hor'};                    % how many quarters we want to predict ahead, set to 0-> no forecasts

% MCMC settings:
Input.standardize       = spec_tab{setup_spec,'standardize'};            % Set to 1 as this model is estimated without a constant
Input.MCMC              = spec_tab{setup_spec,'MCMC'};
Input.BURNIN            = spec_tab{setup_spec,'BURNIN'};

% Prior settings
Input.delta_minesota=spec_tab{setup_spec,'delta_minesota'};
Input.minesotaadaptive  = spec_tab{setup_spec,'minesotaadaptive'};  % if 1 use minesota prior, set this rather to 1, the mineosota prior is country specific
Input.MinesotaGL        = spec_tab{setup_spec,'MinesotaGL'};        % if 1 use local priors for minesota prior, set this rather to 0, very flexiable
Input.CS_local          = spec_tab{setup_spec,'CS_local'};          % if 1 local priors for homogeneity restirction, set this rather to 0, very flexiable
Input.CS_country        = spec_tab{setup_spec,'CS_country'};        % if 1 shrinks country pairs i.e. N*(N-1)/2 hyperparameter
Input.CS_global         = spec_tab{setup_spec,'CS_global'};         % if 1 shrinks all country pairs i.e. one hyperparameter for all countries
Input.Min_HC            = spec_tab{setup_spec,'Min_HC'};            % 1: half-Cauchy otherwise use inversegamma prior IG(0,0)i.e. jeffry, this applys to all prior
Input.Minesota_shape    = spec_tab{setup_spec,'Min_shape'};
Input.Minesota_scale    = spec_tab{setup_spec,'Min_scale'};
Input.CS_HC             = spec_tab{setup_spec,'CS_HC'};             % 1: half-Cauchy otherwise use inversegamma prior IG(0,0)i.e. jeffry, this applys to all prior
Input.CS_shape          = spec_tab{setup_spec,'CS_shape'};
Input.CS_scale          = spec_tab{setup_spec,'CS_scale'};
Input.delta             = spec_tab{setup_spec,'delta'};
Input.mean              = spec_tab{setup_spec,'mean'};
Input.twostep              = spec_tab{setup_spec,'twostep'};