% Author: 7sDream
% FinishTime: 2015.1.1
% -----------------------
% 作用 播放音符
% allNotes: 所有音符的波形矩阵
% noteTexts: 音符文本矩阵
% fs: 音符采样率

function playNotes(allNotes, noteTexts, fs)
    music = noteText2Music(allNotes, noteTexts);
    sound(music, fs);
end