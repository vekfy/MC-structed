%% reflaction_1
% lack of boundary
n_in = 1;
n_out = 1; 
N = 1e6;
use_gpu=false;
if use_gpu
    dir_0 = gpuArray.rand(N,3);
else
    dir_0 = rand(N,3);
end
dir_0 = normr(dir_0);
critical_angle_incidence = angles_of_incidence(dir_0);
ang_ref = angles_of_refraction(critical_angle_incidence, n_in, n_out);
dir_refract =  dir_of_refraction(dir_0, critical_angle_incidence, ang_ref, n_in, n_out);

assert(norm(dir_refract - dir_0)/norm(dir_0) < 1e-8); 
%% reflaction_2
% normal incidence
n_in = 1;
n_out = 1.33; 
N = 1e1;
dir_0 = cat(2, zeros(N,2),ones(N,1));
critical_angle_incidence = angles_of_incidence(dir_0);
ang_ref = angles_of_refraction(critical_angle_incidence, n_in, n_out);
dir_refract =  dir_of_refraction(dir_0, critical_angle_incidence, ang_ref, n_in, n_out);
assert(norm(dir_refract - dir_0)/norm(dir_0) < 1e-8); 

dir_refract_2 = dir_of_refraction_without_angles(dir_0, n_in, n_out);
assert(norm(dir_refract_2-dir_0)/norm(dir_0) < 0.001);


%% refration test
dir_0 = [sqrt(2)/2, 0, -sqrt(2)/2];
n_in = 0.9;
n_out = 1;
dir_refract_theor = [0.636396, 0, -0.771362]; 

ang_inc = angles_of_incidence(dir_0);
ang_ref = angles_of_refraction(ang_inc, n_in, n_out);
dir_refract =  dir_of_refraction(dir_0, ang_inc, ang_ref, n_in, n_out);

assert(norm(dir_refract-dir_refract_theor)/norm(dir_refract_theor) < 0.001);

dir_refract_2 = dir_of_refraction_without_angles(dir_0, n_in, n_out);
assert(norm(dir_refract_2-dir_refract_theor)/norm(dir_refract_theor) < 0.001);

%% reflaction_3
%condition of total reflection
n_in = 1.33;
n_out = 1; 
N = 1e6;
critical_angle_incidence = asin(n_out/n_in)*ones(N,1); 

dir_z = cos(critical_angle_incidence);
phi = 2 * pi * rand(N,1);
dir_x = sqrt(1 - dir_z.^2) .* cos(phi);
dir_y = sqrt(1 - dir_z.^2) .* sin(phi);
dir_0 = [dir_x dir_y dir_z];

angle_of_incidence = angles_of_incidence(dir_0);
assert(norm(critical_angle_incidence - angle_of_incidence)/norm(critical_angle_incidence) < 1e-8); 
ang_ref = angles_of_refraction(angle_of_incidence, n_in, n_out);
dir_refract = dir_of_refraction(dir_0, angle_of_incidence, ang_ref, n_in, n_out);
assert(all(abs(dir_refract(:,3)) < 1e-8)); 
dir_refract_2 = dir_of_refraction_without_angles(dir_0, n_in, n_out);
assert(all(abs(dir_refract_2(:,3)) < 1e-8)); 

%% reflaction_4
% угол больше критического
n_in = 2;
n_out = 1; 
N = 1e6;
max_critical_angle_incidence = asin(n_out/n_in); 

angle_of_incidence_of_total_reflectance = random('uniform', max_critical_angle_incidence, pi/2, N, 1);

dir_z = cos(angle_of_incidence_of_total_reflectance);
phi = 2 * pi * rand(N,1);
dir_x = sqrt(1 - dir_z.^2) .* cos(phi);
dir_y = sqrt(1 - dir_z.^2) .* sin(phi);
dir_0 = [dir_x dir_y dir_z];

angle_of_incidence = angles_of_incidence(dir_0);
assert(norm(angle_of_incidence_of_total_reflectance - angle_of_incidence)/norm(angle_of_incidence_of_total_reflectance) < 1e-8); 

ang_ref = angles_of_refraction(angle_of_incidence, n_in, n_out);
dir_refract = dir_of_refraction(dir_0, angle_of_incidence, ang_ref, n_in, n_out);

assert(all(abs(dir_refract(:,3)) < 1e-8));
dir_refract_2 = dir_of_refraction_without_angles(dir_0, n_in, n_out);
assert(isreal(dir_refract_2) == false);

