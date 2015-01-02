% Author: 7sDream
% FinishTime: 2015.1.1

function music = noteText2Music(allNotes, noteTexts)
    % ���ڰ������ı�ת��Ϊ��Ƶ�źš�
    % -------------------------------
    % noteText������
    % { 'E41', 'C41', '01', 'AB41'}
    % -------------------------------
    
    scaleTable = {'B', 'AB', 'A', 'GA', 'G', 'FG', ...
        'F', 'E', 'DE', 'D', 'CD', 'C'};            % ���ױ�
    scaleNum = 0;
    music = [];
    [~, amount] = size(noteTexts);                  % ��ȡ��������
    for i = 1 : amount
        noteText = noteTexts{i};
        if strcmp(noteText(1),'0') == 1             % �����ı��ĵ�һ���ַ���0��ʾΪ��ֹ��
            noteLength = str2double(noteText(2)); 
            switch noteLength
                case 1
                    note = zeros(1, 22051);    % 01 = ��ֹ 1/2 ��
                case 2
                    note = zeros(1, 11026);    % 02 = ��ֹ 1/4 ��
                case 3
                    note = zeros(1, 5513);     % 03 = ��ֹ 1/4 ��
            end
        else
            scale = noteText(1:end-2);                  % ���������ֹ�����һ���ַ��������������ַ�Ϊ����
            degree = str2double(noteText(end-1:end-1));	% �����ڶ����ַ�Ϊ����
            noteLength = str2double(noteText(end:end)); % ���һ���ַ�Ϊ�������ȣ���������ֹ�����һ���ַ���ͬ
            equMartix = strcmpi(scaleTable, scale);     % ����һ��Forѭ�����ڲ������������ױ��е�λ��
            for scaleNum = 1 : 12
                if equMartix(scaleNum) == 1
                    break
                end
            end
            note = [];
            note(1,:) = allNotes{noteLength}(scaleNum, degree,:); % note Ϊ����õ���Ƶ�ź�
        end
        if isempty(music)       % �����е���Ƶ�ź�����������
            music = note;
        else
            music = [music(:,:) note];
        end
    end
    music = music/max(music);   % ��һ��
end