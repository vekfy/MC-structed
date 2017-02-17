function photons_deep_hist = photons_histograms(photons_deep_hist, x_grid, y_grid, hist_grid, pos, max_deep)
    ix = discretize(pos(:,1), x_grid);
    iy = discretize(pos(:,2), y_grid);
    ind_max_deep = discretize(max_deep, hist_grid);
    
    out = isnan(ix) | isnan(iy);
    ix(out) = [];
    iy(out) = [];
    ind_max_deep(out) = [];
    
    ind_deep = sub2ind(size(photons_deep_hist), ix, iy, ind_max_deep);
    accum_deep = accumarray(ind_deep, 1);
    ind_deep = [1:max(ind_deep)]';
    photons_deep_hist(ind_deep) = photons_deep_hist(ind_deep) + accum_deep;
end
