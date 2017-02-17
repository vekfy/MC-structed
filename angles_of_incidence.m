function angles = angles_of_incidence(dir)
    angles = acos(abs(dir(:,3)));
end
