function w = hmaSymmetricWeights(n)
        % calculate the constant denominator
        m = fix((n-1)/2);
        m1 = (m+1)*(m+1);
        m2 = (m+2)*(m+2);
        d  = 8*(m+2)*(m2-1)*(4*m2-1)*(4*m2-9)*(4*m2-25);
        % calculate the weights
        w = NaN(1,n); % 1:n
        m3 = (m+3)*(m+3);
        for j=0:m 
            j2 = j*j;
            v = (315*(m1-j2)*(m2-j2)*(m3-j2)*(3*m2-11*j2-16))/d;
            w(m+1+j) = v;
            if j > 0
             w(m+1-j) = v;
            end
        end
    end