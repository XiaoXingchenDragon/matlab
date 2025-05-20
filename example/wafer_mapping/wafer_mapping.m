addpath('functions');
files = dir('raw_data/*.xls');


    sort_prefix_length=15;
    sheetname_all = {};
    anodei_all = [];
% 遍历处理每个文件
for i = 1:length(files)
    input_file = fullfile(files(i).folder, files(i).name);
    [~, name, ~] = fileparts(files(i).name);

    % 提取数据
    %[anodev, anodei, sheet_names] = process_iv_raw(input_file,true);
    % 构造输出路径（写入 results 文件夹）
    

    %选择性的输出sheetname和anodei，屏蔽掉A测试并排序，有利于后续的Ea提取

    [anodev, anodei, sheet_names] = process_iv_raw(input_file, false, exclude_list,sort_prefix_length);
    sheetname_all = [sheetname_all, sheet_names];     % 横向拼接 1×N cell
    anodei_all = [anodei_all, anodei];
end 
    
    failed_die.FER1.cols = [6, 5];
    failed_die.FER1.rows_list = {[5:9], [9, 10]};
    wafersize=[13,13];
    num_overlap=666;
    num_null=0;

    keywords = {'FER1', 'FER3'};
    for i=1:length(keywords)
    [filtered_names, filtered_anodei] = column_extract(sheetname_all, anodei_all, keywords{i});
    [Ron_map, Von_map] = wafer_mapping(filtered_names, anodev, filtered_anodei, wafersize, failed_die, num_overlap, num_null);
    filenameRon= ['Ron_' keywords{i} '.xlsx'];
    writematrix(Ron_map, filenameRon);
    filenameVon= ['Von_' keywords{i} '.xlsx'];
    writematrix(Ron_map, filenameVon);
    end



%     输出整理后的raw data
%     output_file = fullfile('export_excel/', 'Ea.xlsx');
%     Write_excel(output_file, anodev, Ea_array, sorted_sheet_names);
%     fprintf('✅ 已处理 %s → %s\n', files(i).name, output_file);
%     
%     output_file = fullfile('export_excel/', 'Linearity.xlsx');
%     Write_excel(output_file, anodev, linearity_array, sorted_sheet_names);
%     fprintf('✅ 已处理 %s → %s\n', files(i).name, output_file);
