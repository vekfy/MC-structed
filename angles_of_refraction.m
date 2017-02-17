function angles = angles_of_refraction(angle_incidence, n_in, n_out)
    temp = n_in.*sin(angle_incidence)./n_out;
    temp(temp > 1) = 1; 
    temp(temp < -1) = -1;
    angles = asin(temp);
end
