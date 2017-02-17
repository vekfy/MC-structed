function MonteCarlo_Rect(varargin)
%% MonteCarlo_RectGPU ������� ��� ������������� ��
%    'use_gpu': {false}/true - ������������ GPU ��� ��������
%    'is_calculate_irradiance': {true}/false - ������������ �� irradiance
%    'is_show_irradiance': {true}/false - ���������� �� �� ������ ���� irradiance
%    'is_calculate_directed_escape': {true}/false - ������� �� ������������ �����?
%    'is_calculate_histograms': {true}/false - ������� �� ����������� ������?   
%    'result_filename': {['MC.mat']} - ��� ����� �����������
%    'total_photons': {[1e7]} - ����� ���������� �������                   
%    'x': {10} - ������ �� � � mm
%    'y': {10} - ������ �� y � mm
%    'z': {[0 5]}  - ������� ����� � mm
%    'sourse_position': {[5, 5, 0]} -  ������� ��������� 
%    'sourse_direction': {[0, 0, 1]} - ����������� ���������
%    'ma': {[0.1]} - mm^-1
%    'ms': {[2]} - mm^-1  
%    'g': {[0.7]}        
%    'n_in': {1.33} - ������������ ����������� �� ���������� �����
%    'n_out': {[1 1]} - ������������ ����������� �� ������� (2 �����)
%    'dx': {0.1}      - ��� ����� ��� irradiance � ����������
%    'dy': {0.1}      - ��� ����� ��� irradiance � ����������
%    'dz': {0.1}      - ��� ����� ��� irradiance � ����������
%    'd_hist': {0.1}  - ��� ����� ��� ����������
%    'directed_escape_radius': {0.1}    - ������ ������������� ������ � mm
%    'directed_escape_refracted_angle': {pi/180} - ���� ������������� ������ � mm    
    
    params = set_parameters(varargin{:});
    use_gpu = params.use_gpu;
    is_calculate_irradiance = params.is_calculate_irradiance;     % ������������ �� irradiance
    is_show_irradiance = params.is_show_irradiance;           % ���������� �� �� ������ ���� irradiance
    is_calculate_directed_escape = params.is_calculate_directed_escape; % ������� �� ������������ �����?
    is_calculate_histograms = params.is_calculate_histograms;       % ������� �� ����������� ������?   
    result_filename = params.result_filename;
    
    total_photons = params.total_photons;                   
    x = params.x; %mm
    y = params.y; %mm
    z = params.z;  %mm     % ������� �����: numel(z) = ���������� ����� + 1
    min_z = min(z);
    max_z = max(z);
    
    ma = params.ma;    %mm^-1       % ��� ������� ����
    ms = params.ms;    %mm^-1        % ��� ������� ����
    g = params.g;      % ��� ������� ����
    n = params.n;            % numel(n) = ���������� ����� + 2  
   
    dx = params.dx;           %��� �����
    dy = params.dy;           %��� �����
    dz = params.dz;           %��� �����
    d_hist = params.d_hist;

    directed_escape_radius = params.directed_escape_radius;       % ������ ������������� ������
    directed_escape_refracted_angle = params.directed_escape_refracted_angle;   % ���� ������������� ������

    sourse_position = params.sourse_position;
    sourse_direction = params.sourse_direction;

    pack_photons = 1e6;
    
    if use_gpu
        reset(gpuDevice);
        n = gpuArray(n);
    end

    if is_calculate_irradiance
        x_grid = linspace(0, x, x/dx + 1);
        y_grid = linspace(0, y, y/dy + 1);
        z_grid = linspace(0, max_z, max_z/dz + 1);
        irradiance = zeros(numel(x_grid)-1, numel(y_grid)-1, numel(z_grid)-1);
        if use_gpu
            irradiance = gpuArray(irradiance);
            x_grid = gpuArray(x_grid);
            y_grid = gpuArray(y_grid);
            z_grid = gpuArray(z_grid);
        end
    end
       
    if is_calculate_histograms
        x_grid = linspace(0, x, x/dx);
        y_grid = linspace(0, y, y/dy);
        hist_grid = [0:d_hist:max_z];
        photons_deep_hist = zeros(numel(x_grid) - 1, numel(y_grid) - 1, numel(hist_grid) - 1);
        if use_gpu
            x_grid = gpuArray(x_grid);
            y_grid = gpuArray(y_grid);
            hist_grid = gpuArray(hist_grid);
            photons_deep_hist = gpuArray(photons_deep_hist);
        end
    end

    %% Monte-Carlo
    adjacent_directed_count = 0;
    opposite_directed_count = 0;
    mt = ms + ma;
    wb=waitbar(0,'Time');

    [pos, dir, weight, max_deep, layer] = launch_photons(sourse_position, sourse_direction, pack_photons, use_gpu);

    calculated_photons = 0;

    tic;
    while (calculated_photons < total_photons)
        pos_previous = pos;
        pos = move_photons(pos, dir, layer, mt, use_gpu);
        
        [pos, dir, layer, is_need_recalculation] = reflect_photons(pos, pos_previous, dir, layer, z, n, use_gpu);

        if is_calculate_irradiance
            in = pos(:,1) >= 0 & pos(:,2) >= 0 & pos(:,3) >=0 & pos(:,1) <= x & pos(:,2) <= y & pos(:,3) <= max_z;
            if use_gpu
                irradiance = calculate_irradiance_simple_gpu(pos_previous(in,:), pos(in,:), weight(in), x_grid, y_grid, z_grid, irradiance);
            else
                irradiance = calculate_irradiance_simple(pos_previous(in,:), pos(in,:), weight(in), x_grid, y_grid, z_grid, irradiance);
            end
            if is_show_irradiance 
                figure(1)
                imagesc(z_grid, x_grid, squeeze(log(sum(irradiance,2))));
                axis equal;
                xlabel('Z, mm');
                ylabel('X, mm');
            end
        end
       
        weight = absorb_photons(weight, ma, mt);
        max_deep = max(max_deep, pos(:,3));
        
        dir = photon_scattering(dir, g, layer, is_need_recalculation, use_gpu);
                
        out = pos(:,1) < 0 | pos(:,2) < 0 | pos(:,1) > x | pos(:,2) > y | layer <=0 | layer >= numel(z); 
        new_photons = out;
        calculated_photons = calculated_photons + sum(new_photons);    

        if is_calculate_histograms
            detected_photons = find(layer <=0);
            if numel(detected_photons) > 0 
                photons_deep_hist = photons_histograms(photons_deep_hist, x_grid, y_grid, hist_grid, pos(detected_photons,:), max_deep(detected_photons,:));
            end
        end
        
        if is_calculate_directed_escape
            opposite_escaped = layer == numel(z);
            opposite_directed_count = opposite_directed_count + get_directed_count(pos(opposite_escaped,:), dir(opposite_escaped,:), weight(opposite_escaped), n(end-1), n(end), sourse_position, directed_escape_radius, directed_escape_refracted_angle);
            
            adjacent_escaped = layer == 0;
            adjacent_directed_count = adjacent_directed_count + get_directed_count(pos(adjacent_escaped,:), dir(adjacent_escaped,:), weight(adjacent_escaped), n(end-1), n(end), sourse_position, directed_escape_radius, directed_escape_refracted_angle);
        end

        [pos(new_photons,:), dir(new_photons,:), weight(new_photons,:), max_deep(new_photons,:), layer(new_photons,:)] = launch_photons(sourse_position, sourse_direction, sum(new_photons), use_gpu);
        if ~all(pos(:,3) <= max_z)
            disp('ERROR')
        end
       
        if use_gpu
            perc = gather(calculated_photons / total_photons);
        else
            perc = calculated_photons / total_photons;
        end

        if use_gpu == false
            assert(isreal(dir), '���-�� ��������� � ������� �����������');
            assert(all(~isnan(dir(:))), '���-�� ��������� � ������� �����������');
        end
        
        elapsed_time = toc;
        waitbar(perc,wb,sprintf('Time Remain %g s', elapsed_time/perc - elapsed_time));
        pause(0.0001);
    end
    close(wb);
    toc
    save(result_filename);
end

function directed_count = get_directed_count(pos, dir, weight, n_in, n_out, center, max_radius, max_refracted_angle)
    dist_from_center = sqrt(sum(bsxfun(@minus, pos, center).^2,2));

    suspect = find(dist_from_center < max_radius);
    dir_suspect = dir(suspect, :);
    angle_incidence = angles_of_incidence(dir_suspect);
    angle_refraction = angles_of_refraction(angle_incidence, n_in, n_out);
    
    suspect = suspect(abs(angle_refraction) <= max_refracted_angle);
    
    directed_count = sum(weight(suspect));
end









