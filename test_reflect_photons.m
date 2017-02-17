use_gpu = false;
%% test_1
% % lack of boundary

N = 1e2;

pos = [rand(N,1) rand(N,1) 10* rand(N,1)];
pos_previous = [zeros(N,1) zeros(N,1) zeros(N,1)];
dir = pos - pos_previous;
dir = normr(dir);
layer = ones(N,1);
z_plane =[0 0.9 * min(pos(:,3)) 1];

n = [1 1 1 1];

[pos_next, dir_next, layer_next, is_need_recalculation] = reflect_photons(pos, pos_previous, dir, layer, z_plane, n, use_gpu);

pos_next_theor = [zeros(N,1) zeros(N,1)  0.9*min(pos(:,3))*ones(N,1)];

assert(numel(is_need_recalculation) == N);
assert(all(pos_next_theor(:,3) == pos_next(:,3)));
assert(norm(dir_next - dir) < 1e-10);
assert(all(layer_next - layer==1));
assert(all(is_need_recalculation == 0));

%% test_2
% full reflectance
n = [1 2 1];
N = 1e6;
layer = ones(N, 1);
max_critical_angle_incidence = asin(n(1)/n(2)); 

angle_of_incidence_of_total_reflectance = random('uniform', max_critical_angle_incidence, pi/2, N, 1);

dir_z = cos(angle_of_incidence_of_total_reflectance);
phi = 2 * pi * rand(N,1);
dir_x = sqrt(1 - dir_z.^2) .* cos(phi);
dir_y = sqrt(1 - dir_z.^2) .* sin(phi);
dir = [dir_x dir_y dir_z];

pos_previous = [zeros(N,1) zeros(N,1) zeros(N,1)];
pos = pos_previous + dir;
z_plane = [0 0.9 * min(pos(:,3))];
    
[pos_next, dir_next, layer_next, is_need_recalculation] = reflect_photons(pos, pos_previous, dir, layer, z_plane, n, use_gpu);

assert(numel(is_need_recalculation) == N);
assert(all(z_plane(2) == pos_next(:,3)));
assert(all(dir_next(:,3) ==  - dir(:,3)));
assert(all(layer_next == layer));
assert(all(is_need_recalculation == 0));
    
%% test_3
% part reflectance from "right" to "left"
n = [1 2 1];
N = 1e6;
layer = ones(N, 1);
angle_incidence = 0.1; 

dir_z = -cos(angle_incidence)*ones(N, 1);
phi = 2 * pi * rand(N,1);
dir_x = sqrt(1 - dir_z.^2) .* cos(phi);
dir_y = sqrt(1 - dir_z.^2) .* sin(phi);
dir = [dir_x dir_y dir_z];

angle_refraction = angles_of_refraction(angle_incidence, n(2), n(1));

angles_diff = angle_incidence - angle_refraction;
angles_sum = angle_incidence + angle_refraction;
R = 0.5*(sin(angles_diff)/sin(angles_sum))^2 + 0.5*(tan(angles_diff)/tan(angles_sum))^2;

pos_previous = [zeros(N,1) zeros(N,1) zeros(N,1)];
pos = pos_previous + dir;
z_plane = [0.9 * min(pos(:,3)) 0];
[pos_next, dir_next, layer_next, is_need_recalculation] = reflect_photons(pos, pos_previous, dir, layer, z_plane, n, use_gpu);

ind_reflected_logical = dir_next(:,3) == -dir(:,3);
reflected_count = sum(ind_reflected_logical); 
reflected_part = reflected_count / N;

assert(numel(is_need_recalculation) == N);
assert(all(z_plane(1) == pos_next(:,3)));
assert(all(layer_next(ind_reflected_logical) == layer(ind_reflected_logical)));
assert(all(layer_next(~ind_reflected_logical) == layer(~ind_reflected_logical)-1));
assert(all(is_need_recalculation == 0));

sigma = sqrt(N*R*(1-R));
mean = N*R;
assert(abs(reflected_count - mean) <= 3*sigma);

%% test_3
% part reflectance from "left" to "right"
n = [1 2 1];
N = 1e6;
layer = ones(N, 1);
angle_incidence = 0.1; 

dir_z = cos(angle_incidence)*ones(N, 1);
phi = 2 * pi * rand(N,1);
dir_x = sqrt(1 - dir_z.^2) .* cos(phi);
dir_y = sqrt(1 - dir_z.^2) .* sin(phi);
dir = [dir_x dir_y dir_z];

angle_refraction = angles_of_refraction(angle_incidence, n(2), n(1));

angles_diff = angle_incidence - angle_refraction;
angles_sum = angle_incidence + angle_refraction;
R = 0.5*(sin(angles_diff)/sin(angles_sum))^2 + 0.5*(tan(angles_diff)/tan(angles_sum))^2;

pos_previous = [zeros(N,1) zeros(N,1) zeros(N,1)];
pos = pos_previous + dir;
z_plane = [0 0.9 * min(pos(:,3))];
[pos_next, dir_next, layer_next, is_need_recalculation] = reflect_photons(pos, pos_previous, dir, layer, z_plane, n, use_gpu);

ind_reflected_logical = dir_next(:,3) == -dir(:,3);
reflected_count = sum(ind_reflected_logical); 
reflected_part = reflected_count / N;

assert(numel(is_need_recalculation) == N);
assert(all(z_plane(2) == pos_next(:,3)));
assert(all(layer_next(ind_reflected_logical) == layer(ind_reflected_logical)));
assert(all(layer_next(~ind_reflected_logical) == layer(~ind_reflected_logical)+1));
assert(all(is_need_recalculation == 0));

sigma = sqrt(N*R*(1-R));
mean = N*R;
assert(abs(reflected_count - mean) <= 3*sigma);

