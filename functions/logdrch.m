function dens = logdrch(x,alpha)


dens=sum(gammaln(alpha))-gammaln(sum(alpha))+sum((alpha-1).*log(x));

if dens==Inf
    dens=10000000000;
end
