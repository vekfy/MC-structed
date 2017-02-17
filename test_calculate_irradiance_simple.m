% test
    photons_coords_prev = [0 0 0;
                           0 0 0;
                           0 0 0;
                           0 0 1.1];
    photons_coords = [0.1 0.5 0.99;
                           1.5 1.5 0;
                           2 2 0;
                           2 1 0];
    x_grid = [0 1 2];
    y_grid = [0 1 2];
    z_grid = [0 1 2];

    weight = [0.5; 1; 1; 1];
    
    irradiance = zeros(numel(x_grid)-1, numel(y_grid)-1, numel(z_grid)-1);
    irradiance_check = zeros(size(irradiance));
    
    irradiance = calculate_irradiance_simple(photons_coords_prev, photons_coords, weight, x_grid, y_grid, z_grid, irradiance);
    
    irradiance_check(1,1,1) = 2.5;
    irradiance_check(2,2,1) = 3;
    irradiance_check(1,1,2) = 1;

    assert(isequal(irradiance_check, irradiance));