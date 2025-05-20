function [turnon_voltage] = process_tonV_i(anodev, anodei_table,  I_turnon)
% extract_turnon_voltage - 提取每列电流首次超过阈值时的电压（Turn-On Voltage）
%
% 输入：
%   anodev        - 电压列向量 (n×1)
%   anodei_table  - 电流数据表 (n×m)，每列对应一个测量
%   sheet_names   - 1×m cell，每列对应的 sheet 名称
%   I_turnon      - 电流阈值（标量）
%
% 输出：
%   turnon_voltage - 1×m 向量，每列对应的 turn-on 电压
%   sheet_names    - 同输入，保持对应关系

    m = size(anodei_table, 2);
    turnon_voltage = NaN(1, m);  % 初始化为 NaN，防止没有超过阈值时报错

    for col = 1:m
        current_column = anodei_table(:, col);

        % 找到第一个超过阈值的索引
        idx = find(current_column >= I_turnon, 1, 'first');

        if ~isempty(idx)
            turnon_voltage(col) = anodev(idx);
        end
    end
end
