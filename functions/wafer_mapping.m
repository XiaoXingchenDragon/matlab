function [Ron_map, Von_map] = wafer_mapping(sheetnames, anodev, anodei_table, wafersize, failed_die, num_overlap, num_null)
% wafer_mapping_debug - 含调试信息的 Ron/Von 映射提取函数

    m = wafersize(1);
    n = wafersize(2);

    Ron_map = zeros(m, n);
    Von_map = zeros(m, n);
    count_map = zeros(m, n);

    fprintf('\n=== 开始处理 %d 个器件 ===\n\n', length(sheetnames));

    for i = 1:length(sheetnames)
        name_str = sheetnames{i};  % ✅ 保持为 char 类型，适配 regexp
        fprintf('>> 第 %d 个器件: %s\n', i, name_str);

        % 正则表达式匹配坐标 (X,Y)
        expr = '\((\d+),(\d+)\)';
        tokens = regexp(name_str, expr, 'tokens');
        if isempty(tokens) || length(tokens{1}) < 2
            fprintf('   ❌ 坐标提取失败: %s\n\n', name_str);
            continue;
        end
        X = str2double(tokens{1}{1});
        Y = str2double(tokens{1}{2});

        if isnan(X) || isnan(Y) || X < 1 || X > n || Y < 1 || Y > m
            fprintf('   ⚠️ 坐标非法或超出范围: X=%d, Y=%d\n\n', X, Y);
            continue;
        end

        current = anodei_table(:, i);

        % 检查电流是否为空或全为0
        if all(isnan(current))
            fprintf('   ❌ 电流全为 NaN\n\n');
            Ron_map(Y, X) = num_null;
            Von_map(Y, X) = num_null;
            continue;
        elseif all(current == 0)
            fprintf('   ⚠️ 电流全为 0\n\n');
            Ron_map(Y, X) = num_null;
            Von_map(Y, X) = num_null;
            continue;
        end

        % 拟合区间设置
        fit_range = 118:122;
        if max(fit_range) > length(current) || max(fit_range) > length(anodev)
            fprintf('   ❌ 拟合区间越界: 数据长度 %d, 区间最大值 %d\n\n', length(current), max(fit_range));
            Ron_map(Y, X) = num_null;
            Von_map(Y, X) = num_null;
            continue;
        end

        % 打印电流值用于调试
        fprintf('   ✅ 拟合电流值（%d:%d）: ', fit_range(1), fit_range(end));
        disp(current(fit_range)');

        % 拟合
        try
            [Ron, Von] = fit_Ron_Von(current, anodev, fit_range(1), fit_range(end));
        catch ME
            fprintf('   ❌ 拟合失败: %s\n\n', ME.message);
            Ron_map(Y, X) = num_null;
            Von_map(Y, X) = num_null;
            continue;
        end

        % 写入 map
        if count_map(Y, X) == 0
            Ron_map(Y, X) = Ron;
            Von_map(Y, X) = Von;
            count_map(Y, X) = 1;
            fprintf('   ✅ 成功写入: Ron = %.4f, Von = %.4f\n\n', Ron, Von);
        else
            Ron_map(Y, X) = num_overlap;
            Von_map(Y, X) = num_overlap;
            fprintf('   ⚠️ 重复坐标，标记为 %d\n\n', num_overlap);
        end
    end

    % 设置失效 die 区域
    failed_fields = fieldnames(failed_die);
    for f = 1:length(failed_fields)
        ftype = failed_fields{f};
        col_list = failed_die.(ftype).cols;
        row_lists = failed_die.(ftype).rows_list;

        for j = 1:length(col_list)
            col = col_list(j);
            rows = row_lists{j};
            Ron_map(rows, col) = 100;
            Von_map(rows, col) = 100;
        end
    end

    fprintf('=== 处理完成！Ron_map 非零点数: %d ===\n\n', nnz(Ron_map ~= 0 & Ron_map ~= num_overlap & Ron_map ~= 100));
end

function [Ron, Von] = fit_Ron_Von(current, voltage, m, n)
% 线性拟合：y = Ron * x + Von，仅在 m 到 n 行拟合
    fit_current = current(m:n);
    fit_voltage = voltage(m:n);
    p = polyfit(fit_current, fit_voltage, 1);
    Ron = p(1);
    Von = p(2);
end


