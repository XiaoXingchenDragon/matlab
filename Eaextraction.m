addpath('functions');
files = dir('raw_data/*.xls');


    exclude_list = {'A1', 'A9'};
    sort_prefix_length=6;
    sheet_groups = {};      % 所有文件的 sheet name 列表
    anodei_groups = {};     % 所有文件的 anodei 列表
    temp_array = [];    
% 遍历处理每个文件
for i = 1:length(files)
    input_file = fullfile(files(i).folder, files(i).name);
    [~, name, ~] = fileparts(files(i).name);

    % 提取数据
    %[anodev, anodei, sheet_names] = process_iv_raw(input_file,true);
    % 构造输出路径（写入 results 文件夹）
    

    %选择性的输出sheetname和anodei，屏蔽掉A测试并排序，有利于后续的Ea提取

    [anodev, anodei, sheet_names] = process_iv_raw(input_file, true, exclude_list,sort_prefix_length);
        % 存储当前文件的 sheet name 和 anodei
    sheet_groups{end+1} = sheet_names;           %#ok<SAGROW>
    anodei_groups{end+1} = anodei;      % 用 mean(anodei) 得到代表当前温度下每个 sheet 的电流值

    % 手动设定温度（或你可以根据文件名自动推断）
    % 例如 IV_300K.xls → 提取 300
    % 这里我们假设你有一个温度表：
    temp_array(end+1) = str2num(name)+273.15;  %#ok<SAGROW>
end
    [sorted_sheet_names, Ea_array, linearity_array] = ...
    Ea_Linearity_extraction(sheet_groups, anodei_groups, temp_array);
   
    %turnon voltage
%     I_turnon=1E-3;
%     [turnon_voltage] = process_tonV_i(anodev, anodei,I_turnon);
%     
%     output_file = fullfile('export_excel', [name '_turnon=(' num2str(I_turnon) ').xlsx']);
%     Write_excel(output_file, [], turnon_voltage, sheet_names);




    %输出整理后的raw data
    output_file = fullfile('export_excel/', 'Ea.xlsx');
    Write_excel(output_file, anodev, Ea_array, sorted_sheet_names);
    fprintf('✅ 已处理 %s → %s\n', files(i).name, output_file);
    
    output_file = fullfile('export_excel/', 'Linearity.xlsx');
    Write_excel(output_file, anodev, linearity_array, sorted_sheet_names);
    fprintf('✅ 已处理 %s → %s\n', files(i).name, output_file);
