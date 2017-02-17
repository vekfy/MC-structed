function [pos, dir, weight, max_deep, layer] = launch_photons(sourse_position, sourse_direction, count, use_gpu)
    if use_gpu    
        pos = gpuArray(repmat(sourse_position, count,1));
        dir = gpuArray(repmat(sourse_direction, count, 1));
        weight = gpuArray.ones(count,1);
        max_deep = gpuArray.zeros(count,1);
        layer = gpuArray.ones(count,1);
    else
        pos = repmat(sourse_position, count,1);
        dir = repmat(sourse_direction, count, 1);
        weight = ones(count,1);
        max_deep = zeros(count,1);
        layer = ones(count,1);
    end
end
