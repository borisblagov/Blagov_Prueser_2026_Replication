function [ef, L] = ineff_factor( X, L )

% This function computes the inefficiency factors for a set of MCMC chains.
% If X is a two-dimensional matrix, it is assumed that each row contains
% a separate chain.  If the lag cut-off L is not provided, an attempt will
% be made to caculated it based on an auto-correlation "tappering-off"
% rule-of-thumb. In this case, it will also be returned as an additional
% output variable.
%
% NOTICE:
% -------
% Permission is hereby granted to use this code freely for academic
% purposes only, provided that the paper is duly cited as:
%
% Eisenstat, E., Chan, J. C. C. and R. W. Strachan (2015). "Stochastic Model
% Specification Search for Time-Varying Parameter VARs," Econometric
% Reviews, forthcoming.
%
% Any other use of this code, particularly for comercial purposes, is
% strictly prohibited without the prior written consent of the authors.
% Furthermore, this code comes without technical support of any kind.  It
% is expected to reproduce the results reported in the paper.  However,
% beware that the notation may not the match text.  Likewise, it is not
% gauranteed to work under different hardware and / or software settings,
% other than those used for its original design and implementation.
%
% Under no circumstances will the authors be held responsible for any use
% (or misuse) of this code in any way.  If you do not agree to the above,
% you do not have permission to use this code.

n = size( X, 1 );
ef = zeros( n, 1 );

if nargin < 2
    L = zeros( n, 1 );
end

for i = 1:n
    [ef( i ), L( i )] = ineff_factor1( X( i, : ), L( i ) );
end

end

function [ef1, L] = ineff_factor1( x, L )

if L == 0
    L = max( get_L( x ), 20 );
end

r = autocorr( x, L );
ef1 = 1 + 2 * sum( r( 2:end ) );

end

%%%%% HELPER FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%

function r = acorr_simple( x, L )

r = zeros( L, 1 );

for i = 1:L
	y = x( 1:( end - i ) );
	z = x( ( 1 + i ):end );
	r( i ) = mean( ( y - mean( x ) ) .* ( z - mean( x ) ) );
end

r = [1; r / var( x, 1 )];

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function L = get_L( x )

L = 0;
n = length( x );

[r, l, b] = autocorr( x, n - 1, L );
L_new = min( find( abs( r ) < b( 1 ) ) ) - 1;

i = 1;
while i <= 100 && L ~= L_new
	L = L_new;
	[r, l, b] = autocorr( x, L );
	L_new = min( find( abs( r ) < b( 1 ) ) ) - 1;
    i = i + 1;
end

if L ~= L_new
	warning( 'Could not find appropriate truncation lag.  Setting to 0.' );
	L = 0;
end

end