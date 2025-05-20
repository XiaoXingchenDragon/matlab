function Write_excel(result_filename, anodev, anodei_table, sheet_names)
% Write_excel - 将电压和多个 AnodeI 数据写入 Excel 文件
%
% 输入：
%   anodeV可以选择输入为空，输入为 ,[],
%   result_filename - 字符串，输出的 Excel 文件名
%   anodev          - 列向量，电压数据（可为空）
%   anodei_table    - 数值矩阵，每列为一个 AnodeI 数据列
%   sheet_names     - cell 数组，每列对应的 sheet 名，用作列标题
%
% 输出：
%   将数据写入 result_filename 文件的 'Anodei Data' sheet

    % 初始化结果表格
    if isempty(anodev)
        result_table = table();  % 空表格初始化
    else
        result_table = table(anodev);
        result_table.Properties.VariableNames{1} = 'AnodeV';
    end

    % 为每一列 AnodeI 命名
    for col = 1:size(anodei_table, 2)
        col_name = sheet_names{col};

        % 避免列名重复
        if ismember(col_name, result_table.Properties.VariableNames)
            col_name = [col_name '_' num2str(col)];
        end

        result_table.(col_name) = anodei_table(:, col);
    end

    % 写入 Excel
    writetable(result_table, result_filename, 'Sheet', 'Anodei Data');
end
