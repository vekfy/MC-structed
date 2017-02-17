function dir_refract = dir_of_refraction_without_angles(dir, n_in, n_out)
    % https://en.wikipedia.org/wiki/Snell's_law#Vector_form
    r = n_in./n_out;
    n_dir_z = -sign(dir(:,3));
    dir_refract = bsxfun(@times, dir, r);
    dir_refract(:,3) = dir_refract(:,3) + (-r.*dir(:,3).*n_dir_z - sqrt(1 - r.^2*(1 - dir(:,3).^2))).*n_dir_z;
    dir_refract = normr(dir_refract);
end
