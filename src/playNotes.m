% Author: 7sDream
% FinishTime: 2015.1.1
% -----------------------
% ���� ��������
% allNotes: ���������Ĳ��ξ���
% noteTexts: �����ı�����
% fs: ����������

function playNotes(allNotes, noteTexts, fs)
    music = noteText2Music(allNotes, noteTexts);
    sound(music, fs);
end