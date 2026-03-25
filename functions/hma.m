function r = hma(v,n)

  %the main body of the function
  
  % test that n is an integer, odd and >= 5
  
  n = fix(n(1)); % integer; not vectorised
  if ~mod(n,1)==0 
    error('In hma(v, n), n must be an integer');
  end  
  if(n < 5)        
    error('In hma(v, n), n must be >= 5');
  end  
  if mod(n,2) == 0
    error('In hma(v, n), n must be odd');
  end
  
  % confirm that v is a vector
  if  ~( isvector(v) && isnumeric(v) ) 
    error('In hma(v, n), v must be an atomic, numeric vector');
  end
  
  % handle NA - need to think about this more
  if  any(isnan(v))
    error('In hma(v, n), the vector, v, must not containe NA values');
  end
  
  % calculate the symmetric weights
  weights = hmaSymmetricWeights(n);
  
  % construct the return series
  l = length(v);
  r = NaN(1,l);    % r will be the vector we return
  
  if l < n                % handle short vectors
      r
  end
          
  m = fix((n-1)/2);
  
  for  i=1:l
    if  i <= m  
      % asymmetric weights at the front end
      w = fliplr(hmaAsymmetricWeights(n, i+m, weights));
      r(i) = sum(v(1:(i+m)).*w);
    end
    
    % apply the symmetric weights to the middle of v
    if i > m && i <= l-m 
      r(i) = sum(v((i-m):(i+m)).*weights);
    end
      
    if  i > l-m  
      % asymmetric weights at the back end
      sz = l - i + 1 + m;
      w = hmaAsymmetricWeights(n, sz, weights);
      r(i) = sum(v((i-m):l).*w);
    end
  end
end