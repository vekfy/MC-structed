%% correctness of angle
    N = 1e7;
    dir = rand(N,3);
    dir_norm = normr(dir);
    angles = angles_of_incidence(dir_norm);
    
    assert(isequal(size(angles), [N,1]));
    assert(all(angles >= 0 & angles <= pi/2))

%% perpendicular
    dir = [0 0 1];
    angle = angles_of_incidence(dir);
    assert(angle == 0)

%% parallel
    N = 1e7;
    dir = rand(N,3);
    dir_norm = normr(dir);
    dir_norm(:,3) = 0; 
    angle = angles_of_incidence(dir_norm);
    assert(all(abs(angle - pi/2) < 1e-16))

%% arbitrary degrees
    N = 1e2;
    
    direction_angle = pi * rand(N,1) - pi/2;
    dir_z = sin(direction_angle);
    phi = 2 * pi * rand(N,1);
    dir_x = sqrt(1 - dir_z.^2) .* cos(phi);
    dir_y = sqrt(1 - dir_z.^2) .* sin(phi);
    
    dir = [dir_x dir_y dir_z];
    angle = angles_of_incidence(dir);
    angle_incidence_theor = pi/2 - abs(direction_angle);
    assert(all(abs(angle - angle_incidence_theor) < 1e-8))
    