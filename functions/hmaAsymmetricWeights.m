function u = hmaAsymmetricWeights(n, mw, w)

    % calculate the asymmetric end-weights
    % formula from Mike Doherty (2001), 'The Surrogate Henderson Filters in X-11',
    % Aust, NZ J of Stat. 43(4), 2001, pp901-999
    % see formula (1) on page 903
    
    % returns a dictionary of asymmetrical weights from 1 to mw;
    % where mw is less than n, and
    % w is the dictionary of symmetric henderson weights indexed from 1 to n
    
    sumResidual = sum(w((mw+1):n));
    sumEnd = 0;
    for  i=(mw+1):n
      sumEnd = sumEnd + ((i)-((mw+1)/2)) * w(i);
    end
    ic = 1.0;
    if n >= 13 && n < 15
      ic = 3.5;
    end
    if n >= 15
      ic = 4.5;
    end
    b2s2 = (4.0/pi)/(ic*ic);
    f1 = sumResidual/mw;
    u = 1:mw;
    for  r=1:mw
      calc1 = (r - (mw+1)/2.0) * b2s2;
      calc2 = 1 + (mw*(mw-1)*(mw+1)/12) * b2s2;
      u(r) = w(r) + f1 + ( calc1 / calc2 ) * sumEnd;
    end
end
    