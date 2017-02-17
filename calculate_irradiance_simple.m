function irradiance = calculate_irradiance_simple(photons_coords_prev, photons_coords, weight, x_grid, y_grid, z_grid, irradiance)
    N = numel(weight);

    ix_prev = discretize(photons_coords_prev(:,1), x_grid);
    iy_prev = discretize(photons_coords_prev(:,2), y_grid);
    iz_prev = discretize(photons_coords_prev(:,3), z_grid);

    ix = discretize(photons_coords(:,1), x_grid);
    iy = discretize(photons_coords(:,2), y_grid);
    iz = discretize(photons_coords(:,3), z_grid);
     
    irradiance_size = size(irradiance);
    
    mysub2ind_func=@(i,j,k) i+(j-1)*irradiance_size(1)+(k-1)*irradiance_size(1)*irradiance_size(2);
    
    t=tic;
    for i = 1:N,
        ind_prev = [ix_prev(i) iy_prev(i) iz_prev(i)];
        ind = [ix(i) iy(i) iz(i)];

        [isx,isy,isz] = bresenham_line3d_f(ind_prev, ind);

        line_indexes = mysub2ind_func(isx, isy, isz);
        try
            irradiance(line_indexes) = irradiance(line_indexes) + weight(i);
        catch
            disp('ERRRORORO!!');
        end
    end
    toc(t)



% % % % try
% % % %         [~,ix_prev] = histc(photons_coords_prev(:,1), x_grid);
% % % %         [~,iy_prev] = histc(photons_coords_prev(:,2), y_grid);
% % % %         [~,iz_prev] = histc(photons_coords_prev(:,3), z_grid);
% % % % 
% % % %         [~,ix] = histc(photons_coords(:,1), x_grid);
% % % %         [~,iy] = histc(photons_coords(:,2), y_grid);
% % % %         [~,iz] = histc(photons_coords(:,3), z_grid);
% % % %         
% % % %         ix_prev = min(ix_prev, numel(x_grid)-1);
% % % %         ix = min(ix, numel(x_grid)-1);
% % % %         iy_prev = min(iy_prev, numel(y_grid)-1);
% % % %         iy = min(iy, numel(y_grid)-1);
% % % %         iz_prev = min(iz_prev, numel(z_grid)-1);
% % % %         iz = min(iz, numel(z_grid)-1);
% % % %     catch
% % % %        return
% % % %     end
% % % %         
% % % %         
% % % %     I = num2cell([ix iy iz],2);
% % % %     I_prev = num2cell([ix_prev iy_prev iz_prev],2);
% % % %     Irradiance_size = size(Irradiance);
% % % %     mysub2ind=@(i,j,k) i+(j-1)*Irradiance_size(1)+(k-1)*Irradiance_size(1)*Irradiance_size(2);
% % % % 
% % % %     calc_type = 'for';
% % % %     switch calc_type
% % % %         case 'cellfun'
% % % %             disp(calc_type)
% % % %             disp('bresenham_line3d_f')
% % % % %             tic
% % % % %             [isx,isy,isz]=cellfun(@bresenham_line3d_f, I, I_prev,'UniformOutput',0);
% % % % %             toc
% % % %             disp('dda')
% % % %             t = tic;
% % % %             [isx,isy,isz]=cellfun(@dda_3d, I, I_prev,'UniformOutput',0);
% % % %             toc(t)
% % % %             disp('mysub2ind')
% % % %             t = tic;
% % % %             ind_of_irradiance=cellfun(mysub2ind,isx,isy,isz,'UniformOutput',0);
% % % %             toc(t)
% % % %             disp('weight_of_irradiance');
% % % %             t = tic;
% % % %             weight_of_irradiance = arrayfun(@(i) {ones(numel(ind_of_irradiance{i}),1)*weight(i)}, [1:numel(weight)]');
% % % %             toc(t)
% % % %         case 'for'
% % % %             disp(calc_type)
% % % %             disp('bresenham_line3d_f')
% % % %             disp('mysub2ind')
% % % %             disp('weight_of_irradiance');
% % % %             t = tic;
% % % %             ind_of_irradiance = cell(numel(I),1);
% % % %             weight_of_irradiance = cell(numel(I),1);
% % % %             for i=1:numel(I)
% % % %                 [isx,isy,isz]=bresenham_line3d_f(I{i}, I_prev{i});
% % % %                 ind_of_irradiance{i} = mysub2ind(isx,isy,isz);
% % % %                 weight_of_irradiance{i} = ones(numel(ind_of_irradiance{i}),1)*weight(i);
% % % %             end
% % % %             toc(t)
% % % %     end
% % % %             
% % % %             
% % % %     ind_of_irradiance = cell2mat(ind_of_irradiance);
% % % %     weight_of_irradiance = cell2mat(weight_of_irradiance);
% % % %     vals_ind_of_irradiance = [1:max(ind_of_irradiance)]';
% % % %     
% % % %     bad_index = find (ind_of_irradiance<0);
% % % %     
% % % % %     %%Todo: сделать по нормальному отражения 
% % % % %     ind_of_irradiance(bad_index) = [];
% % % % %     weight_of_irradiance(bad_index) = [];
% % % %     
% % % %     if numel(vals_ind_of_irradiance)>0
% % % %         try
% % % %             accum_weight_of_irradiance = accumarray(ind_of_irradiance,weight_of_irradiance);
% % % %             Irradiance(vals_ind_of_irradiance) = Irradiance(vals_ind_of_irradiance) + accum_weight_of_irradiance;
% % % %         catch
% % % %             disp('asd');
% % % %         end
% % % % 
% % % %     end
end