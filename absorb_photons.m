function weight = absorb_photons(weight, ma, mt)
    weight = weight * (1 - ma/mt);
end
