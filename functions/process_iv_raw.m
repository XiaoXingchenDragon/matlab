function [anodev, anodei_table, sheet_names] = ...
    process_iv_raw(original_file, sort_by_sheetname, exclude_keywords, sort_prefix_length)
% process_iv_raw - 提取 Excel 文件中所有有效 sheet 的 AnodeV 和 AnodeI 数据
%
% 输入：
%   original_file       - 字符串，Excel 文件路径
%   sort_by_sheetname   - 逻辑值，是否按 sheet name 中数字排序
%   exclude_keywords    - cell 数组，包含任意关键词的 sheet 将被跳过
%
% 输出：
%   anodev        - 列向量，对应电压（取自第一个有效 sheet 的 AnodeV）
%   anodei_table  - 数值矩阵，多个 AnodeI 列按列拼接后的结果
%   sheet_names   - cell 数组，每列 AnodeI 对应的 sheet 名称

    [~, sheets] = xlsfinfo(original_file);

    anodev = [];
    anodei_table = [];
    sheet_names = {};

    for i = 1:length(sheets)
        sheet_name = sheets{i};

        % 跳过无效 sheet
        if strcmpi(sheet_name, 'Calc') || strcmpi(sheet_name, 'Settings')
            continue;
        end

        % 跳过包含任意关键词的 sheet
        if any(cellfun(@(kw) contains(sheet_name, kw), exclude_keywords))
            continue;
        end

        data = readtable(original_file, 'Sheet', sheet_name);

        % 只记录一次 AnodeV
        if isempty(anodev)
            anodev = data.AnodeV;
        end

        % 提取 AnodeI 列
        for col_idx = 1:width(data)
            col_name = data.Properties.VariableNames{col_idx};

            if contains(col_name, 'AnodeI', 'IgnoreCase', true)
                processed_column = abs(data.(col_name));
                anodei_table = [anodei_table, processed_column]; %#ok<AGROW>
                sheet_names{end+1} = sheet_name; %#ok<SAGROW>
            end
        end
    end

    if sort_by_sheetname
        numeric_keys = cellfun(@(s) ...
            str2double(regexp(s(1:min(sort_prefix_length, length(s))), '\d+', 'match', 'once')), ...
            sheet_names);
    
        [~, sort_idx] = sort(numeric_keys);
        anodei_table = anodei_table(:, sort_idx);
        sheet_names = sheet_names(sort_idx);
    
        % 裁剪排序后的 sheet_names 为前 prefix_length 个字符
        sheet_names = cellfun(@(s) s(1:min(sort_prefix_length, length(s))), ...
            sheet_names, 'UniformOutput', false);
    end
end