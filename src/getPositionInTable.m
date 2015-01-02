% Author: 7sDream
% FinishTime: 2015.1.1
% -----------------------
% 作用： 把鼠标点击的位置转换为在音符表里的对应下标
% x, y： 鼠标点击坐标

function [row, col] = getPositionInTable(x, y)
    col = floor((x - 1) ./ 17 + 1);
    row = 2;                                                % row = 2 为白键音符所在行。白键排布有规律， 17像素一个白键。
    if y < 67                                               % 67是白键和黑键的交界处，如果鼠标点击的范围可能是黑键
        for left = -5 : 17 : 352                            % 黑键的排布规律
            right = left + 10;
            if left > x                                     % 如果x在两个黑键之间，直接跳出。使用上面算好的白键位置即可。
                break
            end
            if left <= x && x <= right                      % 如果落在某个黑键范围内
                preAmount = floor((left + 5) ./ 17 + 1);    % 算出是第几个黑键
                r = mod(preAmount, 7);                      % 第1 5 8 12 15个黑键其实是不存在的
                if r ~= 1 && r ~= 5                         % 如果黑键位置除以7的余数不是1也不是5，表示确实在黑键上
                    row = 1;                                % raw = 1 为黑键所在行
                    col = preAmount;                        % 列为算出的黑键位置
                end
                break                                       % 如果确实是不存在的黑键，直接跳出，还是使用上面算好的白键位置。
            end
        end
    end
end