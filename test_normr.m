%% CPU: normalize rows of matrix
    N = 10000;
    for k = 1:10,
        data = rand(N, k);
        normed_data = normr(data);
        assert(isequal(size(data), size(normed_data)));
        
        for i = 1:N,
           assert(abs(norm(normed_data(i,:))-1) < 1e-13); 
        end 
    end
        
        