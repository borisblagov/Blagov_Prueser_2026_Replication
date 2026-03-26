function [Ystar Xstar Tstar]=doprior(Y,X,n,m,p,T,ar,arvar,lambda1,lambda3,lambda4)








% generate Yd, using (XXX)
Yd=[diag(ar*arvar/lambda1);zeros(n*(p-1),n);zeros(m,n);diag(arvar)];

% generate Xd, using (XXX)
Jp=diag([1:p].^lambda3);
Xd=[kron(Jp,diag(arvar/lambda1)) zeros(n*p,m);zeros(m,n*p) kron(1/(lambda1*lambda4),eye(m));zeros(n,n*p) zeros(n,m)];

% Compute Td, using (XXX)
Td=n*(p+1)+m;


% finally generate Ystar, Xstar and Tstar
Ystar=[Y;Yd];
Xstar=[X;Xd];
Tstar=T+Td;


