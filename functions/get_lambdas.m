function [T_mat,T_upper_mat,top_value] = get_lambdas(lambdas_mat,parameter,N)

pair_index  = nchoosek(1:N,2);
T_upper_mat = zeros(N,N);
for ii = 1:N
    count_ind = ii;
    t1        = find(pair_index(:,1)==count_ind,1,'first'); % finds the first index
    t2        = find(pair_index(:,1)==count_ind,1,'last');  % % finds the last index
    
    T_upper_mat(ii,ii+1:end) = lambdas_mat(parameter,t1:t2);    % row 1 is the first lag of GDP
end
T_mat      = T_upper_mat + T_upper_mat';
top_value  = max(max(T_mat));