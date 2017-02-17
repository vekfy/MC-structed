function res = discretize(values, grid)
    [~,res] = histc(values, grid);
    res(res == numel(grid)) = numel(grid) - 1;
    res(res == 0) = nan;
end

