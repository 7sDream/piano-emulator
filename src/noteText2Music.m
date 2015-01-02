% Author: 7sDream
% FinishTime: 2015.1.1

function music = noteText2Music(allNotes, noteTexts)
    % 用于把音符文本转换为音频信号。
    % -------------------------------
    % noteText样例：
    % { 'E41', 'C41', '01', 'AB41'}
    % -------------------------------
    
    scaleTable = {'B', 'AB', 'A', 'GA', 'G', 'FG', ...
        'F', 'E', 'DE', 'D', 'CD', 'C'};            % 音阶表
    scaleNum = 0;
    music = [];
    [~, amount] = size(noteTexts);                  % 获取音符数量
    for i = 1 : amount
        noteText = noteTexts{i};
        if strcmp(noteText(1),'0') == 1             % 音符文本的第一个字符是0表示为休止符
            noteLength = str2double(noteText(2)); 
            switch noteLength
                case 1
                    note = zeros(1, 22051);    % 01 = 休止 1/2 秒
                case 2
                    note = zeros(1, 11026);    % 02 = 休止 1/4 秒
                case 3
                    note = zeros(1, 5513);     % 03 = 休止 1/4 秒
            end
        else
            scale = noteText(1:end-2);                  % 如果不是休止符则第一个字符到倒数第三个字符为音阶
            degree = str2double(noteText(end-1:end-1));	% 倒数第二个字符为音度
            noteLength = str2double(noteText(end:end)); % 最后一个字符为音符长度，含义与休止符最后一个字符相同
            equMartix = strcmpi(scaleTable, scale);     % 下面一个For循环用于查找音阶在音阶表中的位置
            for scaleNum = 1 : 12
                if equMartix(scaleNum) == 1
                    break
                end
            end
            note = [];
            note(1,:) = allNotes{noteLength}(scaleNum, degree,:); % note 为查表获得的音频信号
        end
        if isempty(music)       % 将所有的音频信号连接起来。
            music = note;
        else
            music = [music(:,:) note];
        end
    end
    music = music/max(music);   % 归一化
end