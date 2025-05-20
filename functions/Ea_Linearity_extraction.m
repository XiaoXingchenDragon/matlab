% Ea_linearity_extraction.m
% 输入：
%   sheet_groups: 1xN cell，每个元素是一个 sheet name cell 数组（每组）
%   anodei_groups: 1xN cell，每个元素是一个 anodei 列向量数组（对应每组）
%   temp_array: 1xN 数组，每组的温度值（单位 K）
% 输出：
%   sorted_sheet_names: 最终统一顺序后的 sheet name
%   Ea_array: 每个 sheet 的 Ea 值（单位 eV）
%   linearity_array: 每个 sheet 的线性度

function [sorted_sheet_names, Ea_array, linearity_array] = ...
    Ea_Linearity_extraction(sheet_groups, anodei_groups, temp_array)

    % 校验输入一致性
    num_groups = numel(sheet_groups);        % 温度数（如 4）
    assert(num_groups == length(anodei_groups));
    assert(num_groups == length(temp_array));

    reference_sheet_names = sheet_groups{1};     % 以第一组为顺序参考
    num_sheets = length(reference_sheet_names);  % 如 16
    num_points = size(anodei_groups{1}, 1);       % 如 117（电压点数量）

    % 初始化结果矩阵：每列是 sheet，每行为电压点
    Ea_array = zeros(num_points, num_sheets);
    linearity_array = zeros(num_points, num_sheets);

    % 为每个 sheet 构造一个 [温度 × 电压点] 的矩阵
    % 对每个电压点进行 log(current) vs 1/T 拟合
    for s = 1:num_sheets  % 遍历每个 sheet
        current_vs_temp = zeros(num_groups, num_points);  % 温度行，电压列

        for k = 1:num_groups
            [~, sorted_anodei] = anodei_sort(sheet_groups{k}, anodei_groups{k}, reference_sheet_names);
            current_vs_temp(k, :) = sorted_anodei(:, s)';  % 当前 sheet 的电流值随温度变化
        end

        % 针对每个电压点进行拟合
        for v = 1:num_points
            yData = log(current_vs_temp(:, v));         % ln(current)
            xData = 1 ./ temp_array(:);                 % 1/T

            if any(isnan(yData)) || any(isinf(yData))   % 防止出错
                Ea_array(v, s) = NaN;
                linearity_array(v, s) = NaN;
                continue;
            end

            [Ea_array(v, s), linearity_array(v, s)] = EA_linearity_calculation(xData, yData);
        end
    end

    sorted_sheet_names = reference_sheet_names;
end

%% 子函数：anodei_sort
function [sorted_idx, sorted_values] = anodei_sort(input_sheet_names, input_matrix, reference_names)
    % 返回按 reference_names 顺序排列后的列数据
    [~, sorted_idx] = ismember(reference_names, input_sheet_names);
    assert(all(sorted_idx > 0), '某些 sheet name 在输入中找不到匹配');
    sorted_values = input_matrix(:, sorted_idx);  % 正确返回列顺序
end


%% 子函数：EA_linearity_calculation
function [Ea, linearity] = EA_linearity_calculation(referenceValues, yData)
    p = polyfit(referenceValues, yData, 1);
    slope = abs(p(1));
    Ea = slope * (1.380649e-23 / 1.602176634e-19);  % eV

    yFit = polyval(p, referenceValues);
    ssResidual = sum((yData - yFit).^2);
    ssTotal = sum((yData - mean(yData)).^2);
    linearity = 1 - (ssResidual / ssTotal);
end

