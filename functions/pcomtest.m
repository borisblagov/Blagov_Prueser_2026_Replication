function [P_rn,pval,cval] = pcomtest(p_i,alph,r)

% Function to implement intersection union of 
% Spreng and Urga (2022) Combining p-Values for Multivariate Predictive
% Ability Testing, Journal of Business and Economic Statistics
%
% Input: 
%   - p_i: (n x 1) vector of p-values
%   - alph: significance level (default 5%)
%   - r: parameter for test statistic (default 10)
%
% Output: 
%   - P_rn: test statistic
%   - pval: p-value of test statistic
%   - cvla: critical value of test statistc

if nargin <2 || isempty(alph)
    alph = 0.05;
end

if nargin < 3 || isempty(r)
    r = 10;
end

n = length(p_i);

% Numerical trick in case input pvalues are rounded down to zero (usual practice in most programmes)
% to prevent infinity values
p_i(p_i<=10^(-4)) = 10^(-4); 

P_rn = sum(p_i.^(-r))^(1/r)/n;        % Test statistic
pval = min(r/((r-1)*P_rn),1);           % p-value (proposition 1)
cval = r/(alph*(r-1));                % Critical value

disp('----------------------------------------'), disp('')
disp('Intersection Union Test:'), disp('')
disp('----------------------------------------')

disp(''), disp( sprintf('Test statistic: %1.4f' , P_rn ) ), disp('')
disp(''), disp( sprintf('Critical value: %1.4f' , cval ) ), disp('')
disp(''), disp( sprintf('p-value: %1.4f' , pval ) ), disp('')
disp('----------------------------------------')

if P_rn >= cval
    disp('Conclude: reject H_0')
else
    disp('Conclude: do not reject H_0')
end
disp('----------------------------------------'), disp('')

