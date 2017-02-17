function irradiance = calculate_irradiance_simple_gpu(photons_coords_prev, photons_coords, weight, x_grid, y_grid, z_grid, irradiance)
    photons_coords_prev_cpu = gather(photons_coords_prev);
    photons_coords_cpu = gather(photons_coords);
    weight_cpu = gather(weight);
    x_grid_cpu = gather(x_grid);
    y_grid_cpu = gather(y_grid); 
    z_grid_cpu = gather(z_grid); 
    irradiance_cpu = gather(irradiance);
    
    irradiance_cpu = calculate_irradiance_simple(photons_coords_prev_cpu, photons_coords_cpu, weight_cpu, x_grid_cpu, y_grid_cpu, z_grid_cpu, irradiance_cpu);
    irradiance = gpuArray(irradiance_cpu);
   
end