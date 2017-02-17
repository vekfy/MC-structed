function params = set_parameters(varargin)
%% params = set_parameters(varargin)
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
    params.is_calculate_irradiance = true;     % ������������ �� irradiance
    params.is_show_irradiance = true;           % ���������� �� �� ������ ���� irradiance
    params.is_calculate_directed_escape = true; % ������� �� ������������ �����?
    params.is_calculate_histograms = true;       % ������� �� ����������� ������?   
    params.result_filename = 'MC.mat';
    
    params.total_photons = 1e7;                   
    params.x = 10; %mm
    params.y = 10; %mm
    params.z = [0 5];  %mm     % ������� �����: numel(z) = ���������� ����� + 1
    
    params.ma = [0.1];  %mm^-1   % ��� ������� ����
    params.ms = [2]; %mm^-1      % ��� ������� ����
    params.g = [0.7];            % ��� ������� ����
    params.n_in = 1.33;        % ������������ ����������� �� ���������� �����
    params.n_out = [1 1];        % ������������ ����������� �� �������
   
    
    params.dx = 0.1;           %��� �����
    params.dy = 0.1;           %��� �����
    params.dz = 0.1;           %��� �����
    params.d_hist = 0.1;

    params.directed_escape_radius = 0.1;       % ������ ������������� ������
    params.directed_escape_refracted_angle = pi/180;   % ���� ������������� ������
    
    params.adjacent_directed_count = 0;
    params.opposite_directed_count = 0;
    
    params.sourse_position = [5, 5, 0];
    params.sourse_direction = [0, 0, 1];
end

function check_parameters(params)
    assert(numel(params.ma) == numel(params.ms),'����� �������� ms, ma, g, n ������ ���� �����������');
    assert(numel(params.ma) == numel(params.g),'����� �������� ms, ma, g, n ������ ���� �����������');
    assert(numel(params.ma) == numel(params.n_in),'����� �������� ms, ma, g, n ������ ���� �����������');
    assert(numel(params.z) == numel(params.n_in) + 1, '����� ������� z ������ ���� ����� ���������� ����� + 1');
    assert(numel(params.sourse_position) == 3, '����� ������� sourse_position ������ ���� ����� 3');
    assert(numel(params.sourse_direction) == 3, '����� ������� sourse_direction ������ ���� ����� 3');
    assert(numel(params.n_out) == 2, '����� ������� n_out ������ ���� ����� 2');
end