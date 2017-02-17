function params = set_parameters(varargin)
%% params = set_parameters(varargin)
%    'use_gpu': {false}/true - использовать GPU при рассчете
%    'is_calculate_irradiance': {true}/false - рассчитывать ли irradiance
%    'is_show_irradiance': {true}/false - показывать ли на каждом шаге irradiance
%    'is_calculate_directed_escape': {true}/false - считать ли направленный вылет?
%    'is_calculate_histograms': {true}/false - считать ли гистограммы глубин?   
%    'result_filename': {['MC.mat']} - имя файла результатов
%    'total_photons': {[1e7]} - общее количество фотонов                   
%    'x': {10} - размер по х в mm
%    'y': {10} - размер по y в mm
%    'z': {[0 5]}  - границы слоев в mm
%    'sourse_position': {[5, 5, 0]} -  позиция источника 
%    'sourse_direction': {[0, 0, 1]} - направление источника
%    'ma': {[0.1]} - mm^-1
%    'ms': {[2]} - mm^-1  
%    'g': {[0.7]}        
%    'n_in': {1.33} - коэффициенты преломления на внутренних слоях
%    'n_out': {[1 1]} - коэффициенты преломления на снаружи (2 числа)
%    'dx': {0.1}      - шаг сетки для irradiance и гистограмм
%    'dy': {0.1}      - шаг сетки для irradiance и гистограмм
%    'dz': {0.1}      - шаг сетки для irradiance и гистограмм
%    'd_hist': {0.1}  - шаг сетки для гистограмм
%    'directed_escape_radius': {0.1}    - радиус направленного вылета в mm
%    'directed_escape_refracted_angle': {pi/180} - угол направленного вылета в mm

    params = set_default_parameters();
    if mod(nargin, 2) == 1
        error('myApp:argChk', 'Wrong number of input arguments');
    end
    
    for i=1:2:nargin,
        params.(varargin{i}) = varargin{i+1};
    end
    
    params.pack_photons = min(1e6, params.total_photons);
    params.n = [params.n_out(1), params.n_in, params.n_out(2)];
    
    check_parameters(params);
end

function params = set_default_parameters()
    params.use_gpu = false;
    params.is_calculate_irradiance = true;     % рассчитывать ли irradiance
    params.is_show_irradiance = true;           % показывать ли на каждом шаге irradiance
    params.is_calculate_directed_escape = true; % считать ли направленный вылет?
    params.is_calculate_histograms = true;       % считать ли гистограммы глубин?   
    params.result_filename = 'MC.mat';
    
    params.total_photons = 1e7;                   
    params.x = 10; %mm
    params.y = 10; %mm
    params.z = [0 5];  %mm     % границы слоев: numel(z) = количество слоев + 1
    
    params.ma = [0.1];  %mm^-1   % для каждого слоя
    params.ms = [2]; %mm^-1      % для каждого слоя
    params.g = [0.7];            % для каждого слоя
    params.n_in = 1.33;        % коэффициенты преломления на внутренних слоях
    params.n_out = [1 1];        % коэффициенты преломления на снаружи
   
    
    params.dx = 0.1;           %шаг сетки
    params.dy = 0.1;           %шаг сетки
    params.dz = 0.1;           %шаг сетки
    params.d_hist = 0.1;

    params.directed_escape_radius = 0.1;       % радиус направленного вылета
    params.directed_escape_refracted_angle = pi/180;   % угол направленного вылета
    
    params.adjacent_directed_count = 0;
    params.opposite_directed_count = 0;
    
    params.sourse_position = [5, 5, 0];
    params.sourse_direction = [0, 0, 1];
end

function check_parameters(params)
    assert(numel(params.ma) == numel(params.ms),'Длины векторов ms, ma, g, n должны быть одинаковыми');
    assert(numel(params.ma) == numel(params.g),'Длины векторов ms, ma, g, n должны быть одинаковыми');
    assert(numel(params.ma) == numel(params.n_in),'Длины векторов ms, ma, g, n должны быть одинаковыми');
    assert(numel(params.z) == numel(params.n_in) + 1, 'Длина вектора z должна быть равна количеству слоев + 1');
    assert(numel(params.sourse_position) == 3, 'Длина вектора sourse_position должна быть равна 3');
    assert(numel(params.sourse_direction) == 3, 'Длина вектора sourse_direction должна быть равна 3');
    assert(numel(params.n_out) == 2, 'Длина вектора n_out должна быть равна 2');
end