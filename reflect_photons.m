function [pos, dir, layer, is_need_recalculation] = reflect_photons(pos, pos_previous, dir, layer, z_planes, n, use_gpu)
%%Расчет отражения фотонов (gpu-версия).
% pos - текущая позиция,
% pos_prev - предыдущая позиция,
% dir - единичное направление, фактически может быть рассчитано как
% (pos-pos_prev)/||pos-pos_prev||
% layer - слои, на которых находятся фотоны,
% z_planes - z-координаты слоёв
% n - все показатели преломления
   
    count = size(dir,1);
    suspect = [];
    
    for z_plane = z_planes,
        suspect = [suspect; find((pos_previous(:,3) - z_plane).*(pos(:,3) - z_plane) < 0)];
    end
    suspect = unique(suspect);
  
    is_need_recalculation = true(count,1);
    is_need_recalculation(suspect) = false;
    if numel(suspect) > 0
        if use_gpu
            %         is_need_recalculation = gpuArray.true(count,1);
            n_in = gpuArray.ones(numel(suspect), 1);
            n_out = gpuArray.ones(numel(suspect), 1);
            z_photon_intesection = gpuArray.zeros(numel(suspect), 1);
        else
            %         is_need_recalculation = true(count,1);
            n_in = ones(numel(suspect), 1);
            n_out = ones(numel(suspect), 1);
            z_photon_intesection = zeros(numel(suspect), 1);
        end
        dir_suspect = dir(suspect,:); 
        angle_incidence = angles_of_incidence(dir_suspect);

        dir_negative = dir_suspect(:,3) < 0;
        z_photon_intesection(dir_negative) = z_planes(layer(suspect(dir_negative)));
        z_photon_intesection(~dir_negative) = z_planes(layer(suspect(~dir_negative))+1);
        
        s = (z_photon_intesection - pos_previous(suspect,3))./dir(suspect,3);
        pos(suspect,:) = pos_previous(suspect,:) + bsxfun(@times, dir_suspect, s);   % все фотоны, которые пересекли границу - возвращаются на границу 
        pos(suspect,3) = z_photon_intesection;
        
        
        n_in(:) = n(layer(suspect) + 1);
        n_out(dir_negative) = n(layer(suspect(dir_negative)));
        n_out(~dir_negative) =  n(layer(suspect(~dir_negative)) + 2);

        angle_refraction = angles_of_refraction(angle_incidence, n_in, n_out);
        complex_index = angle(angle_refraction) ~= 0 ;
        
        angle_refraction(complex_index) = 0;
        
        if use_gpu
            R = gpuArray.zeros(numel(suspect), 1);
        else
            R = zeros(numel(suspect), 1);
        end
        
        ind_zero_angle_incidence = angle_incidence == 0;
        if any(ind_zero_angle_incidence)
            R(ind_zero_angle_incidence) = (n_in(ind_zero_angle_incidence) - n_out(ind_zero_angle_incidence)).^2./(n_in(ind_zero_angle_incidence) + n_out(ind_zero_angle_incidence)).^2;
            ind = angle_incidence > 0;
            angle_incidence_1 = angle_incidence(ind);
            angle_refraction_1 = angle_refraction(ind);
            R(ind) = (sin(angle_incidence_1 - angle_refraction_1).^2./sin(angle_incidence_1 + angle_refraction_1).^2 + tan(angle_incidence_1 - angle_refraction_1).^2./tan(angle_incidence_1 + angle_refraction_1).^2) / 2;
        else
            R = (sin(angle_incidence - angle_refraction).^2./sin(angle_incidence + angle_refraction).^2 + tan(angle_incidence - angle_refraction).^2./tan(angle_incidence + angle_refraction).^2) / 2;
        end
        
        if use_gpu
            reflected_indexes = gpuArray.rand(size(R)) <= R;    
        else
            reflected_indexes = rand(size(R)) <= R;    
        end
        
        ind_layer_plus = ~reflected_indexes & ~dir_negative;
        layer(suspect(ind_layer_plus)) = layer(suspect(ind_layer_plus)) + 1;
        ind_layer_minus = ~reflected_indexes & dir_negative;
        layer(suspect(ind_layer_minus)) = layer(suspect(ind_layer_minus)) - 1;
        
        reflected_photons = suspect(reflected_indexes);
        refracted_photons = suspect(~reflected_indexes);
        
        % новые направления
        if any(reflected_photons)
            dir(reflected_photons, 3) = - dir(reflected_photons, 3);
        end
        if any(refracted_photons)
            dir(refracted_photons, :) = dir_of_refraction(dir(refracted_photons,:), angle_incidence(~reflected_indexes), angle_refraction(~reflected_indexes), n_in(~reflected_indexes), n_out(~reflected_indexes));
        end
    end
end
