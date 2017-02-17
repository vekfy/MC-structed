function res = normr(data)
%% function res = normr(data)
% Функция для нормализации матрицы data по строкам
    norm = sqrt(sum(data.^2, 2));
    res = bsxfun(@rdivide, data, norm); 
    