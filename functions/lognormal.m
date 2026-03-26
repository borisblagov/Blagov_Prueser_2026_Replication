function dens = lognormal(y,mu,sig2,delta)

dens=-delta*log(sig2.^.5)-delta*.5*log(2*pi)-.5*delta*((y-mu)^2)/sig2;


