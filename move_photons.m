function pos = move_photons(pos, dir, layer, mt, use_gpu)
    count = size(dir, 1); 
    if use_gpu
        eps = gpuArray.rand(count,1);
    else
        eps = rand(count,1);
    end
    
    s = -log(eps)./mt(1, layer)';
    pos = pos + bsxfun(@times, dir, s);
end