function [filtered_names, filtered_anodei] = column_extract(sheetnames, anodei_table, keyword)
% column_extract - 按关键词筛选 sheetname 和对应的 anodei 列
%
% 输入：
%   sheetnames     - 1×N cell 数组，列标签
%   anodei_table   - M×N 数组，电流数据矩阵
%   keyword        - 字符串，筛选关键词（区分大小写）
%
% 输出：
%   filtered_names     - 1×K cell 数组，包含关键词的列名
%   filtered_anodei    - M×K 数组，对应的电流列子集

    mask = contains(sheetnames, keyword);  % 找出包含 keyword 的列索引
    filtered_names = sheetnames(mask);     % 提取子集列名
    filtered_anodei = anodei_table(:, mask);  % 提取子集数据列
end

