function dir_refract = dir_of_refraction(dir, angle_incidence, angle_refraction, n_in, n_out)
    % https://en.wikipedia.org/wiki/Snell's_law#Vector_form
    r = n_in./n_out;
    n_dir_z = -sign(dir(:,3));
    dir_refract = bsxfun(@times, dir, r);
    dir_refract(:,3) = dir_refract(:,3) + (r.*cos(angle_incidence) - cos(angle_refraction)) .* n_dir_z;
    dir_refract = normr(dir_refract);
end
